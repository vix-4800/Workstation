-- Tokyo Night Theme Configuration
return {
  "folke/tokyonight.nvim",
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    require("tokyonight").setup({
      style = "night", -- The theme comes in four styles: `storm`, `moon`, `night` and `day`
      light_style = "day", -- The theme to use when the background is set to light
      transparent = false, -- Enable this to disable setting the background color
      terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
      styles = {
        comments = { italic = false }, -- Disable italics in comments
        keywords = { italic = false },
        functions = {},
        variables = {},
        sidebars = "dark", -- style for sidebars, see below
        floats = "dark", -- style for floating windows
      },
      sidebars = { "qf", "help" }, -- Set a darker background on sidebar-like windows
      day_brightness = 0.3, -- Adjusts the brightness of the colors of the **Day** style
      hide_inactive_statusline = false, -- Enabling this option, will hide inactive statuslines
      dim_inactive = false, -- dims inactive windows
      lualine_bold = false, -- When `true`, section headers in the lualine theme will be bold

      on_colors = function(colors) end,
      on_highlights = function(highlights, colors) end,
    })

    -- Set the colorscheme
    vim.cmd.colorscheme("tokyonight-night")
  end,
}
