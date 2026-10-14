import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
NVIM = shutil.which("nvim")
DATA_HOME = Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local/share"))
LAZY_ROOT = DATA_HOME / "nvim/lazy"


@unittest.skipUnless(NVIM and (LAZY_ROOT / "lazy.nvim").is_dir(), "requires installed Neovim and Lazy")
class NvimBootstrapTest(unittest.TestCase):
    def test_failed_lazy_bootstrap_exits_without_waiting_for_keyboard_input(self):
        with tempfile.TemporaryDirectory(prefix="nvim-bootstrap-failure-") as directory:
            root = Path(directory)
            shutil.copytree(ROOT / "roles/editor/files/nvim", root / "config/nvim")
            (root / "bin").mkdir()
            git = root / "bin/git"
            git.write_text("#!/bin/bash\necho 'Clone failed' >&2\nexit 1\n")
            git.chmod(0o755)
            env = os.environ | {
                "PATH": str(root / "bin"),
                "XDG_CONFIG_HOME": str(root / "config"),
                "XDG_DATA_HOME": str(root / "data"),
                "XDG_STATE_HOME": str(root / "state"),
                "XDG_CACHE_HOME": str(root / "cache"),
                "NVIM_LOG_FILE": str(root / "nvim.log"),
            }
            env.pop("NVIM_APPNAME", None)
            result = subprocess.run(
                [NVIM, "--headless", "-u", "NONE", "-i", "NONE", "-c",
                 'lua require("config.upgrade").run("lazy")'],
                env=env, text=True, capture_output=True, timeout=3,
            )
            self.assertEqual(result.returncode, 1, result.stderr)
            self.assertIn("Clone failed", result.stderr)

    def test_maintenance_initializes_lazy_with_no_editor_plugins_or_handlers(self):
        with tempfile.TemporaryDirectory(prefix="nvim-bootstrap-test-") as directory:
            root = Path(directory)
            shutil.copytree(ROOT / "roles/editor/files/nvim", root / "config/nvim")
            (root / "data/nvim").mkdir(parents=True)
            (root / "data/nvim/lazy").symlink_to(LAZY_ROOT, target_is_directory=True)
            script = root / "bootstrap.lua"
            script.write_text('''
package.preload["lazy.manage"] = function()
  return { update = function(opts)
    assert(opts.wait and opts.show == false)
    local config = require("lazy.core.config")
    assert(vim.tbl_count(config.plugins) > 40, "Lazy was not initialized")
    assert(#config.spec.notifs == 0, vim.inspect(config.spec.notifs))
    vim.api.nvim_exec_autocmds("VimEnter", {})
    vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy" })
    vim.wait(100)
    for name, plugin in pairs(config.plugins) do
      if name ~= "lazy.nvim" then assert(not plugin._.loaded, name .. " loaded") end
    end
    for name, handler in pairs(require("lazy.core.handler").handlers) do
      assert(vim.tbl_isempty(handler.active), name .. " handler active")
    end
    print("PASS maintenance initialized Lazy without editor side effects")
  end }
end
local function completed_task() return { wait = function() return true end } end
package.preload["nvim-treesitter"] = function()
  return { setup = function() end, install = completed_task, update = completed_task }
end
require("config.upgrade").run("lazy")
''')
            env = os.environ | {
                "XDG_CONFIG_HOME": str(root / "config"),
                "XDG_DATA_HOME": str(root / "data"),
                "XDG_STATE_HOME": str(root / "state"),
                "XDG_CACHE_HOME": str(root / "cache"),
                "NVIM_LOG_FILE": str(root / "nvim.log"),
            }
            env.pop("NVIM_APPNAME", None)
            result = subprocess.run(
                [NVIM, "--headless", "-u", "NONE", "-i", "NONE", "-l", str(script)],
                env=env, text=True, capture_output=True, timeout=15,
            )
            output = result.stdout + result.stderr
            self.assertEqual(result.returncode, 0, output)
            self.assertIn("PASS maintenance initialized Lazy", output)


if __name__ == "__main__":
    unittest.main()
