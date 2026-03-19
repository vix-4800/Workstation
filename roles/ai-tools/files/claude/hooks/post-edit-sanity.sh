#!/usr/bin/env bash

set -euo pipefail

input="$(cat)"
file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"

if [[ -z "$file_path" || ! -f "$file_path" ]]; then
  exit 0
fi

case "$file_path" in
  *.php)
    php -l "$file_path"

    if grep -nE '\b(dd|dump|var_dump|print_r)\s*\(' "$file_path" >/dev/null; then
      printf 'Warning: debug helper detected in %s\n' "$file_path" >&2
    fi
    ;;
  *.json)
    jq empty "$file_path" >/dev/null
    ;;
  *.sh)
    bash -n "$file_path"
    ;;
esac

exit 0
