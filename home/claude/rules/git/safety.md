# Git Safety Rules

## Commit Restriction

**ABSOLUTELY NEVER COMMIT WITHOUT EXPLICIT USER PERMISSION.**

- MUST use AskUserQuestion before ANY `git commit`, `/git:commit`, or `/git:commit-staged`
- Permission valid for ONE commit only
- ONLY commit when user explicitly says "commit" in CURRENT message
- Show what will be committed and ask final confirmation

## Backup Before Destructive Operations

ALWAYS backup before: `git restore`, `git reset`, `git checkout` (with uncommitted changes), file deletion of uncommitted work.

## Git Stash Forbidden

**NEVER use `git stash`** (shared across worktrees → contamination). Use backup branch instead.

## Stay in Worktree Directory

If starting in `.worktrees/{branch}/`, ALL operations stay there. Use absolute paths to check root state.
