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
- `one()` already fetches one record. Add `limit(1)` only when it makes a reused query's intent clearer.

### AR Runtime Pitfalls

- **Related model persistence**: `$model->relation->field = $value` changes the related object when the relation resolves to an object, but it does not persist the change. Read it into a local variable when an explicit null guard and save are needed: `$rel = $model->relation; if ($rel === null) { return; } $rel->field = $value; $rel->save()`.
- **Null safety inconsistency**: A nullsafe chain `$model->relation?->field` in a condition does not guarantee `$model->relation` is non-null on the next line. Direct `$model->relation->field = $value` will throw "Attempt to assign property on null". Add an explicit null guard before any direct access.
- **Relation cache after external changes**: A local `$rel->save()` normally updates the same related object already held by the parent. Refresh the relation when another query, a database trigger, or a re-assignment can have changed the stored value.

## Review Checklist

- Is validation explicit at the boundary?
- Is authorization consistent with RBAC or service-level policy checks?
- Are controllers thin and services carrying workflow logic?
- Are Active Record queries eager-loaded and bounded appropriately?
- Do tests cover the relevant request, validation, and persistence flow?
- Are AR relation accesses free of indirect modification and null safety inconsistencies?
- Does the implementation match the stated task requirements — are the right abstractions used, is logic placed in the right layer, and are the architectural decisions sound?
- Can deeply nested conditions be flattened with early returns or combined into a single condition?
