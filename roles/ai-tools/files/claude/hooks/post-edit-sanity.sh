#!/usr/bin/env bash

set -euo pipefail

input="$(cat)"
file_path="$(printf '%s' "${input}" | jq -r '.tool_input.file_path // empty')"

if [[ -z "${file_path}" || ! -f "${file_path}" ]]; then
  exit 0
fi

case "${file_path}" in
  *.php)
    php -l "${file_path}"

    if grep -nE '\b(dd|dump|var_dump|print_r)\s*\(' "${file_path}" >/dev/null; then
      printf 'Warning: debug helper detected in %s\n' "${file_path}" >&2
    fi
    ;;
  *.json)
    jq empty "${file_path}" >/dev/null
    ;;
  *.go)
    if command -v gofmt >/dev/null 2>&1; then
      gofmt -e "${file_path}" >/dev/null 2>&1
    fi
    ;;
  *.sh)
    bash -n "${file_path}"
    ;;
  *.toml)
    if command -v python3 >/dev/null 2>&1; then
      python3 -c 'import sys, tomllib; tomllib.load(open(sys.argv[1], "rb"))' "${file_path}" 2>&1
    fi
    ;;
  *.lua)
    if command -v luac >/dev/null 2>&1; then
      luac -p "${file_path}" 2>&1
    fi
    ;;
  *.yml|*.yaml)
    if command -v yamllint >/dev/null 2>&1; then
      yamllint -d relaxed "${file_path}" 2>&1
    fi
    ;;
  *)
    exit 0
    ;;
esac

exit 0
