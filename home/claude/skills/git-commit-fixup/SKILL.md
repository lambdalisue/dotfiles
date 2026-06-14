---
name: git-commit-fixup
description: Analyze working tree changes, map to existing commits, and create fixup commits for autosquash
argument-hint: "[context]"
---

## Arguments

- `context` (optional): Additional context for mapping changes to commits (e.g., "These changes are for the auth refactor", "Fix edge cases in parser"). This context will be used to inform which existing commits the changes should be mapped to.

## When to use

The user invoking `/git-commit-fixup` IS the explicit intent to commit — do NOT ask for approval.

**Self-contained**: this skill reads git and commits directly from the
top-level session. Do NOT spawn a subagent — it adds a slow context round-trip.

## Conventions

- **Fixup**: `git commit --fixup=<sha>` creates a commit auto-squashed into its target during `git rebase -i --autosquash`.
- **Mapping**: map each hunk to the commit whose intent it extends — semantic intent is the primary signal, file/region overlap is secondary, and a later commit is the tiebreaker when intent fits several equally. Changes with no related commit become a new commit.
- **Commit = WHY** (t-wada). Message language follows the repo (detect from `git log`; default English).

## Language

- User-facing explanations, summaries: **Japanese**
- Git artifacts (commit messages, branch names): **preserve original language** (repo's existing language)

## Workflow

1. **Analyze** (read-only git):
   1. Detect base branch: `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'` (fallback: `main`/`master`).
   2. Commits since base: `git log --oneline <base>..HEAD`. If there are no commits to fixup against, inform the user and suggest using `/git-commit` instead. **STOP**.
   3. Working tree: `git status --short`, `git diff --stat`, `git diff --cached --stat`. If nothing to commit, inform the user and **STOP**.
   4. Review changes with `git diff` and `git diff --cached`; inspect candidate target commits with `git show --stat <sha>` / `git show <sha>` as needed.
   5. Build a plan mapping changes to target commits (mostly `fixup`, with `new` for anything unmapped). Each entry: type, target SHA (for `fixup`) or full message (for `new`), and the explicit list of files to stage.

2. **Execute** - Run **directly via the Bash tool**. Do NOT ask for approval — the `/git-commit-fixup` invocation is the explicit permission.

   Procedure:
   1. Backup: `git backup "before commit-fixup"` (or `git branch backup/$(date +%s) HEAD` if `git backup` alias is unavailable)
   2. For each entry in the plan, in order:
      - Reset staging if needed: `git reset -q HEAD -- .`
      - Stage the planned files explicitly by name
      - Verify: `git diff --cached --stat`
      - For fixup entries: `git commit --fixup=<target-sha>`
      - For new-commit entries: `git commit -m "<message>"`
   3. Report `git log --oneline` of the new commits to the user.

   **Forbidden during execution**: `git add -A`, `git add .`, `git commit -a`, `git stash`, `git rebase`, `git commit --amend`. Stage explicitly by name only.

   If a commit fails (e.g., pre-commit hook), stop and report — do NOT improvise around the failure.

3. **Present** - Show rebase instructions in Japanese:
   ```
   ✅ fixup コミットを作成しました

   以下のコマンドで自動的にスカッシュできます:
     git rebase -i --autosquash origin/<base-branch>
   ```
