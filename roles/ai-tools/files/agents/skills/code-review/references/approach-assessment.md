# Approach Assessment Reference

Use this reference when a change is non-trivial, adds a new feature, introduces schema/API/CRUD, performs a broad refactor, changes task scope, or looks larger than the stated requirement.

The goal is to judge whether the chosen approach is appropriate, not only whether the code compiles or passes the happy path.

## Core Questions

Ask these before line-level comments:

- What problem is the change trying to solve?
- Is that problem real and supported by the ticket, bug report, user story, or surrounding code?
- Does the implementation solve the root problem or only one visible symptom?
- Is the implementation proportionate to the task?
- Is the change creating permanent structure for a temporary or narrow requirement?
- Could the same outcome be achieved with existing concepts, data, services, controllers, commands, settings, or UI?
- Does the implementation preserve the current domain model, or does it introduce a parallel model?
- Does the approach make rollback, migration, deployment, or future maintenance harder?

## Things To Challenge

Challenge the implementation when it introduces:

- A new table where existing data is already the source of truth
- A new column that duplicates derivable state
- A new CRUD controller for a narrow internal operation
- A new endpoint where an existing endpoint/action could be extended safely
- A new service, action, repository, DTO, enum, event, job, listener, policy, or config option that does not reduce complexity
- Copied logic instead of shared logic
- Changes to unrelated modules, formatting, generated files, or public APIs
- A broad refactor mixed into a bug fix
- A data migration for something that should be computed
- A persistent setting for something that is request-scoped or temporary
- Extra flags, modes, or conditionals that make future behaviour harder to reason about

## Valid Approach-Level Findings

Approach-level findings are valid when they name a concrete risk:

- Data drift
- Two sources of truth
- Hard-to-reverse schema/API shape
- Future feature work becoming harder
- Higher operational risk
- Inconsistent domain model
- Security or authorization bypass through a new path
- Duplicated validation or business rules
- Unnecessary public surface area
- Bigger testing burden than necessary

Do not write approach comments as vague taste:

Bad:

- This feels overengineered.
- This should be cleaner.
- I do not like this abstraction.

Good:

- This adds a dedicated table for a value that is already derived from `orders.status` and `payments.status`, creating a second source of truth. A query/view/computed method would avoid data drift.
- This creates a full CRUD controller, but the ticket only needs one internal approve/reject action. The extra create/update/delete paths expand the authorization and testing surface without supporting the requirement.
- This duplicates the existing eligibility calculation from `SubscriptionPolicy`, so future rule changes will need to be made in two places.

## Scope Review

Flag unrelated changes when they:

- Make the diff harder to review
- Change behaviour outside the stated task
- Touch public API, schema, config, tests, or generated files without explanation
- Hide risky changes inside formatting or cleanup
- Should be split into a separate PR

Use `[blocking]` when unrelated changes can break behaviour, data, security, deployment, or public contracts.
Use `[suggestion]` when they mainly hurt reviewability or maintainability.

## When Not To Challenge the Approach

Do not challenge the approach when:

- The implementation follows an established project pattern and the pattern is not unsafe
- The larger structure is required by the framework or existing architecture
- The diff is intentionally mechanical and behaviour-preserving
- The task explicitly requires the new schema/API/CRUD and the implementation matches it safely
- A simpler approach would only be aesthetically preferable, not safer or more maintainable
