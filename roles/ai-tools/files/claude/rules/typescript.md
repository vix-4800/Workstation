---
paths:
  - '**/*.ts'
  - '**/*.tsx'
  - '**/*.js'
  - '**/*.jsx'
---

- strict: true in tsconfig. No `any` without explicit justification.
- const by default; let only when reassignment is necessary. Never var.
- async/await over promise chains. Always handle rejections.
- === not ==. No implicit type coercion.
- Keep components (React/Vue/Svelte) small and focused on a single responsibility.
- Run the project's linter and type-checker after changes when available.
