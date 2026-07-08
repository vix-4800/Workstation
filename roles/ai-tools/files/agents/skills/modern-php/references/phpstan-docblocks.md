# PHPStan DocBlocks Reference

Use only when writing or reviewing non-trivial PHPDoc/PHPStan annotations.
PHPDoc must refine native PHP types, not repeat them.

## Core rules

- Native PHP types first: parameters, returns, properties, enums, `readonly`, `final`.
- Add PHPDoc only when PHP cannot express the contract precisely.
- Do not duplicate native types: avoid `@param int $id` for `int $id`.
- Do not leave meaningful `array`, `iterable`, `callable`, or `mixed` unexplained.
- Prefer the narrowest truthful PHPStan type.
- Use `/** ... */`; plain `/* ... */` is not PHPDoc.
- Keep annotations honest. PHPStan trusts PHPDoc.

Bad:

```php
/** @param int $id @return User|null */
public function find(int $id): ?User {}
```

Good:

```php
/** @return list<User> */
public function findActiveUsers(): array {}
```

## Type selection

When native type is too broad, refine it:

- `string` → `non-empty-string`, `numeric-string`, `literal-string`, `lowercase-string`, `class-string<T>`.
- `int` → `positive-int`, `non-negative-int`, `int<min, max>`, `int-mask-of<...>`.
- `array` → `list<T>`, `non-empty-list<T>`, `array<TKey, TValue>`, `array{...}`.
- `iterable` → `iterable<TKey, TValue>`.
- `Generator` → `Generator<TKey, TValue, TSend, TReturn>`.
- `callable` → `callable(Arg): Return` or `Closure(Arg): Return`.
- repeated complex shape → `@phpstan-type`.
- input-output type relation → `@template` or conditional return type.
- custom guard/helper → `@phpstan-assert*`.

## Strings

Use precise string types when validation or construction guarantees them.

```php
/**
 * @param non-empty-string $email
 * @param numeric-string $amount
 */
public function handle(string $email, string $amount): void {}
```

- `non-empty-string`: IDs, emails, slugs, tokens, filenames, normalized names.
- `numeric-string`: numeric data received as strings.
- `literal-string`: developer-authored SQL, shell, HTML, or template fragments.
- `lowercase-string` / `uppercase-string`: normalized keys and codes.
- `class-string<T>`: factories, containers, hydrators, serializers, reflection.

## Integers

Use bounded integer types when the domain has limits.

```php
/**
 * @param positive-int $page
 * @param int<1, 100> $perPage
 */
public function paginate(int $page, int $perPage): Page {}
```

- `positive-int`: IDs, page numbers, positive counts.
- `non-negative-int`: offsets, retry counts, indexes, sizes.
- `int<0, 100>`: percent/rating/progress.
- `int<1, max>`: lower-bounded values.
- `int-mask<1, 2, 4>` / `int-mask-of<Self::FLAG_*>`: bit flags.

## Arrays and iterables

Never document a known array as bare `array`.

```php
/** @return list<User> */
public function all(): array {}

/** @return array<positive-int, User> */
public function byId(): array {}

/** @param non-empty-list<positive-int> $ids */
public function deleteMany(array $ids): void {}
```

- `list<T>`: sequential zero-based array.
- `non-empty-list<T>`: list with at least one item.
- `array<TKey, TValue>`: map.
- `non-empty-array<TKey, TValue>`: non-empty map.
- `iterable<TKey, TValue>`: array or `Traversable`.
- `Generator<TKey, TValue, TSend, TReturn>`: generator.

## Array shapes

Use shapes for validated request data, decoded JSON, config, API responses, and short-lived DTO-like arrays.

```php
/**
 * @return array{
 *     id: positive-int,
 *     email: non-empty-string,
 *     roles: list<non-empty-string>,
 *     lastLoginAt?: non-empty-string
 * }
 */
public function payload(User $user): array {}
```

- `foo: Type`: required key.
- `foo?: Type`: optional key.
- `array{foo: int, ...}`: unknown extra keys are allowed.
- `array{foo: int, ...<string, mixed>}`: typed extra keys are allowed.
- `object{foo: int, bar?: string}`: object shape.

Prefer a DTO/value object when the shape becomes long-lived domain data.

## Aliases

Use `@phpstan-type` for repeated or large shapes. Import aliases instead of copying them.

```php
/**
 * @phpstan-type UserPayload array{
 *     id: positive-int,
 *     email: non-empty-string,
 *     roles: list<non-empty-string>
 * }
 */
final class UserPayloadFactory
{
    /** @return UserPayload */
    public function create(User $user): array {}
}

/** @phpstan-import-type UserPayload from UserPayloadFactory */
final class UserPayloadExporter
{
    /** @param UserPayload $payload */
    public function export(array $payload): string {}
}
```

Rule: if a shape is longer than 3-5 lines and appears more than once, alias it.

