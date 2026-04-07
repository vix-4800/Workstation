# AI Coding Agent Instructions

## Behaviour

- When a task is ambiguous, ask one targeted question — do not assume and implement both paths.
- Read existing code before modifying. When Serena MCP is available, prefer `get_symbols_overview` and `find_symbol`
  over reading whole files.
- Do not summarise what you just did. State what changed and why in one or two sentences.
- Never use emojis in code, comments, or commit messages.

## Skills

Use the smallest relevant set for the task.

- `ansible-patterns` — Ansible roles, tasks, handlers, templates, idempotency.
- `api-design` — REST contracts, pagination, filtering, error formats, idempotency.
- `backend-patterns` — service/repository boundaries, transactions, caching, jobs.
- `code-review` — PR reviews, diff analysis, regression hunting.
- `coding-standards` — refactoring, naming, structure, consistency.
- `database-patterns` — schema, migrations, indexes, query behaviour, ORM.
- `laravel-patterns` — Laravel controllers, Form Requests, policies, Eloquent.
- `modern-php` — PHP implementation, static-analysis fixes, PHP 8.3+ conventions.
- `security-review` — auth, input, uploads, secrets, external URLs, webhooks.
- `testing-strategy` — what tests to add, how deep, coverage gaps.
- `yii2-patterns` — Yii2 controllers, form models, services, RBAC, Active Record.

**Heuristics:**

- PHP → `modern-php` + framework skill. Backend/feature → add `backend-patterns`. DB change → add `database-patterns`.
- API → add `api-design` + `security-review`. Review → `code-review` + domain skill.
- Any trust boundary → `security-review` is mandatory.

## Security (non-negotiable)

- Validate at every trust boundary. Parameterised queries only — never concatenate user data into SQL.
- No secrets in code — use environment variables or a secrets manager.
- Least privilege for DB users, service accounts, and file permissions.
- Sanitise output for context: HTML-escape for HTML, shell-escape for shell.
- No custom crypto. Validate file uploads server-side. Guard against SSRF.

## Version Control

- Conventional Commits: `feat:`, `fix:`, `refactor:`, `chore:`, `test:`, `docs:`.
- One logical change per commit. No debug code (`var_dump`, `dd()`, `console.log`) in committed files.

## Constraints

Do only what is asked. Never without explicit request:

- Refactor code outside the immediate task.
- Add logging, metrics, or feature flags.
- Create abstractions or base classes for future flexibility.
- Create markdown summaries, changelogs, or explanatory documents.
- Add `TODO`/`FIXME` — either fix it now or raise it with the user.
