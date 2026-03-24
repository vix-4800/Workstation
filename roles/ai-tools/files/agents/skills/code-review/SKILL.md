---
name: code-review
description: Use for pull requests, diff reviews, staged changes, regression hunting, and pre-merge checks focused on correctness, security, architecture, validation, data access, and tests.
metadata:
  short-description: Diff-first code review with severity taxonomy
---

# Code Review

Use this skill when reviewing a pull request, staged diff, recent branch change, or a post-implementation patch. The goal is to find real defects, security issues, architectural regressions, and missing tests without flooding the review with noise.

Load `modern-php`, `security-review`, and `backend-patterns` when the change is PHP or backend-heavy. Load `ansible-patterns` for infrastructure or workstation changes. Load `database-patterns` when schema, indexes, queries, or migrations are involved.

## When to Activate

- Reviewing a pull request or branch diff
- Checking whether a fix actually addresses the root cause
- Verifying a refactor did not change behaviour
- Comparing an implementation against a ticket, specs, or agreed plan
- Looking for missing tests, migrations, validation, or security controls

## Review Workflow

1. Read the diff first with `gh pr diff`, `git diff`, or `git show`.
2. Read surrounding code and call sites before judging a changed hunk in isolation.
3. Identify the intended behaviour change.
4. Review in this order: correctness, security, architecture, data access, validation, tests, migrations, style.
5. Report only issues that are likely real and actionable.

## Severity Taxonomy

- `[blocking]` — likely bug, security issue, data-loss risk, broken migration, missing critical validation, or direct merge blocker
- `[suggestion]` — maintainability, architectural, or test-gap issue that should usually be resolved before or soon after merge
- `[nitpick]` — low-risk clarity or consistency issue

## What To Flag

- Incorrect control flow, edge-case regressions, or broken assumptions
- Missing validation, authorization, escaping, or parameterized queries
- Business logic in controllers, god classes, or broken boundaries between layers
- N+1 queries, unsafe migrations, unbounded queries, or cache invalidation gaps
- Missing or misleading tests for newly changed behaviour
- Hardcoded values, debug helpers, commented-out code, or project-standard violations
- Mismatch between the change and the stated ticket, requirements, or plan
- Deeply nested conditions that can be flattened with early returns or combined into fewer branches
- Architectural decision quality: are methods in the right layer, is the approach coherent with the task, are abstractions well-chosen? Flag cases where the implementation technically works but the design is fragile, misplaced, or harder to maintain than an obvious alternative

## What To Avoid

- Do not report style preferences unless they violate repo conventions.
- Do not speculate when the evidence is weak.
- Do not focus on unchanged code unless it directly blocks or invalidates the change.

## Review Checklists

### New Feature

- Does the happy path work end to end?
- Are invalid inputs and permission boundaries handled?
- Are persistence, caching, and external side effects explicit?
- Are tests covering core behaviour and important edge cases?

### Bug Fix

- Does the fix address the root cause, not only the symptom?
- Could the same bug still happen through another entry point?
- Is there a regression test for the original failure mode?
- Did the fix introduce behavioural drift elsewhere?

### Refactor

- Is behaviour preserved?
- Are responsibilities actually cleaner after the refactor?
- Did validation, transaction, or authorization flow change unintentionally?
- Are removed tests or deleted safeguards justified?

### Architectural Assessment

For every non-trivial change, answer these explicitly:

- Does the implementation match the stated task or ticket? If a spec is provided, verify each requirement is addressed.
- Is the logic placed in the right layer? Business rules belong in services/domain, not controllers or AR models.
- Are the method names, abstractions, and data flow coherent with the surrounding code?
- Would a simpler approach have worked equally well without future risk?

If the answer to any of these is "no" or "unclear", raise it as `[suggestion]` or `[blocking]` depending on impact.

## Output Format

For each finding, provide:

- Severity: `[blocking]`, `[suggestion]`, or `[nitpick]`
- Location: file and line, or the nearest changed region
- Why it matters
- Smallest reasonable fix

End with a short verdict: `approve`, `warning`, or `block`.
