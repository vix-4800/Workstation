# PHP 8.3-8.5 Reference

Use this reference when deciding whether a language or standard-library feature is available in the target runtime.

## Official Release References

- PHP 8.3 release notes: <https://www.php.net/releases/8.3/en.php>
- PHP 8.4 release notes: <https://www.php.net/releases/8.4/en.php>
- PHP 8.5 release notes: <https://www.php.net/releases/8.5/en.php>

## Selection Rules

1. Detect the real runtime floor first from `composer.json`, CI, Docker images, or deployment config.
2. Use the newest feature that the project runtime actually supports, not the newest feature that exists.
3. When targeting a shared package or library, bias toward the lowest supported PHP version in that package.
4. Prefer native language features over annotations or helper abstractions when the runtime supports them.

## PHP 8.3 Highlights

- Typed class constants.
- Dynamic class constant fetch.
- `#[\Override]`.
- `json_validate()`.
- Deep-cloning of readonly properties.
- Randomizer additions.

Use 8.3 features freely in repos that already require PHP 8.3+.

## PHP 8.4 Highlights

- Property hooks.
- Asymmetric property visibility.
- Native `#[\Deprecated]`.
- `array_find()`, `array_find_key()`, `array_any()`, `array_all()`.
- `mb_trim()`, `mb_ltrim()`, `mb_rtrim()`, `mb_ucfirst()`, `mb_lcfirst()`.
- New DOM API under the `Dom\` namespace.
- Lazy objects and additional rounding/date helpers.

Property hooks are powerful, but use them where they simplify a real invariant or computed property. Do not replace a
simple typed property with hooks unless there is actual logic to enforce.

## PHP 8.5 Highlights

PHP 8.5 was released on November 20, 2025.

- Pipe operator `|>`.
- Clone-with syntax via `clone($object, [...])`.
- `#[\NoDiscard]`.
- URI extension.
- Closures and first-class callables in constant expressions.

Treat 8.5 features as opt-in. Verify that the deployment target, CI image, and static-analysis tooling all support 8.5
before using them.

## Practical Guidance

- Prefer `#[\Override]` over relying on convention when 8.3+ is guaranteed.
- Prefer native `#[\Deprecated]` over docblock `@deprecated` when 8.4+ is guaranteed.
- Prefer `json_validate()` over `json_decode()`-based validation when 8.3+ is guaranteed.
- Prefer `array_find()` and friends over ad-hoc loops when 8.4+ is guaranteed and the callback is simple.
- Prefer 8.5 pipe chains only when they materially improve readability over a few clear statements.
