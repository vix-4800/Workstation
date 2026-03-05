// gtklock-network-module
// Copyright (c) 2026
//
// Module showing current network connection status in the top-right corner.
// Reads state via nmcli and updates every 5 seconds.

#include <gtk/gtk.h>
#include <glib.h>
#include <stdio.h>
#include <string.h>

#include "gtklock-module.h"

#define MODULE_DATA(x) (x->module_data[self_id])
#define NET_WIN(x)     ((struct network_win *)MODULE_DATA(x))

const gchar module_name[]    = "network";
const guint module_major_version = 4;
const guint module_minor_version = 0;

static int            self_id        = 0;
static guint          update_timer   = 0;
static struct GtkLock *global_gtklock = NULL;

struct network_win {
    GtkWidget *box;
    GtkWidget *icon_label;
    GtkWidget *text_label;
};

// Module has no configurable options
GOptionEntry module_entries[] = {
    { NULL },
};

// ── Helpers ────────────────────────────────────────────────────────────────

typedef struct {
    gchar *icon;
    gchar *text;
    gchar *css_class;
} NetStatus;

static void net_status_free(NetStatus *s) {
    g_free(s->icon);
    g_free(s->text);
    g_free(s->css_class);
}

// Select the Nerd Font WiFi icon based on signal strength icon tier
// (nmcli doesn't expose dBm easily here, so we use a single connected icon)
static NetStatus query_network(void) {
    NetStatus s = {
        .icon      = g_strdup("󰤭"),
        .text      = g_strdup("Нет сети"),
        .css_class = g_strdup("network-none"),
    };

    gchar *out = NULL;
    gint   rc  = 0;
    GError *err = NULL;

    gboolean ok = g_spawn_command_line_sync(
        "nmcli -t -f DEVICE,TYPE,STATE,CONNECTION dev",
        &out, NULL, &rc, &err);

    if (!ok || err || rc != 0) {
        if (err) g_error_free(err);
        g_free(out);
        return s;
    }

    gchar **lines = g_strsplit(out, "\n", -1);
    g_free(out);

    for (gint i = 0; lines[i] != NULL; i++) {
        if (lines[i][0] == '\0') continue;

        gchar **cols = g_strsplit(lines[i], ":", 4);
        guint   ncols = g_strv_length(cols);

        if (ncols < 3) { g_strfreev(cols); continue; }

        const gchar *type  = cols[1];
        const gchar *state = cols[2];
        const gchar *conn  = (ncols >= 4) ? cols[3] : "";

        if (g_strcmp0(state, "connected") == 0) {
            g_free(s.icon);
            g_free(s.text);
            g_free(s.css_class);

            if (g_strcmp0(type, "wifi") == 0) {
                s.icon      = g_strdup("󰤨");
                s.text      = g_strdup((conn && conn[0]) ? conn : "WiFi");
                s.css_class = g_strdup("network-wifi");
            } else if (g_strcmp0(type, "ethernet") == 0) {
                s.icon      = g_strdup("󰈀");
                s.text      = g_strdup((conn && conn[0]) ? conn : "Ethernet");
                s.css_class = g_strdup("network-ethernet");
            } else {
                s.icon      = g_strdup("󰛳");
                s.text      = g_strdup((conn && conn[0]) ? conn : "Подключено");
                s.css_class = g_strdup("network-other");
            }

            g_strfreev(cols);
            break;
        }

        g_strfreev(cols);
    }

    g_strfreev(lines);
    return s;
}

// ── Widget update ──────────────────────────────────────────────────────────

static const gchar *NET_CLASSES[] = {
    "network-none", "network-wifi", "network-ethernet", "network-other", NULL
};

static void update_window(struct Window *win) {
    if (!NET_WIN(win)) return;

    NetStatus s = query_network();

    gtk_label_set_text(GTK_LABEL(NET_WIN(win)->icon_label), s.icon);
    gtk_label_set_text(GTK_LABEL(NET_WIN(win)->text_label), s.text);

    GtkStyleContext *ctx = gtk_widget_get_style_context(NET_WIN(win)->box);
    for (gint i = 0; NET_CLASSES[i]; i++)
        gtk_style_context_remove_class(ctx, NET_CLASSES[i]);
    gtk_style_context_add_class(ctx, s.css_class);

    net_status_free(&s);
}

static gboolean timer_update(gpointer data) {
    (void)data;
    if (!global_gtklock || !global_gtklock->focused_window) return G_SOURCE_CONTINUE;
    update_window(global_gtklock->focused_window);
    return G_SOURCE_CONTINUE;
}

// ── Module callbacks ───────────────────────────────────────────────────────

const gchar *g_module_check_init(GModule *m) {
    (void)m;
    return NULL;
}

void g_module_unload(GModule *m) {
    (void)m;
    if (update_timer > 0) {
        g_source_remove(update_timer);
        update_timer = 0;
    }
    global_gtklock = NULL;
}

void on_activation(struct GtkLock *gtklock, int id) {
    self_id        = id;
    global_gtklock = gtklock;
    update_timer   = g_timeout_add_seconds(5, timer_update, NULL);
}

void on_window_create(struct GtkLock *gtklock, struct Window *win) {
    (void)gtklock;

    struct network_win *nw = g_new0(struct network_win, 1);
    MODULE_DATA(win) = nw;

    // Outer box
    nw->box = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 6);
    gtk_widget_set_name(nw->box, "network-box");

    // Icon (Nerd Font glyph)
    nw->icon_label = gtk_label_new("󰤭");
    gtk_widget_set_name(nw->icon_label, "network-icon");

    // Text label
    nw->text_label = gtk_label_new("...");
    gtk_widget_set_name(nw->text_label, "network-label");

    gtk_box_pack_start(GTK_BOX(nw->box), nw->icon_label, FALSE, FALSE, 0);
    gtk_box_pack_start(GTK_BOX(nw->box), nw->text_label, FALSE, FALSE, 0);

    // Position: top-right corner
    gtk_widget_set_halign(nw->box, GTK_ALIGN_END);
    gtk_widget_set_valign(nw->box, GTK_ALIGN_START);
    gtk_widget_set_margin_top(nw->box, 20);
    gtk_widget_set_margin_end(nw->box, 20);

    gtk_overlay_add_overlay(GTK_OVERLAY(win->overlay), nw->box);
    gtk_widget_show_all(nw->box);

    update_window(win);
}

void on_window_destroy(struct GtkLock *gtklock, struct Window *win) {
    (void)gtklock;
    if (NET_WIN(win)) {
        g_free(NET_WIN(win));
        MODULE_DATA(win) = NULL;
    }
}

void on_locked(struct GtkLock *gtklock)                                               { (void)gtklock; }
void on_output_change(struct GtkLock *gtklock)                                        { (void)gtklock; }
void on_focus_change(struct GtkLock *gtklock, struct Window *win, struct Window *old) { (void)gtklock; (void)old; if (win) update_window(win); }
void on_idle_hide(struct GtkLock *gtklock)                                            { (void)gtklock; }
void on_idle_show(struct GtkLock *gtklock)                                            { (void)gtklock; }
