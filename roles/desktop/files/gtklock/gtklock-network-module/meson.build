project(
  'gtklock-network-module', 'c',
  version : '1.0.0',
  license : 'GPLv3',
  default_options : ['c_std=c11'],
)

gtk        = dependency('gtk+-3.0')
gmodule    = dependency('gmodule-export-2.0')

dependencies = [gtk, gmodule]

if import('fs').is_absolute(get_option('libdir'))
  gtklock_module_dir = get_option('libdir') / 'gtklock'
else
  gtklock_module_dir = get_option('prefix') / get_option('libdir') / 'gtklock'
endif

shared_module(
  'network-module',
  files('source.c'),
  dependencies : dependencies,
  install       : true,
  name_prefix   : '',
  install_dir   : gtklock_module_dir,
)
