return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = function()
    local icons = require("config.icons")
    return {
      options = {
        icons_enabled = true,
        theme = "catppuccin",
        component_separators = icons.lualine.component_separators,
        section_separators = icons.lualine.section_separators,
        globalstatus = true,
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "filename", "diagnostics" },
        lualine_c = { "branch" },
        lualine_x = { "filetype" },
        lualine_y = { "progress", "searchcount" },
        lualine_z = { "location" },
      },
      tabline = {},
      extensions = { "oil", "fugitive", "mason", "toggleterm", "trouble", "lazy" },
    }
  end,
}
