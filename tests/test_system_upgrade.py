import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "roles/shell/files/fish/functions/system-upgrade.fish"


class SystemUpgradeTest(unittest.TestCase):
    def run_upgrade(self, *, failure="", installed=True, configured=True):
        with tempfile.TemporaryDirectory(prefix="system-upgrade-test-") as directory:
            root = Path(directory)
            binary = root / "bin"
            binary.mkdir()
            log = root / "nvim.log"
            for name, body in {
                "uname": "echo test-kernel",
                "fish": "echo 'fish, version 4.0.0'",
                "pacman": 'case "$1" in -Qoq) exit 1;; esac',
                "sudo": 'exec "$@"',
            }.items():
                path = binary / name
                path.write_text("#!/bin/bash\n" + body + "\n")
                path.chmod(0o755)
            if installed:
                path = binary / "nvim"
                path.write_text(
                    '#!/bin/bash\n'
                    'printf "%s\\n" "$*" >> "$NVIM_TEST_LOG"\n'
                    'if [[ -n "$NVIM_TEST_FAILURE" && "$*" == *"$NVIM_TEST_FAILURE"* ]]; then exit 1; fi\n'
                )
                path.chmod(0o755)
            if configured:
                config = root / "config/nvim/lua/config/upgrade.lua"
                config.parent.mkdir(parents=True)
                config.touch()
            env = os.environ | {
                "PATH": str(binary),
                "XDG_CONFIG_HOME": str(root / "config"),
                "NVIM_TEST_LOG": str(log),
                "NVIM_TEST_FAILURE": failure,
            }
            env.pop("NVIM_APPNAME", None)
            result = subprocess.run(
                ["/usr/bin/fish", "--no-config", "-c", f"source '{SCRIPT}'; system-upgrade"],
                env=env, text=True, capture_output=True, timeout=15,
            )
            return result, log.read_text().splitlines() if log.exists() else []

    def test_updates_both_managers_without_editor_startup(self):
        result, calls = self.run_upgrade()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(calls), 2)
        self.assertIn('run("lazy")', calls[0])
        self.assertIn('run("mason")', calls[1])
        for call in calls:
            self.assertIn("--headless", call)
            self.assertIn("-u NONE", call)
            self.assertIn("-i NONE", call)

    def test_manager_failure_is_reported_and_other_manager_still_runs(self):
        for manager in ("lazy", "mason"):
            with self.subTest(manager=manager):
                result, calls = self.run_upgrade(failure=manager)
                self.assertEqual(result.returncode, 1)
                self.assertEqual(len(calls), 2)
                self.assertIn("1 update step(s) failed", result.stdout)

    def test_missing_neovim_is_skipped(self):
        result, calls = self.run_upgrade(installed=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls, [])

    def test_missing_configuration_is_skipped(self):
        result, calls = self.run_upgrade(configured=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls, [])


if __name__ == "__main__":
    unittest.main()
