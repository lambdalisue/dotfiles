---
name: pr-address
disable-model-invocation: true
description: Address PR review comments and CI failures end-to-end — run pr-review, fix failing CI, deal-review, git-commit, autosquash rebase, and push in sequence
argument-hint: "[context]"
---

## Arguments

- `context` (optional): Guidance forwarded to /deal-review on which findings
  to address and how (e.g., "1, 2 は対応、3 は不要", "全部対応").

## Language

- User-facing output: **Japanese**

## Authorization

The user's invocation of this skill IS the explicit intent for the whole
chain: implementing fixes, committing, rewriting local history with
autosquash, and pushing. Do NOT ask for approval between steps. The git
safety rules still apply (explicit staging, backups, no `git add -A`,
no `git stash`).

## Workflow

Run the following steps strictly in order. Steps 1, 3, and 4 invoke an
existing skill via the Skill tool — do NOT re-implement their logic here.

### Step 1: /pr-review

Invoke the Skill tool with `skill: pr-review`. This fetches and displays
the unresolved PR review comments.

### Step 2: CI check and fix

Check the PR's CI status:

```bash
gh pr checks
```

If any check is **failing**:

1. Identify the failing runs and fetch their failure logs:
   `gh run view <run-id> --log-failed` (get run IDs from
   `gh pr checks` / `gh run list --branch <branch>`).
2. Diagnose the root cause. Reproduce locally when practical
   (run the failing test / lint / build command).
3. Implement the fix and verify locally that the failing command now
   passes.

If checks are still **pending**, do not wait for them — note it in the
final report and continue.

**Early exit**: if there are no unresolved review comments (Step 1) AND
no failing CI checks AND `git status --short` is clean, report that
there is nothing to address in Japanese and **STOP**.

### Step 3: /deal-review

Skip this step if Step 1 found no unresolved comments.

Invoke the Skill tool with `skill: deal-review`, passing this skill's
`context` argument through as-is. This implements fixes, replies to
threads, and resolves them.

### Step 4: /git-commit

If `git status --short` shows no changes, skip to Step 5.

Invoke the Skill tool with `skill: git-commit`. Pass a short context
summarizing what the changes address (PR review findings and/or the CI
failure that was fixed). This creates fixup and/or new commits.

### Step 5: Autosquash rebase

Only needed when Step 4 created `fixup!` commits
(check `git log --oneline origin/<base>..HEAD`); otherwise skip to
Step 6.

1. Detect the base branch:
   `git symbolic-ref refs/remotes/origin/HEAD | perl -pe 's@^refs/remotes/origin/@@'`
   (fallback: `main`).
2. Backup: `git backup "before autosquash"` (or
   `git branch backup/$(date +%s) HEAD`).
3. Squash non-interactively:
   `GIT_SEQUENCE_EDITOR=: GIT_EDITOR=true git rebase -i --autosquash origin/<base>`
4. If the rebase stops on a conflict, resolve it and continue to
   completion (follow the /git-resolve approach). NEVER leave a rebase
   in progress.

### Step 6: Push

- Never push while on the base branch itself (`main`/`master`) — report
  and STOP.
- If Step 5 rewrote history (or the branch had already diverged from the
  remote): `git push --force-with-lease`
- Otherwise: `git push` (add `-u origin <branch>` if no upstream is set).

### Step 7: Report

Summarize in Japanese:

- 対応した指摘 / スキップした指摘（deal-review の結果）
- CI の状態と修正内容（修正した場合は原因と対処）
- 作成・スカッシュしたコミット（`git log --oneline origin/<base>..HEAD`）
- push 結果（通常 push か force-with-lease か）
