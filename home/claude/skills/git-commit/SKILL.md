---
name: git-commit
description: Analyze working tree changes and commit them — fixup into existing commits where appropriate, otherwise new atomic commits
argument-hint: "[context]"
---

## Arguments

- `context` (optional): Additional context for the commit messages / mapping (e.g., "Fix #123", "Performance improvement", "These changes belong to the auth refactor"). Used to generate accurate messages and to inform which existing commits changes map to.

## Behavior

Commits all working tree changes directly — the `/git-commit` invocation IS the
explicit intent to commit, so do NOT ask for approval. It is **fixup-aware**:
changes are mapped to existing commits (since base branch) as `fixup` where
appropriate, otherwise committed as new atomic commits; with no commits since
base it falls back to new commits only.

**Self-contained**: this skill reads git and commits directly from the
top-level session. Do NOT spawn a subagent — it adds a slow context round-trip.

Use `/git-commit-new` for new commits only (no fixup).

## Conventions

- **Conventional Commits**: `<type>[scope]: <subject>` + body (the WHY) + footer; breaking changes use `feat!`/`fix!` only.
- **Commit = WHY** (t-wada): the body explains why, not what. Message language follows the repo (detect from `git log`; default English).
- **Atomic**: split by intent, not by file. Extract standalone precursors (helpers, type definitions, refactors) into earlier commits when they would leave the tree in a valid state.
- **Fixup mapping**: map each hunk to the commit whose intent it extends — semantic intent is the primary signal, file/region overlap is secondary, and a later commit is the tiebreaker when intent fits several equally. Changes with no related commit become a new commit.

## Language

- User-facing explanations, summaries: **Japanese**
- Git artifacts (commit messages, branch names, PR titles/bodies): **preserve original language** (repo's existing language)

## Workflow

1. **Analyze** (read-only git):
   1. Detect base branch: `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'` (fallback: `main`/`master`).
   2. Commits since base: `git log --oneline <base>..HEAD`. If none, there is nothing to fixup against → plan new commits only.
   3. Working tree: `git status --short`, `git diff --stat`, `git diff --cached --stat`. If nothing to commit, inform the user and **STOP**.
   4. Review changes with `git diff` and `git diff --cached`; inspect candidate target commits with `git show --stat <sha>` / `git show <sha>` as needed.
   5. Detect commit-message language: `git log --oneline -5`.
   6. Build a fixup-aware plan (mix of `fixup` and `new` entries), folding the `context` into the messages to explain WHY. Each entry: type, target SHA (for `fixup`) or full message (for `new`), and the explicit list of files to stage.

2. **Execute** - Run **directly via the Bash tool**. Do NOT ask for approval — the `/git-commit` invocation is the explicit permission.

   Procedure:
   1. Backup: `git backup "before commit-all"` (or `git branch backup/$(date +%s) HEAD` if `git backup` alias is unavailable)
   2. For each entry in the plan, in order:
      - Reset staging if needed: `git reset -q HEAD -- .`
      - Stage the planned files explicitly by name (`git add <file>...`); for partial hunks use `git add -p <file>` only when truly necessary — prefer file-level staging
      - Verify: `git diff --cached --stat`
      - For `fixup` entries: `git commit --fixup=<target-sha>`
      - For `new` entries: `git commit -m "<message>"` (use a heredoc for multi-line messages)
   3. Report `git log --oneline` of the new commits to the user

   **Forbidden during execution**: `git add -A`, `git add .`, `git commit -a`, `git stash`, `git rebase`, `git commit --amend`. Stage explicitly by name only.

   If a commit fails (e.g., pre-commit hook), stop and report — do NOT improvise around the failure.

3. **Present** - If the plan contained any `fixup` entries, show rebase instructions in Japanese:
   ```
   ✅ コミットを作成しました（fixup を含みます）

   以下のコマンドで fixup を自動的にスカッシュできます:
     git rebase -i --autosquash origin/<base-branch>
   ```
   If the plan contained only new commits, this step is unnecessary.
