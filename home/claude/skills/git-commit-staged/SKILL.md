---
name: git-commit-staged
description: Commit already-staged changes — fixup into existing commits where appropriate, otherwise a new commit
argument-hint: "[context]"
---

## Arguments

- `context` (optional): Additional context for the commit message / mapping (e.g., "Fix #123", "Performance improvement", "These changes belong to the auth refactor"). Used to generate an accurate message and to inform which existing commits the staged changes map to.

## Behavior

Commits the already-staged changes directly — the `/git-commit-staged` invocation
IS the explicit intent to commit, so do NOT ask for approval. It is
**fixup-aware**: staged changes are mapped to existing commits (since base
branch) as `fixup` where appropriate, otherwise committed as a new commit; with
no commits since base it falls back to a single new commit.

**Self-contained**: this skill reads git and commits directly from the
top-level session. Do NOT spawn a subagent — it adds a slow context round-trip.

Use `/git-commit-staged-new` for a new commit only (no fixup).

## Conventions

- **Conventional Commits**: `<type>[scope]: <subject>` + body (the WHY) + footer; breaking changes use `feat!`/`fix!` only.
- **Commit = WHY** (t-wada). Message language follows the repo (detect from `git log`; default English).
- **Fixup mapping**: map staged changes to the commit whose intent they extend — semantic intent primary, file/region overlap secondary, later commit as tiebreaker. Staged changes spanning several targets may split across multiple fixup/new entries.

## Language

- User-facing explanations, summaries: **Japanese**
- Git artifacts (commit messages, branch names, PR titles/bodies): **preserve original language** (repo's existing language)

## Workflow

1. **Pre-check** - Verify staging status:
   ```bash
   git diff --cached --quiet && echo "NOTHING_STAGED" || echo "HAS_STAGED_CHANGES"
   ```
   If "NOTHING_STAGED", inform the user: "ステージングされた変更がありません。先に `git add <file>` でファイルをステージングしてください。" and **STOP**.

2. **Analyze** (read-only git):
   1. Detect base branch: `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'` (fallback: `main`/`master`).
   2. Commits since base: `git log --oneline <base>..HEAD`. If none, plan a single new commit from the staged set.
   3. Review the staged changes: `git diff --cached`; inspect candidate target commits with `git show --stat <sha>` / `git show <sha>` as needed.
   4. Detect commit-message language: `git log --oneline -5`.
   5. Build a fixup-aware plan (mix of `fixup` and `new` entries) over the staged set, folding the `context` into the message. Each entry: type, target SHA (for `fixup`) or full message (for `new`), and the files in that group.

3. **Execute** - Run **directly via the Bash tool**. Do NOT ask for approval — the `/git-commit-staged` invocation is the explicit permission.

   Procedure (single fixup target — staging untouched):
   1. Backup: `git backup "before commit-staged"` (or `git branch backup/$(date +%s) HEAD` if `git backup` alias is unavailable)
   2. `git commit --fixup=<target-sha>`
   3. Report `git log --oneline -1`

   Procedure (single new commit — staging untouched):
   1. Backup as above
   2. Verify staging is still intact: `git diff --cached --stat`
   3. `git commit -m "<message>"` (use a heredoc for multi-line messages)
   4. Report `git log --oneline -1`

   Procedure (multiple targets — needs re-staging):
   1. Backup as above
   2. Note the current staged set via `git diff --cached --stat`
   3. For each entry, in plan order:
      - Reset staging: `git reset -q HEAD -- .`
      - Re-stage only the files in this group, explicitly by name
      - Verify: `git diff --cached --stat`
      - For `fixup` entries: `git commit --fixup=<target-sha>`
      - For `new` entries: `git commit -m "<message>"`
   4. Report `git log --oneline` of the new commits

   **Forbidden during execution**: `git add -A`, `git add .`, `git commit -a`, `git stash`, `git rebase`, `git commit --amend`. Stage explicitly by name only.

   If a commit fails (e.g., pre-commit hook), stop and report — do NOT improvise around the failure.

4. **Present** - If the plan contained any `fixup` entries, show rebase instructions in Japanese:
   ```
   ✅ コミットを作成しました（fixup を含みます）

   以下のコマンドで fixup を自動的にスカッシュできます:
     git rebase -i --autosquash origin/<base-branch>
   ```
   If the plan contained only a new commit, this step is unnecessary.
