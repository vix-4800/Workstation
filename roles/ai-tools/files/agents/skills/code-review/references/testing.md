# Testing Reference

Use this reference when tests are added, removed, weakened, missing, or when the change modifies behaviour that should be protected by tests.

The goal is to judge whether tests prove the important behaviour and protect against the real risk introduced by the change.

## General Test Review

Ask:

- What behaviour changed?
- What could break because of this change?
- Do the tests cover that behaviour directly?
- Would the tests fail before the fix or implementation?
- Do the tests assert the important outcome, not only an implementation detail?
- Are error, validation, permission, and edge cases covered when relevant?
- Are tests placed at the right level: unit, feature/integration, database, API, browser, or end-to-end?
- Are fixtures/factories realistic enough to catch the risk?

## New Feature Tests

Expect tests for:

- Happy path
- Main invalid input path
- Permission boundary
- Important edge cases
- Persistence result
- Side effects, jobs, events, notifications, cache invalidation, or external calls when relevant
- Public API/response shape when relevant

Do not require exhaustive tests for every trivial branch. Focus on behaviour that could realistically break.

## Bug Fix Tests

For bug fixes, expect a regression test that:

- Reproduces the original failure mode
- Fails before the fix
- Passes after the fix
- Covers the entry point where the bug happened
- Checks root cause, not only the visible symptom

Flag when a bug fix has no regression test unless there is a clear reason it is impractical.

Common finding:

- The code now handles empty input, but no regression test covers the empty-input case that caused the bug. A test should assert the original failure mode so this does not regress.

## Refactor Tests

For refactors, ask:

- Is behaviour preserved?
- Were tests removed, weakened, or moved without equivalent coverage?
- Are public contracts still covered?
- Did validation, authorization, transactions, or side effects move without tests proving equivalence?
- Are new abstractions tested through behaviour rather than internal structure?

If the refactor is large and tests are weak, flag that the review cannot confidently verify behaviour preservation.

## Security and Authorization Tests

Expect tests for:

- User cannot access another user's/tenant's resource
- Unauthorized user is rejected before mutation
- Role/permission differences
- Bulk operations with mixed ownership
- Validation bypass through alternate entry points
- Sensitive data not exposed in response when that is a risk

Use `[blocking]` when missing tests cover a high-risk permission/security path and the code is not obviously safe.

## Database and Migration Tests

Expect tests or checks for:

- New constraints and validation alignment
- Data backfill behaviour
- Query scopes and ownership boundaries
- Important indexes/lookup patterns when project tests cover this
- Migrations on representative existing data when migration risk is high

## Side Effect Tests

Expect tests for:

- Jobs/events/notifications are dispatched at the right time
- Side effects are not dispatched on validation/authorization failure
- External calls are not made before state is safely persisted when relevant
- Retryable jobs are idempotent when duplicates matter
- Cache/search/files are updated or invalidated when state changes

## Weak Tests To Flag

Flag tests that:

- Only assert HTTP status `200` without checking important output/state
- Only check that a method was called while missing observable behaviour
- Mock away the risky dependency and therefore cannot catch the bug
- Use unrealistic factories that skip required domain state
- Assert implementation details that will make safe refactors painful
- Are too broad/flaky and do not isolate the behaviour under review
- Remove or weaken assertions without explanation

## When Missing Tests Are Not Worth Flagging

Do not flag missing tests for:

- Pure formatting or comments
- Trivial rename with no behaviour change
- Dead-code removal when existing tests still pass and behaviour is unaffected
- Mechanical generated changes when the generator is trusted by the project

If tests are absent project-wide, still mention missing tests for risky changes, but frame the finding around the specific changed behaviour rather than generic coverage.

## Severity Guidance

Use `[blocking]` when missing tests make a risky bug fix, authorization change, migration, money/status workflow, or critical domain rule unsafe to merge.

Use `[suggestion]` when tests should be added but the implementation is otherwise visibly safe.

Use `[nitpick]` only for small test clarity or naming issues.
