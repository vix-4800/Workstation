# Tooling And Verification

Use this reference when running or interpreting the PHP quality gates. These notes are derived from the shared workstation configs.

## Discovery Order

1. Prefer repo-local binaries in `vendor/bin/`.
2. Prefer repo-local config files if the project defines its own.
3. Fall back to shared workstation configs only when the project intentionally uses them.
4. Run the smallest relevant scope that still catches the change safely.

## PHPCS

Key expectations:

- `declare(strict_types=1)` is required in normal PHP files.
- PSR-12 formatting.
- 4-space indentation.
- 120-character line limit, 150 absolute limit.
- Short arrays only.
- Forbidden functions include `var_dump`, `dd`, `dump`, `print_r`, `var_export`, `compact`, `eval`, `extract`, `is_null`, and `call_user_func`.
- `@` error suppression is forbidden.
- Variable variables are forbidden.
- PhpStorm-only attributes are forbidden.
- `@deprecated` annotations are flagged.
- Superglobal access is restricted outside bootstrap-style entry points.
- Nesting depth above 4 is flagged.

Typical command pattern:

```bash
vendor/bin/phpcs --standard=phpcs.xml src
```

## PHPStan

Key expectations:

- `level: max` with bleeding-edge rules.
- Implicit mixed is checked.
- Dynamic properties are checked.
- Missing `#[\Override]` on methods and properties is checked.
- Checked exceptions are enforced more strictly than the PHP default.
- Private property types are inferred from constructors, but explicit typing is still preferred.
- PHPDoc is not treated as fully certain.

Typical command pattern:

```bash
vendor/bin/phpstan analyse --configuration=phpstan.neon
```

## Rector

Key expectations:

- Early-return, coding-style, dead-code, and code-quality sets enabled.
- `JsonThrowOnErrorRector` enabled.
- Override and deprecated attribute migration rules enabled.
- Constructor promotion and additional type-declaration rules enabled.

Typical command pattern:

```bash
vendor/bin/rector process --dry-run --config=rector.php
```

## PHPMD

Key thresholds:

- Cyclomatic complexity: 10.
- NPath complexity: 200.
- Method length: 100 lines.
- Parameter count: 8.
- Class length: 1000 lines.
- Too many fields: 20.
- Too many methods: 25.
- Too many public methods: 20.
- Empty catch blocks are errors.

Typical command pattern:

```bash
vendor/bin/phpmd src,app text phpmd.xml
```

Adjust the target paths to the current project structure.

## PHP-CS-Fixer

Notable expectations:

- Risky rules are enabled.
- `DateTimeImmutable` is preferred.
- Yoda conditions are disabled.
- `is_null()` is rewritten toward strict null comparisons.
- A set of custom fixers reinforces null-safe operators, catch blocks, docblock cleanup, and related style rules.

Typical command pattern:

```bash
vendor/bin/php-cs-fixer fix --dry-run --diff --config=php-cs-fixer.php
```

## Tests

- Use `vendor/bin/phpunit` or `vendor/bin/pest` according to the project.
- Run the narrowest relevant suite first, then widen only if the change touches shared infrastructure.
- For review tasks, explicitly state when tests were not run and why.
