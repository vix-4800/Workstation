# AGENTS.md authoring guide

## Inclusion and structure

For each rule, ask: what concrete project mistake does this prevent, and is it already
handled by executable configuration or another applicable instruction? Keep commands
that agents need to run that configuration, plus constraints they cannot reliably infer.
Keep a boundary at the root when overlooking it would cause consequential edits.

Use ordinary Markdown, exact `AGENTS.md` casing, descriptive headings, short bullets,
and fenced examples with language labels. No required schema, frontmatter, or standard
set of sections exists. The open format supports root and scoped files; actual loading
depends on the agent. [AGENTS.md format](https://agents.md/)

Organize by the decisions an agent needs to make. A useful starting order is:

1. Critical scope and protected paths.
2. Commands, their prerequisites, and verification requirements.
3. Non-obvious architecture or project conventions.
4. Conditional documentation references.
5. Completion reporting or contribution rules, if the project specifies them.

A one-sentence project description can orient the reader. A full directory tree,
dependency catalog, or architecture essay usually repeats discoverable information.
Delete sections that have no project-specific content. These ordering choices are
editorial recommendations, not requirements imposed by the format.

## Write rules agents can apply

| Decision | Useful instruction shape |
| --- | --- |
| Command | State purpose, exact command, working directory, prerequisites, and when to run it. |
| Restriction | Name the protected path or action and the supported alternative. |
| Conditional policy | State an observable trigger, required action, and applicable scope. |
| Reference | Name the document, what it answers, and when to read it. |
| Verification | State the required check and what to report if it cannot execute. |

Use one operative requirement per bullet. Use **must** for actual mandatory project
policy and **prefer** for a default with legitimate alternatives. Include a brief reason
when it prevents misapplication. Avoid stacking vague qualifications onto requirements.

For example, a generated-code restriction should say where the generated output lives
and how the project regenerates it. A documentation reference should say to read the
migration guide before changing database schema, rather than asking agents to read
every document on every task.

For commands, inspect the manifest or task runner and the CI environment. A documented
command can be real but unavailable locally, or it can be stale and no longer defined.
Keep these cases distinct. A missing mandatory integration command does not make unit
tests an acceptable substitute. Report the broken entry point; preserve the requirement.
Avoid publishing guessed commands or a check as passing after only reading its definition.

Keep runtime versions in their maintained manifests or version files. Repeat an exact
version only when it is a necessary, documented compatibility constraint; otherwise
point to the source. Do not store a session's missing dependencies, temporary failures,
credentials, absolute home paths, or task progress as permanent project instructions.

## Scope and compatibility

Use root `AGENTS.md` as the shared source where supported. A nested file contains local
differences and applies to its subtree; it does not automatically erase all parent rules.
Avoid adding one file per directory without a real need. For edits across subtrees, check
each applicable instruction set. Do not claim that Markdown itself enforces permissions
or takes priority over the tool's system instructions and execution restrictions.

Compatibility notes checked **2026-09-18**; verify the actual installed version and surface
when configuring or promising automatic loading:

- **Codex:** startup discovery walks from the project root to the launch working directory.
  At each level it selects at most one file: `AGENTS.override.md`, then `AGENTS.md`, then
  configured fallbacks. More specific guidance overrides conflicting earlier guidance.
  Do not promise that a root launch automatically includes every descendant file while
  editing. Route agents to applicable subtree instructions explicitly when needed.
  The documented default combined discovery budget is **32 KiB**, controlled by
  `project_doc_max_bytes`; it is not a recommended document size. Splitting files on the
  same discovered path does not remove their combined cost.
  [Codex discovery](https://developers.openai.com/codex/guides/agents-md/)
- **Claude Code:** loads `CLAUDE.md`, not `AGENTS.md` directly. A thin `CLAUDE.md` can
  import the shared file with `@AGENTS.md`, preserving Claude-specific rules below it.
  Nested `AGENTS.md` needs its own supported loading route; a root import does not import
  all descendants. Imports expand at launch and therefore do not save context.
  Anthropic's **under 200 lines** recommendation concerns `CLAUDE.md`; the first-200-lines
  auto-memory behavior concerns the separate `MEMORY.md`, not an AGENTS.md standard.
  [Claude Code memory and imports](https://code.claude.com/docs/en/memory)
- **GitHub Copilot:** support differs among CLI, IDE chat, cloud agent, and code review.
  Check the support matrix for the requested feature. Repository-wide
  `.github/copilot-instructions.md` and path-specific `.instructions.md` are distinct
  mechanisms. GitHub documents precedence among applicable instruction types; reconcile
  those files rather than assuming `AGENTS.md` overrides them. Do not promise that a link
  or Claude's `@` import syntax in a Copilot file expands automatically.
  [Copilot support matrix](https://docs.github.com/en/copilot/reference/custom-instructions-support),
  [instruction types and precedence](https://docs.github.com/en/copilot/concepts/prompting/response-customization)
- **OpenCode:** supports `AGENTS.md` with documented local/global discovery and Claude
  fallbacks. Its `instructions` configuration can load additional files. A plain file
  reference in `AGENTS.md` is not an automatic import; use an explicit reading trigger
  for conditional documents. Verify nested behavior instead of assuming Codex's merge rules.
  [OpenCode rules](https://opencode.ai/docs/rules/)
- **Gemini CLI:** uses `GEMINI.md` by default and supports changing `context.fileName` to
  `AGENTS.md`. Check its memory display and discovery for the actual configuration.
  [Gemini CLI context](https://geminicli.com/docs/cli/gemini-md/)

Inspect existing adapters before changing them. Preserve their substantive rules; adapter
migration is not implied by an AGENTS.md-only request. If an authorized adapter needs a
copy because imports are unsupported, keep it minimal and identify its maintained source.
Avoid creating parallel comprehensive instruction files that inevitably drift.

## Example

Illustrative monorepo with verified pnpm scripts and generated API output; adapt only
the applicable parts after inspecting the target repository. This is not a universal template.

```markdown
# Project instructions

## Scope and constraints

- Before editing a subtree, read its applicable nested `AGENTS.md` files.
- API clients in `packages/api/generated/` are generated. Change the source schema
  and regenerate with `pnpm --filter @example/api generate` from the repository root.

## Commands and verification

- Use the pnpm version declared by `packageManager` in root `package.json`.
- From the repository root, run `pnpm lint` and tests for affected packages.
  Web tests: `pnpm --filter @example/web test`.
- If a required check cannot run, report the command and blocker.
  Do not claim verification completed without its result.

## Conditional documentation

- Before schema changes, read `docs/db.md` for migration and rollback requirements.
```

This example exposes command scope and a generated-file boundary, points to the version
source, and gives a reading trigger. Add setup instructions only when needed and supported
by the actual repository. Authorship of this file does not authorize running regeneration.

## Avoid these failure modes

- Generic exhortations such as “write clean code” or “follow best practices”: replace
  with a concrete project convention or remove.
- Repeating formatter rules: point to the configured check; explain only meaningful
  exceptions or constraints the tools cannot enforce.
- Mandatory planning, delegation, full-suite testing, approval, or documentation on every
  edit: encode these only when existing project policy requires them, with clear triggers.
- Conflicting absolutes: specify scope and resolve the intended policy rather than making
  agents guess. Never discard a safety or compliance requirement because tooling is broken.
- Arbitrary role personas, emphasis on every rule, agent-specific tool names in shared
  instructions, and claims to override higher-priority tool instructions.
- Full README copies, long tutorials, session logs, broad “read everything” instructions,
  and links without purpose or reading conditions.
- Auto-generated drafts treated as authoritative without checking commands and policy.
- New commits, pushes, deployment, dependency installation, or CI changes introduced as
  implicit steps of writing project instructions.

## Evidence and maintenance

There is no demonstrated universal optimum for word count. The skill's word ranges are
an editorial starting point, not an empirical threshold. Anthropic recommends concise,
specific instructions and removing lines that do not prevent mistakes.
[Claude Code best practices](https://code.claude.com/docs/en/best-practices)

Research gives mixed results in different settings. Gloaguen et al.'s revised study
reports no general task-success improvement and higher average inference costs; it finds
repository overviews unhelpful in its benchmarks.
[Evaluating AGENTS.md, v2](https://arxiv.org/abs/2602.11988v2)
Lulla et al., studying 124 pull requests across 10 repositories, report lower median
runtime and output-token use with comparable task completion behavior.
[Efficiency study, v2](https://arxiv.org/abs/2601.20404v2)
These results do not establish that generating an AGENTS.md guarantees better work.

Dos Santos et al. catalog context bloat, skill leakage, lint leakage, blind references,
initialization fossilization, and conflicting instructions. Their prevalence analysis
uses heuristics and manual review; it is not a causal measure of agent performance.
[Configuration smells, v5](https://arxiv.org/abs/2606.15828v5)

Practical synthesis: retain non-standard project requirements, prune duplication, and
evaluate representative tasks. When evaluation is available, compare the same repository
revision and tasks with and without the changed instructions. Observe command selection,
constraint violations, task correctness, and unnecessary work; success in one run is not
a universal guarantee. Do not create new evaluation infrastructure merely to author a file.

Review instructions when their commands, boundaries, or policies change, or when repeated
agent mistakes reveal ambiguity. Prefer replacing a weak rule to accumulating more rules.
OpenAI likewise recommends short, accurate durable guidance and task-specific references.
[Codex best practices](https://developers.openai.com/codex/learn/best-practices/)
