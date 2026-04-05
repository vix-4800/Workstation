---
paths:
  - '**/*.py'
---

- Use type annotations everywhere (mypy --strict compatible).
- Prefer dataclasses or pydantic models for data structures.
- Use context managers for resource management (files, connections, locks).
- Raise specific exceptions — never bare `Exception`.
- Explicit is better than implicit — prefer clarity over cleverness.
