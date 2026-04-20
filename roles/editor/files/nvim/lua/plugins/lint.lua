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
      lua = { "luacheck" },
      sh = { "shellcheck" },
      bash = { "shellcheck" },
      dotenv = { "dotenv_linter" },
      javascript = { "eslint" },
      typescript = { "eslint" },
      javascriptreact = { "eslint" },
      typescriptreact = { "eslint" },
      vue = { "eslint" },
      css = { "stylelint" },
      scss = { "stylelint" },
      less = { "stylelint" },
      html = { "linthtml" },
      sql = { "sqlfluff" },
      nginx = { "nginx_lint" },
      make = { "checkmake" },
      ["yaml.ansible"] = { "ansible_lint" },
      xml = { "xmllint" },
    }

    -- Configure shellcheck to use custom config
    lint.linters.shellcheck.args = {
      "--format=json",
      "--rcfile=" .. configs.getConfig("shellcheck"),
      "-",
    }

    -- Configure luacheck to use custom config
    lint.linters.luacheck.args = {
      "--config",
      configs.getConfig("luacheck"),
      "--formatter",
      "plain",
      "--codes",
      function()
        return vim.api.nvim_buf_get_name(0)
      end,
    }
    lint.linters.luacheck.stdin = false

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
      args = { "--plain", "check", "--skip-updates", "$FILENAME" },
      stream = "stdout",
      ignore_exitcode = true,
      parser = function(output)
        local diagnostics = {}
        for line in output:gmatch("[^\r\n]+") do
          local _, lnum, check, message = line:match("^(.+):(%d+) ([%w_]+): (.+)$")
          if lnum then
            table.insert(diagnostics, {
              lnum = tonumber(lnum) - 1,
              col = 0,
              message = message .. " [" .. check .. "]",
              severity = vim.diagnostic.severity.WARN,
              source = "dotenv-linter",
            })
          end
        end
        return diagnostics
      end,
    }

    -- Configure ESLint to use global config
    lint.linters.eslint.args = {
      "--config",
      configs.getConfig("eslint"),
      "--format",
      "json",
      "--stdin",
      "--stdin-filename",
      function()
        return vim.api.nvim_buf_get_name(0)
      end,
    }

    -- Configure stylelint to use global config
    lint.linters.stylelint.args = {
      "--config",
      configs.getConfig("stylelint"),
      "--formatter",
      "json",
      "--stdin-filename",
      function()
        return vim.api.nvim_buf_get_name(0)
      end,
    }

    -- Configure linthtml (custom linter, not built into nvim-lint)
    lint.linters.linthtml = {
      cmd = "linthtml",
      stdin = false,
      args = {
        "--config",
        configs.getConfig("linthtml"),
        "--no-color",
        function()
          return vim.api.nvim_buf_get_name(0)
        end,
      },
      stream = "stdout",
      ignore_exitcode = true,
      parser = function(output)
        local diagnostics = {}
        for line in output:gmatch("[^\r\n]+") do
          local lnum, col, severity, message, rule =
            line:match("^%s*(%d+):(%d+)%s+(error|warning)%s+(.-)%s%s+(%S+)%s*$")
          if not lnum then
            lnum, col, severity, message, rule = line:match("^%s*(%d+):(%d+)%s+(%w+)%s+(.-)%s%s+(%S+)%s*$")
          end
          if lnum then
            table.insert(diagnostics, {
              lnum = tonumber(lnum) - 1,
              col = tonumber(col) - 1,
              message = vim.trim(message) .. " [" .. rule .. "]",
              severity = severity == "error" and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN,
              source = "linthtml",
            })
          end
        end
        return diagnostics
      end,
    }

    -- Configure jsonlint
    lint.linters.jsonlint.args = {
      "--config",
      configs.getConfig("jsonlintrc"),
      "--compact",
      "--quiet",
    }

    -- Configure sqlfluff to use global config
    lint.linters.sqlfluff.args = {
      "lint",
      "--config",
      configs.getConfig("sqlfluff"),
      "--format",
      "json",
      "--dialect",
      "mysql",
      "-",
    }

    -- Configure checkmake
    lint.linters.checkmake.args = {
      "--config=" .. configs.getConfig("checkmake"),
      "--format={{.LineNumber}}:{{.Rule}}:{{.Violation}}\n",
    }
    lint.linters.checkmake.stdin = false

    -- Configure nginx-lint
    lint.linters.nginx_lint = {
      cmd = "nginx-lint",
      stdin = false,
      args = {
        "--format",
        "json",
        "--no-color",
        "--config",
        configs.getConfig("nginx_lint"),
        function()
          return vim.api.nvim_buf_get_name(0)
        end,
      },
      stream = "stdout",
      ignore_exitcode = true,
      parser = function(output)
        local diagnostics = {}
        local ok, decoded = pcall(vim.json.decode, output)
        if not ok or type(decoded) ~= "table" or type(decoded.errors) ~= "table" then
          return diagnostics
        end

        for _, item in ipairs(decoded.errors) do
          local line = tonumber(item.line) or 1
          local column = tonumber(item.column) or 1
          local severity = item.severity == "Error" and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN
          local rule = item.category and item.rule and (" [" .. item.category .. "/" .. item.rule .. "]") or ""

          table.insert(diagnostics, {
            lnum = line - 1,
            col = column - 1,
            message = item.message .. rule,
            severity = severity,
            source = "nginx-lint",
          })
        end
        return diagnostics
      end,
    }

    -- Configure ansible-lint
    lint.linters.ansible_lint.args = {
      "-c",
      configs.getConfig("ansible_lint"),
      "--format",
      "json",
      "--nocolor",
      "-f",
      function()
        return vim.api.nvim_buf_get_name(0)
      end,
    }

    -- Configure xmllint (custom linter using libxml2)
    lint.linters.xmllint = {
      cmd = "xmllint",
      stdin = true,
      args = { "--noout", "-" },
      stream = "stderr",
      ignore_exitcode = true,
      parser = function(output)
        local diagnostics = {}
        for line in output:gmatch("[^\r\n]+") do
          local lnum, msg = line:match("^%-:(%d+):%s*(.*)")
          if lnum and msg then
            table.insert(diagnostics, {
              lnum = tonumber(lnum) - 1,
              col = 0,
              message = msg,
              severity = vim.diagnostic.severity.ERROR,
              source = "xmllint",
            })
          end
        end
        return diagnostics
      end,
    }

    -- Configure editorconfig-checker (runs on all filetypes)
    lint.linters.editorconfig_checker = {
      cmd = "editorconfig-checker",
      stdin = false,
      args = {
        "--no-color",
        "--config",
        configs.getConfig("editorconfig_checker"),
        function()
          return vim.api.nvim_buf_get_name(0)
        end,
      },
      stream = "stdout",
      ignore_exitcode = true,
      parser = function(output)
        local diagnostics = {}
        for line in output:gmatch("[^\r\n]+") do
          local lnum, msg = line:match("^\t(%d+): (.+)")
          if lnum and msg then
            table.insert(diagnostics, {
              lnum = tonumber(lnum) - 1,
              col = 0,
              message = msg,
              severity = vim.diagnostic.severity.WARN,
              source = "editorconfig-checker",
            })
          end
        end
        return diagnostics
      end,
    }

    -- Conditional actionlint for GitHub Actions workflow files
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
      pattern = { "*.yml", "*.yaml" },
      callback = function()
        local path = vim.fn.expand("%:p")
        if path:match("%.github/workflows/") then
          lint.try_lint({ "actionlint" })
        end
      end,
    })

    -- Filetypes with heavy linters that should only run on save
    local heavy_fts = { php = true, sql = true, ["yaml.ansible"] = true }

    -- Create autocommands for linting
    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    -- All filetypes: lint on save
    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      group = lint_augroup,
      callback = function()
        if vim.bo.modifiable and vim.g.linting_enabled then
          lint.try_lint(get_active_linters())
          -- Run editorconfig-checker on all file types
          if not disabled_linters["editorconfig_checker"] then
            lint.try_lint({ "editorconfig_checker" })
          end
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
        if not choice or not idx then
          return
        end
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
