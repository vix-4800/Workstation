---
name: database-patterns
description: Database design and review patterns for schema, indexes, migrations, query performance, transaction boundaries, and ORM usage.
metadata:
  short-description: Schema, migration, index, and query review guidance
---

# Database Patterns

Use this skill when the task touches schema design, indexes, migrations, query behaviour, or ORM data access. The goal is safe evolution of production data and predictable performance under real workloads.

Load `backend-patterns` when database work crosses service boundaries or transaction design. Load `security-review` when the change includes dynamic filters, user input, or data-exposure risk.

## When to Activate

- Designing or reviewing new tables, columns, relations, or constraints
- Adding indexes or investigating slow queries
- Planning or reviewing database migrations
- Fixing ORM-generated N+1 queries or over-fetching
- Defining transaction boundaries across multiple writes

## Schema Design

- Prefer clear snake_case names for tables and columns.
- Normalize by default, then denormalize only for a measured query or write pattern.
- Use constraints to protect invariants where the database can enforce them.
- Choose nullable columns intentionally; do not use `NULL` as a vague catch-all state.

## Index Strategy

- Index columns used in joins, lookups, uniqueness checks, and high-value filters.
- Design composite indexes around real query shapes, not guesswork.
- Remove duplicate or overlapping indexes when they do not add value.
- Be explicit about write amplification and storage cost when adding indexes.

## Migration Safety

- Prefer backward-compatible, staged migrations for live systems.
- Avoid lock-heavy rewrites during peak traffic when a phased approach exists.
- Treat renames, type changes, and drops as multi-step operations when rollback matters.
- Backfill data in controlled phases instead of mixing destructive schema changes and heavy data movement blindly.

## Query And ORM Review

- Use `EXPLAIN` or equivalent when performance matters.
- Select only the columns needed for the use case.
- Eliminate N+1 access by eager loading, joins, batch queries, or projections.
- Keep pagination stable and deterministic.

Framework notes:

- Laravel: review scopes, eager loading, casts, and mass-assignment boundaries.
- Yii2: review relation loading with `with()` and `joinWith()` and watch generated SQL.
- Doctrine/Symfony: prefer repository queries tuned for the actual read model.

## Transactions

- Keep transactions short and explicit.
- Do not hide remote HTTP calls inside a database transaction unless the workflow truly requires it.
- Make retry semantics and idempotency explicit for multi-step write flows.

## Review Checklist

- Does the schema encode the business invariant clearly?
- Are indexes aligned with actual query patterns?
- Is the migration safe for existing data and live traffic?
- Are ORM access patterns free from N+1 or over-fetching?
- Are transaction boundaries minimal and deliberate?
- Does the change affect auditing, soft deletes, or temporal history requirements?
