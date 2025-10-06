return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- { "j-hui/fidget.nvim", opts = {} },
      -- {"saghen/blink.cmp"},
    },
    {
      "mason-org/mason-lspconfig.nvim",
      dependencies = { "neovim/nvim-lspconfig" },
      opts = {
        ensure_installed = {},
        automatic_installation = false,
      }
    },
  }
}
