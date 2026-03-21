local configs = require("config.linter-configs")

return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local lint = require("lint")

    -- Global linting state
    vim.g.linting_enabled = true

    -- Per-linter disabled state (linter name -> true if disabled)
    local disabled_linters = {}

    -- Returns active linters for current buffer's filetype, minus disabled ones
    local function get_active_linters()
      local ft = vim.bo.filetype
      local all = lint.linters_by_ft[ft] or {}
      return vim.tbl_filter(function(l)
        return not disabled_linters[l]
      end, all)
    end

    lint.linters_by_ft = {
      markdown = { "markdownlint" },
      php = { "phpstan", "phpcs", "phpmd" },
      dockerfile = { "hadolint" },
      json = { "jsonlint" },
      yaml = { "yamllint" },
      python = { "ruff" },
      sh = { "shellcheck" },
      bash = { "shellcheck" },
      dotenv = { "dotenv_linter" },
      javascript = {},
      typescript = {},
    }

    -- Configure shellcheck to use custom config
    lint.linters.shellcheck.args = {
      "--format=json",
      "--rcfile=" .. configs.getConfig("shellcheck"),
      "-",
    }

    -- Configure yamllint to use custom config
    lint.linters.yamllint.args = {
      "--format",
      "parsable",
      "--config-file=" .. configs.getConfig("yamllint"),
      "-",
    }

    -- Configure hadolint to use custom config
    lint.linters.hadolint.args = {
      "--config",
      configs.getConfig("hadolint"),
      "--format",
      "json",
      "-",
    }

    -- Configure markdownlint to use custom config
    lint.linters.markdownlint.args = {
      "--config",
      configs.getConfig("markdownlint"),
      "--json",
      "--stdin",
    }

    -- Configure ruff to use custom config
    lint.linters.ruff.args = {
      "check",
      "--config=" .. configs.getConfig("ruff"),
      "--force-exclude",
      "--quiet",
      "--stdin-filename",
      function()
        return vim.api.nvim_buf_get_name(0)
      end,
      "--output-format",
      "json",
      "-",
    }

    -- Configure phpstan to use custom config
    lint.linters.phpstan = lint.linters.phpstan or {}
    lint.linters.phpstan.cmd = vim.fn.expand("~/.config/composer/vendor/bin/phpstan")
    lint.linters.phpstan.args = {
      "analyse",
      "--error-format=json",
      "--no-progress",
      "--memory-limit=2G",
      "--configuration=" .. configs.getConfig("phpstan"),
      function()
        return vim.api.nvim_buf_get_name(0)
      end,
    }

    -- Configure phpcs to use custom config
    lint.linters.phpcs.cmd = vim.fn.expand("~/.config/composer/vendor/bin/phpcs")
    lint.linters.phpcs.args = {
      "--standard=" .. configs.getConfig("phpcs"),
      "--report=json",
      "--ignore=*/vendor/*",
      "--parallel=4",
      "--no-cache",
      "--extensions=php",
      "-q",
      function()
        return vim.api.nvim_buf_get_name(0)
      end,
    }
    lint.linters.phpcs.stdin = false

    -- Configure phpmd to use custom config
    lint.linters.phpmd = lint.linters.phpmd or {}
    lint.linters.phpmd.cmd = vim.fn.expand("~/.config/composer/vendor/bin/phpmd")
    lint.linters.phpmd.args = {
      function()
        return vim.api.nvim_buf_get_name(0)
      end,
      "json",
      configs.getConfig("phpmd"),
    }
    lint.linters.phpmd.stdin = false

    -- Dotenv-linter configuration
    lint.linters["dotenv_linter"] = {
      cmd = "dotenv-linter",
      stdin = false,
      args = { "check", "--format", "json", "$FILENAME" },
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

    -- Filetypes with heavy linters that should only run on save
    local heavy_fts = { php = true }

    -- Create autocommands for linting
    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    -- All filetypes: lint on save
    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      group = lint_augroup,
      callback = function()
        if vim.bo.modifiable and vim.g.linting_enabled then
          lint.try_lint(get_active_linters())
        end
      end,
    })

    -- Light filetypes only: lint on enter and insert leave
    vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        if vim.bo.modifiable and vim.g.linting_enabled and not heavy_fts[vim.bo.filetype] then
          lint.try_lint(get_active_linters())
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
          lint.try_lint(get_active_linters())
        end
      end
    end, { desc = "Toggle all linting" })

    -- Toggle individual linter by name
    vim.api.nvim_create_user_command("ToggleLinter", function(opts)
      local name = opts.args
      if name == "" then
        vim.notify("Usage: ToggleLinter <linter-name>", vim.log.levels.WARN)
        return
      end
      if disabled_linters[name] then
        disabled_linters[name] = nil
        vim.notify("Linter enabled: " .. name, vim.log.levels.INFO)
        if vim.bo.modifiable and vim.g.linting_enabled then
          lint.try_lint(get_active_linters())
        end
      else
        disabled_linters[name] = true
        vim.notify("Linter disabled: " .. name, vim.log.levels.INFO)
        vim.diagnostic.reset(nil, 0)
        if vim.bo.modifiable and vim.g.linting_enabled then
          lint.try_lint(get_active_linters())
        end
      end
    end, {
      nargs = 1,
      complete = function()
        local ft = vim.bo.filetype
        return lint.linters_by_ft[ft] or {}
      end,
      desc = "Toggle individual linter",
    })

    -- Interactive picker: toggle linters for the current filetype
    vim.keymap.set("n", "<leader>tl", function()
      local ft = vim.bo.filetype
      local linters = lint.linters_by_ft[ft] or {}
      if vim.tbl_isempty(linters) then
        vim.notify("No linters configured for filetype: " .. ft, vim.log.levels.INFO)
        return
      end
      local items = vim.tbl_map(function(l)
        local state = disabled_linters[l] and "[ ]" or "[x]"
        return state .. " " .. l
      end, linters)
      vim.ui.select(items, {
        prompt = "Toggle linter (" .. ft .. "):",
      }, function(choice, idx)
        if not choice or not idx then return end
        local name = linters[idx]
        if disabled_linters[name] then
          disabled_linters[name] = nil
          vim.notify("Linter enabled: " .. name, vim.log.levels.INFO)
        else
          disabled_linters[name] = true
          vim.notify("Linter disabled: " .. name, vim.log.levels.INFO)
        end
        vim.diagnostic.reset(nil, 0)
        if vim.bo.modifiable and vim.g.linting_enabled then
          lint.try_lint(get_active_linters())
        end
      end)
    end, { desc = "[T]oggle [L]inter (picker)" })
  end,
}
