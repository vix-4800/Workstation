---
paths:
  - '**/*.php'
---

- Verify `declare(strict_types=1);` is present.
- Flag `dd`, `dump`, `var_dump`, and `print_r`.
- Prefer `vendor/bin/phpcs`, `vendor/bin/phpstan`, and project PHP test tooling after changes when available.
- Use `modern-php` for implementation guidance and `security-review` for input, output, auth, and secret handling.
