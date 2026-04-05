---
paths:
  - '**/*.go'
---

- Follow gofmt and go vet conventions strictly.
- Always pass context.Context as the first parameter.
- Wrap errors with %w for proper error chain inspection.
- Prefer small, focused interfaces over large ones.
- Be explicit about concurrency — document goroutine lifecycles.
