return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    spec = {
      { "<leader>s", group = "[S]earch" },
      { "<leader>g", group = "[G]it", mode = { "n", "v" } },
      { "<leader>c", group = "[C]ode" },
      { "<leader>cp", group = "[C]ode - PHP" },
      { "<leader>t", group = "[T]oggle" },
      { "<leader>tl", desc = "[T]oggle [L]inter (picker)" },
      { "<leader>r", group = "[R]eplace" },
      { "<leader>d", group = "[D]iagnostic/Debug" },
      { "<leader>a", group = "[A]I Tools" },
      { "<leader>b", group = "[B]uffer" },
      { "<leader>w", group = "[W]indow" },
      { "<leader>q", group = "[Q]uit/Session" },
      { "<leader>v", group = "[V]im Config" },
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