## Constants, enums, class strings

- `key-of<Foo::MAP>`: allowed constant-map keys.
- `value-of<Foo::MAP>`: allowed constant-map values.
- `value-of<SomeBackedEnum>`: enum backing values.
- `SomeEnum::Case`: exactly one enum case.
- `class-string`: valid class-name string.
- `class-string<T>`: valid class name of `T` or subtype.

```php
/**
 * @param key-of<self::DEFAULTS> $key
 * @return value-of<self::DEFAULTS>
 */
public function getDefault(string $key): string {}

/**
 * @template T of object
 * @param class-string<T> $class
 * @return T
 */
public function make(string $class): object {}
```

A plain string can be narrowed to `class-string` with `class_exists($class)`.

## Generics

Use templates when exact input/output relationships must be preserved.

```php
/**
 * @template T
 * @param T $value
 * @return T
 */
public function identity(mixed $value): mixed {}

/**
 * @template T of Animal
 * @param T $animal
 * @return T
 */
public function cloneAnimal(Animal $animal): Animal {}
```

Bind generic parents, interfaces, and traits:

```php
/** @implements Repository<User> */
final class UserRepository implements Repository {}

/** @use HasItems<User> */
final class UserCollection { use HasItems; }
```

Use `@template-covariant` only for read-only producers of `T`.
Use `@template-contravariant` only for consumers of `T`, such as validators or handlers.

## Conditional return types

Use when return type depends on an argument and stays readable.

```php
/** @return ($asFloat is true ? float : string) */
public function now(bool $asFloat): string|float {}

/**
 * @template T of int|list<int>
 * @param T $id
 * @return (T is int ? User : list<User>)
 */
public function fetch(int|array $id): User|array {}
```

Prefer separate methods if the conditional type becomes complex.

## Callable signatures

Do not use bare `callable` when the signature is known.

```php
/**
 * @param list<User> $users
 * @param callable(User): bool $filter
 * @return list<User>
 */
public function filterUsers(array $users, callable $filter): array {}
```

Supported forms: `callable(string, int=): void`, `callable(string, int...): void`, `Closure(User): Response`.
Optional tags: `@param-immediately-invoked-callable`, `@param-later-invoked-callable`, `@param-closure-this Context $callback`.

## Assertions

Use assertion tags for guard helpers. PHPStan does not infer custom guard semantics automatically.

```php
/** @phpstan-assert non-empty-string $value */
public function assertNonEmptyString(string $value): void {}

/** @phpstan-assert-if-true User $value */
public function isUser(mixed $value): bool {}

/** @phpstan-assert-if-false non-empty-string $value */
public function isEmptyString(string $value): bool {}

/** @phpstan-assert-if-true =Admin $this->admin */
public function hasActiveAdmin(): bool {}
```

Use `=Type` when the true branch should narrow but the false branch should not imply the opposite.

## Inline `@var`

Use inline `@var` rarely. Prefer runtime checks, assertion helpers, precise return types, or shaped return types.

```php
/** @var array{id: positive-int, email: non-empty-string}|null $payload */
$payload = json_decode($json, true);
```

Do not use `@var` to silence real uncertainty, such as forcing `User` when a repository can return `null`.

## PHPStan-prefixed tags

Prefer normal `@param`, `@return`, and `@var` with PHPStan syntax.
Use `@phpstan-param`, `@phpstan-return`, or `@phpstan-var` only when another tool cannot parse the advanced type.

```php
/**
 * @param array $payload
 * @phpstan-param array{id: positive-int, email: non-empty-string} $payload
 */
public function handle(array $payload): void {}
```

## Magic API

Use magic annotations only for existing magic APIs. Do not introduce new magic for PHPDoc.

```php
/**
 * @property-read positive-int $id
 * @property non-empty-string $name
 * @method bool isAdmin()
 * @mixin QueryBuilder<User>
 */
final class UserModel {}
```

## Exceptions and API tags

Use `@throws` on public APIs and boundaries where callers need to handle specific exceptions.
Do not add `@throws` to every private helper unless it documents a real contract.

Use only when meaningful: `@internal`, `@api`, `@since`, `@see`, `@link`, `@inheritDoc`.
Prefer native features when available: `final`, `readonly`, `readonly class`, `#[\Deprecated]`.

## Final checklist

- Native types are present wherever PHP can express them.
- PHPDoc does not duplicate native types.
- Non-trivial arrays use `list<T>`, `array<TKey, TValue>`, or `array{...}`.
- Known callables have signatures.
- Dynamic class names use `class-string` or `class-string<T>`.
- Validated strings and integers use precise PHPStan types.
- Repeated large shapes use `@phpstan-type`.
- Assertion tags match real runtime checks.
- Inline `@var` is not hiding a missing null/type check.
- PHPStan passes at the project's configured level.
