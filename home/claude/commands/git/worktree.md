---
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Bash(git worktree:*), Bash(git rev-parse:*), Bash(ls:*), Bash(mkdir:*)
description: Create a git worktree under .worktrees/ with an appropriate branch name
model: haiku
---

## Context

!`git rev-parse --show-toplevel`
!`git branch --show-current`
!`git worktree list`
!`git status --short`
!`git diff --stat origin/main`

## Principles

**Worktree Location**: `<repo-root>/.worktrees/<branch-name>`

**Branch Naming Convention**: `<type>/<short-description>` (same as git:branch)

**Types**:
- `feat` - New feature
- `fix` - Bug fix
- `refactor` - Code restructuring
- `docs` - Documentation only
- `test` - Test additions/modifications
- `chore` - Maintenance tasks

**Description**: Lowercase, hyphen-separated, max 3-4 words describing the change

## Workflow

1. **Analyze** - Review diffs from `origin/main` to understand the nature of changes
2. **Categorize** - Determine the appropriate type based on change content
3. **Draft** - Create worktree path and branch name, display in a fenced code block:
   ```
   Branch: <type>/<short-description>
   Path: .worktrees/<type>/<short-description>

   Reason: <brief explanation of why this name fits the changes>
   ```
4. **STOP** - Wait for user approval before creating worktree (use AskUserQuestion)
5. **Create** - Only after approval, execute:
   ```bash
   mkdir -p <repo-root>/.worktrees
   git worktree add <path> -b <branch-name>
   ```

## Examples

```
Branch: feat/add-oauth-login
Path: .worktrees/feat/add-oauth-login

Reason: Changes introduce new GitHub OAuth authentication functionality
```

```
Branch: fix/parser-empty-input
Path: .worktrees/fix/parser-empty-input

Reason: Changes fix a crash when parser receives empty input
```

## Notes

- If working tree has uncommitted changes, they will NOT be carried to the new worktree
- Use `git worktree list` to see all existing worktrees
- Use `git worktree remove <path>` to clean up worktrees when done

## Begin

Analyze changes from `origin/main`, determine appropriate branch name and worktree path, then present for user approval.

**IMPORTANT**: After drafting the worktree details, you MUST ask the user for approval using AskUserQuestion before executing `git worktree add`. Never create a worktree without explicit user confirmation.
