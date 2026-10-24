#include "../roles/desktop/files/gtklock/gtklock-media-background-module/source.c"

static GMainLoop *loop;
static gint64 started;
static gint64 first_pulse;
static GCancellable *request_cancellable;
static struct Window *test_window;

static gboolean pulse(gpointer data) {
    (void)data;
    if (!first_pulse) first_pulse = g_get_monotonic_time();
    return G_SOURCE_CONTINUE;
}

static gboolean stop_loop(gpointer data) {
    (void)data;
    g_main_loop_quit(loop);
    return G_SOURCE_REMOVE;
}

static gboolean cancel_request(gpointer data) {
    (void)data;
    g_cancellable_cancel(request_cancellable);
    return G_SOURCE_REMOVE;
}

static gboolean destroy_window(gpointer data) {
    (void)data;
    struct media_background *background = MEDIA_BG(test_window);
    g_cancellable_cancel(background->cancellable);
    g_clear_object(&background->cancellable);
    g_clear_object(&background->css_provider);
    g_free(background);
    g_free(test_window);
    test_window = NULL;
    return G_SOURCE_REMOVE;
}

int main(int argc, char **argv) {
    if (argc != 4) return 1;
    struct Window *window = g_malloc0(sizeof(struct Window) + sizeof(void *));
    test_window = window;
    struct media_background *background = g_new0(struct media_background, 1);
    window->module_data[0] = background;
    background->css_provider = gtk_css_provider_new();
    background->is_valid = TRUE;
    self_id = 0;
    is_active = TRUE;
    validate_config();
    soup_session = soup_session_new();

    GVariantBuilder metadata;
    g_variant_builder_init(&metadata, G_VARIANT_TYPE_VARDICT);
    g_variant_builder_add(&metadata, "{sv}", "mpris:artUrl", g_variant_new_string(argv[1]));
    GVariant *value = g_variant_ref_sink(g_variant_builder_end(&metadata));

    loop = g_main_loop_new(NULL, FALSE);
    started = g_get_monotonic_time();
    guint pulse_id = g_timeout_add(20, pulse, NULL);
    g_timeout_add((guint)g_ascii_strtoull(argv[2], NULL, 10), stop_loop, NULL);
    load_album_art_from_metadata(window, value);
    request_cancellable = g_object_ref(background->cancellable);
    if (g_strcmp0(argv[3], "cancel") == 0) g_timeout_add(100, cancel_request, NULL);
    if (g_strcmp0(argv[3], "destroy") == 0) g_timeout_add(100, destroy_window, NULL);
    g_main_loop_run(loop);

    guint files = 0;
    gchar *cache = g_build_filename(g_get_user_cache_dir(), "gtklock", NULL);
    GDir *directory = g_dir_open(cache, 0, NULL);
    if (directory) {
        while (g_dir_read_name(directory)) files++;
        g_dir_close(directory);
    }
    gint64 pulse_ms = first_pulse ? (first_pulse - started) / 1000 : -1;
    g_print("pulse_ms=%" G_GINT64_FORMAT " cache_files=%u\n", pulse_ms, files);

    g_source_remove(pulse_id);
    g_clear_object(&request_cancellable);
    if (test_window) destroy_window(NULL);
    g_free(cache);
    g_variant_unref(value);
    g_main_loop_unref(loop);
    g_module_unload(NULL);
    return pulse_ms >= 0 && pulse_ms < 250 ? 0 : 2;
}
