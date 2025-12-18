---
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git add:*), Bash(git commit:*), Bash(git show:*)
description: Stage meaningful diffs and create Conventional Commits with WHY-focused messages
model: haiku
---

## Context

!`git status --short`
!`git diff --stat`
!`git diff --cached --stat`
!`git log --oneline -5`

## Principles

**Conventional Commits**: `<type>[scope]: <description>` + body + footer

**Breaking Changes**: `feat!:` or `fix!:` only (other types cannot be breaking by definition)

**t-wada's Principle**: Code=HOW, Tests=WHAT, **Commit=WHY**, Comments=WHY NOT

## Workflow

1. **Analyze** - Review diffs, identify logical groupings
2. **Stage** - Skip if already staged; otherwise use `git add -p` for partial staging
3. **Confirm** - Show staged file list and draft commit message, wait for user approval
4. **Commit** - Craft message with body explaining WHY

## Example

```
fix(parser): handle empty input without panic

The parser assumed non-empty input, causing crashes in automated
pipelines. Defensive handling follows the robustness principle.

Fixes #87
```

## Begin

Analyze changes and create commits per logical unit. Process multiple change sets sequentially.
