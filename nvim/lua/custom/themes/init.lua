-- Theme Management
-- Choose your active theme by uncommenting one of the lines below

-- Available themes:
local themes = {
  rose_pine = require 'custom.themes.rose-pine',
  tokyonight = require 'custom.themes.tokyonight',
  catppuccin = require 'custom.themes.catppuccin',
  github = require 'custom.themes.github',
}

-- Set your active theme here:
local active_theme = 'rose_pine' -- Change this to switch themes

-- Return the active theme configuration
return themes[active_theme]
