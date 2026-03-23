#!/usr/bin/env bash
set -euo pipefail

output=$(arch-audit --upgradable --quiet 2>/dev/null || true)

if [[ -n "${output}" ]]; then
    count=$(printf '%s\n' "${output}" | wc -l)
    notify-send --urgency=critical \
        --icon=security-high \
        "Security: ${count} fixable vulnerable package(s)" \
        "${output}"
fi
