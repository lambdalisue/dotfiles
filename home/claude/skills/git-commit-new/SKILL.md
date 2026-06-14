---
name: git-commit-new
description: Analyze working tree changes, plan logically minimal NEW atomic commits per hunk (no fixup), and execute them
argument-hint: "[context]"
---

## Arguments

- `context` (optional): Additional context for the commit messages (e.g., "Fix #123", "Performance improvement", "Refactor for clarity"). This context will be used to generate more accurate and meaningful commit messages for all planned commits.

## Behavior

The user invoking `/git-commit-new` IS the explicit intent to commit — do NOT
ask for approval. It creates **new atomic commits only** and never maps changes
into existing commits as fixups. Use `/git-commit` when you want fixups where
appropriate.

**Self-contained**: this skill reads git and commits directly from the
top-level session. Do NOT spawn a subagent — it adds a slow context round-trip.

## Conventions

- **Conventional Commits**: `<type>[scope]: <subject>` + body (the WHY) + footer; breaking changes use `feat!`/`fix!` only.
- **Commit = WHY** (t-wada): the body explains why, not what. Message language follows the repo (detect from `git log`; default English).
- **Atomic**: split by intent, not by file. Extract standalone precursors (helpers, type definitions, refactors) into earlier commits when they would leave the tree in a valid state.

## Language

- User-facing explanations, summaries: **Japanese**
- Git artifacts (commit messages, branch names, PR titles/bodies): **preserve original language** (repo's existing language)

## Workflow

1. **Analyze** (read-only git):
   1. Working tree: `git status --short`, `git diff --stat`, `git diff --cached --stat`. If nothing to commit, inform the user and **STOP**.
   2. Review changes with `git diff` and `git diff --cached`.
   3. Detect commit-message language: `git log --oneline -5`.
   4. Plan logically minimal new atomic commits at hunk-level granularity, folding the `context` into the messages to explain WHY. Each entry: full commit message + explicit list of files to stage.

2. **Execute** - Run **directly via the Bash tool**. Do NOT ask for approval — the `/git-commit-new` invocation is the explicit permission.

   Procedure:
   1. Backup: `git backup "before commit-all"` (or `git branch backup/$(date +%s) HEAD` if `git backup` alias is unavailable)
   2. For each commit in the plan, in order:
      - Reset staging if needed: `git reset -q HEAD -- .`
      - Stage the planned files explicitly by name (`git add <file>...`); for partial hunks use `git add -p <file>` only when truly necessary — prefer file-level staging
      - Verify: `git diff --cached --stat`
      - Commit with the planned message: `git commit -m "<message>"` (use a heredoc for multi-line messages)
   3. Report `git log --oneline` of the new commits to the user

   **Forbidden during execution**: `git add -A`, `git add .`, `git commit -a`, `git stash`. Stage explicitly by name only.

   If a commit fails (e.g., pre-commit hook), stop and report — do NOT improvise around the failure.
