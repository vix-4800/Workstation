// gtklock-media-background-module
// Copyright (c) 2026

// Module that sets media album art as window background via CSS

#include <playerctl.h>
#include <libsoup/soup.h>
#include <string.h>

#include "gtklock-module.h"

#define MODULE_DATA(x) (x->module_data[self_id])
#define MEDIA_BG(x) ((struct media_background *)MODULE_DATA(x))

struct media_background {
    GtkCssProvider *css_provider;
    gchar *current_art_path;
    GCancellable *cancellable;
    gboolean is_valid;
};

const gchar module_name[] = "media-background";
const guint module_major_version = 4;
const guint module_minor_version = 0;

static int self_id;
static struct GtkLock *global_gtklock = NULL;

PlayerctlPlayerManager *player_manager = NULL;
PlayerctlPlayer *current_player = NULL;
SoupSession *soup_session = NULL;

// Configuration options with defaults
static gchar *opacity_str = NULL;
static gboolean darken = FALSE;
static gchar *darken_amount_str = NULL;
static gboolean hide_playerctl_art = TRUE;
static gchar *background_size = NULL;
static gchar *background_position = NULL;
static gchar *player_filter_str = NULL;

// Parsed values
static gdouble opacity = 1.0;
static gdouble darken_amount = 0.5;
static gchar **allowed_players = NULL;

// Signal handler IDs for safe disconnection during teardown
static gulong metadata_handler_id = 0;
static gulong playback_handler_id = 0;
static gulong player_appeared_handler_id = 0;
static gulong player_vanished_handler_id = 0;
static gulong name_appeared_handler_id = 0;
static gboolean is_active = FALSE;

GOptionEntry module_entries[] = {
    { "opacity", 0, 0, G_OPTION_ARG_STRING, &opacity_str,
      "Album art opacity (0.0-1.0, default: 1.0)", NULL },
    { "darken", 0, 0, G_OPTION_ARG_NONE, &darken,
      "Apply dark overlay on album art for better readability", NULL },
    { "darken-amount", 0, 0, G_OPTION_ARG_STRING, &darken_amount_str,
      "Darkness level of overlay (0.0-1.0, default: 0.5)", NULL },
    { "hide-playerctl-art", 0, 0, G_OPTION_ARG_NONE, &hide_playerctl_art,
      "Hide album art in playerctl module (default: true)", NULL },
    { "show-playerctl-art", 0, G_OPTION_FLAG_REVERSE, G_OPTION_ARG_NONE, &hide_playerctl_art,
      "Show album art in playerctl module alongside background", NULL },
    { "background-size", 0, 0, G_OPTION_ARG_STRING, &background_size,
      "CSS background-size ('cover', 'contain', 'auto', default: 'cover')", NULL },
    { "background-position", 0, 0, G_OPTION_ARG_STRING, &background_position,
      "CSS background-position (default: 'center')", NULL },
    { "player-filter", 0, 0, G_OPTION_ARG_STRING, &player_filter_str,
      "Comma-separated list of allowed player names (e.g. 'spotify,mpv')", NULL },
    { NULL },
};

static void disconnect_player_signals(void) {
    if (current_player) {
        if (metadata_handler_id > 0) {
            g_signal_handler_disconnect(current_player, metadata_handler_id);
            metadata_handler_id = 0;
        }
        if (playback_handler_id > 0) {
            g_signal_handler_disconnect(current_player, playback_handler_id);
            playback_handler_id = 0;
        }
    }
}

static void disconnect_all_signals(void) {
    disconnect_player_signals();
    if (player_manager) {
        if (player_appeared_handler_id > 0) {
            g_signal_handler_disconnect(player_manager, player_appeared_handler_id);
            player_appeared_handler_id = 0;
        }
        if (player_vanished_handler_id > 0) {
            g_signal_handler_disconnect(player_manager, player_vanished_handler_id);
            player_vanished_handler_id = 0;
        }
        if (name_appeared_handler_id > 0) {
            g_signal_handler_disconnect(player_manager, name_appeared_handler_id);
            name_appeared_handler_id = 0;
        }
    }
}

static gboolean is_player_allowed(const gchar *player_name) {
    if (!allowed_players) return TRUE;

    gchar *name_lower = g_ascii_strdown(player_name, -1);
    for (gint i = 0; allowed_players[i] != NULL; i++) {
        if (g_strcmp0(name_lower, allowed_players[i]) == 0) {
            g_free(name_lower);
            return TRUE;
        }
    }
    g_free(name_lower);
    return FALSE;
}

