# Data Access, Migrations, Transactions, and Side Effects Reference

Use this reference when a change touches persistence, schema, migrations, models, repositories, queries, indexes, constraints, transactions, caching, queues, events, files, search indexes, or external services.

The goal is to catch data correctness, performance, consistency, deployability, and operability risks.

## Data Model and Schema

Ask:

- Is new persisted state actually needed?
- Can the value be derived from existing source-of-truth data?
- Does the schema duplicate an existing concept?
- What keeps duplicated data consistent?
- Are nullability, defaults, types, lengths, precision, enums, and constraints correct?
- Are database constraints used for invariants that must always hold?
- Does application validation match database constraints?
- Does the schema fit existing domain language?
- Is this schema/API shape hard to undo later?

Flag:

- Unnecessary tables, columns, relations, indexes, enums, settings, or persisted flags
- Duplicated source-of-truth data
- Missing unique constraints for unique business invariants
- Missing foreign keys where referential integrity matters and the project uses them
- Nullable columns that should be required
- Required columns added without safe defaults/backfill
- Storing display/UI-only state as domain state without justification

## Migrations

Ask:

- Is the migration safe for existing production data?
- Does it lock large tables or rewrite large data unexpectedly?
- Is a backfill needed?
- Should the migration be split into deploy-safe steps?
- Is rollback possible or intentionally not supported?
- Are indexes added safely for the target database?
- Are column renames/drops safe for multi-step deployments?
- Does the app code tolerate old and new schema during deployment?

Flag:

- Adding non-null columns without defaults or backfill
- Dropping/renaming columns while old code may still read them
- Large unbatched updates/deletes/inserts
- Backfills without retry/failure strategy
- Unsafe enum changes
- Missing index for new query pattern
- Irreversible migrations when the project expects reversibility
- Data migrations mixed with schema migrations when that is not the project convention

## Queries and Performance

Ask:

- Is the query scoped by tenant/user/account/project where needed?
- Are filters/indexes aligned?
- Can this become an N+1 query?
- Is pagination or limiting required?
- Is ordering deterministic?
- Are counts/aggregations safe at expected scale?
- Are eager loads, joins, selected columns, and relation constraints correct?
- Is raw SQL parameterized and are identifiers whitelisted?

Flag:

- Unbounded queries on user-facing paths
- Missing pagination for lists/exports/searches
- N+1 queries introduced by loops over relations
- Full table scans for new common lookup paths
- Sorting/filtering by unindexed fields at scale
- Loading full models when only IDs/counts are needed
- Missing deterministic order in paginated results
- Query logic embedded in controllers/views when existing query objects/repositories are used elsewhere

## Transactions and Consistency

Use transactions when multiple state changes must succeed or fail together.

Flag:

- Multiple related records mutated without a transaction
- Balance, inventory, status, permissions, ownership, or counters updated separately without consistency protection
- State transition code that can partially succeed
- Race conditions around check-then-update logic
- Missing locks or atomic updates where concurrent requests can conflict
- External calls inside transactions when they can be slow, retry, or fail unpredictably
- Jobs/events dispatched before the transaction commits

Common finding:

- The code updates the order status and creates a payment record without a transaction. A failure between the two writes can leave the order paid without a payment record or vice versa.

## Side Effects

Side effects include emails, notifications, jobs, events, webhooks, files, cache writes, search indexing, external API calls, logs, audit records, and metrics.

Ask:

- Is the side effect intentional and visible?
- Should it happen only after database commit?
- Is it idempotent if retried?
- What happens if it fails after the database update succeeds?
- Does it leak sensitive data?
- Does it belong in this layer?
- Is there a rollback or compensation strategy?

Flag:

- Emails/jobs/webhooks dispatched before commit
- Non-idempotent retryable jobs
- Duplicate notifications from repeated requests
- Cache not invalidated after writes
- Search index/file/external state not kept consistent with DB state
- Side effects hidden in getters, accessors, model events, observers, or unrelated helpers
- Missing failure handling for external service calls

## Caching

Flag:

- Cache keys missing tenant/user/account scope
- Cache invalidation missing after mutations
- Cache stores sensitive data too broadly
- Stale cache can affect authorization or money/status decisions
- TTL is absent or unreasonable for mutable data
- Negative cache entries can hide newly created records

## Severity Guidance

Use `[blocking]` for data loss, broken migration, unsafe production deploy, inconsistent money/security/state, missing authorization scope in queries, or hard-to-reverse schema mistakes.

Use `[suggestion]` for avoidable schema, missing index likely to hurt soon, weaker transaction boundary, duplicated data with manageable risk, or query organization that will become harder to maintain.

Use `Questions / risks` when production size, deployment strategy, or database engine assumptions are unknown.
