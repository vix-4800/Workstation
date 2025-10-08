return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      { "saghen/blink.cmp" },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = {},
      automatic_installation = false,
    },
  },
  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    dependencies = {
      { "neovim/nvim-lspconfig" },
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        dependencies = {
          "rafamadriz/friendly-snippets",
          config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
          end,
        },
      },
    },
    version = "1.*",

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      snippets = {
        preset = "luasnip",
      },

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
        ghost_text = {
          enabled = false,
        },
        documentation = {
          auto_show = true,
        },
        menu = {
          draw = {
            columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
            treesitter = { "lsp" },
          },
        },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },

      fuzzy = { implementation = "lua" },

      signature = {
        enabled = true,
        window = {
          show_documentation = true,
        },
      },
    },
    opts_extend = { "sources.default" },
  },
}
