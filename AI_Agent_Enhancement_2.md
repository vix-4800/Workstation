# AI Agent Upgrade Plan for a PHP/Review-First Workstation

## Summary

- Build the next iteration around three layers: portable cross-tool skills, native per-tool orchestration features, and strict execution guardrails.
- Keep the current strengths you already have: shared global instructions, `github/serena/context7/docker` MCP, and a repo-managed skill directory. The biggest gap is not infrastructure but specialization: the current skill set is too generic for PHP/Laravel/Yii2 review, secure refactoring, migration safety, and PR triage.
- Use strict defaults: plan/review first, edits second, dangerous shell/network/git actions gated.

## Key Changes

- Make `roles/ai-tools/files/agents/skills` the main shared library and expand it from 4 generic skills to this v1 set: `php-strict-review`, `laravel-architecture`, `yii2-modernization`, `refactor-safely`, `pr-review-owner`, `ci-failure-triage`, `migration-safety`, `ansible-change-safety`, `dependency-upgrade-review`, `security-review`.
- Keep those skills instruction-first. Add `scripts/` only for deterministic evidence gathering with existing local tools: `phpstan`, `phpcs`, `phpmd`, `rector --dry-run`, `composer audit`, `ansible-lint`, `yamllint`, `shellcheck`, `git diff`, `gh`.
- Standardize one cross-tool agent roster with the same names and intent everywhere: `repo-explorer`, `php-reviewer`, `security-reviewer`, `docs-researcher`, `refactor-worker`, `ansible-reviewer`.
- Implement those agents natively per client: `.codex/agents/*.toml`, `.claude/agents/*.md`, `.qwen/agents/*.md`. Keep descriptions aligned so delegation behavior stays predictable across tools.
- For Codex, add a real native layer instead of skills only: custom agents, `[agents]` limits, and `.codex/rules`. Auto-allow only safe discovery and dry-run analysis commands. Keep `git commit/push`, destructive file ops, package installs, remote fetch/install commands, destructive Docker actions, and secret-path access on prompt/deny.
- For Claude, shift from broad edit acceptance to policy-driven permissions. Add `permissions.deny` for `.env*`, `secrets/**`, SSH keys, kube configs, `vault/**`, local host vars, and other sensitive files. Add `PreToolUse` hooks to block protected-file edits and risky shell patterns. Add `PostToolUse` hooks to run file-type-specific validators on changed files.
- For Qwen, stop using a global `auto-edit` baseline. Use plan/default as the normal mode, keep MCP trust disabled by default, and lean on `.qwen/skills`, `.qwen/agents`, and project `.qwen/settings.json` for repo-specific behavior.
- Use Claude plugins and Qwen extensions as one shared packaging path for richer workflows. Create one internal backend-focused plugin/extension pack containing shared skills, the six agents above, protected-file hooks, optional PHP LSP defaults, and optional MCP definitions. Publish it for Claude first, then consume it in Qwen through Qwen’s Claude-plugin compatibility layer.
- Keep MCP expansion narrow in phase 1. Retain `github`, `serena`, `context7`, `docker`. Add only a vetted quality-gates layer, preferably self-authored, exposing safe wrappers around your existing linters/tests. Defer browser automation, write-capable database MCP, and remote infra MCP until guardrails are proven.
- Include config correctness and reproducibility in the same wave. Normalize each client’s config instead of using a weakest-common-denominator setup, fix schema mistakes like the Qwen `folderTrust` typo, and provision all runtime prerequisites explicitly through Ansible so `uv/uvx`, `npx`, `gh`, and related tooling are guaranteed rather than incidental.
- Thin the global instruction file over time. Keep universal behavior and safety rules there, but move stack-specific procedures into skills and agents. For future Laravel/Yii2 repos, add project-scoped instructions and project-scoped skills/agents instead of continuing to grow one monolithic global prompt.

## Test Plan

- Verify all new skills are discovered in `codex`, `claude`, and `qwen`.
- Verify all six agents are listed and can be explicitly invoked.
- Run one PR-review scenario and confirm exploration delegates to `repo-explorer` and findings come from `php-reviewer` and `security-reviewer`.
- Confirm secret files and protected infra files are denied in Claude, risky commands still prompt in Codex, and Qwen does not start in `auto-edit` or YOLO behavior by default.
- Confirm post-edit validation loops work for PHP, shell, YAML, and Ansible files and surface actionable failures back to the agent.
- Validate five representative workflows on a sample repo or scratch branch: Laravel endpoint review, Yii2 refactor review, PR review from diff, CI failure triage, and Ansible role review.
- Verify `just apply` on a fresh machine installs every prerequisite needed for configured skills, agents, hooks, and MCP servers.

## Assumptions

- Default operating mode is `Strict`.
- First wave prioritizes PHP/Laravel/Yii2, code review, refactoring, migrations, and security review over broader DevOps automation.
- GitHub remains the default forge integration unless you later need a parallel GitLab layer.
- Prefer self-authored, version-controlled skills and agents over broad marketplace/plugin sprawl; third-party additions are opt-in and must be audited.
- Reference basis: [Codex Skills](https://developers.openai.com/codex/skills), [Codex Subagents](https://developers.openai.com/codex/subagents), [Codex AGENTS.md](https://developers.openai.com/codex/guides/agents-md), [Codex MCP](https://developers.openai.com/codex/mcp), [Codex Rules](https://developers.openai.com/codex/rules), [Claude Skills](https://code.claude.com/docs/en/skills), [Claude Subagents](https://code.claude.com/docs/en/sub-agents), [Claude Hooks](https://code.claude.com/docs/en/hooks-guide), [Claude MCP](https://code.claude.com/docs/en/mcp), [Claude Settings](https://code.claude.com/docs/en/settings), [Claude Plugins](https://code.claude.com/docs/en/plugins), [Qwen Skills](https://qwenlm.github.io/qwen-code-docs/en/users/features/skills/), [Qwen Subagents](https://qwenlm.github.io/qwen-code-docs/en/users/features/sub-agents/), [Qwen MCP](https://qwenlm.github.io/qwen-code-docs/en/users/features/mcp/), [Qwen Approval Mode](https://qwenlm.github.io/qwen-code-docs/en/users/features/approval-mode/), [Qwen Extensions](https://qwenlm.github.io/qwen-code-docs/en/users/extension/introduction/), [everything-claude-code](https://github.com/affaan-m/everything-claude-code), [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code), [awesome-claude-skills](https://github.com/travisvn/awesome-claude-skills), and [MCP Safety Audit](https://arxiv.org/abs/2504.03767).
