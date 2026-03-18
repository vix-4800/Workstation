#!/usr/bin/env bash
set -euo pipefail

output=$(arch-audit --quiet 2>/dev/null || true)

if [[ -n "$output" ]]; then
    count=$(echo "$output" | wc -l)
    notify-send --urgency=critical \
        --icon=security-high \
        "Security: ${count} vulnerable package(s)" \
        "$output"
fi
