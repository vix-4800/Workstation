return {
  "neovim/nvim-lspconfig",
  dependencies = {
    -- {"saghen/blink.cmp"},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = {},
      automatic_installation = false,
    },
  },
}
