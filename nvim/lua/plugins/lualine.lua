return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      icons_enabled = true,
      theme = "auto",
      component_separators = "",
      section_separators = { left = "", right = "" },
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
  },
}
