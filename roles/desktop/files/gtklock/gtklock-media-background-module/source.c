// gtklock-media-background-module
// Copyright (c) 2026

// Module that sets media album art as window background via CSS

#include <playerctl.h>
#include <libsoup/soup.h>
#include <glib/gstdio.h>
#include <string.h>

#include "gtklock-module.h"

#define MODULE_DATA(x) (x->module_data[self_id])
#define MEDIA_BG(x) ((struct media_background *)MODULE_DATA(x))
#define ART_MAX_BYTES (8 * 1024 * 1024)
#define ART_CHUNK_BYTES (64 * 1024)
#define ART_TIMEOUT_MS 10000

struct media_background {
    GtkCssProvider *css_provider;
    GCancellable *cancellable;
    gboolean is_valid;
};

struct art_request {
    GtkCssProvider *provider;
    GCancellable *cancellable;
    GInputStream *stream;
    GByteArray *bytes;
    GFile *cache_file;
    SoupMessage *message;
    GSource *timeout;
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

static void safe_disconnect(gpointer instance, gulong *handler_id) {
    if (*handler_id > 0 && instance && G_IS_OBJECT(instance) &&
        g_signal_handler_is_connected(instance, *handler_id)) {
        g_signal_handler_disconnect(instance, *handler_id);
    }
    *handler_id = 0;
}

static void disconnect_player_signals(void) {
    safe_disconnect(current_player, &metadata_handler_id);
    safe_disconnect(current_player, &playback_handler_id);
}

static void disconnect_all_signals(void) {
    disconnect_player_signals();
    safe_disconnect(player_manager, &player_appeared_handler_id);
    safe_disconnect(player_manager, &player_vanished_handler_id);
    safe_disconnect(player_manager, &name_appeared_handler_id);
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
    gchar *id = g_uuid_string_random();
    gchar *filename = g_strdup_printf("media-bg-%s", id);
    gchar *path = g_build_filename(module_cache, filename, NULL);
    g_free(filename);
    g_free(id);
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

static void remove_cached_art(gpointer data) {
    gchar *path = data;
    g_unlink(path);
    g_free(path);
}

static void art_request_free(struct art_request *request) {
    g_source_destroy(request->timeout);
    g_source_unref(request->timeout);
    if (request->stream) {
        g_input_stream_close_async(request->stream, G_PRIORITY_DEFAULT, NULL, NULL, NULL);
    }
    if (request->cache_file) {
        remove_cached_art(g_file_get_path(request->cache_file));
    }
    g_clear_object(&request->provider);
    g_clear_object(&request->cancellable);
    g_clear_object(&request->stream);
    g_clear_object(&request->cache_file);
    g_clear_object(&request->message);
    g_byte_array_unref(request->bytes);
    g_free(request);
}

static void art_request_error(struct art_request *request, GError *error) {
    if (!g_error_matches(error, G_IO_ERROR, G_IO_ERROR_CANCELLED)) {
        g_warning("media-background: Failed to load album art: %s", error->message);
    }
    g_error_free(error);
    art_request_free(request);
}

static gboolean art_request_timeout(gpointer data) {
    g_cancellable_cancel(G_CANCELLABLE(data));
    return G_SOURCE_REMOVE;
}

static void art_saved_callback(GObject *source_object, GAsyncResult *res, gpointer user_data) {
    struct art_request *request = user_data;
    GError *error = NULL;
    if (!g_file_replace_contents_finish(G_FILE(source_object), res, NULL, &error)) {
        art_request_error(request, error);
        return;
    }
    if (is_active && !g_cancellable_is_cancelled(request->cancellable)) {
        gchar *path = g_file_get_path(request->cache_file);
        gchar *css = build_background_css(path);
        if (gtk_css_provider_load_from_data(request->provider, css, -1, &error)) {
            g_object_set_data_full(G_OBJECT(request->provider), "media-bg-cache", path, remove_cached_art);
            g_clear_object(&request->cache_file);
        } else {
            g_warning("media-background: Failed to load CSS: %s", error->message);
            g_error_free(error);
            g_free(path);
        }
        g_free(css);
    }
    art_request_free(request);
}

static void read_art_chunk(struct art_request *request);

static void art_read_callback(GObject *source_object, GAsyncResult *res, gpointer user_data) {
    struct art_request *request = user_data;
    GError *error = NULL;
    GBytes *chunk = g_input_stream_read_bytes_finish(G_INPUT_STREAM(source_object), res, &error);
    if (!chunk) {
        art_request_error(request, error);
        return;
    }
    if (!is_active || g_cancellable_is_cancelled(request->cancellable)) {
        g_bytes_unref(chunk);
        art_request_free(request);
        return;
    }
    gsize size = 0;
    gconstpointer data = g_bytes_get_data(chunk, &size);
    if (size > ART_MAX_BYTES - request->bytes->len) {
        g_bytes_unref(chunk);
        art_request_error(request, g_error_new_literal(G_IO_ERROR, G_IO_ERROR_NO_SPACE, "Album art exceeds 8 MiB"));
        return;
    }
    if (size) g_byte_array_append(request->bytes, data, size);
    g_bytes_unref(chunk);
    if (size) {
        read_art_chunk(request);
    } else if (request->bytes->len) {
        g_file_replace_contents_async(
            request->cache_file, (const gchar *)request->bytes->data, request->bytes->len,
            NULL, FALSE, G_FILE_CREATE_PRIVATE | G_FILE_CREATE_REPLACE_DESTINATION,
            request->cancellable, art_saved_callback, request);
    } else {
        art_request_error(request, g_error_new_literal(G_IO_ERROR, G_IO_ERROR_INVALID_DATA, "Empty album art"));
    }
}

static void read_art_chunk(struct art_request *request) {
    g_input_stream_read_bytes_async(request->stream, ART_CHUNK_BYTES, G_PRIORITY_DEFAULT,
                                   request->cancellable, art_read_callback, request);
}

static void file_read_callback(GObject *source_object, GAsyncResult *res, gpointer user_data) {
    struct art_request *request = user_data;
    GError *error = NULL;
    request->stream = G_INPUT_STREAM(g_file_read_finish(G_FILE(source_object), res, &error));
    if (!request->stream) {
        art_request_error(request, error);
        return;
    }
    read_art_chunk(request);
}

static void http_callback(GObject *source_object, GAsyncResult *res, gpointer user_data) {
    struct art_request *request = user_data;
    GError *error = NULL;
    request->stream = soup_session_send_finish(SOUP_SESSION(source_object), res, &error);
    if (!request->stream) {
        art_request_error(request, error);
        return;
    }
    if (!SOUP_STATUS_IS_SUCCESSFUL(soup_message_get_status(request->message))) {
        art_request_error(request, g_error_new(G_IO_ERROR, G_IO_ERROR_FAILED,
                          "Album art HTTP status: %u", soup_message_get_status(request->message)));
        return;
    }
    read_art_chunk(request);
}

static gboolean start_art_request(struct Window *ctx, const gchar *uri) {
    const gchar *scheme = g_uri_peek_scheme(uri);
    gboolean local = g_strcmp0(scheme, "file") == 0;
    if (!local && g_strcmp0(scheme, "http") != 0 && g_strcmp0(scheme, "https") != 0) return FALSE;

    struct art_request *request = g_new0(struct art_request, 1);
    request->provider = g_object_ref(MEDIA_BG(ctx)->css_provider);
    request->cancellable = g_object_ref(MEDIA_BG(ctx)->cancellable);
    request->bytes = g_byte_array_new();
    gchar *path = get_cache_path();
    request->cache_file = g_file_new_for_path(path);
    g_free(path);
    request->timeout = g_timeout_source_new(ART_TIMEOUT_MS);
    g_source_set_callback(request->timeout, art_request_timeout,
                          g_object_ref(request->cancellable), g_object_unref);
    g_source_attach(request->timeout, NULL);

    if (local) {
        GFile *file = g_file_new_for_uri(uri);
        g_file_read_async(file, G_PRIORITY_DEFAULT, request->cancellable, file_read_callback, request);
        g_object_unref(file);
    } else {
        request->message = soup_message_new(SOUP_METHOD_GET, uri);
        if (!request->message) {
            art_request_free(request);
            return FALSE;
        }
        soup_session_send_async(soup_session, request->message, G_PRIORITY_DEFAULT,
                                request->cancellable, http_callback, request);
    }
    return TRUE;
}

static void load_fallback(struct Window *ctx) {
    if (MEDIA_BG(ctx)->cancellable) g_cancellable_cancel(MEDIA_BG(ctx)->cancellable);
    // Clear album art, let style.css show default background
    update_background_css(ctx, NULL);
    g_object_set_data(G_OBJECT(MEDIA_BG(ctx)->css_provider), "media-bg-cache", NULL);
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

    if (!start_art_request(ctx, uri)) load_fallback(ctx);

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

    if (!start_art_request(ctx, uri)) load_fallback(ctx);

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

    if (current_player && G_IS_OBJECT(current_player)) {
        g_object_unref(current_player);
    }
    current_player = NULL;

    if (player_manager && G_IS_OBJECT(player_manager)) {
        g_object_unref(player_manager);
    }
    player_manager = NULL;

    if (soup_session && G_IS_OBJECT(soup_session)) {
        g_object_unref(soup_session);
    }
    soup_session = NULL;

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
    if (old && old != win && MODULE_DATA(old) && MEDIA_BG(old)->cancellable) {
        g_cancellable_cancel(MEDIA_BG(old)->cancellable);
    }
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
        g_free(MODULE_DATA(ctx));
        MODULE_DATA(ctx) = NULL;
    }
}
