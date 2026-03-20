# Framework Conventions

Use this reference after identifying the active PHP framework. Follow the existing framework and project conventions rather than forcing a new architecture.

## Yii2

- Keep controllers thin. Move business rules into services, application handlers, or domain classes.
- Use `Model` or dedicated form models for validation and input normalization.
- Prefer dependency injection and configured components over reaching into `Yii::$app` from deep business logic.
- Use query builder or parameterized Active Record queries. Never concatenate request data into SQL fragments.
- Use behaviors, validators, and data providers where Yii2 already has a native solution.
- Treat Active Record models as persistence-facing objects. Keep cross-cutting business workflows elsewhere.

## Laravel

- Keep controllers thin and delegate to services, actions, jobs, or domain handlers.
- Use Form Requests for validation and authorization entry checks.
- Use Policies and Gates for authorization instead of ad-hoc conditionals in controllers.
- Bind interfaces in service providers when the project already uses DI abstractions.
- Prefer Eloquent scopes, casts, resources, and value objects when they simplify the model without hiding business rules.
- Avoid facade-heavy domain services when constructor injection is reasonable.
- Respect mass-assignment boundaries with `$fillable` or intentional guarded strategies.

## Symfony

- Keep business logic in services, not controllers or entities.
- Use autowiring and constructor injection by default.
- Use voters for authorization decisions.
- Use Messenger, commands, and event subscribers only when the project already uses them or there is a clear boundary.
- Prefer typed DTOs and request mappers over unstructured arrays at service boundaries.

## Cross-Framework Rules

- Do not mix framework conventions in the same code path.
- Do not introduce repositories, DTO layers, or service layers unless they solve an actual problem in the current codebase.
- Prefer framework-native validation and authorization boundaries before custom helpers.
- Keep transport concerns at the edge: HTTP, console input, queues, and ORM hydration should not leak into core business logic.
