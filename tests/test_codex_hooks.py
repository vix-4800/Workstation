import concurrent.futures
import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "roles/ai-tools/files/codex/hooks/check-files.py"


class CodexHooksTest(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="codex-hooks-test-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.project = self.root / "project"
        self.project.mkdir()
        self.home = self.root / "home"
        self.binary = self.root / "bin"
        self.binary.mkdir()
        self.log = self.root / "calls.jsonl"
        self.env = os.environ | {
            "HOME": str(self.home),
            "PATH": str(self.binary),
            "TMPDIR": str(self.root),
            "HOOK_TEST_LOG": str(self.log),
            "HOOK_TEST_FAIL": "",
        }
        for name in (
            "php",
            "bash",
            "fish",
            "luac",
            "xmllint",
            "shellcheck",
            "ruff",
            "eslint",
            "stylelint",
            "linthtml",
            "yamllint",
            "markdownlint-cli2",
            "luacheck",
            "hadolint",
            "checkmake",
            "gofmt",
            "actionlint",
        ):
            binary = self.binary / name
            binary.write_text(
                f"#!{sys.executable}\n"
                "import json, os, sys\n"
                "from pathlib import Path\n"
                "with open(os.environ['HOOK_TEST_LOG'], 'a') as log:\n"
                "    log.write(json.dumps(sys.argv) + '\\n')\n"
                "if Path(sys.argv[0]).name == os.environ.get('HOOK_TEST_FAIL'):\n"
                "    print('fixture diagnostic')\n"
                "    sys.exit(1)\n"
            )
            binary.chmod(0o755)
        for config in (
            ".config/phpcs/phpcs.xml",
            ".config/ruff/pyproject.toml",
            ".config/eslint/eslint.config.js",
            ".stylelintrc.json",
            ".linthtmlrc",
            ".config/yamllint/config",
            ".config/markdownlint/.markdownlint.jsonc",
            ".shellcheckrc",
            ".config/luacheck/.luacheckrc",
            ".config/hadolint.yaml",
            ".config/checkmake/checkmake.ini",
        ):
            path = self.home / config
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("{}\n")

    def file(self, name, content=""):
        path = self.project / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)
        return path

    def hook(self, event, *, patch="", turn="turn-1", session="session-1", active=False):
        payload = {
            "hook_event_name": event,
            "session_id": session,
            "turn_id": turn,
            "cwd": str(self.project),
            "tool_name": "apply_patch",
            "tool_input": {"command": patch},
            "stop_hook_active": active,
        }
        result = subprocess.run(  # noqa: S603 -- Only the hook script and a JSON fixture are executed.
            [sys.executable, str(SCRIPT)],
            input=json.dumps(payload),
            text=True,
            capture_output=True,
            env=self.env,
            timeout=10,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stderr, "")
        return json.loads(result.stdout) if result.stdout else {}

    def calls(self):
        return [json.loads(line) for line in self.log.read_text().splitlines()] if self.log.exists() else []

    def test_syntax_errors_are_model_context_without_blocking_tool_result(self):
        self.file("bad.json", "{broken")
        self.file("bad.toml", "value = [")
        self.file("bad.py", "def broken(:\n")
        result = self.hook(
            "PostToolUse", patch="\n".join(f"*** Add File: {name}" for name in ("bad.json", "bad.toml", "bad.py"))
        )
        self.assertNotIn("decision", result)
        context = result["hookSpecificOutput"]["additionalContext"]
        for name in ("bad.json", "bad.toml", "bad.py"):
            self.assertIn(name, context)
        self.assertEqual(self.calls(), [])

    def test_lint_is_deferred_batched_and_drained(self):
        first = self.file("first.py", "value = 1\n")
        second = self.file("second.py", "value = 2\n")
        for name in ("first.py", "second.py", "first.py"):
            self.assertEqual(self.hook("PostToolUse", patch=f"*** Update File: {name}"), {})
        self.assertEqual(self.calls(), [])
        self.assertEqual(self.hook("Stop"), {})
        calls = self.calls()
        self.assertEqual(len(calls), 1)
        self.assertEqual(Path(calls[0][0]).name, "ruff")
        self.assertEqual(calls[0][-2:], [str(first), str(second)])
        self.assertIn(str(self.home / ".config/ruff/pyproject.toml"), calls[0])
        self.assertEqual(self.hook("Stop"), {})
        self.assertEqual(self.calls(), calls)

    def test_failed_lint_continues_once_and_rechecks_repairs_without_looping(self):
        self.file("file.py", "value = 1\n")
        self.env["HOOK_TEST_FAIL"] = "ruff"
        self.hook("PostToolUse", patch="*** Update File: file.py")
        result = self.hook("Stop")
        self.assertEqual(result["decision"], "block")
        self.assertIn("fixture diagnostic", result["reason"])
        self.hook("PostToolUse", patch="*** Update File: file.py")
        result = self.hook("Stop", active=True)
        self.assertNotIn("decision", result)
        self.assertIn("fixture diagnostic", result["systemMessage"])
        self.assertEqual(len(self.calls()), 2)

    def test_turns_and_sessions_are_isolated(self):
        self.file("one.py", "value = 1\n")
        self.file("two.py", "value = 2\n")
        self.hook("PostToolUse", patch="*** Update File: one.py")
        self.hook("PostToolUse", patch="*** Update File: two.py", turn="turn-2")
        self.hook("Stop", session="other-session")
        self.assertEqual(self.calls(), [])
        self.hook("Stop")
        self.assertEqual(self.calls()[0][-1], str(self.project / "one.py"))
        self.hook("Stop", turn="turn-2")
        self.assertEqual(self.calls()[1][-1], str(self.project / "two.py"))

    def test_concurrent_patches_do_not_lose_pending_files(self):
        names = [f"file-{index}.py" for index in range(8)]
        for name in names:
            self.file(name, "value = 1\n")
        with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
            list(executor.map(lambda name: self.hook("PostToolUse", patch=f"*** Add File: {name}"), names))
        self.hook("Stop")
        self.assertEqual(set(self.calls()[0][-8:]), {str(self.project / name) for name in names})

    def test_moves_deletes_generated_and_external_paths(self):
        moved = self.file("moved.py", "value = 1\n")
        outside = self.root / "outside.py"
        outside.write_text("invalid python\n")
        (self.project / "linked.py").symlink_to(outside)
        self.file("vendor/generated.py", "invalid python\n")
        self.hook(
            "PostToolUse",
            patch="\n".join(
                [
                    "*** Update File: old.py",
                    "*** Move to: moved.py",
                    "*** Delete File: gone.py",
                    "*** Update File: ../outside.py",
                    "*** Update File: linked.py",
                    "*** Update File: vendor/generated.py",
                ]
            ),
        )
        self.hook("Stop")
        self.assertEqual(self.calls()[0][-1], str(moved))
        self.assertEqual(len(self.calls()), 1)

    def test_extensionless_shell_and_quoted_filenames_use_arguments(self):
        name = "script $(touch sentinel); name"
        path = self.file(name, "#!/usr/bin/env bash\ntrue\n")
        self.hook("PostToolUse", patch=f"*** Add File: {name}")
        self.assertEqual(Path(self.calls()[0][0]).name, "bash")
        self.hook("Stop")
        self.assertEqual(Path(self.calls()[1][0]).name, "shellcheck")
        self.assertEqual(self.calls()[1][-1], str(path))
        self.assertFalse((self.project / "sentinel").exists())

    def test_missing_binary_or_config_is_reported_without_installation(self):
        self.file("file.py", "value = 1\n")
        (self.binary / "ruff").unlink()
        self.hook("PostToolUse", patch="*** Add File: file.py")
        self.assertIn("command unavailable", self.hook("Stop")["systemMessage"])
        self.file("file.css", "body {}\n")
        (self.home / ".stylelintrc.json").unlink()
        self.hook("PostToolUse", patch="*** Add File: file.css")
        self.assertIn("global config missing", self.hook("Stop")["systemMessage"])
        self.assertEqual(self.calls(), [])

    def test_markdown_uses_installed_cli2_and_global_ignores(self):
        self.file("note.md", "# Note\n")
        ignore = self.home / ".config/markdownlint/.markdownlintignore"
        ignore.write_text("AGENTS.md\n**/references/*.md\n")
        self.hook("PostToolUse", patch="*** Add File: note.md")
        self.hook("Stop")
        call = self.calls()[0]
        self.assertEqual(Path(call[0]).name, "markdownlint-cli2")
        self.assertIn("#**/AGENTS.md", call)
        self.assertIn("#**/references/*.md", call)
        self.assertEqual(call[-1], ":" + str(self.project / "note.md"))

    def test_jsonc_configuration_is_not_rejected_as_strict_json(self):
        self.file(".vscode/settings.json", '{\n// Valid JSONC\n"editor.tabSize": 4,\n}\n')
        self.file("tsconfig.build.json", '{\n// Valid JSONC\n"compilerOptions": {},\n}\n')
        result = self.hook(
            "PostToolUse",
            patch="\n".join(
                [
                    "*** Update File: .vscode/settings.json",
                    "*** Update File: tsconfig.build.json",
                ]
            ),
        )
        self.assertEqual(result, {})
        self.assertEqual(self.hook("Stop"), {})
        self.assertEqual(self.calls(), [])

    def test_html_linter_receives_relative_paths(self):
        self.file("pages/sample.html", "<!doctype html>\n")
        self.hook("PostToolUse", patch="*** Add File: pages/sample.html")
        self.hook("Stop")
        self.assertEqual(Path(self.calls()[0][0]).name, "linthtml")
        self.assertEqual(self.calls()[0][-1], "./pages/sample.html")

    def test_deployed_symlinks_execute_configured_commands(self):
        source = SCRIPT.parent.parent
        directory = self.home / ".codex"
        directory.mkdir()
        (directory / "hooks.json").symlink_to(source / "hooks.json")
        (directory / "hooks").symlink_to(source / "hooks")
        (self.binary / "python3").symlink_to(sys.executable)
        configuration = json.loads((directory / "hooks.json").read_text())
        self.file("file.py", "value = 1\n")
        for event in ("PostToolUse", "Stop"):
            command = configuration["hooks"][event][0]["hooks"][0]["command"]
            payload = {
                "hook_event_name": event,
                "session_id": "session",
                "turn_id": "turn",
                "cwd": str(self.project),
                "tool_name": "apply_patch",
                "tool_input": {"command": "*** Add File: file.py"},
            }
            result = subprocess.run(  # noqa: S603 -- Execute the checked-in hook command through its deployed symlink.
                ["/usr/bin/bash", "--noprofile", "--norc", "-c", command],
                input=json.dumps(payload),
                cwd=self.project,
                env=self.env,
                text=True,
                capture_output=True,
                timeout=10,
                check=False,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stderr, "")
        self.assertEqual(len(self.calls()), 1)
        self.assertEqual(Path(self.calls()[0][0]).name, "ruff")

    def test_typescript_without_project_is_skipped_and_workflows_are_targeted(self):
        self.file("file.ts", "export const value = 1;\n")
        self.file(".github/workflows/ci.yml", "---\n")
        self.file("other.yml", "---\n")
        self.hook(
            "PostToolUse",
            patch="\n".join(
                [
                    "*** Add File: file.ts",
                    "*** Add File: .github/workflows/ci.yml",
                    "*** Add File: other.yml",
                ]
            ),
        )
        self.assertIn("no tsconfig.json", self.hook("Stop")["systemMessage"])
        calls = self.calls()
        self.assertEqual([Path(call[0]).name for call in calls], ["yamllint", "actionlint"])
        self.assertEqual(calls[1][-1], str(self.project / ".github/workflows/ci.yml"))
        self.assertNotIn(str(self.project / "other.yml"), calls[1])


if __name__ == "__main__":
    unittest.main()
