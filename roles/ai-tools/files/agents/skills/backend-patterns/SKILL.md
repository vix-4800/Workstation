---
name: backend-patterns
description: Use for PHP backend refactors and reviews involving controllers, services, repositories, transactions, query performance, caching, jobs, and error handling in Yii2, Laravel, or Symfony.
metadata:
  short-description: Backend architecture patterns for PHP applications
---

# Backend Patterns

Use this skill when structuring or reviewing server-side PHP code. The goal is clear boundaries, predictable side effects, and code that stays maintainable as the application grows.

Load `modern-php` with this skill when the task includes language features, strict typing, or tool-driven refactors.

## When to Activate

- Designing or refactoring backend architecture
- Splitting work between controllers, services, repositories, and handlers
- Optimizing database access and eliminating N+1 queries
- Adding caching, background jobs, or asynchronous workflows
- Defining transaction boundaries and error translation
- Reviewing backend code for maintainability or scale risks

## Core Principles

1. Keep transport, business logic, and persistence concerns separate.
2. Use the simplest architecture that fits the current codebase.
3. Do not add repository or service layers just because they are fashionable.
4. Make side effects explicit: writes, external calls, cache invalidation, and queued work should be obvious.
5. Translate exceptions at the boundary where they become HTTP or CLI output.

## Application Boundaries

### Controller Or Action

Responsibilities:

- Parse the request.
- Authorize the action.
- Validate input.
- Call an application service or handler.
- Map result to an HTTP response.

Non-responsibilities:

- Database orchestration.
- Business-rule branching.
- Cache invalidation strategy.
- Direct cross-service workflow logic.

### Service Or Handler

Responsibilities:

- Execute use cases.
- Coordinate repositories, domain objects, and integrations.
- Own transaction boundaries when multiple writes must succeed together.
- Emit events or dispatch jobs when that is part of the use case.

### Repository Or Query Object

Responsibilities:

- Encapsulate non-trivial persistence access.
- Expose a clear API for reads and writes that the application layer needs.
- Batch or eager-load related data where needed.

Do not add repositories for trivial pass-through CRUD if the current framework conventions do not benefit from them.

## Example Flow

```php
final class CreateOrderAction
{
    public function __construct(
        private readonly OrderService $orders,
    ) {
    }

    public function __invoke(CreateOrderRequest $request): JsonResponse
    {
        $order = $this->orders->create($request->toDto());

        return new JsonResponse([
            'data' => [
                'id' => $order->id,
            ],
        ], 201);
    }
}
```

The controller stays at the boundary. Validation and mapping happen at the edge; business orchestration happens below it.

## Data Access Patterns

### Query Optimization

- Select only the columns you need.
- Use eager loading or explicit batch queries for related records.
- Avoid loading large object graphs when a summary projection is enough.
- Prefer database-side filtering and sorting over in-memory filtering.

### N+1 Prevention

- Laravel: eager load with `with()` and constrain relationships intentionally.
- Yii2: use `with()`/`joinWith()` thoughtfully and watch generated SQL.
- Symfony/Doctrine: use fetch joins or repository queries designed for the view model.

### Transactions

Use a transaction when one use case coordinates multiple writes or state transitions.

Rules:

- Keep the transaction scope small.
- Do not perform slow remote HTTP calls inside a database transaction unless the workflow explicitly requires it.
- Prefer post-commit jobs or outbox/event patterns for external side effects.

## Caching

Use caching to remove repeated expensive reads, not to hide broken query design.

Patterns:

- Cache-aside for read-heavy objects.
- Short-lived query/result caching for dashboards or expensive aggregations.
- Explicit invalidation on writes.
- Per-user or per-tenant scoping where data visibility differs.

Rules:

- Define cache keys deterministically.
- Include tenant/user/context when required.
- Choose TTLs intentionally.
- Make stale-data tradeoffs explicit.

## Background Jobs And Async Work

Queue work when it is slow, retryable, or not required for the immediate response:

- Emails, notifications, exports, webhooks
- Long-running imports or report generation
- External API syncs

Rules:

- Keep job payloads small and serializable.
- Make handlers idempotent.
- Use retries only for transient failure modes.
- Record enough context to diagnose failures without logging secrets.

## Error Handling

- Throw domain-specific exceptions inside the application layer.
- Catch and translate them at the boundary.
- Return stable API errors instead of framework exception dumps.
- Log enough context to debug, but never log secrets, tokens, or sensitive payloads.

## Framework Guidance

- Yii2: use services and form models to stop controllers and Active Record classes from accumulating workflow logic.
- Laravel: keep controllers thin, use jobs/events where the app already relies on them, and prefer service classes or actions for multi-step use cases.
- Symfony: keep controllers small, use services for orchestration, and keep entity logic focused on domain invariants rather than transport concerns.

## Review Checklist

- Are responsibilities split cleanly between controller, service, and persistence layers?
- Is the chosen architecture proportional to the complexity of the use case?
- Are transaction boundaries explicit and minimal?
- Are N+1 queries or over-fetching risks addressed?
- Is caching solving a real bottleneck with clear invalidation?
- Are background jobs idempotent and appropriately scoped?
- Are exceptions translated cleanly at the boundary?
