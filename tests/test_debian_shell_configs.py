import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

try:
    import yaml
except ImportError:
    yaml = None


ROOT = Path(__file__).resolve().parents[1]
ANSIBLE = shutil.which("ansible-playbook")
FISH = shutil.which("fish")


class DebianShellConfigTest(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="debian-shell-")
        self.addCleanup(temporary.cleanup)
        self.home = Path(temporary.name)

    @unittest.skipUnless(FISH, "requires Fish")
    def test_update_upgrades_packages_only_after_successful_index_refresh(self):
        binary = self.home / "bin"
        binary.mkdir()
        sudo = binary / "sudo"
        sudo.write_text(
            '#!/bin/sh\nprintf "%s\\n" "$*" >> "$COMMAND_LOG"\n'
            'if [ "$*" = "apt update" ]; then exit "${UPDATE_STATUS:-0}"; fi\n'
        )
        sudo.chmod(0o755)
        log = self.home / "commands"
        for status, expected in ((0, ["apt update", "apt upgrade"]), (7, ["apt update"])):
            with self.subTest(update_status=status):
                log.write_text("")
                result = subprocess.run(  # noqa: S603 - Test-controlled shell and source; sudo is a local recorder.
                    [FISH, "--no-config", "--interactive", "--command", 'source "$argv[1]"; update',
                     "--", str(ROOT / "roles/debian/files/workstation.fish")],
                    env=os.environ | {
                        "HOME": str(self.home), "XDG_CONFIG_HOME": str(self.home / "config"),
                        "XDG_DATA_HOME": str(self.home / "data"), "TERM": "xterm-256color",
                        "PATH": f"{binary}:/usr/bin:/bin", "COMMAND_LOG": str(log), "UPDATE_STATUS": str(status),
                    },
                    text=True, capture_output=True, timeout=10, check=False,
                )
                self.assertEqual(result.returncode, status, result.stderr)
                self.assertEqual(log.read_text().splitlines(), expected)

    @unittest.skipUnless(ANSIBLE and FISH and yaml, "requires Ansible, Fish and PyYAML")
    def test_shell_configs_are_linked_with_local_backups_and_shared_kitty_defaults(self):
        repo = self.home / "repo"
        for directory in ("shell/files", "debian/files", "debian/scripts", "base/files",
                          "appearance/files/bat", "appearance/files/btop"):
            shutil.copytree(ROOT / "roles" / directory, repo / "roles" / directory)
        config_home = self.home / "config with spaces"
        fish = config_home / "fish/conf.d/99-workstation.fish"
        kitty = config_home / "kitty/kitty.conf"
        originals = {fish: "set -g local_setting yes\n", kitty: "font_size 18\n"}
        for path, content in originals.items():
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(content)
        shell = yaml.safe_load((ROOT / "roles/debian/tasks/shell.yml").read_text())
        names = {
            "Prepare writable Fish and Kitty directories", "Create user terminal and Fish configuration directories",
            "Deploy portable Fish settings", "Validate portable Fish settings",
            "Link shared terminal and editor assets",
            "Deploy the Kitty config with automatic X11 or Wayland selection",
        }
        tasks = [task for task in shell if task["name"] in names]
        for task in tasks:
            if "ansible.builtin.include_tasks" in task:
                task["ansible.builtin.include_tasks"]["file"] = str(ROOT / "roles/debian/tasks/user_links.yml")
        defaults = ROOT / "roles/debian/defaults/main/debian.yml"
        variables = yaml.safe_load(defaults.read_text())
        variables.update({
            "home": str(self.home), "dotfiles_dir": str(repo), "debian_config_home": str(config_home),
            "role_path": str(repo / "roles/debian"),
        })
        playbook = self.home / "deploy.yml"
        playbook.write_text(yaml.safe_dump([{
            "hosts": "localhost", "gather_facts": False, "vars": variables, "tasks": tasks,
        }]))
        for run in range(2):
            result = subprocess.run(  # noqa: S603 - Only isolated configuration tasks run in the temporary home.
                [ANSIBLE, "-i", "localhost,", "-c", "local", str(playbook)],
                env=os.environ | {
                    "ANSIBLE_CONFIG": str(ROOT / "ansible-debian.cfg"),
                    "ANSIBLE_HOME": str(self.home / "ansible"),
                    "ANSIBLE_REMOTE_TMP": str(self.home / "remote"), "ANSIBLE_NOCOLOR": "1",
                },
                text=True, capture_output=True, timeout=90, check=False,
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            if run:
                self.assertRegex(result.stdout, r"changed=0\b")
        for destination, source in (
            (fish, repo / "roles/debian/files/workstation.fish"),
            (kitty, repo / "roles/debian/files/kitty/kitty.conf"),
        ):
            with self.subTest(destination=destination.name):
                self.assertTrue(destination.is_symlink())
                self.assertEqual(destination.resolve(), source)
                backups = list(destination.parent.glob(f"{destination.name}.workstation-backup-*/{destination.name}"))
                self.assertEqual(len(backups), 1)
                self.assertEqual(backups[0].read_text(), originals[destination])
                destination.write_text(destination.read_text() + "\n# user change\n")
                self.assertTrue(source.read_text().endswith("\n# user change\n"))
        self.assertEqual((kitty.parent / "workstation.conf").resolve(), repo / "roles/shell/files/kitty/kitty.conf")
        kitty_binary = shutil.which("kitty")
        if kitty_binary:
            result = subprocess.run(  # noqa: S603 - Installed parser reads only the temporary config.
                [kitty_binary, "+runpy",
                 ("import sys; from kitty.config import load_config; "
                 "opts = load_config(sys.argv[1]); "
                 "assert opts.linux_display_server == 'auto'; "
                 "assert opts.font_size == 14.0; "
                 "assert opts.background_opacity == 0.80; "
                  "assert opts.foreground.as_sharp == '#cdd6f4'"),
                 str(kitty)],
                text=True, capture_output=True, timeout=10, check=False,
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
