import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

try:
    import yaml
except ImportError:
    yaml = None


ROOT = Path(__file__).resolve().parents[1]
ADOPT = ROOT / "roles/debian/scripts/adopt-config"
GIT_CONFIG = ROOT / "roles/editor/files/git/gitconfig"
ANSIBLE = shutil.which("ansible-playbook")


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
    def test_git_runs_configured_and_local_precommit_hooks(self):
        git = shutil.which("git")
        reported_version = subprocess.check_output([git, "--version"], text=True).split()[2]  # noqa: S603
        if tuple(map(int, reported_version.split(".")[:2])) < (2, 54):
            self.skipTest("requires Git 2.54 config-based hook support")

        config = self.home / ".gitconfig"
        self.adopt("link", GIT_CONFIG, config)
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

    @unittest.skipUnless(ANSIBLE and yaml, "requires ansible-playbook and PyYAML")
    def test_deployed_editor_and_codex_settings_write_through_to_repository(self):
        repo = self.home / "repo"
        for role in ("editor", "ai-tools"):
            shutil.copytree(ROOT / f"roles/{role}/files", repo / f"roles/{role}/files")
        config_home = self.home / "config with spaces"
        settings = config_home / "Code/User/settings.json"
        codex = self.home / ".codex/config.toml"
        originals = {
            self.home / ".gitconfig": "[alias]\nlocal-only = status\n",
            settings: '{"editor.tabSize": 8}\n', codex: "[desktop]\nsetting = true\n",
        }
        for path, content in originals.items():
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(content)
        auth = self.home / ".codex/auth.json"
        auth.write_text('{"example": "local auth"}')

        editor = yaml.safe_load((ROOT / "roles/debian/tasks/editor.yml").read_text())
        ai = yaml.safe_load((ROOT / "roles/debian/tasks/ai_tools.yml").read_text())
        codex_tasks = next(
            task["block"] for task in ai if task["name"] == "Deploy Codex configuration with local backups"
        )
        tasks = [task for task in editor if task["name"] in {
            "Link editor configuration and hook scripts with local backups",
            "Deploy Visual Studio Code settings with local tool paths",
        }]
        tasks += [task for task in codex_tasks if task["name"] in {
            "Adopt the shared Codex settings", "Link Codex assets and shared instructions",
        }]
        variables = yaml.safe_load((ROOT / "roles/ai-tools/defaults/main.yml").read_text())
        variables.update(yaml.safe_load((ROOT / "roles/debian/vars/editor.yml").read_text()))
        variables.update({
            "home": str(self.home), "dotfiles_dir": str(repo),
            "debian_config_home": str(config_home),
            "debian_config_adopt_script": str(ADOPT), "debian_ai_adopt_script": str(ADOPT),
            "debian_editor_scripts": str(ROOT / "roles/editor/scripts"),
            "debian_ai_files": str(repo / "roles/ai-tools/files"),
        })
        playbook = self.home / "deploy.yml"
        playbook.write_text(yaml.safe_dump([{
            "hosts": "localhost", "gather_facts": False, "vars": variables, "tasks": tasks,
        }]))
        env = os.environ | {
            "ANSIBLE_CONFIG": str(ROOT / "ansible.cfg"),
            "ANSIBLE_HOME": str(self.home / "ansible"), "ANSIBLE_NOCOLOR": "1",
            "ANSIBLE_REMOTE_TMP": str(self.home / "ansible-remote"),
        }
        for run in range(2):
            result = subprocess.run(  # noqa: S603 - Test-controlled executable, playbook and arguments.
                [ANSIBLE, "-i", "localhost,", "-c", "local", str(playbook)],
                cwd=self.home, env=env, text=True, capture_output=True, timeout=90, check=False,
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            if run == 1:
                self.assertRegex(result.stdout, r"changed=0\b")

        for destination, source in (
            (self.home / ".gitconfig", repo / "roles/editor/files/git/gitconfig"),
            (settings, repo / "roles/editor/files/code/User/settings.json"),
            (codex, repo / "roles/ai-tools/files/codex/config.toml"),
        ):
            with self.subTest(destination=destination.name):
                self.assertTrue(destination.is_symlink())
                self.assertEqual(destination.resolve(), source)
                self.assertEqual(source.read_bytes(), (ROOT / source.relative_to(repo)).read_bytes())
                backups = list(destination.parent.glob(f"{destination.name}.workstation-backup-*/{destination.name}"))
                self.assertEqual(len(backups), 1)
                self.assertEqual(backups[0].read_text(), originals[destination])
                marker = "\n// local edit\n" if destination == settings else "\n# local edit\n"
                destination.write_text(destination.read_text() + marker)
                self.assertTrue(source.read_text().endswith(marker))
        self.assertEqual(auth.read_text(), '{"example": "local auth"}')

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
