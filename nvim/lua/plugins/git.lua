return {
  {
    "lewis6991/gitsigns.nvim",
    opts = function()
      local icons = require("config.icons")
      return {
        signs = icons.git.signs,
        signs_staged = icons.git.signs_staged,
        signs_staged_enable = true,
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        watch_gitdir = {
          follow_files = true,
        },
        auto_attach = true,
        attach_to_untracked = false,
        current_line_blame = false,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",
          delay = 1000,
          ignore_whitespace = false,
          virt_text_priority = 100,
          use_focus = true,
        },
        current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil,
        max_file_length = 40000,
        preview_config = {
          style = "minimal",
          relative = "cursor",
          row = 0,
          col = 1,
        },
      }
    end,
    event = "BufReadPre",
    keys = {
      { "<leader>gs", function() require("gitsigns").stage_hunk() end, desc = "[S]tage hunk", mode = "n" },
      { "<leader>gs", function() require("gitsigns").stage_hunk({vim.fn.line("."), vim.fn.line("v")}) end, desc = "[S]tage hunk", mode = "v" },
      { "<leader>gS", function() require("gitsigns").stage_buffer() end, desc = "[S]tage buffer" },

      { "<leader>gr", function() require("gitsigns").reset_hunk() end, desc = "[R]eset hunk", mode = "n" },
      { "<leader>gr", function() require("gitsigns").reset_hunk({vim.fn.line("."), vim.fn.line("v")}) end, desc = "[R]eset hunk", mode = "v" },
      { "<leader>gR", function() require("gitsigns").reset_buffer() end, desc = "[R]eset buffer" },

      { "<leader>gu", function() require("gitsigns").undo_stage_hunk() end, desc = "[U]ndo stage hunk" },

      { "]g", function() require("gitsigns").next_hunk() end, desc = "Next hunk" },
      { "[g", function() require("gitsigns").prev_hunk() end, desc = "Previous hunk" },
    },
    config = function(_, opts)
      require("gitsigns").setup(opts)
    end,
  },
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gread", "Gwrite", "Ggrep", "GMove", "GDelete", "GBrowse", "GRemove", "GRename", "Glgrep", "Gedit" },
    keys = {
      { "<leader>gg", "<cmd>Git<CR>", desc = "status" },
      { "<leader>gl", "<cmd>Git log<CR>", desc = "[L]og" },
      { "<leader>gc", "<cmd>Git commit<CR>", desc = "[C]ommit" },
      { "<leader>gP", "<cmd>Git push<CR>", desc = "[P]ush" },
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "[V]iew diff" },
      { "<leader>gD", "<cmd>DiffviewClose<CR>", desc = "Close diff[V]iew" },

      { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "[H]istory (current file)" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "[H]istory (all)" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = {
          layout = "diff2_horizontal",
        },
        file_history = {
          layout = "diff2_horizontal",
        },
      },
    },
  },
}
