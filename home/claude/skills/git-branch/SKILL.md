---
name: git-branch
description: Analyze changes from origin/main and create a descriptively named branch
---

## Behavior

Proposes a conventionally named branch from the current changes, gets approval,
and creates it. **Self-contained**: this skill reads git and creates the branch
directly from the top-level session. Do NOT spawn a subagent.

## Convention

- Branch name: `<type>/<short-description>` — type is one of `feat`, `fix`, `refactor`, `docs`, `test`, `chore`; description is lowercase, hyphen-separated, max 3-4 words.

## Language

- User-facing explanations, summaries, AskUserQuestion: **Japanese**
- Git artifacts (branch names): **preserve original language** (repo's existing language)

## Workflow

1. **Analyze** (read-only) - `git branch --show-current`, `git status --short`, `git diff --stat origin/main`, `git log --oneline -3`. Determine the type and a short description, then propose `Branch: <type>/<short-description>` with a brief reason.

2. **Approve** - Present the proposed name with AskUserQuestion, options: "Approve", "Edit" (let the user modify the name), "Cancel".

3. **Create** - If approved, run `git switch -c <branch-name>` directly via Bash and confirm. (Never use `git stash`.)
