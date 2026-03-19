---
name: coding-standards
description: PHP-first coding standards for naming, structure, maintainability, reviewability, and cross-language quality rules. Use for refactoring, code review, and enforcing consistent conventions in PHP applications.
metadata:
  short-description: PHP-first coding standards and maintainability rules
---

# Coding Standards

Use this skill as the baseline quality layer for refactors and code review. It is PHP-first because that is the primary stack, but the design principles remain useful across languages.

Load `modern-php` with this skill when the task is PHP-specific and needs language features, framework conventions, or toolchain-derived constraints.

## When to Activate

- Reviewing code quality and maintainability
- Refactoring existing code
- Starting a new module or feature
- Enforcing naming and structural consistency
- Trimming over-engineered code
- Deciding whether to extract, inline, split, or keep a design as-is

## Core Principles

### Correctness Before Style

- Make the behaviour correct before trying to make it clever.
- Do not trade clarity for indirection unless the indirection removes real duplication or risk.

### Smallest Useful Change

- Prefer the narrowest change that solves the problem.
- Do not smuggle refactors into unrelated work.
- Keep diffs easy to review.

### Readability Over Cleverness

- Names should explain intent.
- Hidden side effects are worse than a few extra lines.
- Self-documenting code beats comments that restate the obvious.

### No Speculative Abstractions

- Do not add a base class, trait, repository, helper, or strategy layer without a concrete need.
- Wait for the second or third real use case before generalising.

## PHP-First Baseline

- Use `declare(strict_types=1);` unless the project explicitly exempts that file type.
- Use explicit parameter, return, and property types.
- Prefer `final` or `abstract` classes when the framework does not require open inheritance.
- Prefer constructor injection over globals, service locators, or hidden framework access.
- Prefer enums, value objects, and typed DTOs for stable domain concepts.
- Use guard clauses and early returns to keep nesting shallow.
- Avoid flag arguments. Split behaviour into separate methods when the branches are meaningfully different.
- Keep controllers thin and keep business logic out of views/templates.

## Naming

| Construct | Convention |
|---|---|
| Variables | `camelCase` in PHP and JS/TS, `snake_case` in Python |
| Functions and methods | `camelCase` in PHP and JS/TS, `snake_case` in Python |
| Classes | `PascalCase` |
| Constants | `UPPER_SNAKE_CASE` |
| Interfaces in PHP | Noun or adjective, never `I*` |
| Enum cases in PHP | `PascalCase` |
| Boolean names | Predicate form such as `isActive`, `hasAccess`, `canPublish` |

Rules:

- Avoid one-letter variables outside tiny local loops.
- Prefer `userId` over `id` when the wider context is unclear.
- Avoid abbreviations unless they are genuinely universal, such as `url`, `id`, `http`, or `dto`.

## Function And Class Design

- A function should do one coherent thing.
- If a method needs a long docblock to explain its control flow, split it.
- Keep side effects obvious in method names and call sites.
- Separate pure calculation from I/O where practical.
- Use composition before inheritance.
- If a class name contains `And`, that is usually a smell.

## Comments And Documentation

- Comment the why, not the what.
- Delete comments that merely narrate the code.
- Keep public APIs documented where the contract is not obvious.
- Do not leave dead code commented out.

## Review Questions

- Is this the smallest change that solves the problem?
- Are the names precise enough that comments are unnecessary?
- Are responsibilities split at sensible boundaries?
- Is there hidden coupling or a surprising side effect?
- Is the abstraction earning its keep right now?
- Would the next person understand the code without reading half the repository?

## Cross-Language Fallback

When the task is not PHP:

- Keep strict typing enabled where the language supports it.
- Use immutable updates or explicit state transitions instead of hidden mutation.
- Handle errors explicitly; do not ignore failure paths.
- Preserve the same quality bar for naming, testability, and clear boundaries.
