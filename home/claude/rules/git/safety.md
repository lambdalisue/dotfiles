# Git Safety Rules

## Commit Restriction

**NEVER commit without explicit user permission.**

- Use AskUserQuestion to obtain explicit approval before `git commit`
- Permission valid for ONE commit ONLY, expires immediately after
- Use `/git:commit` for proper workflow with approval steps

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
