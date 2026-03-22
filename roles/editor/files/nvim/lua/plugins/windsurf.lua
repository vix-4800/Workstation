return {
  "Exafunction/windsurf.nvim",
  event = "BufEnter",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("codeium").setup({
      enable_cmp_source = false,
      virtual_text = {
        enabled = true,
        key_bindings = {
          accept = "<M-l>",
          accept_word = "<M-w>",
          accept_line = "<M-L>",
          next = "<M-]>",
          prev = "<M-[>",
          clear = "<M-c>",
        },
      },
    })

    require("codeium.virtual_text").set_statusbar_refresh(function()
      require("lualine").refresh()
    end)
  end,
}
