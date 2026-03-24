---
name: modern-php
description: >
  Use for PHP 8.3-8.5 implementation, bug fixes, refactors, debugging, and
  code review in Yii2, Laravel, or Symfony projects using Composer, PHPStan,
  phpcs, rector, phpmd, php-cs-fixer, PHPUnit, or Pest.
license: MIT
metadata:
  version: "1.0.0"
  domain: language
  triggers: PHP, Yii2, Laravel, Symfony, Composer, PHPStan, phpcs, rector, phpmd, php-cs-fixer, PHPUnit, Pest, PSR
  role: specialist
  scope: implementation
  output-format: code
---

# Modern PHP

Senior PHP developer specialising in PHP 8.3-8.5, Yii2, Laravel, and Symfony with strict typing, PSR-12, and static-analysis-first delivery.

## Load References When Needed

| Topic | Reference | Load when |
|---|---|---|
| PHP 8.3-8.5 features | `references/php-8.3-8.5.md` | Selecting language features or checking version support |
| Framework conventions | `references/framework-conventions.md` | Working inside Yii2, Laravel, or Symfony |
| Quality gates | `references/tooling-and-verification.md` | Running or interpreting phpcs/phpstan/rector/phpmd/php-cs-fixer/tests |

## Core Workflow

1. Detect the real target first: PHP version floor, framework, coding style, and local quality gates.
2. Implement the smallest change that fits the current architecture instead of importing patterns from another framework.
3. Prefer strict typing, constructor injection, value objects, enums, and framework-native validation/authorization patterns.
4. Verify with the repo's own local tools before finishing. If a tool is missing or misconfigured, say so explicitly.

## Core Constraints

### MUST DO

1. Add `declare(strict_types=1);` to every PHP file unless the project explicitly exempts that file class.
2. Use explicit parameter, return, and property types. Avoid implicit `mixed`.
3. Follow PSR-12 formatting with 4-space indentation and a 120-character line limit.
4. Use short array syntax `[]`.
5. Use strict comparisons. Prefer `===` and `!==`.
6. Prefer constructor property promotion and `readonly` where it matches the model.
7. Add `#[\Override]` when overriding inherited methods or properties on supported PHP versions.
8. Prefer `final` or `abstract` classes unless the framework requires extension points.
9. Prefer explicit null/empty checks such as `=== null` and `$items === []`.
10. Use early returns and keep nesting shallow.
11. Use `JSON_THROW_ON_ERROR` for JSON encoding and decoding unless the surrounding API already guarantees exception-safe wrappers.
12. Keep cyclomatic complexity, method length, and parameter count within the local tool thresholds.
13. Use `password_hash($plainTextPassword, PASSWORD_ARGON2ID)` for password storage unless the framework already wraps this safely.
14. Prefer repository-local binaries and config files for verification over global defaults.
15. Use `json_validate($input)` as an early guard before `json_decode()` whenever the input crosses a trust boundary (HTTP, file, external API). Reject and return immediately if validation fails; do not attempt to decode invalid JSON.
16. After `json_decode()`, annotate the result variable with an inline `@var array{...}|null` doc block that fully describes the expected shape. This gives phpstan structural type information and documents the contract.
17. Add PHPDoc with `@param` (including full array shape) and `@return` on ALL methods — including private — when a parameter or return type is `array` with a non-trivial structure. When native types fully express the contract and no shape detail is needed, PHPDoc may be omitted.
18. Use `sprintf()` for strings that embed variable values inside HTML attribute quotes. Never use double-quoted interpolation with backslash-escaped inner quotes such as `"<tag attr=\"{$val}\""`.
19. Use single-quoted strings for all literals that contain no variable interpolation or PHP escape sequences. Use double-quoted strings only when interpolation or sequences such as `\n` are needed.
20. No column-alignment of variable assignments or match/array arms. Use exactly one space on each side of `=` and `=>`. Never pad with extra spaces to achieve visual alignment.

### MUST NOT DO

1. Do not leave `var_dump`, `dd`, `dump`, `print_r`, or `var_export` in committed code.
2. Do not use `compact`, `extract`, `eval`, or `call_user_func` in application code.
3. Do not use `@` error suppression.
4. Do not use variable variables such as `$$name`.
5. Do not access `$_GET`, `$_POST`, `$_REQUEST`, and other superglobals outside bootstrap or framework boundaries.
6. Do not rely on PhpStorm-only attributes such as `ArrayShape`, `ExpectedValues`, `Pure`, or `NoReturn`.
7. Do not add `@deprecated` when native `#[\Deprecated]` is available for the target PHP version.
8. Do not leave empty catch blocks.
9. Do not place business logic in controllers, console commands, or Active Record models when a service or domain class is the proper boundary.
10. Do not instantiate service dependencies with `new` inside business logic when constructor injection is available.
11. Do not use double-quoted strings for literals that contain no interpolation or escape sequences. Do not pad `=` or `=>` with extra spaces to column-align assignments or match/array arms.

## PHP Version Features Quick Reference

