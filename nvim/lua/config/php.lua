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

vim.keymap.set('n', '<leader>pr', function()
  vim.cmd 'write'
  local file = vim.fn.expand '%:p'
  local cfg = vim.fn.expand('~/.config/rector/rector.php')
  vim.notify('rector: ' .. file)
  vim.system(
    { 'rector', 'process', file, '--ansi', '--no-progress-bar', '--config=' .. cfg },
    { text = true, cwd = project_root() },
    function(res)
      vim.schedule(function()
        if res.code == 0 then
          vim.cmd 'checktime'
          vim.notify 'rector: done'
        else
          vim.notify((res.stderr or 'rector error'), vim.log.levels.ERROR)
        end
      end)
    end)
end, { desc = 'Rector: current file' })

-- PHPStan analysis
vim.keymap.set('n', '<leader>ps', function()
  local file = vim.fn.expand '%:p'
  local cfg = vim.fn.expand('~/.config/phpstan/phpstan.neon')
  vim.notify('PHPStan: analyzing ' .. file)
  vim.system(
    { 'phpstan', 'analyse', file, '--ansi', '--configuration=' .. cfg },
    { text = true, cwd = project_root() },
    function(res)
      vim.schedule(function()
        if res.code == 0 then
          vim.notify 'PHPStan: no errors found'
        else
          vim.notify((res.stdout or 'PHPStan found issues'), vim.log.levels.WARN)
        end
      end)
    end)
end, { desc = 'PHPStan: analyze current file' })

-- PHPCS check
vim.keymap.set('n', '<leader>pc', function()
  local file = vim.fn.expand '%:p'
  local cfg = vim.fn.expand('~/.config/phpcs/phpcs.xml')
  vim.notify('PHPCS: checking ' .. file)
  vim.system(
    { 'phpcs', '--standard=' .. cfg, file },
    { text = true, cwd = project_root() },
    function(res)
      vim.schedule(function()
        if res.code == 0 then
          vim.notify 'PHPCS: no issues found'
        else
          vim.notify((res.stdout or 'PHPCS found issues'), vim.log.levels.WARN)
        end
      end)
    end)
end, { desc = 'PHPCS: check current file' })

-- PHPStan analyze project
vim.keymap.set('n', '<leader>pS', function()
  local cfg = vim.fn.expand('~/.config/phpstan/phpstan.neon')
  vim.notify('PHPStan: analyzing project...')
  vim.system(
    { 'phpstan', 'analyse', '--ansi', '--configuration=' .. cfg },
    { text = true, cwd = project_root() },
    function(res)
      vim.schedule(function()
        if res.code == 0 then
          vim.notify 'PHPStan: no errors found in project'
        else
          vim.notify((res.stdout or 'PHPStan found issues in project'), vim.log.levels.WARN)
        end
      end)
    end)
end, { desc = 'PHPStan: analyze project' })

-- PHPCS check project
vim.keymap.set('n', '<leader>pC', function()
  local cfg = vim.fn.expand('~/.config/phpcs/phpcs.xml')
  vim.notify('PHPCS: checking project...')
  vim.system(
    { 'phpcs', '--standard=' .. cfg, '.' },
    { text = true, cwd = project_root() },
    function(res)
      vim.schedule(function()
        if res.code == 0 then
          vim.notify 'PHPCS: no issues found in project'
        else
          vim.notify((res.stdout or 'PHPCS found issues in project'), vim.log.levels.WARN)
        end
      end)
    end)
end, { desc = 'PHPCS: check project' })
