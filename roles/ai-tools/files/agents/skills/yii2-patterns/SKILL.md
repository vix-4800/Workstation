---
name: yii2-patterns
description: Yii2-specific architecture and review patterns for controllers, form models, services, Active Record usage, RBAC, scenarios, and validation boundaries.
metadata:
  short-description: Yii2 conventions for backend implementation and review
---

# Yii2 Patterns

Use this skill when the task touches Yii2 application structure or framework conventions. The goal is to keep controllers small, validation explicit through models or DTO-style objects, and Active Record usage under control.

Load `modern-php` for language-level guidance, `backend-patterns` for broader architecture decisions, and `security-review` for auth, input, or secret boundaries.

## When to Activate

- Implementing or reviewing Yii2 controllers, form models, services, or console actions
- Deciding where validation, scenarios, and authorization belong
- Reviewing Active Record relation loading, transactions, or query structure
- Planning tests for Yii2 application behaviour

## Core Conventions

- Keep controllers and actions at the HTTP or CLI boundary.
- Use form models, request models, or explicit mappers for validation.
- Keep business workflows in services when they span multiple models or integrations.
- Use RBAC or explicit policy checks for authorization.
- Treat scenarios as validation and state-shaping tools, not as a substitute for service boundaries.

## Active Record Review

- Avoid putting broad workflow logic directly into AR models.
- Use `with()` or `joinWith()` intentionally to prevent N+1 queries.
- Keep transactions explicit around multi-write use cases.
- Prefer dedicated query methods when AR queries become dense or reused.
- Always use `limit(1)` when fetching a single record via `one()`.

### AR Runtime Pitfalls

- **Indirect modification of overloaded property**: `$model->relation->field = $value` calls `__get` which returns a copy — the assignment is silently discarded and PHP emits "Indirect modification of overloaded property has no effect". Always assign the relation to a local variable first: `$rel = $model->relation; $rel->field = $value; $rel->save()`.
- **Null safety inconsistency**: A nullsafe chain `$model->relation?->field` in a condition does not guarantee `$model->relation` is non-null on the next line. Direct `$model->relation->field = $value` will throw "Attempt to assign property on null". Add an explicit null guard before any direct access.
- **Stale relation after re-assignment**: After modifying and saving a related model, the parent's in-memory relation cache may be stale. Do not read `$parent->relation->field` after mutating it through a local variable without refreshing.

## Review Checklist

- Is validation explicit at the boundary?
- Is authorization consistent with RBAC or service-level policy checks?
- Are controllers thin and services carrying workflow logic?
- Are Active Record queries eager-loaded and bounded appropriately?
- Do tests cover the relevant request, validation, and persistence flow?
- Are AR relation accesses free of indirect modification and null safety inconsistencies?
- Does the implementation match the stated task requirements — are the right abstractions used, is logic placed in the right layer, and are the architectural decisions sound?
- Can deeply nested conditions be flattened with early returns or combined into a single condition?
