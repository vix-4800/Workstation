---
paths:
  - '**/*.php'
---

- Add `declare(strict_types=1)` at the top of every file.
- Never use debug helpers (`var_dump`, `dd`, `dump`, `print_r`, `console.log`) in committed code.
- Declare explicit types for all function parameters and return values.
- Use readonly classes and constructor property promotion where applicable.
- Typed exceptions — throw specific exception types, never bare `\Exception`.
- Use abstract and final class modifiers appropriately.
- Prefer dependency injection over service location or static access.
- Never use `empty()`, `isset()` for type-checking — use explicit comparisons.
- Never use `@` error suppression.
- Prefer `vendor/bin/phpcs`, `vendor/bin/phpstan`, and `vendor/bin/rector` after changes when available.
- Use `modern-php` skill for implementation; `security-review` for input, output, auth, and secrets.
