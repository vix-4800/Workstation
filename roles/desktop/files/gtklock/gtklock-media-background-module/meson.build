# gtklock-media-background-module

project(
  'gtklock-media-background-module', 'c',
  version : '1.0.0',
  license : 'GPLv3',
  default_options : ['c_std=c11'],
)

gtk = dependency('gtk+-3.0')
gmodule_export = dependency('gmodule-export-2.0')
playerctl = dependency('playerctl')
libsoup = dependency('libsoup-3.0')

dependencies = [
  gtk,
  gmodule_export,
  playerctl,
  libsoup,
]

gtklock_media_background_module_sources = files('source.c')

gtklock_media_background_module_set = [
  gtklock_media_background_module_sources,
]

if import('fs').is_absolute(get_option('libdir'))
  gtklock_module_dir = get_option('libdir') / 'gtklock'
else
  gtklock_module_dir = get_option('prefix') / get_option('libdir') / 'gtklock'
endif

shared_module(
  'media-background',
  gtklock_media_background_module_set,
  dependencies: dependencies,
  install: true,
  install_dir: gtklock_module_dir / 'modules',
)
