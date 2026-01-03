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
};

const gchar module_name[] = "media-background";
const guint module_major_version = 4;
const guint module_minor_version = 0;

static int self_id;
static struct GtkLock *global_gtklock = NULL;

PlayerctlPlayerManager *player_manager = NULL;
PlayerctlPlayer *current_player = NULL;
SoupSession *soup_session = NULL;

static gchar *fallback_image = NULL;

GOptionEntry module_entries[] = {
    { "fallback-image", 0, 0, G_OPTION_ARG_STRING, &fallback_image, "Path to fallback image when no media playing", NULL },
    { NULL },
};

static gchar *get_cache_path(void) {
    const gchar *cache_dir = g_get_user_cache_dir();
    gchar *module_cache = g_build_filename(cache_dir, "gtklock", NULL);
    g_mkdir_with_parents(module_cache, 0755);
    gchar *path = g_build_filename(module_cache, "media-bg.jpg", NULL);
    g_free(module_cache);
    return path;
}

static void update_background_css(struct Window *ctx, const gchar *image_path) {
    if (!ctx || !MEDIA_BG(ctx)) return;

    GtkCssProvider *provider = MEDIA_BG(ctx)->css_provider;
    if (!provider) return;

    gchar *css_data;
    if (image_path && g_file_test(image_path, G_FILE_TEST_EXISTS)) {
        css_data = g_strdup_printf(
            "window { "
            "  background-image: url('file://%s'); "
            "  background-size: cover; "
            "  background-position: center; "
            "  background-repeat: no-repeat; "
            "}"
            "#playerctl-album-art { opacity: 0; min-width: 0; min-height: 0; }",
            image_path);
    } else {
        css_data = g_strdup(
            "window { background-color: @base; }"
            "#playerctl-album-art { opacity: 0; min-width: 0; min-height: 0; }");
    }

    gtk_css_provider_load_from_data(provider, css_data, -1, NULL);
    g_free(css_data);
}

static void on_image_saved(const gchar *path, struct Window *ctx) {
    if (!ctx || !MEDIA_BG(ctx)) return;

    g_free(MEDIA_BG(ctx)->current_art_path);
    MEDIA_BG(ctx)->current_art_path = g_strdup(path);

    update_background_css(ctx, path);
}

static void file_read_callback(GObject *source_object, GAsyncResult *res, gpointer user_data) {
    GError *error = NULL;
    GFileInputStream *input_stream = g_file_read_finish(G_FILE(source_object), res, &error);

    if (error != NULL) {
        g_warning("media-background: Failed to read file: %s", error->message);
        g_error_free(error);
        return;
    }

    struct Window *ctx = user_data;
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
    GError *error = NULL;
    GInputStream *stream = soup_session_send_finish(SOUP_SESSION(source_object), res, &error);

    if (error != NULL) {
        g_warning("media-background: HTTP request failed: %s", error->message);
        g_error_free(error);
        return;
    }

    struct Window *ctx = user_data;
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
    if (fallback_image && g_file_test(fallback_image, G_FILE_TEST_EXISTS)) {
        on_image_saved(fallback_image, ctx);
    } else {
        update_background_css(ctx, NULL);
    }
}

static void load_album_art(struct Window *ctx) {
    if (!current_player) {
        load_fallback(ctx);
        return;
    }

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
        g_file_read_async(file, G_PRIORITY_DEFAULT, NULL, file_read_callback, ctx);
        g_object_unref(file);
    } else if (g_strcmp0("http", scheme) == 0 || g_strcmp0("https", scheme) == 0) {
        SoupMessage *msg = soup_message_new(SOUP_METHOD_GET, uri);
        soup_session_send_async(soup_session, msg, G_PRIORITY_DEFAULT, NULL, http_callback, ctx);
        g_object_unref(msg);
    } else {
        load_fallback(ctx);
    }

    g_free(uri);
}

