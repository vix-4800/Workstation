return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = function()
    local icons = require("config.icons")
    local theme = require("config.lualine-theme")

    return {
      options = {
        icons_enabled = true,
        theme = theme,
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
        lualine_x = {
          {
            function()
              local status = require("codeium.virtual_text").status()
              if status.state == "completions" then
                return " " .. status.current .. "/" .. status.total
              elseif status.state == "waiting" then
                return " *"
              end
              return " "
            end,
            cond = function()
              return pcall(require, "codeium.virtual_text")
            end,
          },
          "filetype",
        },
        lualine_y = { "progress", "searchcount" },
        lualine_z = { "location" },
      },
      tabline = {},
      extensions = { "oil", "fugitive", "mason", "toggleterm", "trouble", "lazy" },
    }
  end,
}
