---
paths:
  - '**/*.sh'
  - 'bin/*'
  - 'roles/*/scripts/*'
---

- Use `#!/usr/bin/env bash` for bash scripts and `set -euo pipefail`.
- Quote variable expansions unless word splitting is intentional.
- Use `local` inside bash functions.
- Run `shellcheck` when available and do not use Fish syntax in role scripts.
