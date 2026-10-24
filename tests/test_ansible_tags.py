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


@unittest.skipUnless(ANSIBLE and yaml, "requires Ansible and PyYAML")
class AnsibleTagsTest(unittest.TestCase):
    def test_config_tag_reaches_nested_configs_without_installing_packages(self):
        with tempfile.TemporaryDirectory(prefix="ansible-tags-") as directory:
            work = Path(directory)
            package_tasks = set()
            for role in ("network", "desktop", "development"):
                destination = work / "roles" / role / "tasks"
                destination.mkdir(parents=True)
                for source in (ROOT / "roles" / role / "tasks").glob("*.yml"):
                    tasks = yaml.safe_load(source.read_text())
                    safe_tasks = []
                    for task in tasks:
                        name = f"{role}: {task['name']}"
                        if "packages" in task.get("tags", []):
                            package_tasks.add(name)
                        if "ansible.builtin.include_tasks" in task:
                            safe_tasks.append(task)
                        else:
                            # Preserve production tag routing, replace host mutations with observable markers.
                            safe_tasks.append({
                                "name": name,
                                "ansible.builtin.debug": {"msg": name},
                                "tags": task.get("tags", []),
                            })
                    (destination / source.name).write_text(yaml.safe_dump(safe_tasks))
            config = work / "ansible.cfg"
            config.write_text("[defaults]\nretry_files_enabled = false\n")
            playbook = work / "tags.yml"
            playbook.write_text(yaml.safe_dump([{
                "name": "Test config tag routing",
                "hosts": "localhost",
                "gather_facts": False,
                "roles": [{"role": role, "tags": [role]} for role in ("network", "desktop", "development")],
            }]))
            result = subprocess.run(  # noqa: S603
                [ANSIBLE, "-i", "localhost,", str(playbook), "--tags", "config"],
                cwd=work, env=os.environ | {"ANSIBLE_CONFIG": str(config), "ANSIBLE_LOCAL_TEMP": str(work / "tmp")},
                text=True, capture_output=True, timeout=30, check=False,
            )
            output = result.stdout + result.stderr
            self.assertEqual(result.returncode, 0, output)
            for name in (
                "network: Deploy WireGuard config from vault",
                "network: Deploy usbguard allowlist rules",
                "network: Deploy zapret2 config",
                "desktop: Deploy waybar config",
                "desktop: Deploy gtklock config",
                "development: Deploy xdebug config",
                "development: Configure Docker NVIDIA runtime",
            ):
                self.assertIn(name, output)
            for name in package_tasks:
                self.assertNotIn(name, output)


if __name__ == "__main__":
    unittest.main()
