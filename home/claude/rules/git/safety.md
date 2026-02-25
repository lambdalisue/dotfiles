# Git Safety Rules

## Commit Restriction

**ABSOLUTELY NEVER COMMIT WITHOUT EXPLICIT USER PERMISSION.**

- MUST use AskUserQuestion before ANY commit operation
- Permission valid for ONE commit only
- ONLY commit when user explicitly says "commit" in CURRENT message
- Show what will be committed and ask final confirmation

**NEVER run `git commit` directly via the Bash tool.** All commits MUST go through:
- `/git:commit` — analyze working tree and create atomic commits
- `/git:commit-staged` — commit already-staged changes
- `/git:commit-fixup` — map working tree changes to existing commits as fixup
- `/git:commit-staged-fixup` — map staged changes to existing commits as fixup

This applies to the main orchestrator AND any manual commit attempts.
Direct `git add ... && git commit` or `git commit -m "..."` via Bash is **PROHIBITED**.

## Backup Before Destructive Operations

ALWAYS backup before: `git restore`, `git reset`, `git checkout` (with uncommitted changes), file deletion of uncommitted work.

## Git Stash Forbidden

**NEVER use `git stash`** (shared across worktrees → contamination). Use backup branch instead.

## Stay in Worktree Directory

If starting in `.worktrees/{branch}/`, ALL operations stay there. Use absolute paths to check root state.
