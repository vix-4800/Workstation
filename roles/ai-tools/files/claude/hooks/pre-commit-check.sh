#!/usr/bin/env bash

set -euo pipefail

input="$(cat)"
command="$(printf '%s' "${input}" | jq -r '.tool_input.command // empty')"
commitlint_config="${HOME}/.config/commitlint/commitlint.config.js"

if [[ -z "${command}" ]]; then
  exit 0
fi

case "${command}" in
  git\ commit*|*/git\ commit*)
    ;;
  *)
    exit 0
    ;;
esac

if ! command -v commitlint >/dev/null 2>&1; then
  exit 0
fi

if [[ ! -f "${commitlint_config}" ]]; then
  exit 0
fi

commit_message="$(
  printf '%s' "${input}" | python3 -c '
import json
import shlex
import sys

try:
    payload = json.load(sys.stdin)
except json.JSONDecodeError:
    raise SystemExit(0)

command = payload.get("tool_input", {}).get("command", "")
if not command:
    raise SystemExit(0)

try:
    parts = shlex.split(command)
except ValueError:
    raise SystemExit(0)

if len(parts) < 2:
    raise SystemExit(0)

executable = parts[0].rsplit("/", 1)[-1]
if executable != "git" or parts[1] != "commit":
    raise SystemExit(0)

messages = []
i = 2

while i < len(parts):
    part = parts[i]

    if part in ("-m", "--message"):
        if i + 1 >= len(parts):
            raise SystemExit(0)

        messages.append(parts[i + 1])
        i += 2
        continue

    if part.startswith("--message="):
        messages.append(part.split("=", 1)[1])
    elif part in ("-F", "--file") or part.startswith("--file="):
        raise SystemExit(0)

    i += 1

if messages:
    sys.stdout.write("\n\n".join(messages))
'
)"

if [[ -z "${commit_message}" ]]; then
  exit 0
fi

commitlint_output="$(
  printf '%s\n' "${commit_message}" |
    commitlint --config "${commitlint_config}" 2>&1
)" || commitlint_status=$?

commitlint_status="${commitlint_status:-0}"

if [[ "${commitlint_status}" -eq 0 ]]; then
  exit 0
fi

printf '%s\n' 'Warning: commitlint rejected the inline git commit message.' >&2
printf '%s\n' "${commitlint_output}" >&2
exit 0