static gdouble parse_double(const gchar *str, gdouble default_val, gdouble min, gdouble max) {
    if (!str || str[0] == '\0') return default_val;

    gchar *endptr = NULL;
    gdouble val = g_ascii_strtod(str, &endptr);

    if (endptr == str) return default_val;
    if (val < min) return min;
    if (val > max) return max;

    return val;
}

static void validate_config(void) {
    opacity = parse_double(opacity_str, 1.0, 0.0, 1.0);
    darken_amount = parse_double(darken_amount_str, 0.5, 0.0, 1.0);

    if (!background_size) background_size = g_strdup("cover");
    if (!background_position) background_position = g_strdup("center");

    if (player_filter_str && player_filter_str[0] != '\0') {
        allowed_players = g_strsplit(player_filter_str, ",", -1);
        for (gint i = 0; allowed_players[i] != NULL; i++) {
            gchar *stripped = g_strstrip(allowed_players[i]);
            gchar *lower = g_ascii_strdown(stripped, -1);
            g_free(allowed_players[i]);
            allowed_players[i] = lower;
        }
    }
}

static gchar *get_cache_path(void) {
    const gchar *cache_dir = g_get_user_cache_dir();
    gchar *module_cache = g_build_filename(cache_dir, "gtklock", NULL);
    g_mkdir_with_parents(module_cache, 0755);
    gchar *path = g_build_filename(module_cache, "media-bg.jpg", NULL);
    g_free(module_cache);
    return path;
}

static gchar *build_background_css(const gchar *image_path) {
    GString *css = g_string_new("");

    // Only set window background when we have album art
    // Otherwise let style.css handle the default background
    if (image_path && g_file_test(image_path, G_FILE_TEST_EXISTS)) {
        g_string_append(css, "window { background-image: ");

        // Calculate overlay for darken effect
        gdouble overlay_alpha = 0.0;

        if (darken) {
            overlay_alpha = darken_amount;
        }

        // If opacity < 1.0, increase overlay to simulate transparency
        if (opacity < 1.0) {
            gdouble fade = 1.0 - opacity;
            overlay_alpha = overlay_alpha + fade * (1.0 - overlay_alpha);
        }

        if (overlay_alpha > 0.0) {
            g_string_append_printf(css,
                "linear-gradient(rgba(0, 0, 0, %.2f), rgba(0, 0, 0, %.2f)), ",
                overlay_alpha, overlay_alpha);
        }

        g_string_append_printf(css, "url('file://%s'); ", image_path);
        g_string_append_printf(css, "background-size: %s; ", background_size);
        g_string_append_printf(css, "background-position: %s; ", background_position);
        g_string_append(css, "background-repeat: no-repeat; } ");
    }

    // Hide playerctl album art if configured
    if (hide_playerctl_art) {
        g_string_append(css,
            "#playerctl-album-art { opacity: 0; min-width: 0; min-height: 0; } ");
    }

    gchar *result = g_string_free(css, FALSE);
    return result;
}

static void update_background_css(struct Window *ctx, const gchar *image_path) {
    if (!ctx || !MEDIA_BG(ctx) || !MEDIA_BG(ctx)->is_valid) return;

    GtkCssProvider *provider = MEDIA_BG(ctx)->css_provider;
    if (!provider) return;

    gchar *css_data = build_background_css(image_path);

    GError *error = NULL;
    gtk_css_provider_load_from_data(provider, css_data, -1, &error);

    if (error != NULL) {
        g_warning("media-background: Failed to load CSS: %s", error->message);
        g_error_free(error);
    }

    g_free(css_data);
}

static void on_image_saved(const gchar *path, struct Window *ctx) {
    if (!ctx || !MEDIA_BG(ctx) || !MEDIA_BG(ctx)->is_valid) return;

    g_free(MEDIA_BG(ctx)->current_art_path);
    MEDIA_BG(ctx)->current_art_path = g_strdup(path);

    update_background_css(ctx, path);
}

