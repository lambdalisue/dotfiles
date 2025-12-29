# Git Safety Rules

## Commit Restriction

**ABSOLUTELY NEVER COMMIT WITHOUT EXPLICIT USER PERMISSION.**

This is a HARD REQUIREMENT with NO EXCEPTIONS:

- **BLOCKING REQUIREMENT**: You MUST use AskUserQuestion to obtain explicit approval before ANY `git commit` or `/git:commit` command
- Permission is valid for ONE commit ONLY, expires immediately after
- NEVER commit even if:
  - User said "fix all issues"
  - Task seems complete
  - User requested code changes
  - Previous conversation mentioned commits
- ONLY commit when user explicitly says "commit" or "create a commit" in their CURRENT message
- If unsure whether user wants a commit, ask explicitly: "Should I commit these changes?"
- After obtaining permission, verify user wants to commit by showing what will be committed and ask final confirmation

## Backup Before Destructive Operations

**ALWAYS backup before operations that may lose working tree state.**

Examples requiring backup:

- `git restore`
- `git reset`
- `git checkout` (switching branches with uncommitted changes)
- `git stash drop`
- Any file deletion/overwrite of uncommitted work

## Git Stash Forbidden

**NEVER use `git stash`.** (Shared across worktrees → contamination)

Use backup branch instead: Create temp branch, commit WIP, switch back, cherry-pick.

## Stay in Worktree Directory

**NEVER leave worktree directory when working on worktree task.**

- If starting in `.worktrees/{branch}/`, ALL operations stay there
- Do NOT `cd` to root repository or other directories
- Run all commands (git, deno, etc.) from within worktree
- Use absolute paths to check root repository state without changing directory
