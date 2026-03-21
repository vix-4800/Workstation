---
name: laravel-patterns
description: Laravel-specific architecture and review patterns for controllers, Form Requests, policies, Eloquent usage, jobs, resources, and validation boundaries.
metadata:
  short-description: Laravel conventions for backend implementation and review
---

# Laravel Patterns

Use this skill when the task touches Laravel application structure or framework conventions. The goal is to keep controllers thin, validation explicit, authorization centralized, and Eloquent usage predictable.

Load `modern-php` for language-level guidance, `backend-patterns` for broader architecture decisions, and `security-review` for auth, input, or secret boundaries.

## When to Activate

- Implementing or reviewing Laravel controllers, jobs, policies, requests, or services
- Deciding where validation and authorization belong
- Reviewing Eloquent query patterns, scopes, eager loading, or transactions
- Planning tests around Laravel application flows

## Core Conventions

- Keep controllers focused on transport concerns.
- Use Form Requests or explicit DTO mapping for validation at the boundary.
- Use Policies or Gates for authorization.
- Move multi-step workflows into actions or services when they exceed simple controller logic.
- Keep jobs idempotent and payloads small.

## Eloquent Review

- Prevent N+1 queries with deliberate eager loading.
- Prefer scopes or dedicated query objects when query logic becomes non-trivial.
- Avoid mass assignment with broad request payloads.
- Use transactions for multi-write workflows that must succeed together.

## Review Checklist

- Is validation happening at the request boundary?
- Is authorization explicit and framework-native?
- Is business logic escaping the controller?
- Are Eloquent queries bounded, eager-loaded, and proportional to the use case?
- Do tests cover the framework wiring that matters for the change?
