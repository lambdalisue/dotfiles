---
name: git-commit-new
description: Analyze working tree changes, plan logically minimal NEW atomic commits per hunk (no fixup), and execute them
argument-hint: "[context]"
---

Follow `~/.claude/skills/git-commit/COMMON.md` for the invocation contract,
conventions, language policy, and execute procedure — read it first if it is
not already in context. This file defines only what is specific to
`/git-commit-new`.

## Arguments

- `context` (optional): Additional context for the commit messages (e.g.,
  "Fix #123", "Refactor for clarity"). Used to generate more accurate and
  meaningful commit messages for all planned commits.

## Behavior

Creates **new atomic commits only** — never maps changes into existing
commits as fixups. Use `/git-commit` when you want fixups where appropriate.

## Workflow

1. **Analyze** (read-only git):
   1. Working tree: `git status --short`, `git diff --stat`,
      `git diff --cached --stat`. If nothing to commit, inform the user and
      **STOP**.
   2. Review changes with `git diff` and `git diff --cached`.
   3. Plan logically minimal new atomic commits at hunk-level granularity,
      folding the `context` into the messages to explain WHY. Each entry:
      full commit message + explicit list of files to stage (all entries are
      `new`).

2. **Execute** per COMMON.md (backup reason: `"before commit-all"`).
   The Present step is unnecessary — no fixups are created.
