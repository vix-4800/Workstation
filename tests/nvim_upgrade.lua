vim.opt.rtp:prepend(vim.fn.getcwd() .. "/roles/editor/files/nvim")

local upgrade = require("config.upgrade")
local tests = 0
local function test(name, callback)
  callback()
  tests = tests + 1
  print("PASS " .. name)
end

test("Lazy waits and reports plugin failures", function()
  local completed = false
  local plugin = { _ = { tasks = {} } }
  package.loaded["lazy.core.config"] = { plugins = { example = plugin }, spec = { notifs = {} } }
  package.loaded["lazy.manage"] = {
    update = function(opts)
      assert(opts.wait and opts.show == false)
      completed = true
      plugin._.tasks = { {
        has_errors = function()
          return true
        end,
      } }
    end,
  }
  local ok, err = pcall(upgrade.lazy)
  assert(completed)
  assert(not ok and tostring(err):find("example", 1, true), tostring(err))
end)

test("Lazy reports success when all plugin tasks succeed", function()
  package.loaded["lazy.core.config"] = { plugins = {}, spec = { notifs = {} } }
  package.loaded["lazy.manage"] = { update = function() end }
  upgrade.lazy()
end)

local function mason_registry(fail_package, refresh_success)
  local completed = {}
  local packages = {}
  for _, name in ipairs({ "lua-language-server", "prettier" }) do
    packages[#packages + 1] = {
      name = name,
      is_installing = function()
        return false
      end,
      get_latest_version = function()
        return "2.0"
      end,
      get_installed_version = function()
        return "1.0"
      end,
      install = function(_, opts, callback)
        assert(opts.version == "2.0")
        vim.defer_fn(function()
          completed[name] = true
          callback(name ~= fail_package, name == fail_package and "download failed" or nil)
        end, 10)
      end,
    }
  end
  package.loaded["mason"] = { setup = function() end }
  package.loaded["mason-registry"] = {
    update = function(callback)
      vim.defer_fn(function()
        callback(refresh_success ~= false, {})
      end, 10)
    end,
    get_installed_packages = function()
      return packages
    end,
    get_installed_package_names = function()
      return { "lua-language-server", "prettier" }
    end,
    get_package = function(name)
      for _, package in ipairs(packages) do
        if package.name == name then
          return package
        end
      end
      error("Package not found: " .. name)
    end,
  }
  return completed
end

test("Mason waits for every installed package, including manually installed tools", function()
  local completed = mason_registry()
  upgrade.mason()
  assert(completed["lua-language-server"] and completed.prettier)
end)

test("Mason reports failed downloads after the remaining packages finish", function()
  local completed = mason_registry("prettier")
  local ok, err = pcall(upgrade.mason)
  assert(not ok and tostring(err):find("prettier", 1, true), tostring(err))
  assert(completed["lua-language-server"] and completed.prettier)
end)

test("Mason rejects a failed registry refresh", function()
  local completed = mason_registry(nil, false)
  local ok, err = pcall(upgrade.mason)
  assert(not ok and tostring(err):find("registry", 1, true), tostring(err))
  assert(next(completed) == nil)
end)

test("Mason reports an orphan package while updating healthy packages", function()
  local completed = mason_registry()
  local registry = package.loaded["mason-registry"]
  registry.get_installed_package_names = function()
    return { "removed-tool", "lua-language-server", "prettier" }
  end
  registry.get_installed_packages = function()
    error("Package not found: removed-tool")
  end
  local ok, err = pcall(upgrade.mason)
  assert(not ok and tostring(err):find("removed-tool", 1, true), tostring(err))
  assert(completed["lua-language-server"] and completed.prettier)
end)

local function parser_update(install_success, update_success)
  package.loaded["lazy.core.config"] = {
    plugins = { ["nvim-treesitter"] = { dir = "/tmp", _ = { tasks = {} } } },
    spec = { notifs = {} },
  }
  package.loaded["lazy.manage"] = { update = function() end }
  package.loaded["lazy.core.plugin"] = {
    values = function()
      return { ensure_installed = { "lua" } }
    end,
  }
  local finished = {}
  local function task(name, success)
    vim.defer_fn(function()
      finished[name] = true
    end, 10)
    return {
      wait = function(_, timeout)
        assert(vim.wait(timeout, function()
          return finished[name]
        end, 1))
        return success
      end,
    }
  end
  package.loaded["nvim-treesitter"] = {
    setup = function() end,
    install = function()
      return task("install", install_success)
    end,
    update = function()
      return task("update", update_success)
    end,
  }
  return finished
end

test("Lazy waits for parser installation and updates", function()
  local finished = parser_update(true, true)
  upgrade.lazy()
  assert(finished.install and finished.update)
end)

test("Lazy reports failed parser installation", function()
  parser_update(false, true)
  local ok, err = pcall(upgrade.lazy)
  assert(not ok and tostring(err):find("Treesitter installation failed", 1, true), tostring(err))
end)

test("Lazy reports failed parser update", function()
  parser_update(true, false)
  local ok, err = pcall(upgrade.lazy)
  assert(not ok and tostring(err):find("Treesitter update failed", 1, true), tostring(err))
end)

print(tests .. " tests passed")