| Feature | Since | Syntax |
|---|---|---|
| Readonly properties | 8.1 | `public readonly string $name` |
| Enums | 8.1 | `enum Status: string {}` |
| Fibers | 8.1 | `new \Fiber(static fn() => null)` |
| First-class callables | 8.1 | `$callable = $service->handle(...)` |
| `never` return type | 8.1 | `function fail(): never` |
| Intersection types | 8.1 | `Countable&Stringable $value` |
| Readonly classes | 8.2 | `readonly class Money {}` |
| DNF types | 8.2 | `(A&B)|null $value` |
| Typed class constants | 8.3 | `public const string VERSION = '1.0'` |
| Dynamic class constant fetch | 8.3 | `Foo::{$name}` |
| `#[\Override]` | 8.3 | `#[\Override] public function boot(): void` |
| `json_validate()` | 8.3 | `json_validate($payload)` |
| Deep-clone readonly properties | 8.3 | `public function __clone(): void { ... }` |
| Property hooks | 8.4 | `public string $name { get => ...; set => ...; }` |
| Asymmetric visibility | 8.4 | `public private(set) string $id` |
| `#[\Deprecated]` | 8.4 | `#[\Deprecated(message: 'Use newMethod()')]` |
| New DOM API | 8.4 | `Dom\HTMLDocument::createFromString(...)` |
| `array_find()` and friends | 8.4 | `array_find($items, static fn($item) => ...)` |
| Lazy objects | 8.4 | `$reflection->newLazyProxy(...)` |
| `mb_trim()` family | 8.4 | `mb_trim($value)` |
| Pipe operator | 8.5 | `$value |> trim(...) |> strtolower(...)` |
| Clone-with | 8.5 | `clone($dto, ['name' => $name])` |
| `#[\NoDiscard]` | 8.5 | `#[\NoDiscard] function parse(): Result` |
| URI extension | 8.5 | `new Uri\Rfc3986\Uri($url)` |

Use only features supported by the target runtime. PHP 8.5 was released on November 20, 2025; verify project runtime support before introducing 8.5-only syntax.

## Code Patterns

Use framework-agnostic examples for shared logic. Keep framework-specific helpers in framework layers, not in DTOs, enums, or domain services.

### Readonly DTO

```php
<?php

declare(strict_types=1);

final readonly class CreateUserData
{
    public function __construct(
        public string $name,
        public string $email,
        public string $plainTextPassword,
    ) {
    }
}
```

### Typed Service With Constructor Injection

```php
<?php

declare(strict_types=1);

final class UserCreator
{
    public function __construct(
        private readonly UserRepositoryInterface $users,
    ) {
    }

    public function create(CreateUserData $data): User
    {
        return $this->users->create(
            name: $data->name,
            email: $data->email,
            passwordHash: password_hash($data->plainTextPassword, PASSWORD_ARGON2ID),
        );
    }
}
```

### Backed Enum With Behaviour

```php
<?php

declare(strict_types=1);

enum UserStatus: string
{
    case Active = 'active';
    case Inactive = 'inactive';
    case Banned = 'banned';

    public function label(): string
    {
        return match ($this) {
            self::Active => 'Active',
            self::Inactive => 'Inactive',
            self::Banned => 'Banned',
        };
    }
}
```

### Property Hooks For Boundary Validation

```php
<?php

declare(strict_types=1);

final class Temperature
{
    public float $celsius {
        set (float $value) {
            if ($value < -273.15) {
                throw new \InvalidArgumentException('Temperature cannot be below absolute zero.');
            }

            $this->celsius = $value;
        }
    }

    public function __construct(float $celsius)
    {
        $this->celsius = $celsius;
    }
}
```

### JSON Input Guard With Structural Annotation

```php
<?php

declare(strict_types=1);

// 1. Validate syntax before touching the data.
if (!json_validate($json)) {
    return null;
}

/**
 * @var array{
 *   blocks: array<int, array{
 *     type: string,
 *     data: array{text?: string, level?: int}
 *   }>
 * }|null $data
 */
$data = json_decode($json, true);

// 2. Guard against structural mismatch after decode.
if (!is_array($data) || !isset($data['blocks']) || !is_array($data['blocks'])) {
    return null;
}
```

### sprintf() for HTML Attribute Strings

```php
// Avoid: backslash escapes inside double-quoted interpolation.
$img = "<img src=\"{$src}\" alt=\"{$caption}\">";

// Prefer: sprintf with single-quoted template.
$img = sprintf('<img src="%s" alt="%s">', $src, $caption);
```

## Framework Guidance

- Follow the framework already present in the repo. Do not import Laravel patterns into Yii2, or Symfony patterns into Laravel.
- Prefer framework-native validation, authorization, queue, and DI primitives before inventing custom abstractions.
- Keep controllers/actions thin. Input mapping, business rules, and persistence orchestration belong in services, handlers, or domain classes.
- Treat Active Record, Eloquent models, and Doctrine entities as persistence boundaries, not as dumping grounds for unrelated business logic.

Load `references/framework-conventions.md` before implementing framework-specific code paths.

## Verification

Run the smallest relevant verification set for the touched scope:

1. `phpcs` for style and forbidden patterns.
2. `phpstan` for type safety, override attributes, exception contracts, and strict rules.
3. `rector --dry-run` for modernisation drift and automated refactor expectations.
4. `phpmd` for complexity and design regressions.
5. `php-cs-fixer --dry-run` if the project uses it.
6. `phpunit` or `pest` for behavioural coverage.

Use repo-local binaries such as `vendor/bin/...` when available. Load `references/tooling-and-verification.md` for command patterns and config-derived expectations.
