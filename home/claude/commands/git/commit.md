---
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git commit:*)
description: Create a Conventional Commit from already staged changes
model: sonnet
---

## Context

!`git diff --cached --stat`
!`git log --oneline -5`

## Principles

**Conventional Commits**: `<type>[scope]: <description>` + body + footer

**Breaking Changes**: `feat!:` or `fix!:` only (other types cannot be breaking by definition)

**t-wada's Principle**: Code=HOW, Tests=WHAT, **Commit=WHY**, Comments=WHY NOT

**Staging is NOT this command's job**: NEVER run `git add` or any staging command. If nothing is staged, tell the user and stop.

## Workflow

1. **Check** - Run `git diff --cached --stat`. If nothing is staged, inform the user and **STOP** immediately
2. **Analyze** - Review staged diffs with `git diff --cached`
3. **Draft** - Create commit message summarizing the WHY in a fenced code block:
   ```
   <type>[scope]: <description>

   <body explaining WHY>

   [optional footer]
   ```
4. **STOP** - Wait for user approval (use AskUserQuestion)
5. **Commit** - Only after approval, execute `git commit` with the approved message

## Example

```
fix(parser): handle empty input without panic

The parser assumed non-empty input, causing crashes in automated
pipelines. Defensive handling follows the robustness principle.

Fixes #87
```

## Begin

Check for staged changes. If present, analyze and draft a commit message for user approval. If nothing is staged, inform the user and stop.

**IMPORTANT**:
1. NEVER run `git add`, `git add -p`, or any staging command — this is out of scope
2. You MUST ask the user for approval using AskUserQuestion before executing `git commit`
