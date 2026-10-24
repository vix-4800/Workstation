import copy
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

try:
    import yaml
except ImportError:
    yaml = None


ROOT = Path(__file__).resolve().parents[1]
ANSIBLE = shutil.which("ansible-playbook")


@unittest.skipUnless(ANSIBLE and yaml, "requires Ansible and PyYAML")
class WireGuardDeploymentTest(unittest.TestCase):
    def test_diff_does_not_disclose_keys_when_creating_or_rotating_config(self):
        tasks = yaml.safe_load((ROOT / "roles/network/tasks/wireguard.yml").read_text())
        task = copy.deepcopy(next(task for task in tasks if task["name"] == "Deploy WireGuard config from vault"))
        with tempfile.TemporaryDirectory(prefix="wireguard-deployment-") as directory:
            work = Path(directory)
            destination = work / "wg0.conf"
            module = task["ansible.builtin.template"]
            module.update(src=str(ROOT / "roles/network/templates/wg0.conf.j2"), dest=str(destination))
            module.pop("owner")
            module.pop("group")
            task["become"] = False
            config = work / "ansible.cfg"
            config.write_text("[defaults]\nretry_files_enabled = false\n")
            environment = os.environ | {
                "ANSIBLE_CONFIG": str(config),
                "ANSIBLE_LOCAL_TEMP": str(work / "tmp"),
                "ANSIBLE_REMOTE_TEMP": str(work / "remote-tmp"),
            }
            for index in range(2):
                private_key = f"test-private-key-{index}"
                preshared_key = f"test-preshared-key-{index}"
                playbook = work / "deploy.yml"
                playbook.write_text(yaml.safe_dump([{
                    "name": "Test WireGuard deployment",
                    "hosts": "localhost",
                    "connection": "local",
                    "gather_facts": False,
                    "vars": {
                        "ansible_python_interpreter": "/usr/bin/python3",
                        "vault_wg_private_key": private_key,
                        "vault_wg_preshared_key": preshared_key,
                        "vault_wg_address": "192.0.2.2/32",
                        "vault_wg_dns": "192.0.2.1",
                        "vault_wg_peer_public_key": "test-public-key",
                        "vault_wg_endpoint": "192.0.2.1:51820",
                    },
                    "tasks": [task],
                }]))
                result = subprocess.run(
                    [ANSIBLE, "-i", "localhost,", str(playbook), "--diff"],
                    cwd=work, env=environment, text=True, capture_output=True, timeout=30,
                )
                output = result.stdout + result.stderr
                self.assertEqual(result.returncode, 0, output)
                self.assertIn(private_key, destination.read_text())
                self.assertIn(preshared_key, destination.read_text())
                self.assertEqual(destination.stat().st_mode & 0o777, 0o600)
                for secret in ("test-private-key-", "test-preshared-key-"):
                    self.assertNotIn(secret, output)


if __name__ == "__main__":
    unittest.main()
