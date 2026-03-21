---
paths:
  - '**/*.go'
---

- Run `gofmt` and relevant `go test` or `go vet` checks after changes when available.
- Pass `context.Context` explicitly at request, job, and I/O boundaries.
- Return wrapped errors instead of panicking in normal control flow.
- Keep concurrency explicit and avoid unsynchronized shared mutable state.
