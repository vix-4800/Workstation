---
paths:
  - '**/*.php'
---

- Verify `declare(strict_types=1);` is present.
- Flag `dd`, `dump`, `var_dump`, and `print_r`.
- Explicit types on all properties, methods, and parameters.
- Use `readonly` properties and constructor promotion (PHP 8.x) where appropriate.
- Throw specific typed exceptions. Never `throw new \Exception()` for a known failure mode.
- Classes are `abstract` or `final` unless the framework requires otherwise.
- Depend on abstractions. Inject dependencies; do not instantiate inside business logic.
- Avoid `empty()`, `isset()` for logic, `is_null()`, and `@` error suppression — prefer explicit checks.
- Prefer `vendor/bin/phpcs`, `vendor/bin/phpstan`, and `vendor/bin/rector` after changes when available.
- Use `modern-php` skill for implementation; `security-review` for input, output, auth, and secrets.
