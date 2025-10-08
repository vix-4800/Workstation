return {
  "mfussenegger/nvim-lint",
  config = function()
    local lint = require("lint")
    lint.linters_by_ft = {
      markdown = { "markdownlint" },
      php = { "phpstan", "phpcs" },
      dockerfile = { "hadolint" },
      json = { "jsonlint" },
      yaml = { "yamllint" },
      python = { "pylint", "flake8" },
      sh = { "shellcheck" },
      -- lua = { "luacheck" },
    }

    -- Configure phpstan to use custom config
    lint.linters.phpstan = lint.linters.phpstan or {}
    lint.linters.phpstan.args = {
      "analyse",
      "--error-format=json",
      "--no-progress",
      "--configuration=" .. vim.fn.expand("~/.config/phpstan/phpstan.neon"),
      function()
        return vim.api.nvim_buf_get_name(0)
      end,
    }

    -- Configure phpcs to use custom config
    lint.linters.phpcs.cmd = vim.fn.expand("~/.config/composer/vendor/bin/phpcs")
    lint.linters.phpcs.args = {
      "--standard=" .. vim.fn.expand("~/.config/phpcs/phpcs.xml"),
      "--report=json",
      "-q",
      function()
        return vim.api.nvim_buf_get_name(0)
      end,
    }
    lint.linters.phpcs.stdin = false

    lint.linters.phpcs.env = {
      PHP_CS_FIXER_IGNORE_ENV = "1",
    }

    -- Create autocommand which carries out the actual linting on the specified events.
    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        -- Only run the linter in buffers that you can modify in order to
        -- avoid superfluous noise, notably within the handy LSP pop-ups that
        -- describe the hovered symbol using Markdown.
        if vim.bo.modifiable then
          lint.try_lint()
        end
      end,
    })
  end,
}
