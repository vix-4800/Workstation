---
name: api-design
description: REST API design patterns for PHP backends, including resource naming, HTTP semantics, validation boundaries, pagination, filtering, error responses, idempotency, versioning, and rate limiting.
metadata:
  short-description: REST API design patterns for PHP applications
---

# API Design

Use this skill when designing or reviewing HTTP APIs. Keep the contract stable, predictable, and easy to consume from non-PHP clients.

Load `modern-php` alongside this skill when the task includes implementation details, DTOs, controller code, or tool-driven verification.

## When to Activate

- Designing new REST endpoints
- Reviewing existing API contracts
- Adding filtering, sorting, pagination, or search
- Defining validation and error response formats
- Planning versioning, idempotency, or rate-limiting behaviour
- Converting framework handlers into a stable external contract

## Core Rules

1. Model URLs around resources, not actions.
2. Use HTTP status codes semantically instead of inventing transport-level status fields.
3. Validate input at the boundary and map it to typed DTOs or validated arrays before business logic.
4. Keep response shapes consistent across the API.
5. Do not leak ORM internals, stack traces, SQL errors, or framework-specific exception messages into responses.
6. Keep controllers thin. Contract handling belongs at the HTTP boundary; business rules belong in services or handlers.

## URL Design

### Resource Structure

```text
GET    /api/v1/users
GET    /api/v1/users/{id}
POST   /api/v1/users
PATCH  /api/v1/users/{id}
DELETE /api/v1/users/{id}

GET    /api/v1/users/{id}/orders
POST   /api/v1/orders/{id}/cancel
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh
```

### Naming Rules

- Use lowercase, plural, kebab-case resource names.
- Use path segments for ownership or hierarchy, not for filters.
- Use query parameters for filtering, sorting, includes, and pagination.
- Reserve verb-style endpoints for true actions that do not map cleanly to CRUD.

## HTTP Semantics

| Method | Use for | Notes |
|---|---|---|
| `GET` | Read resources | Safe and idempotent |
| `POST` | Create resources or trigger actions | Not idempotent by default |
| `PUT` | Full replacement | Should be idempotent |
| `PATCH` | Partial update | Keep patch semantics explicit |
| `DELETE` | Remove resources | Usually idempotent |

## Status Codes

| Status | Use for |
|---|---|
| `200 OK` | Successful read or update with response body |
| `201 Created` | Resource created successfully; include `Location` when useful |
| `202 Accepted` | Asynchronous work accepted but not finished |
| `204 No Content` | Successful action with no response body |
| `400 Bad Request` | Malformed request shape or invalid syntax |
| `401 Unauthorized` | Missing or invalid authentication |
| `403 Forbidden` | Authenticated but not allowed |
| `404 Not Found` | Resource absent or intentionally hidden |
| `409 Conflict` | Duplicate state, version conflict, or illegal transition |
| `422 Unprocessable Entity` | Structurally valid request with domain validation errors |
| `429 Too Many Requests` | Rate limit exceeded |
| `500 Internal Server Error` | Unexpected server failure |
| `503 Service Unavailable` | Temporary outage or maintenance |

## Validation Boundaries

Validate before hitting business logic:

- Laravel: Form Requests or dedicated request DTOs.
- Yii2: `Model` or `FormModel` validation rules and scenarios.
- Symfony: validator-backed DTOs or request mappers.

Rules:

- Reject unknown or malformed input early.
- Normalize types at the boundary.
- Return field-level validation errors in a stable format.
- Keep domain validation separate from transport validation when the rules differ.

## Response Shapes

### Success Response

```json
{
  "data": {
    "id": "usr_123",
    "email": "alice@example.com",
    "name": "Alice"
  }
}
```

### Collection Response

```json
{
  "data": [
    { "id": "usr_123", "name": "Alice" },
    { "id": "usr_456", "name": "Bob" }
  ],
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 42
  },
  "links": {
    "self": "/api/v1/users?page=1&per_page=20",
    "next": "/api/v1/users?page=2&per_page=20"
  }
}
```

### Error Response

```json
{
  "error": {
    "code": "validation_error",
    "message": "Request validation failed.",
    "details": [
      {
        "field": "email",
        "code": "invalid_format",
        "message": "The email field must be a valid email address."
      }
    ]
  }
}
```

Rules:

- Keep error envelopes consistent.
- Make `code` machine-readable and stable.
- Make `message` human-readable but safe.
- Put field-level details in a list, not embedded prose.

## Pagination

### Offset Pagination

Use for admin screens, search results, or small datasets where jumping to page N matters.

```text
GET /api/v1/users?page=2&per_page=20
```

### Cursor Pagination

Use for feeds, infinite scroll, or large datasets where consistency and performance matter more than page numbers.

```text
GET /api/v1/users?cursor=eyJpZCI6MTIzfQ&limit=20
```

Rules:

- Always define a deterministic sort order.
- Cap the maximum page size.
- Return pagination metadata and navigational links or cursors.
- Do not expose raw database offsets as a long-term public contract if you expect scale.

## Filtering, Sorting, And Search

Examples:

```text
GET /api/v1/orders?status=paid&customer_id=usr_123
GET /api/v1/products?price[gte]=10&price[lte]=100
GET /api/v1/users?sort=-created_at,name
GET /api/v1/users?search=alice
```

Rules:

- Whitelist sortable and filterable fields.
- Reject unknown filter keys.
- Use stable parameter naming across endpoints.
- Keep full-text search semantics distinct from exact-match filters.

## Idempotency And Concurrency

- Support idempotency keys for external `POST` endpoints that create side effects such as payments or webhooks.
- Use optimistic locking, version fields, or unique constraints where concurrent updates matter.
- Return `409 Conflict` when the request is valid but collides with current resource state.

## Versioning

- Start without versioning only for short-lived private APIs.
- For stable/public APIs, prefer URI or header versioning and document the rule consistently.
- Add fields in a backward-compatible way before removing or renaming anything.
- Deprecate with clear migration paths and dates.

## Security Boundaries

- Authentication decides who the caller is.
- Authorization decides what the caller can do.
- Validation decides whether the payload is acceptable.
- Business rules decide whether the action is allowed in the current state.

Do not blur these layers.

## Review Checklist

- Are URLs resource-oriented and predictable?
- Are status codes semantically correct?
- Is validation performed before business logic?
- Are errors stable, machine-readable, and safe?
- Is pagination appropriate for the dataset size and client behaviour?
- Are sorting/filtering fields explicitly whitelisted?
- Are idempotency and concurrency handled where side effects exist?
- Does the contract avoid leaking framework or database internals?
