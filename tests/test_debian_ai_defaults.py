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


@unittest.skipUnless(ANSIBLE and yaml, "requires ansible-playbook and PyYAML")
class DebianAIDefaultsTest(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="debian-ai-defaults-")
        self.addCleanup(temporary.cleanup)
        self.workspace = Path(temporary.name)
        self.home = self.workspace / "home"
        self.home.mkdir()

    def run_config(self, overrides, assertions, check=False):
        inventory = self.workspace / "inventory"
        (inventory / "host_vars").mkdir(parents=True)
        (inventory / "hosts.yml").write_text(yaml.safe_dump({
            "all": {"hosts": {"localhost": {"ansible_connection": "local"}}},
        }))
        (inventory / "host_vars/localhost.yml").write_text(yaml.safe_dump({
            "home": str(self.home), "dotfiles_dir": str(ROOT),
            **overrides,
        }))
        playbook = self.workspace / "playbook.yml"
        playbook.write_text(yaml.safe_dump([{
            "hosts": "localhost", "gather_facts": False,
            "tasks": [
                {"name": "Configure Debian AI tools", "ansible.builtin.import_role": {
                    "name": str(ROOT / "roles/debian"), "tasks_from": "ai_tools",
                }},
                {"name": "Verify effective defaults", "ansible.builtin.assert": {
                    "that": assertions,
                }, "tags": ["config"]},
            ],
        }]))
        env = os.environ | {
            "ANSIBLE_CONFIG": str(ROOT / "ansible.cfg"),
            "ANSIBLE_HOME": str(self.workspace / "ansible"),
            "ANSIBLE_LOCAL_TEMP": str(self.workspace / "ansible-local"),
            "ANSIBLE_REMOTE_TMP": str(self.workspace / "ansible-remote"),
            "ANSIBLE_NOCOLOR": "1",
        }
        result = subprocess.run(  # noqa: S603 - Test-controlled playbook and inventory.
            [ANSIBLE, "-i", str(inventory / "hosts.yml"), str(playbook), "--tags", "config"]
            + (["--check"] if check else []),
            cwd=self.workspace, env=env, text=True, capture_output=True, timeout=90, check=False,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_shared_defaults_resolve_references_with_config_tags(self):
        self.run_config({}, [
            "ai_tools_codex_rules_path == home ~ '/.codex/rules/default.rules'",
            "ai_tools_global_instruction_home_path == home ~ '/.agents/instructions/AGENTS.md'",
            "ai_tools_home_symlinks[0].src == ai_tools_global_instruction_home_path",
            "ai_tools_repo_symlinks[-1].src == ai_tools_global_instruction_repo_src",
            "ai_tools_repo_symlinks[-1].dest == ai_tools_global_instruction_home_path",
            "debian_fisher_version is defined",
        ], check=True)

    def test_inventory_ai_overrides_control_config_tag_deployment(self):
        self.run_config({
            "ai_tools_playwright_browser": "chromium",
            "ai_tools_codex_rules_path": "{{ home }}/custom-rules/host.rules",
            "ai_tools_global_instruction_home_path": "{{ home }}/instructions/host.md",
            "ai_tools_shared_skill_names": ["api-design"],
            "ai_tools_repo_symlinks": [
                {"src": "codex/hooks.json", "dest": "{{ home }}/.codex/custom-hooks.json"},
                {"src": "agents/instructions/AGENTS.md", "dest": "{{ ai_tools_global_instruction_home_path }}"},
                {"src": "claude/settings.json", "dest": "{{ home }}/.claude/settings.json"},
            ],
        }, [
            "ai_tools_playwright_browser == 'chromium'",
            "ai_tools_codex_rules_path == home ~ '/custom-rules/host.rules'",
            "ai_tools_shared_skill_names == ['api-design']",
            "ai_tools_repo_symlinks | length == 3",
            "ai_tools_home_symlinks[0].src == home ~ '/instructions/host.md'",
        ])
        self.assertEqual((self.home / ".codex/custom-hooks.json").resolve(),
                         ROOT / "roles/ai-tools/files/codex/hooks.json")
        self.assertFalse((self.home / ".codex/config.toml").exists())
        self.assertFalse((self.home / ".claude").exists())
        self.assertEqual((self.home / ".codex/AGENTS.md").resolve(),
                         ROOT / "roles/ai-tools/files/agents/instructions/AGENTS.md")
        for client in (".agents", ".codex"):
            skills = self.home / client / "skills"
            self.assertEqual([path.name for path in skills.iterdir()], ["api-design"])
            self.assertEqual((skills / "api-design").resolve(),
                             ROOT / "roles/ai-tools/files/agents/skills/api-design")
        rules = self.home / "custom-rules/host.rules"
        self.assertFalse(rules.is_symlink())
        self.assertEqual(rules.read_bytes(), (ROOT / "roles/ai-tools/files/codex/rules/default.rules").read_bytes())


if __name__ == "__main__":
    unittest.main()
