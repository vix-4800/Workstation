---
name: agents-md
description: Use when creating, updating, reviewing, or shortening a project's AGENTS.md, including scoped instructions in monorepos and compatibility with multiple coding agents.
metadata:
  short-description: Evidence-based project instructions for coding agents
---

# AGENTS.md

Create concise project instructions that prevent concrete mistakes. Include verified
project constraints and useful commands; let repository files remain the source of facts.

Read [the authoring guide](references/authoring-guide.md) before drafting. It covers
formatting, compatibility, examples, and research with source links. Recheck official
documentation when the requested tools or versions differ from its compatibility notes.

## Workflow

1. **Inspect before writing.** Read applicable existing instructions, `CONTRIBUTING.md`,
   relevant README sections, build manifests, task runners, CI, and formatter/test
   configuration. Inspect representative code only where conventions remain unclear.
   Exclude dependencies, generated output, and vendored trees from broad discovery.
2. **Establish evidence.** Trace each proposed command, path, or constraint to repository
   evidence or an explicit user requirement. Prefer executable configuration for command
   syntax; preserve documented policy. If they disagree, flag the discrepancy instead
   of inventing a replacement or silently weakening a mandatory check. Ask only when
   missing information blocks a safe draft. Reference manifests for changing versions.
3. **Choose scope.** Put shared rules at the root. Add nested files only for meaningful
   subtree differences; write their scope and local additions or overrides explicitly.
   Keep unrelated parent rules applicable. When nested discovery is uncertain, include
   a root instruction to read the applicable subtree file before editing there.
4. **Draft actionable rules.** Cover relevant commands with working directories and
   prerequisites, non-obvious constraints, and required verification. Add brief project
   orientation, architectural boundaries, or completion reporting only where useful.
   Omit empty sections. Preserve existing intent when editing; keep unrelated files intact.
5. **Check compatibility.** Identify the actual agents and surfaces in use. Use portable
   Markdown for shared rules. Inspect adapters for conflicts. Modify adapters only within
   the requested scope; otherwise report the loading gap. Do not assume all tools expand
   imports, read links automatically, or load every nested file.
6. **Validate.** Confirm paths and command definitions. Run the smallest relevant safe
   checks when prerequisites and authorization permit. Distinguish static inspection
   from execution. Do not install dependencies, start services, apply state, or publish
   merely to validate documentation. Preserve required checks when execution is blocked.
7. **Review behavior.** Walk through a normal edit, a subtree edit, and a blocked-check
   case. Can an agent find the right instructions, choose checks, and report limitations?
   Remove redundant rules and resolve contradictions; leave no invented commands.

## Length

No standard or research establishes a universally optimal size. These are editorial
starting points, not quotas or tool limits:

- Root: about **200–600 words**, often **50–150 lines**; smaller projects can need less.
- Nested: about **100–300 words** of local differences.
- Above roughly **200 lines**, review for duplication, unnecessary detail, and scope.

Count the whole applicable instruction chain, including adapters and eager imports.
Keep important constraints even when they exceed a target. Move conditional detail to
existing docs with explicit reading triggers; splitting eagerly loaded files saves no context.

## Delivery

Return the requested files and a concise list of actual checks and remaining blockers.
Keep research and drafting notes out of the generated `AGENTS.md`. Do not commit, push,
deploy, or create additional policy files as an implicit part of authoring instructions.
