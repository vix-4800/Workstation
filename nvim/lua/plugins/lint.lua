return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local lint = require("lint")

    -- Global linting state
    vim.g.linting_enabled = true

    lint.linters_by_ft = {
      markdown = { "markdownlint" },
      php = { "phpstan", "phpcs" },
      dockerfile = { "hadolint" },
      json = { "jsonlint" },
      yaml = { "yamllint" },
      python = { "pylint", "flake8" },
      sh = { "shellcheck" },
      -- lua = { "luacheck" },
      dotenv = { "dotenv-linter" },
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

    -- Dotenv-linter configuration
    lint.linters["dotenv-linter"] = {
      cmd = "dotenv-linter",
      stdin = false,
      args = { "check", "--format", "json", "$FILENAME" },
      -- stream = "stdout",
      stream = "stderr",
      ignore_exitcode = true,
      parser = function(output)
        local diagnostics = {}
        local ok, decoded = pcall(vim.json.decode, output)
        if not ok or type(decoded) ~= "table" then
          return diagnostics
        end

        for _, item in ipairs(decoded) do
          table.insert(diagnostics, {
            lnum = (item.line - 1) or 0,
            col = 0,
            message = item.message,
            severity = vim.diagnostic.severity.WARN,
            source = "dotenv-linter",
          })
        end
        return diagnostics
      end,
    }

    -- Create autocommand which carries out the actual linting on the specified events.
    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        -- Only run the linter in buffers that you can modify in order to
        -- avoid superfluous noise, notably within the handy LSP pop-ups that
        -- describe the hovered symbol using Markdown.
        if vim.bo.modifiable and vim.g.linting_enabled then
          lint.try_lint()
        end
      end,
    })

    -- Toggle all linting
    vim.api.nvim_create_user_command("ToggleLinting", function()
      vim.g.linting_enabled = not vim.g.linting_enabled
      local status = vim.g.linting_enabled and "enabled" or "disabled"
      vim.notify("Linting " .. status, vim.log.levels.INFO)
      if not vim.g.linting_enabled then
        vim.diagnostic.reset(nil, 0)
      else
        if vim.bo.modifiable then
          lint.try_lint()
        end
      end
    end, { desc = "Toggle all linting" })
  end,
}
