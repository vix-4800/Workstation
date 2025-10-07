return {
  "nvim-telescope/telescope.nvim",
  -- tag = '0.1.0',
  branch = "master",
  event = "VimEnter",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
    { "nvim-telescope/telescope-ui-select.nvim" },
    { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
  },
  config = function()
    require("telescope").setup({
      -- defaults = {
      --   mappings = {
      --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
      --   },
      -- },
      -- pickers = {}
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown(),
        },
      },
    })

    local telescope = require("telescope")

    -- Enable Telescope extensions if they are installed
    pcall(telescope.load_extension, "fzf")
    pcall(telescope.load_extension, "ui-select")
    pcall(telescope.load_extension, "notify")
  end,
  keys = {
    {
      "<leader><leader>",
      function()
        require("telescope.builtin").buffers()
      end,
      desc = "[ ] Find existing buffers",
    },
    {
      "<leader>sb",
      function()
        require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end,
      desc = "Fuzzily search in current [b]uffer",
    },
    {
      "<leader>sf",
      function()
        require("telescope.builtin").find_files()
      end,
      desc = "[S]earch [F]iles",
    },
    {
      "<leader>sw",
      function()
        require("telescope.builtin").grep_string()
      end,
      desc = "[S]earch current [W]ord",
    },
    {
      "<leader>sg",
      function()
        require("telescope.builtin").live_grep()
      end,
      desc = "[S]earch by [G]rep",
    },
    {
      "<leader>sq",
      function()
        require("telescope.builtin").diagnostics()
      end,
      desc = "[S]earch Diagnostics",
    },
    {
      "<leader>sn",
      function()
        require("telescope").extensions.notify.notify()
      end,
      desc = "[S]earch [N]otifications",
    },
  },
}