static void file_read_callback(GObject *source_object, GAsyncResult *res, gpointer user_data) {
    struct Window *ctx = user_data;
    GError *error = NULL;
    GFileInputStream *input_stream = g_file_read_finish(G_FILE(source_object), res, &error);

    if (error != NULL) {
        if (!g_error_matches(error, G_IO_ERROR, G_IO_ERROR_CANCELLED)) {
            g_warning("media-background: Failed to read file: %s", error->message);
        }
        g_error_free(error);
        return;
    }

    if (!is_active || !ctx || !MEDIA_BG(ctx) || !MEDIA_BG(ctx)->is_valid) {
        g_object_unref(input_stream);
        return;
    }

    gchar *cache_path = get_cache_path();

    GFile *cache_file = g_file_new_for_path(cache_path);
    GFileOutputStream *output_stream = g_file_replace(
        cache_file, NULL, FALSE, G_FILE_CREATE_REPLACE_DESTINATION, NULL, &error);

    if (error != NULL) {
        g_warning("media-background: Failed to create cache: %s", error->message);
        g_error_free(error);
        g_object_unref(input_stream);
        g_object_unref(cache_file);
        g_free(cache_path);
        return;
    }

    g_output_stream_splice(
        G_OUTPUT_STREAM(output_stream),
        G_INPUT_STREAM(input_stream),
        G_OUTPUT_STREAM_SPLICE_CLOSE_SOURCE | G_OUTPUT_STREAM_SPLICE_CLOSE_TARGET,
        NULL, &error);

    g_object_unref(input_stream);
    g_object_unref(output_stream);
    g_object_unref(cache_file);

    if (error != NULL) {
        g_warning("media-background: Failed to save: %s", error->message);
        g_error_free(error);
        g_free(cache_path);
        return;
    }

    on_image_saved(cache_path, ctx);
    g_free(cache_path);
}

static void http_callback(GObject *source_object, GAsyncResult *res, gpointer user_data) {
    struct Window *ctx = user_data;
    GError *error = NULL;
    GInputStream *stream = soup_session_send_finish(SOUP_SESSION(source_object), res, &error);

    if (error != NULL) {
        if (!g_error_matches(error, G_IO_ERROR, G_IO_ERROR_CANCELLED)) {
            g_warning("media-background: HTTP request failed: %s", error->message);
        }
        g_error_free(error);
        return;
    }

    if (!is_active || !ctx || !MEDIA_BG(ctx) || !MEDIA_BG(ctx)->is_valid) {
        g_object_unref(stream);
        return;
    }

    gchar *cache_path = get_cache_path();

    GFile *cache_file = g_file_new_for_path(cache_path);
    GFileOutputStream *output_stream = g_file_replace(
        cache_file, NULL, FALSE, G_FILE_CREATE_REPLACE_DESTINATION, NULL, &error);

    if (error != NULL) {
        g_warning("media-background: Failed to create cache: %s", error->message);
        g_error_free(error);
        g_object_unref(stream);
        g_object_unref(cache_file);
        g_free(cache_path);
        return;
    }

    g_output_stream_splice(
        G_OUTPUT_STREAM(output_stream),
        stream,
        G_OUTPUT_STREAM_SPLICE_CLOSE_SOURCE | G_OUTPUT_STREAM_SPLICE_CLOSE_TARGET,
        NULL, &error);

    g_object_unref(output_stream);
    g_object_unref(cache_file);

    if (error != NULL) {
        g_warning("media-background: Failed to save: %s", error->message);
        g_error_free(error);
        g_free(cache_path);
        return;
    }

    on_image_saved(cache_path, ctx);
    g_free(cache_path);
}

static void load_fallback(struct Window *ctx) {
    // Clear album art, let style.css show default background
    update_background_css(ctx, NULL);
}

static void load_album_art(struct Window *ctx) {
    if (!ctx || !MEDIA_BG(ctx) || !MEDIA_BG(ctx)->is_valid) return;

    if (!current_player) {
        load_fallback(ctx);
        return;
    }

    // Cancel any pending async operations
    if (MEDIA_BG(ctx)->cancellable) {
        g_cancellable_cancel(MEDIA_BG(ctx)->cancellable);
        g_object_unref(MEDIA_BG(ctx)->cancellable);
    }
    MEDIA_BG(ctx)->cancellable = g_cancellable_new();

    GError *error = NULL;
    gchar *uri = playerctl_player_print_metadata_prop(current_player, "mpris:artUrl", &error);

    if (error != NULL) {
        g_warning("media-background: Failed to get art URL: %s", error->message);
        g_error_free(error);
        load_fallback(ctx);
        return;
    }

    if (!uri || uri[0] == '\0') {
        g_free(uri);
        load_fallback(ctx);
        return;
    }

    const char *scheme = g_uri_peek_scheme(uri);

    if (g_strcmp0("file", scheme) == 0) {
        GFile *file = g_file_new_for_uri(uri);
        g_file_read_async(file, G_PRIORITY_DEFAULT, MEDIA_BG(ctx)->cancellable, file_read_callback, ctx);
        g_object_unref(file);
    } else if (g_strcmp0("http", scheme) == 0 || g_strcmp0("https", scheme) == 0) {
        SoupMessage *msg = soup_message_new(SOUP_METHOD_GET, uri);
        if (msg) {
            soup_session_send_async(soup_session, msg, G_PRIORITY_DEFAULT, MEDIA_BG(ctx)->cancellable, http_callback, ctx);
            g_object_unref(msg);
        } else {
            load_fallback(ctx);
        }
    } else {
        load_fallback(ctx);
    }

    g_free(uri);
}

