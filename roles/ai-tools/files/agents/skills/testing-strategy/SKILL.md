---
name: testing-strategy
description: Test strategy guidance for unit, integration, and feature tests, including regression coverage, boundary selection, and verification planning.
metadata:
  short-description: Behaviour-first test planning and test-gap review guidance
---

# Testing Strategy

Use this skill when deciding what to test, how deep to test it, and whether a change leaves important behaviour uncovered. Prefer tests that document intended behaviour and catch regressions without overfitting to implementation details.

Load `code-review` when evaluating a diff for missing coverage. Load `modern-php`, `laravel-patterns`, or `yii2-patterns` when the framework affects test shape and fixtures.

## When to Activate

- Reviewing whether a code change has sufficient tests
- Planning tests for a new feature, bug fix, or refactor
- Deciding between unit, integration, and feature coverage
- Adding regression tests for a production bug

## Core Rules

1. Test behaviour, not private implementation details.
2. Match the test level to the risk.
3. Prefer one clear regression test over many redundant shallow assertions.
4. Cover the changed behaviour and the critical edge cases introduced by the change.

## Test-Level Guidance

### Unit Tests

- Use for pure logic, calculations, mappers, validators, and deterministic helpers.
- Mock external dependencies aggressively.
- Keep them fast and isolated.

### Integration Or Feature Tests

- Use for controller-to-service-to-database flows, authorization boundaries, validation rules, and framework wiring.
- Prefer them when the risk is in orchestration rather than in one pure function.
- Assert user-visible outcomes, not incidental internal calls.

## Review Checklist

- Does the change introduce new behaviour without a corresponding test?
- Is there a regression test for the bug being fixed?
- Are authorization, validation, and persistence flows exercised at the right level?
- Would the current tests still protect the behaviour after an internal refactor?
- Are migrations, background jobs, or cache invalidation paths covered where they matter?
