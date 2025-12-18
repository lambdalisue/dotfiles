---
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Bash(git checkout:*), Bash(git switch:*)
description: Analyze changes from origin/main and create a descriptively named branch
model: haiku
---

## Context

!`git branch --show-current`
!`git status --short`
!`git diff --stat origin/main`
!`git log --oneline -3`

## Principles

**Branch Naming Convention**: `<type>/<short-description>`

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
3. **Draft** - Create branch name and display in a fenced code block:
   ```
   Branch: <type>/<short-description>

   Reason: <brief explanation of why this name fits the changes>
   ```
4. **STOP** - Wait for user approval before creating branch (use AskUserQuestion)
5. **Create** - Only after approval, execute `git switch -c <branch-name>`

## Examples

```
Branch: feat/add-oauth-login

Reason: Changes introduce new GitHub OAuth authentication functionality
```

```
Branch: fix/parser-empty-input

Reason: Changes fix a crash when parser receives empty input
```

```
Branch: docs/api-examples

Reason: Changes add API usage examples to documentation
```

## Begin

Analyze changes from `origin/main`, determine appropriate branch type and name, then present for user approval.

**IMPORTANT**: After drafting the branch name, you MUST ask the user for approval using AskUserQuestion before executing `git switch -c`. Never create a branch without explicit user confirmation.