static void load_album_art_from_metadata(struct Window *ctx, GVariant *metadata) {
    if (!ctx || !MEDIA_BG(ctx) || !MEDIA_BG(ctx)->is_valid) return;

    if (!metadata) {
        load_album_art(ctx);
        return;
    }

    // Cancel any pending async operations
    if (MEDIA_BG(ctx)->cancellable) {
        g_cancellable_cancel(MEDIA_BG(ctx)->cancellable);
        g_object_unref(MEDIA_BG(ctx)->cancellable);
    }
    MEDIA_BG(ctx)->cancellable = g_cancellable_new();

    GVariant *art_url_variant = g_variant_lookup_value(metadata, "mpris:artUrl", G_VARIANT_TYPE_STRING);
    if (!art_url_variant) {
        load_fallback(ctx);
        return;
    }

    const gchar *uri = g_variant_get_string(art_url_variant, NULL);
    if (!uri || uri[0] == '\0') {
        g_variant_unref(art_url_variant);
        load_fallback(ctx);
        return;
    }

    const char *scheme = g_uri_peek_scheme(uri);

    if (g_strcmp0("file", scheme) == 0) {
        GFile *file = g_file_new_for_uri(uri);
        g_file_read_async(file, G_PRIORITY_DEFAULT, MEDIA_BG(ctx)->cancellable, file_read_callback, ctx);
        g_object_unref(file);
    } else if (g_strcmp0("http", scheme) == 0 || g_strcmp0("https", scheme) == 0) {
        SoupMessage *msg = soup_message_new(SOUP_METHOD_GET, uri);
        if (msg) {
            soup_session_send_async(soup_session, msg, G_PRIORITY_DEFAULT, MEDIA_BG(ctx)->cancellable, http_callback, ctx);
            g_object_unref(msg);
        } else {
            load_fallback(ctx);
        }
    } else {
        load_fallback(ctx);
    }

    g_variant_unref(art_url_variant);
}

static void on_metadata_changed(PlayerctlPlayer *player, GVariant *metadata, gpointer user_data) {
    if (!is_active) return;
    struct GtkLock *gtklock = user_data;
    if (gtklock->focused_window) {
        load_album_art_from_metadata(gtklock->focused_window, metadata);
    }
}

static void on_playback_status(PlayerctlPlayer *player, PlayerctlPlaybackStatus status, gpointer user_data) {
    if (!is_active) return;
    struct GtkLock *gtklock = user_data;
    if (gtklock->focused_window) {
        // When stopped, clear album art; otherwise try to load it
        if (status == PLAYERCTL_PLAYBACK_STATUS_STOPPED) {
            load_fallback(gtklock->focused_window);
        } else {
            load_album_art(gtklock->focused_window);
        }
    }
}

static void on_player_appeared(PlayerctlPlayerManager *manager, PlayerctlPlayer *player, gpointer user_data) {
    if (!is_active) return;
    struct GtkLock *gtklock = user_data;

    if (current_player) return;

    gchar *name = NULL;
    g_object_get(player, "player-name", &name, NULL);
    if (name && !is_player_allowed(name)) {
        g_free(name);
        return;
    }
    g_free(name);

    current_player = g_object_ref(player);

    metadata_handler_id = g_signal_connect(player, "metadata",
        G_CALLBACK(on_metadata_changed), gtklock);
    playback_handler_id = g_signal_connect(player, "playback-status",
        G_CALLBACK(on_playback_status), gtklock);

    if (gtklock->focused_window) {
        load_album_art(gtklock->focused_window);
    }
}

static void on_player_vanished(PlayerctlPlayerManager *manager, PlayerctlPlayer *player, gpointer user_data) {
    if (!is_active) return;
    struct GtkLock *gtklock = user_data;

    if (current_player == player) {
        disconnect_player_signals();
        g_object_unref(current_player);
        current_player = NULL;
    }

    if (gtklock->focused_window) {
        load_fallback(gtklock->focused_window);
    }
}

