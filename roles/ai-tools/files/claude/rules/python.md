---
paths:
  - '**/*.py'
---

- Type-annotate all function signatures. mypy --strict must pass without errors.
- Use dataclasses or pydantic models instead of raw dicts for structured data.
- Context managers (with) for all resource management: files, DB connections, locks.
- Raise specific exceptions from the built-in hierarchy or domain exceptions. Never bare `except:` or `except Exception:` without re-raise.
- Prefer explicit over implicit. Avoid *args and **kwargs unless building generic utilities.
- Run mypy and the project's test suite after changes when available.
