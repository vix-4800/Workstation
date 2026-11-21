import importlib.util
import os
import shutil
import subprocess
import sys
import tempfile
import tomllib
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ADOPT = ROOT / "roles/debian/scripts/adopt-config"
GIT_CONFIG = ROOT / "roles/editor/files/git/gitconfig"
CODEX_CONFIG = ROOT / "roles/ai-tools/files/codex/config.toml"


class ConfigAdoptionTest(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="debian-config-")
        self.addCleanup(temporary.cleanup)
        self.home = Path(temporary.name)

    def adopt(self, kind, source, destination):
        result = subprocess.run(  # noqa: S603
            [sys.executable, str(ADOPT), kind, str(source), str(destination)],
            cwd=self.home, text=True, capture_output=True, timeout=10, check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout.strip()

    @unittest.skipUnless(shutil.which("git"), "requires Git")
    def test_git_adopts_settings_without_replacing_existing_local_hooks(self):
        config = self.home / ".gitconfig"
        hooks = self.home / "custom-hooks"
        hooks.mkdir()
        existing = f"[core]\n\thooksPath = {hooks}\n[alias]\n\twhere = rev-parse --show-toplevel\n"
        config.write_text(existing)
        managed = self.home / ".gitconfig.workstation"
        managed.symlink_to(GIT_CONFIG)
        env = {key: value for key, value in os.environ.items() if not key.startswith("GIT_")}
        env.update(HOME=str(self.home), GIT_CONFIG_NOSYSTEM="1", GIT_CONFIG_GLOBAL=str(config))

        def git_config(key):
            return subprocess.check_output(  # noqa: S603
                ["git", "config", "--get-all", key], text=True, env=env, cwd=self.home,
            ).splitlines()

        self.assertEqual(self.adopt("git", managed, config), "changed")
        self.assertEqual(self.adopt("git", managed, config), "unchanged")
        self.assertEqual(git_config("core.hooksPath"), [str(hooks)])
        self.assertEqual(git_config("alias.where"), ["rev-parse --show-toplevel"])
        self.assertEqual(git_config("hook.php-lint.event"), ["pre-commit"])
        self.assertEqual(git_config("hook.secret-check.event"), ["pre-commit", "pre-push"])
        self.assertEqual(git_config("credential.https://github.com.helper")[-1],
                         "!/usr/bin/gh auth git-credential")
        backups = list(self.home.glob(".gitconfig.workstation-backup-*"))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(), existing)

    @unittest.skipUnless(shutil.which("git"), "requires Git")
    def test_git_runs_configured_and_local_precommit_hooks(self):
        git = shutil.which("git")
        reported_version = subprocess.check_output([git, "--version"], text=True).split()[2]  # noqa: S603
        if tuple(map(int, reported_version.split(".")[:2])) < (2, 54):
            self.skipTest("requires Git 2.54 config-based hook support")

        config = self.home / ".gitconfig"
        managed = self.home / ".gitconfig.workstation"
        managed.symlink_to(GIT_CONFIG)
        self.adopt("git", managed, config)
        repo = self.home / "repo"
        repo.mkdir()
        env = {key: value for key, value in os.environ.items() if not key.startswith("GIT_")}
        env.update(HOME=str(self.home), GIT_CONFIG_NOSYSTEM="1", GIT_CONFIG_GLOBAL=str(config))

        def run_git(*args):
            return subprocess.check_output(  # noqa: S603
                [git, *args], cwd=repo, env=env, text=True, stderr=subprocess.STDOUT, timeout=10,
            )

        run_git("init", "-q")
        hooks = self.home / "my-hooks"
        hooks.mkdir()
        run_git("config", "--local", "core.hooksPath", str(hooks))
        user_bin = self.home / ".local/bin"
        user_bin.mkdir(parents=True)
        for command in (user_bin / "check-staged-php", user_bin / "check-secrets", hooks / "pre-commit"):
            command.write_text(f"#!/bin/sh\nprintf '%s\\n' {command.name}\n")
            command.chmod(0o755)

        self.assertEqual(set(run_git("hook", "run", "pre-commit").splitlines()),
                         {"check-staged-php", "check-secrets", "pre-commit"})

    @unittest.skipUnless(importlib.util.find_spec("tomlkit"), "requires tomlkit")
    def test_codex_keeps_desktop_projects_and_node_repl_with_backup(self):
        codex = self.home / ".codex"
        codex.mkdir()
        config = codex / "config.toml"
        original = (
            'model = "old-model"\n[desktop]\nsetting = true\n'
            '[projects."/work/Example Project"]\ntrust_level = "trusted"\n'
            '[mcp_servers.node_repl]\ncommand = "/existing/node_repl"\n'
            '[mcp_servers.node_repl.env]\nNODE_REPL_HOME = "/existing/node"\n'
        )
        config.write_text(original)
        auth = codex / "auth.json"
        auth.write_text('{"example": "local auth"}')

        self.assertEqual(self.adopt("codex", CODEX_CONFIG, config), "changed")
        self.assertEqual(self.adopt("codex", CODEX_CONFIG, config), "unchanged")
        effective = tomllib.loads(config.read_text())
        local = tomllib.loads(original)
        base = tomllib.loads(CODEX_CONFIG.read_text())
        self.assertEqual(effective["desktop"], local["desktop"])
        self.assertEqual(effective["projects"], local["projects"])
        self.assertEqual(effective["mcp_servers"]["node_repl"], local["mcp_servers"]["node_repl"])
        self.assertEqual(effective["mcp_servers"]["playwright"], base["mcp_servers"]["playwright"])
        self.assertEqual(effective["model"], base["model"])
        self.assertEqual(auth.read_text(), '{"example": "local auth"}')
        backups = list(codex.glob("config.toml.workstation-backup-*"))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(), original)
        self.assertEqual(backups[0].stat().st_mode & 0o777, 0o600)

    def test_link_backs_up_existing_directory_and_applies_once(self):
        config = self.home / "nvim"
        config.mkdir()
        (config / "init.lua").write_text("local user_settings = true\n")
        managed = ROOT / "roles/editor/files/nvim"

        self.assertEqual(self.adopt("link", managed, config), "changed")
        self.assertEqual(self.adopt("link", managed, config), "unchanged")
        self.assertEqual(config.resolve(), managed)
        backups = list(self.home.glob("nvim.workstation-backup-*/nvim/init.lua"))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(), "local user_settings = true\n")

    def test_fish_legacy_managed_link_is_replaced_with_writable_directory(self):
        path = self.home / "fish"
        managed = ROOT / "roles/shell/files/fish"
        path.symlink_to(managed)

        self.assertEqual(self.adopt("directory", managed, path), "changed")
        self.assertEqual(self.adopt("directory", managed, path), "unchanged")
        self.assertTrue(path.is_dir())
        self.assertFalse(path.is_symlink())
        backup = list(self.home.glob("fish.workstation-backup-*/fish"))
        self.assertEqual([entry.resolve() for entry in backup], [managed])


if __name__ == "__main__":
    unittest.main()
