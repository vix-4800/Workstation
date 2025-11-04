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
      sh = { "shfmt" },
      bash = { "shfmt" },
    },
    formatters = {
      php_cs_fixer = {
        command = "php-cs-fixer",
        args = {
          "fix",
          "--config=" .. vim.fn.expand("~/.config/php-cs-fixer/php-cs-fixer.php"),
          "$FILENAME",
        },
        stdin = false,
      },
      prettier = {
        command = "prettier",
        args = {
          "--config",
          vim.fn.expand("~/.prettierrc"),
          "--stdin-filepath",
          "$FILENAME",
        },
        stdin = true,
      },
      shfmt = {
        prepend_args = { "-i", "2", "-ci" },
      },
      ruff_format = {
        command = "ruff",
        args = {
          "format",
          "--config=" .. vim.fn.expand("~/.config/ruff/pyproject.toml"),
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
          "--config=" .. vim.fn.expand("~/.config/ruff/pyproject.toml"),
          "--stdin-filename",
          "$FILENAME",
          "-",
        },
        stdin = true,
      },
    },
  },
}
