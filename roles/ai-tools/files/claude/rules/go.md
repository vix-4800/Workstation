---
paths:
  - '**/*.go'
---

- Run `gofmt` and relevant `go test` or `go vet` checks after changes when available.
- Pass `context.Context` explicitly at request, job, and I/O boundaries.
- Wrap errors with `%w`; inspect with `errors.Is` / `errors.As`. Return errors, don't panic in normal flow.
- Keep interfaces small; define them where they are consumed, not where they are implemented.
- Keep concurrency explicit and avoid unsynchronized shared mutable state.
