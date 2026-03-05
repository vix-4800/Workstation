// gtklock-battery-module
// Copyright (c) 2026
//
// Module showing battery charge level and status in the top-right corner.
// Reads state from /sys/class/power_supply/ and updates every 30 seconds.
// The widget is hidden automatically on machines without a battery.

#include <gtk/gtk.h>
#include <glib.h>
#include <stdio.h>
#include <string.h>

#include "gtklock-module.h"

#define MODULE_DATA(x) (x->module_data[self_id])
#define BAT_WIN(x)     ((struct battery_win *)MODULE_DATA(x))

// Vertical offset below the network module (≈ 44px icon row + 8px gap)
#define TOP_MARGIN 72

const gchar module_name[]        = "battery";
const guint module_major_version = 4;
const guint module_minor_version = 0;

static int            self_id        = 0;
static guint          update_timer   = 0;
static struct GtkLock *global_gtklock = NULL;

// Set to FALSE on machines without any battery; widget stays hidden
static gboolean has_battery = FALSE;

struct battery_win {
    GtkWidget *box;
    GtkWidget *icon_label;
    GtkWidget *text_label;
};

GOptionEntry module_entries[] = {
    { NULL },
};

// ── Sysfs helpers ──────────────────────────────────────────────────────────

static gchar *sysfs_read(const gchar *path) {
    FILE *f = fopen(path, "r");
    if (!f) return NULL;
    gchar buf[64];
    if (!fgets(buf, sizeof(buf), f)) { fclose(f); return NULL; }
    fclose(f);
    gsize len = strlen(buf);
    if (len > 0 && buf[len - 1] == '\n') buf[len - 1] = '\0';
    return g_strdup(buf);
}

static gint sysfs_read_int(const gchar *path, gint fallback) {
    gchar *val = sysfs_read(path);
    if (!val) return fallback;
    gint n = (gint)g_ascii_strtoll(val, NULL, 10);
    g_free(val);
    return n;
}

// ── Battery icon selection ─────────────────────────────────────────────────
//
// Icons use Nerd Fonts (Material Design) code points — requires a patched font
// such as JetBrainsMono Nerd Font or similar.

static const gchar *icon_for_discharge(gint pct) {
    if (pct <= 10) return "󰂎";   // battery_outline / critical
    if (pct <= 20) return "󰁺";
    if (pct <= 30) return "󰁻";
    if (pct <= 40) return "󰁼";
    if (pct <= 50) return "󰁽";
    if (pct <= 60) return "󰁾";
    if (pct <= 70) return "󰁿";
    if (pct <= 80) return "󰂀";
    if (pct <= 90) return "󰂁";
    if (pct <= 99) return "󰂂";
    return "󰁹";                   // battery_100
}

static const gchar *icon_for_charge(gint pct) {
    if (pct <= 20) return "󰢜";   // battery_charging_20
    if (pct <= 30) return "󰢝";
    if (pct <= 40) return "󰢞";
    if (pct <= 60) return "󰂈";
    if (pct <= 80) return "󰂉";
    if (pct <= 99) return "󰂊";
    return "󰂅";                   // battery_charging_100 / full
}

// ── State query ────────────────────────────────────────────────────────────

typedef struct {
    gint         capacity;       // 0-100, -1 if unavailable
    gchar       *status;         // "Charging" | "Discharging" | "Full" | "Unknown"
    const gchar *icon;           // Nerd Font glyph — points to a string literal, do NOT free
    gchar       *css_class;      // e.g. "battery-charging", "battery-low"
    gchar       *label_text;     // formatted e.g. "85%"
} BatState;

static void bat_state_free(BatState *s) {
    g_free(s->status);
    g_free(s->css_class);
    g_free(s->label_text);
    // s->icon points to a string literal — not freed
}

static gchar *find_battery_path(void) {
    const gchar *base = "/sys/class/power_supply";
    GDir   *dir = g_dir_open(base, 0, NULL);
    if (!dir) return NULL;

    gchar *found = NULL;
    const gchar *name;

    while ((name = g_dir_read_name(dir)) != NULL) {
        gchar *type_path = g_build_filename(base, name, "type", NULL);
        gchar *type      = sysfs_read(type_path);
        g_free(type_path);

        if (type && g_strcmp0(type, "Battery") == 0) {
            found = g_build_filename(base, name, NULL);
            g_free(type);
            break;
        }
        g_free(type);
    }

    g_dir_close(dir);
    return found;
}

