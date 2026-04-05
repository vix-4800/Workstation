---
paths:
  - '**/*.ts'
  - '**/*.tsx'
  - '**/*.js'
  - '**/*.jsx'
---

- Enable strict mode in tsconfig.json (`strict: true`).
- Never use `any` — use `unknown` when the type is truly dynamic.
- Default to `const` for variable declarations.
- Prefer async/await over raw Promise chains.
- Use `===` and `!==` exclusively (no `==` or `!=`).
- Keep components and functions small and focused on a single responsibility.
