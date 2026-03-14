// gtklock-playerctl-module
// Copyright (c) 2024 Jovan Lanik

// Module header

#include "gtk/gtk.h"

struct Window {
	GdkMonitor *monitor;

	GtkWidget *window;
	GtkWidget *overlay;
	GtkWidget *window_box;
	GtkWidget *body_revealer;
	GtkWidget *body_grid;
	GtkWidget *input_label;
	GtkWidget *input_field;
	GtkWidget *message_revealer;
	GtkWidget *message_scrolled_window;
	GtkWidget *message_box;
	GtkWidget *unlock_button;
	GtkWidget *error_label;
	GtkWidget *warning_label;
	GtkWidget *info_box;
	GtkWidget *time_box;
	GtkWidget *clock_label;
	GtkWidget *date_label;

	void *module_data[];
};

struct GtkLock {
	GtkApplication *app;
	void *lock;
	pid_t parent;

	GArray *windows;
	GArray *messages;
	GArray *errors;

	struct Window *focused_window;
	gboolean hidden;
	guint idle_timeout;

	guint draw_time_source;
	guint idle_hide_source;

	gboolean follow_focus;
	gboolean use_idle_hide;

	char *time;
	char *date;
	char *time_format;
	char *date_format;
	char *config_path;
	char *layout_path;
	char *lock_command;
	char *unlock_command;

	GArray *modules;
};

const gchar *g_module_check_init(GModule *m);
void g_module_unload(GModule *m);
void on_activation(struct GtkLock *gtklock, int id);
void on_locked(struct GtkLock *gtklock);
void on_output_change(struct GtkLock *gtklock);
void on_focus_change(struct GtkLock *gtklock, struct Window *win, struct Window *old);
void on_idle_hide(struct GtkLock *gtklock);
void on_idle_show(struct GtkLock *gtklock);
void on_window_create(struct GtkLock *gtklock, struct Window *win);
void on_window_destroy(struct GtkLock *gtklock, struct Window *win);
