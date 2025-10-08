-- ╭─────────────────────────────────────────────────────────────────────╮
-- │                        Centralized Icons Config                     │
-- ╰─────────────────────────────────────────────────────────────────────╯
-- All icons used across the Neovim configuration in one place
-- for easy customization and consistency

local M = {}

-- ╭─────────────────────────────────────────────────────────────────────╮
-- │                          Diagnostic Icons                           │
-- ╰─────────────────────────────────────────────────────────────────────╯
M.diagnostics = {
  error = "✗",
  warn = "⚠",
  info = "ℹ",
  hint = "➤",
}

-- ╭─────────────────────────────────────────────────────────────────────╮
-- │                             Git Icons                               │
-- ╰─────────────────────────────────────────────────────────────────────╯
M.git = {
  signs = {
    add = "+",
    change = "~",
    delete = "_",
    topdelete = "‾",
    changedelete = "~",
    untracked = "┆",
  },
  signs_staged = {
    add = "┃",
    change = "┃",
    delete = "_",
    topdelete = "‾",
    changedelete = "~",
    untracked = "┆",
  },
}

-- ╭─────────────────────────────────────────────────────────────────────╮
-- │                            Mason Icons                              │
-- ╰─────────────────────────────────────────────────────────────────────╯
M.mason = {
  package_installed = "✓",
  package_pending = "➜",
  package_uninstalled = "✗",
}

-- ╭─────────────────────────────────────────────────────────────────────╮
-- │                         Dashboard Icons                             │
-- ╰─────────────────────────────────────────────────────────────────────╯
M.dashboard = {
  find_file = "🔍",
  new_file = "",
  recent_files = "📄",
  settings = "⚙️",
  lazy = "",
  mason = "🔨",
  quit = "❌",
}

-- ╭─────────────────────────────────────────────────────────────────────╮
-- │                       Notification Icons                            │
-- ╰─────────────────────────────────────────────────────────────────────╯
M.notifications = {
  -- PHP Tools
  rector_start = "🔧",
  phpstan_start = "🔍",
  phpcs_start = "📋",

  -- Status
  success = "✅",
  error = "❌",
  warning = "⚠️",

  -- Discord Presence
  editing = "📝",
  viewing = "👀",
  midnight = "🌙",
  late_night = "🌙",
  evening = "🌆",
  afternoon = "☀️",
  morning = "🌅",
  early_bird = "🌅",
}

-- ╭─────────────────────────────────────────────────────────────────────╮
-- │                          Lualine Icons                              │
-- ╰─────────────────────────────────────────────────────────────────────╯
M.lualine = {
  section_separators = {
    left = "",
    right = "",
  },
  component_separators = {
    left = "",
    right = "",
  },
}

-- ╭─────────────────────────────────────────────────────────────────────╮
-- │                        Miscellaneous Icons                          │
-- ╰─────────────────────────────────────────────────────────────────────╯
M.misc = {
  virtual_text_prefix = "●",
  list_chars = {
    tab = "» ",
    trail = "·",
    nbsp = "␣",
  },
}

return M
