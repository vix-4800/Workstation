---
name: security-review
description: Use for auth, permissions, user input, secrets, tokens, uploads, HTTP endpoints, webhooks, external URLs, and third-party integrations in PHP applications. Provides a PHP security review checklist for Yii2, Laravel, and Symfony.
metadata:
  short-description: PHP security checklist for web apps and APIs
---

# Security Review

Use this skill whenever code crosses a trust boundary. The default assumption is that input is hostile, external systems fail unpredictably, and sensitive data must be protected even in error cases.

Load `modern-php` alongside this skill when the task includes implementation details, framework hooks, or repo quality-gate fixes.

## When to Activate

- Implementing authentication or authorization
- Handling user input, files, or external URLs
- Creating or reviewing API endpoints
- Working with secrets, tokens, credentials, or PII
- Building payment, billing, or account-management flows
- Integrating third-party APIs or webhooks

## Security Baseline

1. Validate and normalize all inbound input.
2. Authorize every sensitive action explicitly.
3. Parameterize every query.
4. Keep secrets out of code and logs.
5. Escape or sanitize output for the target context.
6. Treat uploads, redirects, webhooks, and outbound HTTP as high-risk boundaries.

## Secrets Management

- Never hardcode API keys, passwords, DSNs, or tokens.
- Load secrets from environment variables, vaults, or deployment-specific secret stores.
- Fail fast when required secrets are missing.
- Do not dump secret-bearing config arrays in logs or error pages.

Review:

- Are all secrets externalized?
- Are `.env` or vault files excluded from version control?
- Could any exception path leak credentials?

## Input Validation

Validate at the boundary before domain logic:

- Laravel: Form Requests, validation rules, casted DTOs.
- Yii2: model rules, scenarios, and explicit input mapping.
- Symfony: validator-backed DTOs or request mappers.

Rules:

- Whitelist allowed fields.
- Enforce type, length, format, and range.
- Reject unexpected fields for sensitive endpoints.
- Do not rely on client-side validation.

## Database Safety

- Use parameterized queries, query builders, or ORM APIs safely.
- Never concatenate user input into SQL, raw where clauses, or order-by fragments.
- Whitelist sortable/filterable columns before building dynamic queries.
- Use least-privilege database credentials when possible.

### Laravel-specific checks

- Protect against mass assignment with `$fillable`, `$guarded`, or explicit attribute mapping.
- Treat `Model::unguard()` and broad `update($request->all())` patterns as security smells.

## Authentication And Authorization

- Authentication identifies the actor.
- Authorization determines whether the actor may perform the action.
- Perform authorization before state-changing operations.

Framework notes:

- Laravel: use Policies, Gates, and Form Request authorization when appropriate.
- Yii2: use RBAC or explicit policy checks in service/controller boundaries.
- Symfony: use voters and security services instead of ad-hoc role checks everywhere.

Review:

- Is every sensitive action authorized?
- Is privilege escalation possible through missing policy checks?
- Are session, token, or cookie settings secure for the deployment context?

## Passwords And Cryptography

- Use `password_hash(..., PASSWORD_ARGON2ID)` or the framework's vetted wrapper.
- Use `password_verify()` for verification.
- Never build custom crypto protocols.
- Use signed tokens, framework CSRF protections, and battle-tested libraries instead of inventing equivalents.

## CSRF, XSS, And Output Safety

- Use framework CSRF protection for browser-based state-changing requests.
- Treat API routes differently only when they are truly stateless and use proper auth.
- Escape output for HTML, JavaScript, JSON, shell, and SQL contexts appropriately.
- Sanitize user-provided HTML before rendering it.
- Do not trust template auto-escaping when manually injecting raw HTML.

## File Uploads

- Validate MIME type server-side.
- Validate extension separately.
- Enforce size limits.
- Generate server-side filenames.
- Store uploads outside the web root when possible.
- Never trust the browser-provided content type alone.

Review:

- Can an attacker upload executable content?
- Can filenames trigger path traversal?
- Is the file ever served back without safe content headers?

## SSRF And Outbound HTTP

Any user-controlled URL or host is a security boundary.

Rules:

- Whitelist allowed hosts or domains where possible.
- Reject private, loopback, link-local, and metadata-service addresses unless explicitly needed.
- Set connect and read timeouts.
- Limit redirects.
- Do not proxy arbitrary URLs without a strong allowlist.

## Deserialization, Command Execution, And Dynamic Code

- Avoid `unserialize()` on untrusted data.
- Avoid `eval()`, shell execution with unescaped input, and dynamic include paths from user data.
- Do not pass unsanitized input into CLI commands, file paths, or templating engines.

## Logging And Error Handling

- Log enough context to investigate incidents.
- Do not log passwords, tokens, session identifiers, or full payment details.
- Do not expose stack traces or SQL errors to clients.
- Make security-relevant failures visible without turning logs into a data leak.

## Review Checklist

- Are secrets externalized and protected?
- Is input validated and normalized at the boundary?
- Are queries parameterized and dynamic fields whitelisted?
- Are authorization checks present before sensitive actions?
- Are uploads, redirects, and outbound HTTP constrained safely?
- Are CSRF, XSS, and output-encoding concerns handled for the actual context?
- Are logs and error responses free from sensitive data?
