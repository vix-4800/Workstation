#!/usr/bin/env python3
"""Check patch syntax immediately and batch file linters at the end of a turn."""

import ast
import fcntl
import hashlib
import json
import os
import re
import shutil
import stat
import subprocess
import sys
import tempfile
import time
import tokenize
import tomllib
from pathlib import Path

EXCLUDED = {".git", ".cache", ".venv", "venv", "node_modules", "vendor", "__pycache__", "dist", "build"}
OUTPUT_LIMIT = 6000
PRIVATE_DIRECTORY_MODE = 0o700
PRIVATE_FILE_MODE = 0o600


def patch_paths(command):
    paths = set()
    previous = None
    for line in command.splitlines():
        match = re.fullmatch(r"\*\*\* (Add|Update|Delete) File: (.+)", line)
        if match:
            operation, previous = match.groups()
            if operation != "Delete":
                paths.add(previous)
        elif line.startswith("*** Move to: ") and previous is not None:
            paths.discard(previous)
            paths.add(line.removeprefix("*** Move to: "))
    return paths


def eligible_paths(names, cwd):
    paths = []
    for name in sorted(names):
        path = (cwd / name).resolve()
        if not path.is_relative_to(cwd) or EXCLUDED.intersection(path.relative_to(cwd).parts):
            continue
        if path.is_file() and path.stat().st_size <= 1024 * 1024:
            paths.append(path)
    return paths


def file_kind(path):
    suffix = path.suffix.lower()
    if path.name.endswith(".blade.php"):
        return ""
    if suffix == ".json" and (
        path.name
        in {"settings.json", "keybindings.json", "tasks.json", "launch.json", "extensions.json", "jsconfig.json"}
        or path.name.startswith("tsconfig")
    ):
        return "jsonc"
    if path.name in {"Dockerfile", "Containerfile"} or path.name.startswith("Dockerfile."):
        return "docker"
    if path.name in {"Makefile", "makefile", "GNUmakefile"}:
        return "make"
    if suffix:
        kinds = {
            ".sh": "shell",
            ".bash": "shell",
            ".yaml": "yaml",
            ".yml": "yaml",
            **dict.fromkeys((".js", ".mjs", ".cjs", ".ts", ".tsx", ".mts", ".cts"), "eslint"),
        }
        return kinds.get(suffix, suffix.removeprefix("."))
    with path.open("rb") as source:
        shebang = source.readline(256).decode("utf-8", errors="replace")
    interpreters = {r"(?:bash|sh)": "shell", "fish": "fish", r"python[\d.]*": "py"}
    for interpreter, kind in interpreters.items():
        if re.match(r"^#!.*\b" + interpreter + r"\b", shebang):
            return kind
    return ""


def pending_paths(payload, cwd, added=None):
    # Keep runtime state outside symlinked configuration; serialize concurrent patches.
    directory = Path(tempfile.gettempdir()) / f"codex-file-hooks-{os.getuid()}"
    directory.mkdir(mode=PRIVATE_DIRECTORY_MODE, exist_ok=True)
    info = directory.lstat()
    if (
        not stat.S_ISDIR(info.st_mode)
        or info.st_uid != os.getuid()
        or stat.S_IMODE(info.st_mode) != PRIVATE_DIRECTORY_MODE
    ):
        raise OSError("Unsafe hook state directory")
    key = json.dumps([payload["session_id"], payload["turn_id"], str(cwd)])
    state = directory / (hashlib.sha256(key.encode()).hexdigest() + ".json")
    if added is None and not state.exists():
        return set()
    descriptor = os.open(state, os.O_CREAT | os.O_RDWR | os.O_NOFOLLOW, PRIVATE_FILE_MODE)
    with os.fdopen(descriptor, "r+") as stream:
        fcntl.flock(stream, fcntl.LOCK_EX)
        info = os.fstat(stream.fileno())
        if (
            not stat.S_ISREG(info.st_mode)
            or info.st_uid != os.getuid()
            or info.st_nlink != 1
            or stat.S_IMODE(info.st_mode) != PRIVATE_FILE_MODE
        ):
            raise OSError("Unsafe hook state file")
        content = stream.read()
        pending = set(json.loads(content)) if content else set()
        stream.seek(0)
        json.dump(sorted(pending | set(added)) if added is not None else [], stream)
        stream.truncate()
    return pending


def run_check(args, cwd, deadline, config=None):
    if config is not None and not config.is_file():
        return False, f"Skipped {args[0]}: global config missing: {config}"
    if shutil.which(args[0]) is None:
        return False, f"Skipped {args[0]}: command unavailable"
    remaining = deadline - time.monotonic()
    if remaining <= 0:
        return False, f"Skipped {args[0]}: hook time budget exhausted"
    # Spool output to disk so a noisy tool cannot exhaust the hook's memory.
    with tempfile.TemporaryFile() as output:
        try:
            # Fixed executable map; file paths are separate arguments, never shell code.
            result = subprocess.run(  # noqa: S603
                args,
                cwd=cwd,
                stdin=subprocess.DEVNULL,
                stdout=output,
                stderr=output,
                timeout=min(10, remaining),
                check=False,
            )
        except subprocess.TimeoutExpired:
            return True, f"{args[0]} timed out; run this check manually."
        output.seek(0)
        message = output.read(OUTPUT_LIMIT).decode("utf-8", errors="replace").strip()
    failed = result.returncode != 0 or (args[0] == "gofmt" and bool(message))
    return failed, f"{args[0]}:\n{message or 'Check failed without diagnostics'}" if failed else ""


