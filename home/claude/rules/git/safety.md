# Git Safety Rules

## Commit Restriction

**NEVER commit without explicit user permission.**

### Workflow

1. **Stage** - Prepare files to commit
2. **Draft** - Create commit message
3. **Confirm** - Show staged files and draft message to user
4. **STOP** - Wait for user approval (use AskUserQuestion)
5. **Commit** - Only after approval, execute `git commit`

### Rules

- Commits forbidden by default
- Permission is valid for ONE commit ONLY and expires immediately after use
- If you make additional changes (e.g., update README), you MUST ask for
  permission again before committing
- After each commit, MUST recite:
  > "🚨 COMMIT PERMISSION EXPIRED 🚨 I am now FORBIDDEN to commit. I will NOT
  > commit again until explicitly permitted. If I need to commit, I MUST ASK
  > FIRST."

**IMPORTANT**: Always use AskUserQuestion to obtain explicit approval before executing `git commit`. Never assume permission is granted.

## Backup Before Destructive Operations

**ALWAYS backup before operations that may lose working tree state.**

Examples requiring backup:

- `git restore`
- `git reset`
- `git checkout` (switching branches with uncommitted changes)
- `git stash drop`
- Any file deletion/overwrite of uncommitted work

## Git Stash Forbidden

**NEVER use `git stash`.**

Git stash is shared across worktrees, causing cross-worktree contamination.

**Use backup branch instead:**

```bash
git checkout -b "backup/$(git branch --show-current)/$(date +%Y%m%d-%H%M%S)"
git commit -am "WIP: before risky refactoring"
git checkout -
git cherry-pick --no-commit HEAD@{1}
```

## Stay in Worktree Directory

**NEVER leave worktree directory when working on worktree task.**

- If starting in `.worktrees/{branch}/`, ALL operations stay there
- Do NOT `cd` to root repository or other directories
- Run all commands (git, deno, etc.) from within worktree
- Use absolute paths to check root repository state without changing directory
