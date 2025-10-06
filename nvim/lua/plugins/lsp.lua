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
  {
    "saghen/blink.cmp",
    event = "VimEnter",
    dependencies = {
      { "neovim/nvim-lspconfig" },
      -- {'rafamadriz/friendly-snippets'}
    },
    version = "1.*",

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = "default",

        -- Additional keymaps (optional)
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
      },

      appearance = {
        nerd_font_variant = "mono",
      },

      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 500,
        },
      },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },

      fuzzy = { implementation = "lua" },

      signature = { enabled = true },
    },
    opts_extend = { "sources.default" },
  },
}
