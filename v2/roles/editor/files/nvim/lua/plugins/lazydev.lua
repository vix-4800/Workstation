return {
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {
    library = {
      { path = "lazy.nvim", words = { "Lazy" } },
      { path = "luvit-meta/library", words = { "vim%.uv" } },
    },
  },
}
