local icons = require("config.icons")

local function project_root()
  local uv = vim.uv
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