static void load_album_art_from_metadata(struct Window *ctx, GVariant *metadata) {
    if (!metadata) {
        load_album_art(ctx);
        return;
    }

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
        g_file_read_async(file, G_PRIORITY_DEFAULT, NULL, file_read_callback, ctx);
        g_object_unref(file);
    } else if (g_strcmp0("http", scheme) == 0 || g_strcmp0("https", scheme) == 0) {
        SoupMessage *msg = soup_message_new(SOUP_METHOD_GET, uri);
        soup_session_send_async(soup_session, msg, G_PRIORITY_DEFAULT, NULL, http_callback, ctx);
        g_object_unref(msg);
    } else {
        load_fallback(ctx);
    }

    g_variant_unref(art_url_variant);
}

static void on_metadata_changed(PlayerctlPlayer *player, GVariant *metadata, gpointer user_data) {
    struct GtkLock *gtklock = user_data;
    if (gtklock->focused_window) {
        load_album_art_from_metadata(gtklock->focused_window, metadata);
    }
}

static void on_playback_status(PlayerctlPlayer *player, PlayerctlPlaybackStatus status, gpointer user_data) {
    struct GtkLock *gtklock = user_data;
    if (gtklock->focused_window) {
        load_album_art(gtklock->focused_window);
    }
}

static void on_player_appeared(PlayerctlPlayerManager *manager, PlayerctlPlayer *player, gpointer user_data) {
    struct GtkLock *gtklock = user_data;
    current_player = player;

    g_signal_connect(player, "metadata", G_CALLBACK(on_metadata_changed), gtklock);
    g_signal_connect(player, "playback-status", G_CALLBACK(on_playback_status), gtklock);

    if (gtklock->focused_window) {
        load_album_art(gtklock->focused_window);
    }
}

static void on_player_vanished(PlayerctlPlayerManager *manager, PlayerctlPlayer *player, gpointer user_data) {
    struct GtkLock *gtklock = user_data;
    current_player = NULL;

    if (gtklock->focused_window) {
        load_fallback(gtklock->focused_window);
    }
}

static void on_name_appeared(PlayerctlPlayerManager *manager, PlayerctlPlayerName *name, gpointer user_data) {
    if (current_player) return;

    current_player = playerctl_player_new_from_name(name, NULL);
    if (current_player) {
        playerctl_player_manager_manage_player(player_manager, current_player);
        g_object_unref(current_player);
    }
}

void g_module_unload(GModule *m) {
    if (player_manager) {
        g_object_unref(player_manager);
        player_manager = NULL;
    }
    if (soup_session) {
        g_object_unref(soup_session);
        soup_session = NULL;
    }
    current_player = NULL;
}

void on_activation(struct GtkLock *gtklock, int id) {
    self_id = id;
    global_gtklock = gtklock;

    soup_session = soup_session_new();

    GError *error = NULL;
    player_manager = playerctl_player_manager_new(&error);

    if (error != NULL) {
        g_warning("media-background: Failed to create player manager: %s", error->message);
        g_error_free(error);
        return;
    }

    g_signal_connect(player_manager, "player-appeared", G_CALLBACK(on_player_appeared), gtklock);
    g_signal_connect(player_manager, "player-vanished", G_CALLBACK(on_player_vanished), gtklock);
    g_signal_connect(player_manager, "name-appeared", G_CALLBACK(on_name_appeared), NULL);

    GList *available_players = NULL;
    g_object_get(player_manager, "player-names", &available_players, NULL);
    if (available_players) {
        PlayerctlPlayerName *name = available_players->data;
        current_player = playerctl_player_new_from_name(name, NULL);
        if (current_player) {
            playerctl_player_manager_manage_player(player_manager, current_player);
            g_object_unref(current_player);
        }
    }
}

void on_window_create(struct GtkLock *gtklock, struct Window *ctx) {
    MODULE_DATA(ctx) = g_malloc0(sizeof(struct media_background));

    MEDIA_BG(ctx)->css_provider = gtk_css_provider_new();
    MEDIA_BG(ctx)->current_art_path = NULL;

    gtk_style_context_add_provider_for_screen(
        gdk_screen_get_default(),
        GTK_STYLE_PROVIDER(MEDIA_BG(ctx)->css_provider),
        GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);

    load_album_art(ctx);
}

void on_focus_change(struct GtkLock *gtklock, struct Window *win, struct Window *old) {
    if (win && MODULE_DATA(win)) {
        load_album_art(win);
    }
}

void on_window_destroy(struct GtkLock *gtklock, struct Window *ctx) {
    if (MEDIA_BG(ctx)) {
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