static void on_name_appeared(PlayerctlPlayerManager *manager, PlayerctlPlayerName *name, gpointer user_data) {
    (void)user_data;

    if (!is_active || current_player) return;

    if (name->name && !is_player_allowed(name->name)) return;

    GError *error = NULL;
    PlayerctlPlayer *player = playerctl_player_new_from_name(name, &error);

    if (error != NULL) {
        g_warning("media-background: Failed to create player: %s", error->message);
        g_error_free(error);
        return;
    }

    if (player) {
        playerctl_player_manager_manage_player(player_manager, player);
        g_object_unref(player);
    }
}

void g_module_unload(GModule *m) {
    is_active = FALSE;
    disconnect_all_signals();

    if (current_player) {
        g_object_unref(current_player);
        current_player = NULL;
    }
    if (player_manager) {
        g_object_unref(player_manager);
        player_manager = NULL;
    }
    if (soup_session) {
        g_object_unref(soup_session);
        soup_session = NULL;
    }

    g_free(background_size);
    g_free(background_position);
    g_free(opacity_str);
    g_free(darken_amount_str);
    g_free(player_filter_str);
    g_strfreev(allowed_players);
    background_size = NULL;
    background_position = NULL;
    opacity_str = NULL;
    darken_amount_str = NULL;
    player_filter_str = NULL;
    allowed_players = NULL;
}

void on_activation(struct GtkLock *gtklock, int id) {
    self_id = id;
    global_gtklock = gtklock;

    validate_config();

    is_active = TRUE;

    soup_session = soup_session_new();

    GError *error = NULL;
    player_manager = playerctl_player_manager_new(&error);

    if (error != NULL) {
        g_warning("media-background: Failed to create player manager: %s", error->message);
        g_error_free(error);
        return;
    }

    player_appeared_handler_id = g_signal_connect(player_manager, "player-appeared",
        G_CALLBACK(on_player_appeared), gtklock);
    player_vanished_handler_id = g_signal_connect(player_manager, "player-vanished",
        G_CALLBACK(on_player_vanished), gtklock);
    name_appeared_handler_id = g_signal_connect(player_manager, "name-appeared",
        G_CALLBACK(on_name_appeared), gtklock);

    GList *available_players = NULL;
    g_object_get(player_manager, "player-names", &available_players, NULL);
    if (available_players) {
        PlayerctlPlayerName *name = available_players->data;
        PlayerctlPlayer *player = playerctl_player_new_from_name(name, NULL);
        if (player) {
            playerctl_player_manager_manage_player(player_manager, player);
            g_object_unref(player);
        }
    }
}

void on_window_create(struct GtkLock *gtklock, struct Window *ctx) {
    MODULE_DATA(ctx) = g_malloc0(sizeof(struct media_background));

    MEDIA_BG(ctx)->css_provider = gtk_css_provider_new();
    MEDIA_BG(ctx)->current_art_path = NULL;
    MEDIA_BG(ctx)->cancellable = NULL;
    MEDIA_BG(ctx)->is_valid = TRUE;

    // Use USER priority (800) to override style.css (APPLICATION = 600)
    gtk_style_context_add_provider_for_screen(
        gdk_screen_get_default(),
        GTK_STYLE_PROVIDER(MEDIA_BG(ctx)->css_provider),
        GTK_STYLE_PROVIDER_PRIORITY_USER);

    load_album_art(ctx);
}

void on_focus_change(struct GtkLock *gtklock, struct Window *win, struct Window *old) {
    if (is_active && win && MODULE_DATA(win)) {
        load_album_art(win);
    }
}

void on_window_destroy(struct GtkLock *gtklock, struct Window *ctx) {
    // Disconnect all signal handlers to prevent callbacks accessing freed window data
    is_active = FALSE;
    disconnect_all_signals();

    if (MEDIA_BG(ctx)) {
        // Mark as invalid first to prevent callbacks from using this context
        MEDIA_BG(ctx)->is_valid = FALSE;

        // Cancel any pending async operations
        if (MEDIA_BG(ctx)->cancellable) {
            g_cancellable_cancel(MEDIA_BG(ctx)->cancellable);
            g_object_unref(MEDIA_BG(ctx)->cancellable);
            MEDIA_BG(ctx)->cancellable = NULL;
        }

        if (MEDIA_BG(ctx)->css_provider) {
            gtk_style_context_remove_provider_for_screen(
                gdk_screen_get_default(),
                GTK_STYLE_PROVIDER(MEDIA_BG(ctx)->css_provider));
            g_object_unref(MEDIA_BG(ctx)->css_provider);
        }
        g_free(MEDIA_BG(ctx)->current_art_path);
        g_free(MODULE_DATA(ctx));
        MODULE_DATA(ctx) = NULL;
    }
}
