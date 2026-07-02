# Architecture and Layering Reference

Use this reference when the change touches controllers, services, domain logic, models, repositories, jobs, commands, events, validators, policies, DTOs, or broad maintainability concerns.

The goal is to identify misplaced responsibility, fragile boundaries, duplicated logic, and abstractions that make future work harder.

## Responsibility Boundaries

Prefer boundaries that match the existing project architecture. Repository conventions are more important than generic architecture advice unless the convention is unsafe.

Typical expectations:

- Controllers should orchestrate request validation, authorization, application calls, and response construction. They should not hold business rules or multi-step workflows.
- Request/validation classes should validate input shape and basic constraints. They should not make domain decisions that require persistence, permissions, or side effects unless the project convention explicitly allows it.
- Domain/application services should hold business workflows, decisions, and state transitions.
- Policies/guards should hold authorization decisions.
- Repositories/query objects should hold complex persistence queries when the project uses them.
- Models should represent persistence and simple invariants. Avoid hiding large workflows, external side effects, or authorization in model events/callbacks.
- Jobs/commands should coordinate execution, but business decisions should remain reusable and testable.
- Migrations should change schema/data, not encode application business flow.

## Architecture Smells To Flag

Flag technically working code when:

- A controller performs business decisions instead of orchestration
- A method validates input, checks permissions, mutates state, dispatches side effects, and builds responses all at once
- Domain rules are hidden in views, controllers, migrations, callbacks, observers, or infrastructure code
- A new service is only a thin wrapper around one method call and does not clarify anything
- A new abstraction is introduced before there are multiple use cases or a clear boundary
- Existing abstractions are bypassed instead of reused
- Existing domain language is ignored and a parallel concept is introduced
- The same business rule exists in multiple places
- Error handling differs from surrounding code without reason
- Framework-specific details leak into code that should stay domain/application-level
- Code becomes harder to test because dependencies are hidden or created inline
- Public interfaces become wider than the requirement needs

## Controller Review

For controller or endpoint changes, ask:

- Is this endpoint needed?
- Is a full CRUD controller needed, or would a narrower action be safer?
- Is authorization explicit and early?
- Is request validation server-side and complete?
- Does the controller delegate business workflow to a service/action/domain layer?
- Are transactions and side effects handled outside the controller when appropriate?
- Is response shape consistent with existing endpoints?
- Are errors mapped consistently?

Common finding:

- The endpoint works, but it puts eligibility calculation and state transition directly in the controller. This makes the rule hard to reuse from jobs/commands and risks inconsistent behaviour through other entry points.

## Service / Action Review

For service/action changes, ask:

- Does the service have one clear responsibility?
- Does it model a real domain/application action, or is it a vague utility bucket?
- Are dependencies explicit?
- Is the method doing too many unrelated steps?
- Are errors and return values consistent with surrounding services?
- Is the service reusable from all relevant entry points?
- Does it make testing easier or harder?

Flag services named too broadly, such as `Manager`, `Helper`, `Processor`, or `Service`, when their responsibilities are unclear or expanding.

## Model / Active Record Review

For model changes, ask:

- Is this a simple persistence concern or a business workflow hidden inside the model?
- Are callbacks/events introducing invisible side effects?
- Does a model method perform external calls, dispatch jobs, or modify other aggregates unexpectedly?
- Are accessors/mutators hiding expensive queries or side effects?
- Is mass assignment safe?
- Are casts, defaults, relationships, and scopes consistent with schema and usage?

## Duplication and Source of Truth

Flag duplication when:

- A business rule is copied instead of reused
- Validation is duplicated but not guaranteed to stay consistent
- A computed value is persisted without a synchronization strategy
- Two services/controllers/jobs now implement the same state transition
- Tests assert two different versions of the same rule

Use stronger severity when duplication can lead to incorrect permissions, money/accounting bugs, data drift, or inconsistent state transitions.

## Complexity and Nesting

Flag deep nesting or broad methods when the complexity creates real risk:

- Important guard conditions are buried
- Error handling is hard to follow
- Authorization/validation is mixed with mutation
- Multiple unrelated responsibilities are in one method
- The code will be difficult to test without large setup

Prefer small, targeted fixes:

- Extract a named private method when it clarifies a condition or workflow
- Use early returns for guard clauses
- Move business rules into an existing service/policy/domain object
- Reuse an existing abstraction instead of creating a new one

Do not suggest decomposition only because a method is long. Explain the concrete maintenance or correctness risk.
