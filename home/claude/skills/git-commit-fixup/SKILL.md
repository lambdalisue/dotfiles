---
name: git-commit-fixup
disable-model-invocation: true
description: Analyze working tree changes, map to existing commits, and create fixup commits for autosquash
argument-hint: "[context]"
---

Follow `~/.claude/skills/git-commit/COMMON.md` for the invocation contract,
conventions (especially fixup mapping), language policy, base branch
detection, execute procedure, and autosquash presentation — read it first if
it is not already in context. This file defines only what is specific to
`/git-commit-fixup`.

## Arguments

- `context` (optional): Additional context for mapping changes to commits
  (e.g., "These changes are for the auth refactor"). Used to inform which
  existing commits the changes should be mapped to.

## Behavior

Maps working tree changes to existing commits as `fixup` commits for
`git rebase -i --autosquash`. Changes with no related commit become new
commits. Use `/git-commit` for the general fixup-or-new behavior.

## Workflow

1. **Analyze** (read-only git):
   1. Detect base branch (per COMMON.md).
   2. Commits since base: `git log --oneline <base>..HEAD`. If there are no
      commits to fixup against, inform the user and suggest `/git-commit`
      instead. **STOP**.
   3. Working tree: `git status --short`, `git diff --stat`,
      `git diff --cached --stat`. If nothing to commit, inform the user and
      **STOP**.
   4. Review changes with `git diff` and `git diff --cached`; inspect
      candidate target commits with `git show --stat <sha>` / `git show <sha>`
      as needed.
   5. Build a plan mapping changes to target commits (mostly `fixup`, with
      `new` for anything unmapped). Each entry: type, target SHA (for
      `fixup`) or full message (for `new`), and the explicit list of files
      to stage.

2. **Execute** per COMMON.md (backup reason: `"before commit-fixup"`).

3. **Present** per COMMON.md.
