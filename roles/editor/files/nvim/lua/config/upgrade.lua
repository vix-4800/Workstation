local M = {}
local timeout_ms = 600000

function M.lazy()
  require("lazy.manage").update({ wait = true, show = false })
  local config = require("lazy.core.config")
  for _, notice in ipairs(config.spec.notifs) do
    assert(notice.level < vim.log.levels.ERROR, notice.msg)
  end
  for name, plugin in pairs(config.plugins) do
    for _, task in ipairs(plugin._.tasks or {}) do
      assert(not task:has_errors(), "Lazy update failed: " .. name)
    end
  end

  local plugin = config.plugins["nvim-treesitter"]
  if plugin then
    vim.opt.rtp:prepend(plugin.dir)
    local treesitter = require("nvim-treesitter")
    treesitter.setup({ install_dir = vim.fn.stdpath("data") .. "/site" })
    local opts = require("lazy.core.plugin").values(plugin, "opts", false)
    assert(treesitter.install(opts.ensure_installed):wait(timeout_ms), "Treesitter installation failed")
    assert(treesitter.update():wait(timeout_ms), "Treesitter update failed")
  end
end

function M.mason()
  local config = package.loaded["lazy.core.config"]
  if config and config.plugins["mason.nvim"] then
    vim.opt.rtp:prepend(config.plugins["mason.nvim"].dir)
  end
  require("mason").setup()
  local registry = require("mason-registry")
  local refreshed
  registry.update(function(success)
    refreshed = success
  end)
  assert(
    vim.wait(timeout_ms, function()
      return refreshed ~= nil
    end, 100),
    "Mason registry refresh timed out"
  )
  assert(refreshed, "Mason registry refresh failed")

  local pending = 0
  local failures = {}
  for _, name in ipairs(registry.get_installed_package_names()) do
    pending = pending + 1
    local function complete(success, result)
      if not success then
        failures[#failures + 1] = name .. ": " .. tostring(result)
      end
      pending = pending - 1
    end
    local ok, err = pcall(function()
      local package = registry.get_package(name)
      assert(not package:is_installing(), "installation is already running")
      local latest = package:get_latest_version()
      if latest == package:get_installed_version() then
        complete(true)
      else
        package:install({ version = latest }, vim.schedule_wrap(complete))
      end
    end)
    if not ok then
      complete(false, err)
    end
  end
  assert(
    vim.wait(timeout_ms, function()
      return pending == 0
    end, 100),
    "Mason package updates timed out"
  )
  assert(#failures == 0, "Mason updates failed: " .. table.concat(failures, "; "))
end

function M.run(manager)
  local ok, err = xpcall(function()
    assert(manager == "lazy" or manager == "mason", "Unknown Neovim package manager")
    vim.g.workstation_upgrade = true
    require("config.options")
    require("config.lazy")
    M[manager]()
  end, debug.traceback)
  if not ok then
    io.stderr:write(tostring(err) .. "\n")
    vim.cmd("cquit 1")
  else
    vim.cmd("qa!")
  end
end

return M
