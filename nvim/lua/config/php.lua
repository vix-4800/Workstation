local icons = require("config.icons")

local function project_root()
  local uv = vim.loop
  local function exists(p)
    return p and uv.fs_stat(p) ~= nil
  end
  local dir = vim.fn.expand("%:p:h")
  while dir and #dir > 1 do
    if exists(dir .. "/.git") or exists(dir .. "/composer.json") then
      return dir
    end
    dir = dir:match("(.*)/[^/]+$")
  end
  return vim.fn.getcwd()
end

-- ╭─────────────────────────────────────────────────────────────────────╮
-- │                           PHP Code Actions                          │
-- ╰─────────────────────────────────────────────────────────────────────╯
-- Rector: refactor current file
vim.keymap.set("n", "<leader>cpr", function()
  vim.cmd("write")
  local file = vim.fn.expand("%:p")
  local cfg = vim.fn.expand("~/.config/rector/rector.php")
  vim.notify(icons.notifications.rector_start .. " Rector: refactoring " .. vim.fn.expand("%:t"))
  vim.system(
    { "rector", "process", file, "--ansi", "--no-progress-bar", "--config=" .. cfg },
    { text = true, cwd = project_root() },
    function(res)
      vim.schedule(function()
        if res.code == 0 then
          vim.cmd("checktime")
          vim.notify(icons.notifications.success .. " Rector: refactoring completed")
        else
          vim.notify(icons.notifications.error .. " Rector: " .. (res.stderr or "error"), vim.log.levels.ERROR)
        end
      end)
    end
  )
end, { desc = "[R]efactor PHP file (Rector)" })

-- PHPStan: analyze current file
vim.keymap.set("n", "<leader>cps", function()
  local file = vim.fn.expand("%:p")
  local cfg = vim.fn.expand("~/.config/phpstan/phpstan.neon")
  vim.notify(icons.notifications.phpstan_start .. " PHPStan: analyzing " .. vim.fn.expand("%:t"))
  vim.system(
    { "phpstan", "analyse", file, "--ansi", "--configuration=" .. cfg },
    { text = true, cwd = project_root() },
    function(res)
      vim.schedule(function()
        if res.code == 0 then
          vim.notify(icons.notifications.success .. " PHPStan: no errors found")
        else
          vim.notify(icons.notifications.warning .. " PHPStan: found issues", vim.log.levels.WARN)
        end
      end)
    end
  )
end, { desc = "[S]tatic analysis PHP file (PHPStan)" })

-- PHPCS: check current file
vim.keymap.set("n", "<leader>cpc", function()
  local file = vim.fn.expand("%:p")
  local cfg = vim.fn.expand("~/.config/phpcs/phpcs.xml")
  vim.notify(icons.notifications.phpcs_start .. " PHPCS: checking " .. vim.fn.expand("%:t"))
  vim.system({ "phpcs", "--standard=" .. cfg, file }, { text = true, cwd = project_root() }, function(res)
    vim.schedule(function()
      if res.code == 0 then
        vim.notify(icons.notifications.success .. " PHPCS: no issues found")
      else
        vim.notify(icons.notifications.warning .. " PHPCS: found coding standard issues", vim.log.levels.WARN)
      end
    end)
  end)
end, { desc = "[C]heck PHP coding standards (PHPCS)" })

-- PHPStan: analyze entire project
vim.keymap.set("n", "<leader>cpS", function()
  local cfg = vim.fn.expand("~/.config/phpstan/phpstan.neon")
  vim.notify(icons.notifications.phpstan_start .. " PHPStan: analyzing entire project...")
  vim.system(
    { "phpstan", "analyse", "--ansi", "--configuration=" .. cfg },
    { text = true, cwd = project_root() },
    function(res)
      vim.schedule(function()
        if res.code == 0 then
          vim.notify(icons.notifications.success .. " PHPStan: no errors found in project")
        else
          vim.notify(icons.notifications.warning .. " PHPStan: found issues in project", vim.log.levels.WARN)
        end
      end)
    end
  )
end, { desc = "[S]tatic analysis entire project (PHPStan)" })

-- PHPCS: check entire project
vim.keymap.set("n", "<leader>cpC", function()
  local cfg = vim.fn.expand("~/.config/phpcs/phpcs.xml")
  vim.notify(icons.notifications.phpcs_start .. " PHPCS: checking entire project...")
  vim.system({ "phpcs", "--standard=" .. cfg, "." }, { text = true, cwd = project_root() }, function(res)
    vim.schedule(function()
      if res.code == 0 then
        vim.notify(icons.notifications.success .. " PHPCS: no issues found in project")
      else
        vim.notify(icons.notifications.warning .. " PHPCS: found coding standard issues in project", vim.log.levels.WARN)
      end
    end)
  end)
end, { desc = "[C]heck project coding standards (PHPCS)" })
