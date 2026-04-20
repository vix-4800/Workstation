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
      python = { "ruff_format", "ruff_organize_imports" },
      javascript = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      vue = { "prettierd", "prettier", stop_after_first = true },
      css = { "prettierd", "prettier", stop_after_first = true },
      html = { "prettierd", "prettier", stop_after_first = true },
      json = { "prettierd", "prettier", stop_after_first = true },
      jsonc = { "prettierd", "prettier", stop_after_first = true },
      yaml = { "yamlfmt" },
      markdown = { "prettierd", "prettier", stop_after_first = true },
      dosini = { "inifmt" },
      go = { "gofmt" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      toml = { "taplo" },
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
      inifmt = {
        command = "inifmt",
        stdin = true,
      },
      shfmt = {
        prepend_args = { "-i", "2", "-ci" },
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
      ruff_format = {
        command = "ruff",
        args = {
          "format",
          "--config=" .. configs.getConfig("ruff"),
          "--stdin-filename",
          "$FILENAME",
          "-",
        },
        stdin = true,
      },
      ruff_organize_imports = {
        command = "ruff",
        args = {
          "check",
          "--select",
          "I",
          "--fix",
          "--config=" .. configs.getConfig("ruff"),
          "--stdin-filename",
          "$FILENAME",
          "-",
        },
        stdin = true,
      },
    },
  },
}
