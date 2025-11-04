return {
  "rmagatti/auto-session",
  lazy = false,
  keys = {
    { "<leader>ss", "<cmd>AutoSession search<cr>", desc = "[S]ession [S]earch" },
  },

  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    suppressed_dirs = { "~/", "~/Downloads", "/" },

    enabled = true,
    auto_save = true,
    auto_restore = true,
    auto_create = true,

    ---@type SessionLens
    session_lens = {
      load_on_setup = true,
      theme_conf = { border = true },
      previewer = false,
    },
  },
}
