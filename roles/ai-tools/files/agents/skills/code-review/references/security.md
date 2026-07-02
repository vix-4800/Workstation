# Security Review Reference

Use this reference when a change touches authentication, authorization, validation, user input, external input, files, URLs, HTML, templates, Markdown, commands, webhooks, jobs, APIs, admin screens, secrets, logs, or sensitive data.

The goal is to find concrete security risks introduced or exposed by the change.

## Security Review Order

1. Identify new or changed entry points.
2. Identify the actor: anonymous user, authenticated user, admin, internal job, webhook sender, CLI user, external service, or developer.
3. Identify trust boundaries: request input, route params, headers, cookies, uploaded files, webhooks, external APIs, queues, database records, logs, cache, environment variables.
4. Check authorization before validation details. A well-validated request can still access the wrong data.
5. Check whether the same operation can be reached through another endpoint, command, job, import, or admin flow.
6. Check output and side effects: responses, HTML, files, emails, logs, events, queues, external calls.

## Authorization and IDOR

Flag when:

- A user-controlled ID loads a record without ownership/tenant/scope check
- Authorization exists in UI but not server-side
- Authorization is checked after mutation or side effects
- A new endpoint/command/job bypasses existing policy/service checks
- Admin-only actions are exposed to normal users
- Tenant/account/project boundaries are not enforced in queries
- A bulk operation checks permission once but mutates records from multiple owners

Common finding:

- `Project::find($id)` is used with a route parameter, but the query is not scoped to the current user/account. This creates an IDOR risk; load through the authorized relationship or enforce the policy before returning or mutating the record.

## Validation

Flag when:

- Server-side validation is missing or weaker than frontend validation
- Validation exists only in one entry point but the operation is reachable elsewhere
- Route params, headers, cookies, webhook payloads, uploaded file names, or external API data are trusted
- Validation allows impossible states compared with database/domain constraints
- Validation blocks safe values or rejects existing production data without migration plan
- Validation is duplicated inconsistently across request classes, controllers, services, jobs, and imports

## Injection Risks

Flag when user-controlled input influences:

- SQL fragments, raw where/order/group clauses, dynamic filters, or selected columns
- Shell commands, arguments, environment variables, or process execution
- File paths, archive extraction paths, template names, class names, method names, includes, or imports
- URLs, redirect targets, webhook endpoints, or internal service calls
- HTML, Markdown, rich text, JavaScript, CSS, XML, CSV, or email content

Specific checks:

- SQL: parameterize values and whitelist identifiers such as column names and sort directions.
- XSS: escape output according to context. Sanitizing once is not a replacement for context-aware escaping.
- Path traversal: normalize paths, reject traversal, and enforce a base directory.
- Open redirect: allow only known internal paths or whitelisted hosts.
- Command injection: avoid shell when possible; pass arguments as arrays and validate allowed values.

## Files and Uploads

Flag when:

- File type is trusted from extension or client MIME only
- Original filename is used as a storage path without normalization
- Upload path can be influenced by user input
- Public access is broader than needed
- Image/document processing is done without size limits or failure handling
- Archive extraction can write outside the target directory
- Download endpoint does not verify ownership/permission
- Temporary files are not cleaned up

## SSRF and External Requests

Flag when:

- User input controls a URL fetched by the server
- Internal IPs, localhost, metadata services, private networks, or non-http schemes are not blocked when needed
- Redirects are followed without re-validating the final URL
- DNS rebinding is possible for sensitive environments
- Response size/timeouts are unbounded

## Sensitive Data and Logging

Flag when:

- Passwords, tokens, session IDs, API keys, auth headers, reset links, private URLs, personal data, payment data, or secrets are logged
- Sensitive data is returned in API responses unnecessarily
- Stack traces or debug errors leak details to users
- Events, jobs, notifications, or emails include more data than needed
- Test fixtures accidentally contain real secrets

## Webhooks and External Events

Flag when:

- Webhook signature verification is missing or optional
- Timestamp/replay protection is missing where relevant
- The same event can be processed multiple times without idempotency
- External event payloads are trusted without server-side lookup
- Failure handling can leave partial state

## Mass Assignment and Object Updates

Flag when:

- Request input is passed directly to `create`, `update`, `fill`, or equivalent methods
- Sensitive fields can be changed by users: role, permissions, owner/account ID, status, price, balance, verified flags, timestamps
- A DTO/request object contains fields that should never be user-controlled

## Severity Guidance

Use `[blocking]` for likely exploitable authorization, data exposure, injection, unsafe file handling, secret leakage, missing webhook verification, or mutation of sensitive state.

Use `[suggestion]` for weaker but actionable hardening, inconsistent validation, or security-sensitive design that is not immediately exploitable from the visible diff.

Use `Questions / risks` for concerns that need confirmation, such as whether an endpoint is internal-only or whether upstream middleware guarantees a permission check.
