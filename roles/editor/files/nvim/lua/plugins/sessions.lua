return {
  "rmagatti/auto-session",
  lazy = false,
  keys = {
    { "<leader>ss", "<cmd>AutoSession search<cr>", desc = "[S]ession [S]earch" },
    { "<leader>qr", "<cmd>AutoSession restore<cr>", desc = "[Q]uit/Session: [R]estore session" },
    { "<leader>qd", "<cmd>AutoSession delete<cr>", desc = "[Q]uit/Session: [D]elete session" },
    { "<leader>qs", "<cmd>AutoSession save<cr>", desc = "[Q]uit/Session: [S]ave session" },
    { "<leader>ts", "<cmd>AutoSession toggle<cr>", desc = "[T]oggle [S]ession AutoSave" },
  },

  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    -- Directories to suppress session creation
    suppressed_dirs = {
      "~/",
      "~/Downloads",
      "~/Documents",
      "~/Desktop",
      "/",
      "/tmp",
    },

    -- Main settings
    enabled = true,
    root_dir = vim.fn.stdpath("data") .. "/sessions/",

    -- Auto save/restore settings
    auto_save = true, -- Automatically save session on exit
    auto_restore = false, -- Automatically restore session on startup
    auto_create = true, -- Automatically create new sessions

    -- Use git branch for session names
    use_git_branch = false,

    -- Logging (set to vim.log.levels.DEBUG for troubleshooting)
    log_level = "error",

    -- Close specific buffers before saving session
    close_unsupported_windows = true,

    -- Filetypes to bypass on save
    bypass_save_filetypes = {
      "alpha",
      "dashboard",
      "lazy",
      "mason",
      "oil",
      "notify",
      "TelescopePrompt",
    },

    -- Session lens (Telescope integration)
    ---@type SessionLens
    session_lens = {
      load_on_setup = true,
      theme_conf = {
        border = true,
        winblend = 10,
      },
      previewer = false,
      mappings = {
        delete_session = { "i", "<C-D>" },
        alternate_session = { "i", "<C-S>" },
      },
    },

    -- Hooks for custom behavior
    pre_save_cmds = {
      -- Close nvim-tree or oil before saving
      function()
        -- Close Oil if open
        local oil_ok, oil = pcall(require, "oil")
        if oil_ok then
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "oil" then
              vim.api.nvim_win_close(win, false)
            end
          end
        end
      end,
    },

    post_restore_cmds = {
      -- Custom commands after session restore
      function()
        -- Refresh file explorer or other plugins if needed
        vim.cmd("checktime")
      end,
    },

  },
}
