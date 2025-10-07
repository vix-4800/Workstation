return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    spec = {
      { "<leader>s", group = "[S]earch" },
      { "<leader>g", group = "[G]it", mode = { "n", "v" } },
      { "<leader>c", group = "[C]ode Tools" },
      { "<leader>cp", group = "[C]ode Tools - PHP" },
      { "<leader>t", group = "[T]oggle" },
      { "<leader>r", group = "[R]eplace" },
    },
    delay = 0,
    icons = {
      mappings = vim.g.have_nerd_font,
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
