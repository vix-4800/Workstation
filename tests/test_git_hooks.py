import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GIT = shutil.which("git")
TOKEN = "ghp_" + "A1b2C3d4E5f6G7h8I9j0K1l2M3n4O5p6Q7r8"


@unittest.skipUnless(all(shutil.which(tool) for tool in ("git", "php", "gitleaks")),
                     "requires Git, PHP and Gitleaks")
class GitHooksTest(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="git-hooks-")
        self.addCleanup(self.temporary.cleanup)
        self.work = Path(self.temporary.name)
        self.repo = self.work / "repo"
        self.repo.mkdir()
        home = self.work / "home"
        binary = home / ".local/bin"
        binary.mkdir(parents=True)
        for name in ("check-staged-php", "check-secrets"):
            (binary / name).symlink_to(ROOT / "roles/editor/scripts" / name)
        self.config = home / ".gitconfig"
        self.config.write_text((ROOT / "roles/editor/files/git/gitconfig").read_text())
        self.gitleaks_config = home / ".gitleaks.toml"
        self.gitleaks_config.write_text(
            (ROOT / "roles/development/files/tools/gitleaks/.gitleaks.toml").read_text(),
        )
        self.env = {key: value for key, value in os.environ.items()
                    if not key.startswith(("GIT_", "GITLEAKS_"))}
        self.env.update(HOME=str(home), GIT_CONFIG_NOSYSTEM="1", GIT_CONFIG_GLOBAL="/dev/null")
        self.git("init", "-q")
        self.git("config", "user.name", "Hook Test")
        self.git("config", "user.email", "hooks@example.test")

    def git(self, *args):
        result = subprocess.run(  # noqa: S603 - arguments are controlled test fixtures.
            [GIT, *args], cwd=self.repo, env=self.env,
            text=True, capture_output=True, timeout=15, check=False,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return result.stdout.strip()

    def write(self, name, content):
        (self.repo / name).write_text(content)

    def hook(self, *args):
        return subprocess.run(  # noqa: S603 - arguments are controlled test fixtures.
            [GIT, "hook", "run", *args], cwd=self.repo,
            env=self.env | {"GIT_CONFIG_GLOBAL": str(self.config)},
            text=True, capture_output=True, timeout=15, check=False,
        )

    def test_empty_index_passes(self):
        result = self.hook("pre-commit")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_php_uses_valid_index_with_invalid_worktree(self):
        self.write("space\nname.php", "<?php echo 'valid';\n")
        self.git("add", ".")
        self.write("space\nname.php", "<?php broken (\n")
        result = self.hook("pre-commit")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_invalid_staged_php_blocks_even_with_valid_worktree(self):
        self.write("broken.php", "<?php broken (\n")
        self.git("add", ".")
        self.write("broken.php", "<?php echo 'valid';\n")
        result = self.hook("pre-commit")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("broken.php", result.stdout + result.stderr)

    def test_deleted_and_renamed_php(self):
        self.write("delete.php", "<?php echo 'valid';\n")
        self.git("add", ".")
        self.git("commit", "-qm", "initial")
        self.git("rm", "delete.php")
        result = self.hook("pre-commit")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.write("old.txt", "<?php broken (\n")
        self.git("add", ".")
        self.git("commit", "-qm", "text")
        self.git("mv", "old.txt", "renamed.php")
        result = self.hook("pre-commit")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("renamed.php", result.stdout + result.stderr)

    def test_staged_secret_blocks_and_is_redacted(self):
        self.write("credentials.txt", f"token = '{TOKEN}'\n")
        self.git("add", ".")
        self.write("credentials.txt", "clean\n")
        result = self.hook("pre-commit")
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("leaks found", result.stderr)
        self.assertNotIn(TOKEN, result.stdout + result.stderr)

    def test_unstaged_secret_is_ignored(self):
        self.write("credentials.txt", "clean\n")
        self.git("add", ".")
        self.write("credentials.txt", f"token = '{TOKEN}'\n")
        result = self.hook("pre-commit")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_repository_gitleaks_config_keeps_default_detection(self):
        for config in (ROOT / ".gitleaks.toml",
                       ROOT / "roles/development/files/tools/gitleaks/.gitleaks.toml"):
            with self.subTest(config=config):
                self.write(".gitleaks.toml", config.read_text())
                self.test_staged_secret_blocks_and_is_redacted()

    def test_global_gitleaks_policy_overrides_repository_and_environment(self):
        with self.gitleaks_config.open("a") as config:
            config.write('\n[[rules]]\nid = "global-policy"\n'
                         'description = "Test global policy"\n'
                         "regex = '''workstation-secret-check-fixture'''\n")
        self.write(".gitleaks.toml", "[extend]\nuseDefault = true\n"
                   "[[allowlists]]\npaths = ['.*']\n")
        self.env["GITLEAKS_CONFIG"] = str(self.repo / ".gitleaks.toml")
        self.write("policy.txt", "workstation-secret-check-fixture\n")
        self.git("add", ".")
        result = self.hook("pre-commit")
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("leaks found", result.stderr)

        self.git("commit", "-qm", "policy fixture")
        local = self.git("rev-parse", "HEAD")
        updates = self.work / "updates"
        updates.write_text(f"refs/heads/main {local} refs/heads/main {'0' * len(local)}\n")
        result = self.hook(f"--to-stdin={updates}", "pre-push", "--", "origin", "/unused")
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("leaks found", result.stderr)

    def test_pre_push_scans_commits_with_empty_index(self):
        self.write("clean.txt", "clean\n")
        self.git("add", ".")
        self.git("commit", "-qm", "initial")
        remote = self.git("rev-parse", "HEAD")
        self.write("credentials.txt", f"token = '{TOKEN}'\n")
        self.git("add", ".")
        self.git("commit", "-qm", "secret")
        local = self.git("rev-parse", "HEAD")
        for previous in (remote, "0" * len(remote)):
            with self.subTest(previous=previous):
                updates = self.work / "updates"
                updates.write_text(f"refs/heads/main {local} refs/heads/main {previous}\n")
                result = self.hook(f"--to-stdin={updates}", "pre-push", "--", "origin", "/unused")
                self.assertEqual(result.returncode, 1, result.stderr)
                self.assertIn("leaks found", result.stderr)
                self.assertNotIn(TOKEN, result.stdout + result.stderr)

    def test_pre_push_ignores_deletions_and_existing_remote_secrets(self):
        self.write("credentials.txt", f"token = '{TOKEN}'\n")
        self.git("add", ".")
        self.git("commit", "-qm", "existing secret")
        remote = self.git("rev-parse", "HEAD")
        self.write("clean.txt", "clean\n")
        self.git("add", ".")
        self.git("commit", "-qm", "clean addition")
        local = self.git("rev-parse", "HEAD")
        updates = self.work / "updates"
        updates.write_text(f"refs/heads/main {local} refs/heads/main {remote}\n"
                           f"(delete) {'0' * len(remote)} refs/heads/old {remote}\n")
        result = self.hook(f"--to-stdin={updates}", "pre-push", "--", "origin", "/unused")
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == "__main__":
    unittest.main()