def syntax_checks(paths, cwd, deadline):
    results = []
    for path in paths:
        kind = file_kind(path)
        try:
            if kind == "json":
                json.loads(path.read_text())
            elif kind == "toml":
                tomllib.loads(path.read_text())
            elif kind == "py":
                with tokenize.open(path) as source:
                    ast.parse(source.read(), filename=str(path))
            else:
                commands = {
                    "php": ["php", "-l"],
                    "shell": ["bash", "--noprofile", "--norc", "-n"],
                    "fish": ["fish", "--no-config", "--no-execute"],
                    "lua": ["luac", "-p"],
                    "xml": ["xmllint", "--nonet", "--noout"],
                }
                if kind in commands:
                    results.append(run_check([*commands[kind], str(path)], cwd, deadline))
        except (ValueError, SyntaxError, UnicodeError) as error:
            results.append((True, f"{path}: {error}"))
    return results


def lint_checks(paths, cwd, deadline):
    home = Path.home()
    groups = {}
    notices = []
    for path in paths:
        kind = file_kind(path)
        if (
            kind == "eslint"
            and path.suffix in {".ts", ".tsx", ".mts", ".cts"}
            and not any((parent / "tsconfig.json").is_file() for parent in [path.parent, *path.parent.parents])
        ):
            notices.append((False, f"Skipped ESLint for {path}: no tsconfig.json"))
            continue
        groups.setdefault(kind, []).append(str(path))
        if kind == "yaml" and path.relative_to(cwd).parts[:2] == (".github", "workflows"):
            groups.setdefault("actions", []).append(str(path))
    # One linter per file type. Project-wide analysis and automatic fixes stay manual.
    checks = {
        "php": (str(home / ".config/composer/vendor/bin/phpcs"), ".config/phpcs/phpcs.xml", ["--no-cache", "-q"]),
        "py": ("ruff", ".config/ruff/pyproject.toml", ["check", "--no-cache"]),
        "eslint": ("eslint", ".config/eslint/eslint.config.js", []),
        "css": ("stylelint", ".stylelintrc.json", []),
        "html": ("linthtml", ".linthtmlrc", []),
        "yaml": ("yamllint", ".config/yamllint/config", []),
        "md": ("markdownlint-cli2", ".config/markdownlint/.markdownlint.jsonc", []),
        "shell": ("shellcheck", ".shellcheckrc", ["--severity=warning"]),
        "lua": ("luacheck", ".config/luacheck/.luacheckrc", ["--no-color", "--codes"]),
        "docker": ("hadolint", ".config/hadolint.yaml", []),
        "make": ("checkmake", ".config/checkmake/checkmake.ini", []),
        "go": ("gofmt", None, ["-l"]),
        "actions": ("actionlint", None, ["-no-color", "-pyflakes="]),
    }
    for kind, files in groups.items():
        if kind not in checks:
            continue
        binary, config_name, options = checks[kind]
        config = home / config_name if config_name else None
        args = [binary, *options]
        if config is not None:
            flag = {"php": "--standard=", "shell": "--rcfile=", "yaml": "--config-file="}.get(kind)
            args.extend([flag + str(config)] if flag else ["--config", str(config)])
        targets = files
        if kind == "html":
            targets = ["./" + str(Path(file).relative_to(cwd)) for file in files]
        if kind == "md":
            ignore = config.parent / ".markdownlintignore"
            if ignore.is_file():
                for pattern in ignore.read_text().splitlines():
                    if pattern and not pattern.startswith("#"):
                        args.append("#" + ("**/" if "/" not in pattern else "") + pattern)
            targets = [":" + file for file in files]
        notices.append(run_check([*args, *targets], cwd, deadline, config))
    return notices


def main():
    payload = json.load(sys.stdin)
    event = payload.get("hook_event_name")
    if event not in {"PostToolUse", "Stop"}:
        return
    if not payload.get("session_id") or not payload.get("turn_id"):
        print(json.dumps({"systemMessage": "File checks skipped: session_id or turn_id missing."}))
        return
    cwd = Path(payload["cwd"]).resolve()
    if event == "PostToolUse":
        if payload.get("tool_name") != "apply_patch":
            return
        paths = eligible_paths(patch_paths(payload.get("tool_input", {}).get("command", "")), cwd)
        if not paths:
            return
        pending_paths(payload, cwd, [str(path) for path in paths])
        results = syntax_checks(paths, cwd, time.monotonic() + 20)
    else:
        paths = eligible_paths(pending_paths(payload, cwd), cwd)
        results = lint_checks(paths, cwd, time.monotonic() + 45)
    messages = [message for _, message in results if message]
    if not messages:
        if event == "Stop":
            print("{}")
        return
    message = "\n\n".join(messages)[:OUTPUT_LIMIT]
    if event == "PostToolUse":
        output = {"hookSpecificOutput": {"hookEventName": event, "additionalContext": message}}
    elif any(failed for failed, _ in results) and not payload.get("stop_hook_active"):
        output = {"decision": "block", "reason": "Edited file checks failed. Fix or explain the findings:\n" + message}
    else:
        output = {"systemMessage": message}
    print(json.dumps(output))


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError) as error:
        print(json.dumps({"systemMessage": f"Codex file checks could not complete: {error}"}))
