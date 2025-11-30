## Implementation

- **Avoid duplication**: Check existing code before custom implementations
- **Check existing patterns**: Review code/docs before implementing
- **T-Wada style**: Implement from tests when possible

## STRICT RULES (MUST FOLLOW)

### 1. Git Commit Restriction

**NEVER commit without explicit user permission.**

- Commits are forbidden by default
- Only perform a commit ONCE when the user explicitly grants permission
- After committing, MUST recite this rule:
  > "Reminder: Commits are forbidden by default. I will not commit again unless
  > explicitly permitted."

### 2. Backup Before Destructive Operations

**ALWAYS create a backup before any operation that may lose working tree
state.**

Examples requiring backup:

- `git restore`
- `git reset`
- `git checkout` (switching branches with uncommitted changes)
- `git stash drop`
- Any file deletion or overwrite of uncommitted work

### 3. Pre-Completion Verification

BEFORE reporting task completion, run project specific verification command to
ensure zero errors/warnings:

### 4. English for Version-Controlled Content

**Use English for ALL content tracked by Git:**

- Code (variable names, function names)
- Comments
- Documentation (README, CLAUDE.md, etc.)
- Commit messages
- Error messages in code

Unless the project already contains non-English tracked contents.

### 5. Stay in Worktree During Worktree Tasks

**NEVER leave the worktree directory when working on a worktree task.**

- If you start work in `.worktrees/{branch}/`, ALL operations must stay there
- Do NOT `cd` to the root repository or other directories
- Run all commands (git, deno, etc.) from within the worktree
- If you need to check the root repository state, use absolute paths without
  changing directory

### 6. Git Stash is Forbidden in Worktrees

**NEVER use `git stash` in worktree environments.**

Git stash is shared across all worktrees. This causes accidental cross-worktree
contamination.

**Use backup branch instead:**

```bash
git checkout -b "backup/$(git branch --show-current)/$(date +%Y%m%d-%H%M%S)"
git commit -am "WIP: before risky refactoring"
git checkout -
git cherry-pick --no-commit HEAD@{1}
```

This creates a persistent backup branch while keeping changes in your working
tree.
