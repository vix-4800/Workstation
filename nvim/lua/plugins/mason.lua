return {
  {
    "mason-org/mason.nvim",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        -- Bash
        "shfmt",
        "bash-language-server",
        "shellcheck",

        -- Go
        "gopls",

        -- Lua
        "lua-language-server",
        "stylua",

        -- YAML
        "yamlfmt",
        "yamllint",
        "yaml-language-server",

        -- JSON
        "jsonlint",
        "json-lsp",

        -- Python
        "pyright",
        "pylint",
        "flake8",

        -- HTML, CSS
        "html-lsp",
        "css-lsp",

        -- PHP
        "intelephense",
        "php-cs-fixer",
        "phpstan",
        "phpcs",

        -- Docker
        "hadolint",
        "dockerfile-language-server",
        "docker-compose-language-service",

        -- Other
        "editorconfig-checker",
        "prettier",
        "markdownlint",
      },
      auto_update = true,
      run_on_start = true,
      start_delay = 3000, -- 3 second delay
      debounce_hours = 24,
    },
  },
}
