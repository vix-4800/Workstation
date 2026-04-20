local configs = require("config.linter-configs")

return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>f",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = "",
      desc = "[F]ormat buffer",
    },
  },
  opts = {
    format_on_save = function(bufnr)
      local disable_filetypes = { php = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      else
        return {
          timeout_ms = 500,
          lsp_format = "fallback",
        }
      end
    end,
    formatters_by_ft = {
      lua = { "stylua" },
      php = { "php_cs_fixer" },
      blade = { "blade_formatter" },
      python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
      javascript = { "eslint_fix", "prettier" },
      typescript = { "eslint_fix", "prettier" },
      javascriptreact = { "eslint_fix", "prettier" },
      typescriptreact = { "eslint_fix", "prettier" },
      vue = { "eslint_fix", "prettier" },
      css = { "stylelint_fix", "prettier" },
      scss = { "stylelint_fix", "prettier" },
      less = { "stylelint_fix", "prettier" },
      html = { "prettier" },
      json = { "prettierd", "prettier", stop_after_first = true },
      jsonc = { "prettierd", "prettier", stop_after_first = true },
      yaml = { "yamlfmt" },
      markdown = { "markdownlint_fix", "prettier" },
      dosini = { "inifmt" },
      go = { "gofmt" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      fish = { "fish_indent" },
      toml = { "taplo" },
      dotenv = { "dotenv_linter" },
      sql = { "sqlfluff" },
      nginx = { "nginxbeautifier" },
      xml = {}, -- Use LSP formatter (lemminx)
    },
    formatters = {
      stylua = {
        prepend_args = {
          "--config-path",
          configs.getConfig("stylua"),
        },
      },
      php_cs_fixer = {
        command = vim.fn.expand("~/.config/composer/vendor/bin/php-cs-fixer"),
        args = {
          "fix",
          "--config=" .. configs.getConfig("php_cs_fixer"),
          "$FILENAME",
        },
        stdin = false,
      },
      blade_formatter = {
        command = "blade-formatter",
        args = {
          "--stdin",
          "--config",
          configs.getConfig("blade_formatter"),
        },
        stdin = true,
      },
      nginxbeautifier = {
        command = "nginxbeautifier",
        args = { "-s", "4", "-i", "$FILENAME" },
        stdin = false,
      },
      prettierd = {
        env = {
          PRETTIERD_DEFAULT_CONFIG = configs.getConfig("prettier"),
        },
      },
      prettier = {
        prepend_args = {
          "--config",
          configs.getConfig("prettier"),
        },
      },
      eslint_fix = {
        command = "eslint",
        args = {
          "--config",
          configs.getConfig("eslint"),
          "--fix",
          "$FILENAME",
        },
        stdin = false,
      },
      stylelint_fix = {
        command = "stylelint",
        args = {
          "--config",
          configs.getConfig("stylelint"),
          "--fix",
          "$FILENAME",
        },
        stdin = false,
      },
      markdownlint_fix = {
        command = "markdownlint",
        args = {
          "--config",
          configs.getConfig("markdownlint"),
          "--fix",
          "$FILENAME",
        },
        stdin = false,
      },
      inifmt = {
        command = "inifmt",
        stdin = true,
      },
      dotenv_linter = {
        command = "dotenv-linter",
        args = { "--plain", "fix", "--no-backup", "$FILENAME" },
        stdin = false,
      },
      fish_indent = {
        command = "fish_indent",
        args = { "-w", "$FILENAME" },
        stdin = false,
      },
      shfmt = {
        prepend_args = { "-i", "2", "-ci" },
      },
      sqlfluff = {
        command = "sqlfluff",
        args = {
          "fix",
          "--config",
          configs.getConfig("sqlfluff"),
          "--dialect",
          "mysql",
          "$FILENAME",
        },
        stdin = false,
      },
      taplo = {
        command = "taplo",
        args = {
          "fmt",
          "--config",
          configs.getConfig("taplo"),
          "-",
        },
        stdin = true,
      },
      yamlfmt = {
        command = "yamlfmt",
        args = {
          "-conf",
          configs.getConfig("yamlfmt"),
          "-",
        },
        stdin = true,
      },
      ruff_fix = {
        command = "ruff",
        args = {
          "check",
          "--fix",
          "--config=" .. configs.getConfig("ruff"),
          "$FILENAME",
        },
        stdin = false,
      },
      ruff_organize_imports = {
        command = "ruff",
        args = {
          "check",
          "--select",
          "I",
          "--fix",
          "--config=" .. configs.getConfig("ruff"),
          "$FILENAME",
        },
        stdin = false,
      },
      ruff_format = {
        command = "ruff",
        args = {
          "format",
          "--config=" .. configs.getConfig("ruff"),
          "$FILENAME",
        },
        stdin = false,
      },
    },
  },
}
