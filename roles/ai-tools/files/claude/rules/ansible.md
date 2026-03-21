---
paths:
  - 'site.yml'
  - 'inventory/**/*.yml'
  - 'inventory/**/*.yaml'
  - 'roles/**/*.yml'
  - 'roles/**/*.yaml'
---

- Keep YAML indentation at 2 spaces.
- Use FQCN module names and role-plus-type task tags.
- Prefer modules over `shell` or `command`; when shell is unavoidable, make idempotency explicit.
- For workstation configs, keep symlink direction correct: repo path in `src`, target path in `dest`.
- Validate with `just check`, `just plan`, and `ansible-lint` when available.
