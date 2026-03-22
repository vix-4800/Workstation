return {
  {
    "mason-org/mason.nvim",
    lazy = false,
    opts = function()
      local icons = require("config.icons")
      return {
        ui = {
          icons = icons.mason,
        },
      }
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        -- ╭─────────────────────────────────────────────────────────╮
        -- │ LSP Servers                                             │
        -- ╰─────────────────────────────────────────────────────────╯
        "lua-language-server", -- Lua
        "pyright", -- Python
        "typescript-language-server", -- TypeScript/JavaScript
        "gopls", -- Go
        "bash-language-server", -- Bash
        "intelephense", -- PHP
        "yaml-language-server", -- YAML
        "json-lsp", -- JSON
        "html-lsp", -- HTML
        "css-lsp", -- CSS
        "lemminx", -- XML
        "dockerfile-language-server", -- Docker
        "docker-compose-language-service", -- Docker Compose
        "marksman", -- Markdown
        "fish-lsp", -- Fish
        "nginx-language-server", -- Nginx

        -- ╭─────────────────────────────────────────────────────────╮
        -- │ Formatters                                              │
        -- ╰─────────────────────────────────────────────────────────╯
        "stylua", -- Lua
        "prettier", -- JS/TS/JSON/CSS/HTML/MD
        "prettierd", -- JS/TS/JSON/CSS/HTML/MD
        "yamlfmt", -- YAML

        -- ╭─────────────────────────────────────────────────────────╮
        -- │ Linters                                                 │
        -- ╰─────────────────────────────────────────────────────────╯
        "jsonlint", -- JSON
        "hadolint", -- Dockerfile
        "dotenv-linter", -- .env files
        "actionlint", -- GitHub Actions

        -- ╭─────────────────────────────────────────────────────────╮
        -- │ Other Tools                                             │
        -- ╰─────────────────────────────────────────────────────────╯
        "editorconfig-checker", -- EditorConfig
      },
      auto_update = true,
      run_on_start = true,
      start_delay = 3000, -- 3 second delay
      debounce_hours = 24,
    },
  },
}