static BatState query_battery(void) {
    BatState s = { -1, NULL, NULL, NULL, NULL };

    gchar *bat = find_battery_path();
    if (!bat) {
        has_battery = FALSE;
        s.status    = g_strdup("Unknown");
        s.css_class = g_strdup("battery-unknown");
        s.icon      = "󰂑";        // battery_unknown
        s.label_text = g_strdup("N/A");
        return s;
    }

    has_battery = TRUE;

    gchar *cap_path    = g_build_filename(bat, "capacity", NULL);
    gchar *status_path = g_build_filename(bat, "status",   NULL);

    s.capacity = sysfs_read_int(cap_path, -1);
    s.status   = sysfs_read(status_path);
    if (!s.status) s.status = g_strdup("Unknown");

    g_free(cap_path);
    g_free(status_path);
    g_free(bat);

    // Sanitise capacity
    if (s.capacity < 0)   s.capacity = 0;
    if (s.capacity > 100) s.capacity = 100;

    // Choose icon and CSS class
    gboolean charging = (g_strcmp0(s.status, "Charging") == 0);
    gboolean full     = (g_strcmp0(s.status, "Full")     == 0);

    if (full || (charging && s.capacity >= 100)) {
        s.icon      = "󰂅";        // charging-100 / complete
        s.css_class = g_strdup("battery-full");
    } else if (charging) {
        s.icon      = icon_for_charge(s.capacity);
        s.css_class = g_strdup("battery-charging");
    } else if (s.capacity <= 15) {
        s.icon      = icon_for_discharge(s.capacity);
        s.css_class = g_strdup("battery-critical");
    } else if (s.capacity <= 30) {
        s.icon      = icon_for_discharge(s.capacity);
        s.css_class = g_strdup("battery-low");
    } else {
        s.icon      = icon_for_discharge(s.capacity);
        s.css_class = g_strdup("battery-ok");
    }

    if (charging)
        s.label_text = g_strdup_printf("%d%% ⚡", s.capacity);
    else if (full)
        s.label_text = g_strdup("100%");
    else
        s.label_text = g_strdup_printf("%d%%", s.capacity);

    return s;
}

// ── Widget update ──────────────────────────────────────────────────────────

static const gchar *BAT_CLASSES[] = {
    "battery-full", "battery-charging", "battery-ok",
    "battery-low",  "battery-critical", "battery-unknown", NULL
};

static void update_window(struct Window *win) {
    if (!BAT_WIN(win)) return;

    BatState s = query_battery();

    gtk_widget_set_visible(BAT_WIN(win)->box, has_battery);

    if (has_battery) {
        gtk_label_set_text(GTK_LABEL(BAT_WIN(win)->icon_label), s.icon);
        gtk_label_set_text(GTK_LABEL(BAT_WIN(win)->text_label), s.label_text);

        GtkStyleContext *ctx = gtk_widget_get_style_context(BAT_WIN(win)->box);
        for (gint i = 0; BAT_CLASSES[i]; i++)
            gtk_style_context_remove_class(ctx, BAT_CLASSES[i]);
        gtk_style_context_add_class(ctx, s.css_class);
    }

    bat_state_free(&s);
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
    update_timer   = g_timeout_add_seconds(30, timer_update, NULL);
}

void on_window_create(struct GtkLock *gtklock, struct Window *win) {
    (void)gtklock;

    struct battery_win *bw = g_new0(struct battery_win, 1);
    MODULE_DATA(win) = bw;

    // Outer box
    bw->box = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 6);
    gtk_widget_set_name(bw->box, "battery-box");

    // Icon label
    bw->icon_label = gtk_label_new("󰂑");
    gtk_widget_set_name(bw->icon_label, "battery-icon");

    // Text label
    bw->text_label = gtk_label_new("...");
    gtk_widget_set_name(bw->text_label, "battery-label");

    gtk_box_pack_start(GTK_BOX(bw->box), bw->icon_label, FALSE, FALSE, 0);
    gtk_box_pack_start(GTK_BOX(bw->box), bw->text_label, FALSE, FALSE, 0);

    // Position: top-right, stacked below network module
    gtk_widget_set_halign(bw->box, GTK_ALIGN_END);
    gtk_widget_set_valign(bw->box, GTK_ALIGN_START);
    gtk_widget_set_margin_top(bw->box, TOP_MARGIN);
    gtk_widget_set_margin_end(bw->box, 20);

    gtk_overlay_add_overlay(GTK_OVERLAY(win->overlay), bw->box);
    gtk_widget_show_all(bw->box);

    update_window(win);
}

void on_window_destroy(struct GtkLock *gtklock, struct Window *win) {
    (void)gtklock;
    if (BAT_WIN(win)) {
        g_free(BAT_WIN(win));
        MODULE_DATA(win) = NULL;
    }
}

void on_locked(struct GtkLock *gtklock)                                               { (void)gtklock; }
void on_output_change(struct GtkLock *gtklock)                                        { (void)gtklock; }
void on_focus_change(struct GtkLock *gtklock, struct Window *win, struct Window *old) { (void)gtklock; (void)old; if (win) update_window(win); }
void on_idle_hide(struct GtkLock *gtklock)                                            { (void)gtklock; }
void on_idle_show(struct GtkLock *gtklock)                                            { (void)gtklock; }
