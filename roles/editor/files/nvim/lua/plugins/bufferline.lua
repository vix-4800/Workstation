return {
  "akinsho/bufferline.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("bufferline").setup({
      options = {
        diagnostics = "nvim_lsp",
        show_buffer_close_icons = true,
        show_close_icon = true,
        buffer_close_icon = "󰅖",
        modified_icon = "● ",
        close_icon = " ",
        offsets = {
          {
            filetype = "NvimTree",
            text = "",
            padding = 1,
          },
        },
        max_name_length = 18,
        hover = {
          enabled = true,
          delay = 200,
          reveal = { "close" },
        },
      },
    })
  end,
}
