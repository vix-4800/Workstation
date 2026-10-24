local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local upgrading = vim.g.workstation_upgrade == true
if upgrading then
  vim.go.loadplugins = true
end
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    if upgrading then
      error("Failed to clone lazy.nvim:\n" .. out)
    end
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

local spec = {
  -- Plugins
  { import = "plugins" },

  -- Themes
  -- { import = "themes" }, -- Uncomment this line to load all themes
  -- Or specify individual themes to load
  require("themes.catppuccin"),
}

if upgrading then
  for _, plugin in ipairs({
    "nvim-treesitter/nvim-treesitter",
    "nvim-treesitter/nvim-treesitter-textobjects",
    "rmagatti/auto-session",
    "wakatime/vim-wakatime",
    "mason-org/mason.nvim",
    "stevearc/oil.nvim",
  }) do
    spec[#spec + 1] = { plugin, lazy = true }
  end
  spec[#spec + 1] = { "catppuccin/nvim", name = "catppuccin", lazy = true }
  spec[#spec + 1] = {
    "Exafunction/windsurf.nvim",
    lazy = true,
    event = function()
      return {}
    end,
  }
  spec[#spec + 1] = {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = true,
    event = function()
      return {}
    end,
    opts = { run_on_start = false, auto_update = false },
  }
end

require("lazy").setup({
  spec = spec,
  defaults = { lazy = upgrading },
  install = { colorscheme = { "catppuccin" }, missing = not upgrading },

  -- automatically check for plugin updates (silently)
  checker = { enabled = not upgrading, notify = false },
  change_detection = { enabled = not upgrading },
  local_spec = not upgrading,
})

if upgrading then
  local handler = require("lazy.core.handler")
  for _, plugin in pairs(require("lazy.core.config").plugins) do
    handler.disable(plugin)
  end
end
