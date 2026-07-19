---
name: git-commit
description: Analyze working tree changes and commit them — fixup into existing commits where appropriate, otherwise new atomic commits
argument-hint: "[context]"
---

Follow `~/.claude/skills/git-commit/COMMON.md` for the invocation contract,
conventions, language policy, base branch detection, execute procedure, and
autosquash presentation — read it first if it is not already in context.
This file defines only what is specific to `/git-commit`.

## Arguments

- `context` (optional): Additional context for the commit messages / mapping
  (e.g., "Fix #123", "These changes belong to the auth refactor"). Used to
  generate accurate messages and to inform which existing commits changes
  map to.

## Behavior

Commits all working tree changes. **Fixup-aware**: changes are mapped to
existing commits (since base branch) as `fixup` where appropriate, otherwise
committed as new atomic commits; with no commits since base it falls back to
new commits only.

Use `/git-commit-new` for new commits only (no fixup), `/git-commit-fixup`
for fixup mapping only.

## Workflow

1. **Analyze** (read-only git):
   1. Detect base branch (per COMMON.md).
   2. Commits since base: `git log --oneline <base>..HEAD`. If none, there
      is nothing to fixup against → plan new commits only.
   3. Working tree: `git status --short`, `git diff --stat`,
      `git diff --cached --stat`. If nothing to commit, inform the user and
      **STOP**.
   4. Review changes with `git diff` and `git diff --cached`; inspect
      candidate target commits with `git show --stat <sha>` / `git show <sha>`
      as needed.
   5. Build a fixup-aware plan (mix of `fixup` and `new` entries), folding
      the `context` into the messages to explain WHY. Each entry: type,
      target SHA (for `fixup`) or full message (for `new`), and the explicit
      list of files to stage.

2. **Execute** per COMMON.md (backup reason: `"before commit-all"`).

3. **Present** per COMMON.md.
