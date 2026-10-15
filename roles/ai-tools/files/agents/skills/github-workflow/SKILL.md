---
name: github-workflow
description: Use when creating or updating GitHub issues and pull requests with gh, publishing a branch for a PR, linking PRs to issues, or setting descriptions and assignees. Excludes review-only and CI-debugging requests.
metadata:
  short-description: GitHub issue, branch, and PR workflow with approvals
---

# GitHub Workflow

Carry out the requested parts of issue → branch → changes and checks → push → PR.
Reuse existing work and preserve authorization already given in the conversation.

## Scope and approvals

- Prepare exact commands and final description files before requesting command approval.
  Use the harness approval mechanism for push and GitHub mutations; in Codex, request
  escalation when required by the sandbox. Conversational authorization does not bypass execution policy.
- If policy forbids a command, report the restriction and stop dependent steps.
  Do not bypass it through another tool or transport, or modify policy as part of this workflow.
- Perform only requested operations. Creating a PR does not authorize creating an issue,
  merging, closing issues, force-pushing, or deleting branches.

## Resolve context

Inspect repository instructions, issue/PR templates, `git status --short`, current branch,
remotes, and `gh auth status`. Resolve the target repository, push remote, base and head
from the task, branch configuration, and existing PR. A fork's `origin` can differ from
the PR destination. Do not assume the base is the default branch.

Use explicit `--repo OWNER/REPO` for GitHub operations. Search for matching issues and PRs
before creating them; reuse supplied URLs/numbers and existing work. Ask only when the
remaining ambiguity would change the destination or requested result.

If creation times out or returns an uncertain result, inspect remote state before retrying.
A nonzero exit can still leave a created object. Never blindly repeat `create`.

## Prepare and publish

1. **Issue:** Follow its template. Describe the problem or goal, expected behavior, and
   acceptance criteria; include reproduction details when known. Create or update as requested.
2. **Branch and checks:** Reuse the task branch or create one from the resolved base.
   Stage and commit only task changes when authorized. Run relevant checks before publishing;
   report actual results and any checks not run.
3. **Descriptions:** Follow repository templates and language conventions. Lead the PR body
   with the problem and resulting behavior, then relevant validation and limitations.
   Write multiline bodies to temporary files with literal newlines and use `--body-file`.
   When editing, read the existing body and preserve unrelated content and links.
4. **Assignees:** Apply the requested assignee separately to issue and PR; assignment is not
   inherited through linking. Use `@me` for the authenticated user when self-assignment is
   requested. Otherwise use the supplied login; clarify an unknown requested identity.
   Use `--assignee` on create and `--add-assignee` on edit; preserve other assignees.
5. **Push:** Publish the verified branch to the resolved remote, normally with
   `git push --set-upstream REMOTE BRANCH`. Investigate a rejected push; do not force it.
6. **PR:** Pass explicit `--base` and `--head` after the push succeeds. For a personal fork,
   use `OWNER:BRANCH` as head. This prevents `gh pr create` from implicitly pushing or
   creating a fork. Do not use `gh pr create --dry-run` as a read-only check: it may push.

## Link and verify

For a PR that resolves an issue and targets the default branch, put `Closes #42` in the
PR body. Across repositories, use `Closes OWNER/REPO#42`. For related work that should
leave the issue open, use `Refs OWNER/REPO#42` or its URL.

Closing keywords are ignored for a nondefault base. Use an ordinary reference and report
that it is not a verified Development link or automatic closure. If a Development link
is explicitly required, use a supported approved operation and verify it, or report the
remaining limitation. Do not change the requested base to obtain automatic linking.
See [GitHub's linking rules](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/linking-a-pull-request-to-an-issue).

Read back issue/PR URLs, bodies, assignees, base and head. For a closing link, inspect
`gh pr view NUMBER --repo OWNER/REPO --json closingIssuesReferences`; distinguish a
body reference from a verified closing relationship. Report URLs and incomplete steps.

## Command reference

Adapt these examples to resolved values and requested scope. Each mutation needs command approval.
The body files must already contain reviewed descriptions; the PR body includes the intended issue reference.

```bash
gh issue create --repo owner/repo --title 'Describe the problem' --body-file /tmp/issue-body.md --assignee '@me'
gh issue edit 42 --repo owner/repo --body-file /tmp/issue-body.md --add-assignee '@me'
git push --set-upstream origin fix/42-example
gh pr create --repo owner/repo --base main --head fix/42-example \
  --title 'Fix the problem' --body-file /tmp/pr-body.md --assignee '@me'
gh pr edit 123 --repo owner/repo --body-file /tmp/pr-body.md --add-assignee '@me'
gh issue view 42 --repo owner/repo --json url,body,assignees
gh pr view 123 --repo owner/repo --json url,body,assignees,baseRefName,headRefName,closingIssuesReferences
```
