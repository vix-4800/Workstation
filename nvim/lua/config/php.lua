local function project_root()
  local uv = vim.loop
  local function exists(p)
    return p and uv.fs_stat(p) ~= nil
  end
  local dir = vim.fn.expand '%:p:h'
  while dir and #dir > 1 do
    if exists(dir .. '/.git') or exists(dir .. '/composer.json') then
      return dir
    end
    dir = dir:match '(.*)/[^/]+$'
  end
  return vim.fn.getcwd()
end

vim.keymap.set('n', '<leader>pf', function()
  vim.cmd 'write'
  local file = vim.fn.expand '%:p'
  local cfg = vim.fn.expand '~/.config/php-cs-fixer/php-cs-fixer.php'
  vim.notify('php-cs-fixer: ' .. file)
  vim.system({ 'php-cs-fixer', 'fix', file, '--config=' .. cfg }, { text = true, cwd = project_root() }, function(res)
    vim.schedule(function()
      if res.code == 0 then
        vim.cmd 'checktime'
        vim.notify 'php-cs-fixer: done'
      else
        vim.notify((res.stderr or 'php-cs-fixer error'), vim.log.levels.ERROR)
      end
    end)
  end)
end, { desc = 'PHP CS Fixer: current file' })
