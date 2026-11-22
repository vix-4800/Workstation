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
ANSIBLE = shutil.which("ansible-playbook")


class DebianPlaybookTest(unittest.TestCase):
    def setUp(self):
        self.playbook = ROOT / "debian.yml"

    @unittest.skipUnless(yaml, "requires PyYAML")
    def test_debian_entrypoint_is_local_and_independent_of_arch(self):
        [play] = yaml.safe_load(self.playbook.read_text())
        self.assertEqual(play["hosts"], "localhost")
        self.assertEqual(play["connection"], "local")
        self.assertEqual([entry["role"] for entry in play["roles"]], ["debian"])
        self.assertNotIn("vars_files", play)

    @unittest.skipUnless(yaml, "requires PyYAML")
    def test_debian_installs_codex_as_the_only_ai_client(self):
        ai_settings = ROOT / "roles" / "debian" / "vars" / "ai_tools.yml"
        packages = yaml.safe_load(ai_settings.read_text())["debian_ai_npm_tools"]
        binaries = {package["binary"] for package in packages}
        self.assertIn("codex", binaries)
        self.assertTrue(binaries.isdisjoint({"claude", "opencode", "copilot"}))

    @unittest.skipUnless(yaml, "requires PyYAML")
    def test_optional_command_lookups_use_portable_exit_statuses(self):
        directory = ROOT / "roles" / "debian" / "tasks"
        ai = yaml.safe_load((directory / "ai_tools.yml").read_text())
        ai_tasks = next(task["block"] for task in ai if task["name"] == "Install and verify user AI command-line tools")
        commands = {task["name"]: task["ansible.builtin.command"]["argv"] for task in ai_tasks}
        ai_probe = commands["Find installed AI commands and language servers"][:-1] + ["intelephense"]
        just_probe = yaml.safe_load((directory / "just.yml").read_text())[0]["ansible.builtin.command"]["argv"]
        uv_probe = commands["Find uv and uvx"]
        cases = (
            (ai_probe, [], 1), (ai_probe, ["intelephense"], 0),
            (just_probe, [], 1), (just_probe, ["just"], 0),
            (uv_probe, [], 1), (uv_probe, ["uv"], 1), (uv_probe, ["uv", "uvx"], 0),
        )
        for argv, available, status in cases:
            with self.subTest(command=argv, available=available), tempfile.TemporaryDirectory() as workspace:
                for binary in available:
                    (Path(workspace) / binary).symlink_to("/bin/true")
                result = subprocess.run(argv, env=os.environ | {"PATH": workspace},
                                        text=True, capture_output=True, timeout=5, check=False)
                self.assertEqual(result.returncode, status, result.stderr)

    @unittest.skipUnless(yaml, "requires PyYAML")
    def test_spotify_fetch_failure_leaves_required_flatpak_apps_independent(self):
        try:
            import ansible.template
        except ImportError:
            self.skipTest("requires Ansible Core")

        path = ROOT / "roles" / "debian" / "tasks" / "apps.yml"
        tasks = {task["name"]: task for task in yaml.safe_load(path.read_text())}
        spotify = tasks.get("Install Spotify separately from Flathub")
        self.assertIsNotNone(spotify)
        self.assertEqual(spotify["ansible.builtin.command"]["argv"][-1], "com.spotify.Client")
        self.assertNotIn("com.spotify.Client", yaml.safe_dump(tasks["Install Bitwarden and any required Obsidian Flatpak"]))
        self.assertIn("Report a deferred Spotify installation", tasks)

        from_snapcraft = (
            "Error: Failed to install com.spotify.Client: While downloading https://api.snapcraft.io/download/example.snap: "
            "While fetching https://api.snapcraft.io/download/example.snap: [35] SSL connect error"
        )
        trust = getattr(ansible.template, "trust_as_template", lambda value: value)
        for rc, stderr, fails in ((0, "", False), (1, from_snapcraft, False), (1, "Error: No such ref", True)):
            with self.subTest(rc=rc, stderr=stderr):
                renderer = ansible.template.Templar(variables={spotify["register"]: {"rc": rc, "stderr": stderr}})
                self.assertEqual(renderer.template(trust("{{ " + spotify["failed_when"] + " }}")), fails)

    @unittest.skipUnless(yaml, "requires PyYAML")
    def test_fish_plugin_install_respects_the_standalone_fisher_bootstrap(self):
        try:
            import ansible.template
        except ImportError:
            self.skipTest("requires Ansible Core")

        role = ROOT / "roles" / "debian"
        defaults = yaml.safe_load((role / "defaults" / "main.yml").read_text())
        tasks = yaml.safe_load((role / "tasks" / "fish_plugins.yml").read_text())
        install = next(task for task in tasks if task["name"] == "Install the missing workstation Fish plugins")
        plugins = [
            "ilancosman/tide@v6", "jorgebucaran/nvm.fish", "catppuccin/fish",
            "jorgebucaran/autopair.fish", "franciscolourenco/done",
        ]
        trust = getattr(ansible.template, "trust_as_template", lambda value: value)
        for installed, missing in (([], plugins), (plugins, []), (plugins[:-1], plugins[-1:])):
            with self.subTest(installed=installed):
                renderer = ansible.template.Templar(variables={
                    "debian_fisher_version": defaults["debian_fisher_version"],
                    "debian_fish_plugins": [trust(plugin) for plugin in defaults["debian_fish_plugins"]],
                    "debian_fisher_installed": {"stdout_lines": installed},
                })
                self.assertCountEqual(
                    renderer.template(trust(install["vars"]["debian_fisher_missing"])),
                    missing,
                )

    def test_debian_family_platform_detection(self):
        script = ROOT / "roles" / "debian" / "scripts" / "detect-platform"
        releases = (
            ("ID=debian\nVERSION_ID=12\nVERSION_CODENAME=bookworm\n", "debian", "bookworm"),
            ("ID=debian\nVERSION_ID=13\nVERSION_CODENAME=trixie\n", "debian", "trixie"),
            ("ID=debian\nVERSION_CODENAME=forky\n", "debian", "forky"),
            ("ID=kali\nID_LIKE=debian\nVERSION_CODENAME=kali-rolling\n", "kali", "kali-rolling"),
            ("ID=linuxmint\nID_LIKE='ubuntu debian'\nUBUNTU_CODENAME=noble\n", "ubuntu", "noble"),
            ("ID=linuxmint\nID_LIKE=debian\nDEBIAN_CODENAME=trixie\n", "debian", "trixie"),
            ("ID=linuxmint\nID_LIKE=debian\nVERSION_CODENAME=faye\n", "debian", "faye"),
            ("ID=ubuntu\nVERSION_ID=26.04\nVERSION_CODENAME=resolute\n", "ubuntu", "resolute"),
            ("ID=raspbian\nID_LIKE=debian\nVERSION_CODENAME=trixie\n", "debian", "trixie"),
            ("ID=arch\n", None, None),
            ("ID=ubuntu\nID_LIKE=debian\nVERSION_ID=22.04\nVERSION_CODENAME=jammy\n", None, None),
            ("ID=debian\nVERSION_ID=11\nVERSION_CODENAME=bullseye\n", None, None),
            ("ID=linuxmint\nID_LIKE='ubuntu debian'\nUBUNTU_CODENAME=jammy\n", None, None),
        )
        with tempfile.TemporaryDirectory() as workspace:
            os_release = Path(workspace) / "os-release"
            for info, platform, codename in releases:
                with self.subTest(info=info):
                    os_release.write_text(info)
                    result = subprocess.run([sys.executable, str(script), str(os_release)],
                                            text=True, capture_output=True, check=False)
                    if platform is None:
                        self.assertNotEqual(result.returncode, 0, result.stdout)
                        self.assertIn("Unsupported", result.stderr)
                    else:
                        self.assertEqual(result.returncode, 0, result.stderr)
                        self.assertEqual(result.stdout.splitlines(), [platform, codename])

    @unittest.skipUnless(yaml, "requires PyYAML")
    def test_docker_and_firefox_use_packages_from_the_base_archive(self):
        try:
            import ansible.template
        except ImportError:
            self.skipTest("requires Ansible Core")

        role = ROOT / "roles" / "debian"
        docker_tasks = yaml.safe_load((role / "tasks" / "docker.yml").read_text())
        docker_selection = next(task for task in docker_tasks if task["name"] == "Select native Docker packages")
        docker_install = next(task for task in docker_tasks if task["name"].startswith("Install Docker Engine"))
        ai_tasks = yaml.safe_load((role / "tasks" / "ai_tools.yml").read_text())
        firefox_install = next(task for task in ai_tasks if task["name"].startswith("Install AI tool runtime"))
        ai_vars = yaml.safe_load((role / "vars" / "ai_tools.yml").read_text())
        trust = getattr(ansible.template, "trust_as_template", lambda template: template)

        transitions = {
            name: f"{name}t64" for name in ("libasound2", "libatk1.0-0", "libglib2.0-0", "libgtk-3-0")
        }
        matrix = (
            ("Debian 12", {"docker-compose": "1.29.2-3", "libavcodec59": "1", "libdbus-glib-1-2": "1"},
             [], ["docker.io"], "libavcodec59"),
            ("Debian 13", {"docker-cli": "26", "docker-compose": "2.26.1-4", "libavcodec61": "1"},
             [], ["docker.io", "docker-cli", "docker-compose"], "libavcodec61"),
            ("Ubuntu or Mint", {"docker-compose-v2": "2.40.3-1", "docker-buildx": "0.22", "libavcodec60": "1"},
             [], ["docker.io", "docker-compose-v2", "docker-buildx"], "libavcodec60"),
            ("Kali", {"docker-cli": "28", "docker-compose": "1:2.40.3-3", "docker-buildx": "0.29", "libavcodec62": "1"},
             [], ["docker.io", "docker-cli", "docker-compose", "docker-buildx"], "libavcodec62"),
            ("Existing Docker CE", {"docker-compose-plugin": "2", "docker-buildx-plugin": "0.30", "libavcodec62": "1"},
             ["installed"], ["docker-ce", "docker-ce-cli", "containerd.io", "docker-compose-plugin", "docker-buildx-plugin"],
             "libavcodec62"),
        )
        for target, versions, installed, docker_packages, codec in matrix:
            with self.subTest(target=target):
                libraries = transitions if target == "Debian 12" else transitions.values()
                variables = {"debian_apt_candidates": dict(versions, **dict.fromkeys(libraries, "1")),
                             "debian_docker_vendor": {"stdout_lines": installed}}
                variables.update({key: trust(value) for key, value in docker_selection["vars"].items()})
                variables.update({key: trust(value) for key, value in docker_selection["ansible.builtin.set_fact"].items()})
                variables["debian_ai_packages"] = [trust(value) for value in ai_vars["debian_ai_packages"]]
                variables["debian_ai_libavcodec"] = ai_vars["debian_ai_libavcodec"]
                renderer = ansible.template.Templar(variables=variables)
                self.assertEqual(renderer.template(trust(docker_install["ansible.builtin.apt"]["name"])), docker_packages)
                firefox_packages = renderer.template(trust(firefox_install["ansible.builtin.apt"]["name"]))
                self.assertIn(codec, firefox_packages)
                self.assertEqual(set(firefox_packages) & (set(transitions) | set(transitions.values())), set(libraries))

    @unittest.skipUnless(yaml, "requires PyYAML")
    def test_every_static_and_dynamic_task_file_exists(self):
        directory = ROOT / "roles" / "debian" / "tasks"

        def verify(tasks):
            for task in tasks:
                for directive in ("ansible.builtin.include_tasks", "ansible.builtin.import_tasks"):
                    if directive in task:
                        value = task[directive]
                        self.assertTrue((directory / (value["file"] if isinstance(value, dict) else value)).is_file())
                for section in ("block", "rescue", "always"):
                    verify(task.get(section, []))

        for path in directory.glob("*.yml"):
            with self.subTest(path=path.name):
                verify(yaml.safe_load(path.read_text()))

    @unittest.skipUnless(ANSIBLE, "requires ansible-playbook")
    def test_syntax_and_tags_do_not_require_local_credentials(self):
        with tempfile.TemporaryDirectory() as workspace:
            env = os.environ | {
                "ANSIBLE_CONFIG": str(ROOT / "ansible-debian.cfg"),
                "ANSIBLE_HOME": workspace,
                "ANSIBLE_NOCOLOR": "1",
            }
            env.pop("ANSIBLE_VAULT_PASSWORD_FILE", None)
            for option in ("--syntax-check", "--list-tags"):
                result = subprocess.run(
                    [ANSIBLE, str(self.playbook), option],
                    cwd=ROOT, env=env, text=True, capture_output=True, timeout=90, check=False,
                )
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                if option == "--list-tags":
                    for tag in ("wireguard", "packages", "config", "shell", "development"):
                        self.assertIn(tag, result.stdout)


if __name__ == "__main__":
    unittest.main()
