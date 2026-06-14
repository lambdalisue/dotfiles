---
name: git-commit-staged-fixup
description: Map staged changes to existing commits and create fixup commits for autosquash
argument-hint: "[context]"
---

## Arguments

- `context` (optional): Additional context for mapping changes to commits (e.g., "These changes are for the auth refactor", "Fix edge cases in parser"). This context will be used to inform which existing commits the changes should be mapped to.

## When to use

The user invoking `/git-commit-staged-fixup` IS the explicit intent to commit — do NOT ask for approval.

**Self-contained**: this skill reads git and commits directly from the
top-level session. Do NOT spawn a subagent — it adds a slow context round-trip.

## Conventions

- **Fixup**: `git commit --fixup=<sha>` creates a commit auto-squashed into its target during `git rebase -i --autosquash`.
- **Mapping**: map staged changes to the commit whose intent they extend — semantic intent primary, file/region overlap secondary, later commit as tiebreaker. Anything unmapped becomes a new commit.
- **Commit = WHY** (t-wada). Message language follows the repo (detect from `git log`; default English).

## Language

- User-facing explanations, summaries: **Japanese**
- Git artifacts (commit messages, branch names): **preserve original language** (repo's existing language)

## Workflow

1. **Pre-check** - Verify staging status:
   ```bash
   git diff --cached --quiet && echo "NOTHING_STAGED" || echo "HAS_STAGED_CHANGES"
   ```
   If "NOTHING_STAGED", inform the user: "ステージングされた変更がありません。先に `git add <file>` でファイルをステージングしてください。" and **STOP**.

2. **Analyze** (read-only git):
   1. Detect base branch: `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'` (fallback: `main`/`master`).
   2. Commits since base: `git log --oneline <base>..HEAD`. If there are no commits to fixup against, inform the user and suggest using `/git-commit-staged` instead. **STOP**.
   3. Review the staged changes: `git diff --cached`; inspect candidate target commits with `git show --stat <sha>` / `git show <sha>` as needed.
   4. Build a plan mapping the staged changes to target commits (mostly `fixup`, with `new` for anything unmapped). Each entry: type, target SHA (for `fixup`) or full message (for `new`), and the files in that group.

3. **Execute** - Run **directly via the Bash tool**. Do NOT ask for approval — the `/git-commit-staged-fixup` invocation is the explicit permission.

   Procedure (single fixup target — staging untouched):
   1. `git commit --fixup=<target-sha>`
   2. Report `git log --oneline -1`

   Procedure (multiple targets — needs re-staging):
   1. Note the current staged set via `git diff --cached --stat`
   2. For each group, in plan order:
      - Reset staging: `git reset -q HEAD -- .`
      - Re-stage only the files in this group, explicitly by name
      - Verify: `git diff --cached --stat`
      - For fixup entries: `git commit --fixup=<target-sha>`
      - For new-commit entries: `git commit -m "<message>"`
   3. Report `git log --oneline` of new commits

   **Forbidden during execution**: `git add -A`, `git add .`, `git commit -a`, `git stash`, `git rebase`, `git commit --amend`. Stage explicitly by name only.

   If a commit fails (e.g., pre-commit hook), stop and report — do NOT improvise around the failure.

4. **Present** - Show rebase instructions in Japanese:
   ```
   ✅ fixup コミットを作成しました

   以下のコマンドで自動的にスカッシュできます:
     git rebase -i --autosquash origin/<base-branch>
   ```
