---
name: jj-workspace
disable-model-invocation: true
description: Create a colocated jj workspace under .claude/worktrees with a name derived from the planned change
---

## Behavior

Proposes a workspace name and the change description it will open with, gets
approval, and creates it per `~/.claude/rules/jj/workspace.md`.
**Self-contained**: run jj directly from the top-level session. Do NOT spawn a
subagent.

## Convention

- Name: `<type>-<short-description>` in kebab-case — type is one of `feat`,
  `fix`, `refactor`, `docs`, `test`, `chore`. It names both the workspace and
  its directory.
- Location: `<repo root>/.claude/worktrees/<name>`.
- Base: `trunk()` unless the user names another revision.
- Uncommitted work does not move: the current workspace's `@` stays where it is.

## Language

- User-facing explanations, summaries, AskUserQuestion: **Japanese**
- Workspace name and description: **preserve the repository's language**

## Workflow

1. **Analyze** (read-only): `jj root`, `jj workspace list`, `jj st`,
   `jj log -r 'trunk()..@'`. Propose:
   ```
   Workspace: <name>
   Path: <repo root>/.claude/worktrees/<name>
   Base: trunk()
   Description: <type>[scope]: <subject>

   Reason: <brief explanation>
   ```

2. **Approve** — AskUserQuestion with "Approve", "Edit" (let the user modify),
   "Cancel".

3. **Create** — if approved:
   ```bash
   jj workspace add --name <name> -r 'trunk()' <repo root>/.claude/worktrees/<name>
   jj -R <repo root>/.claude/worktrees/<name> describe -m "<description>"
   ```
   Run `jj workspace add` outside the sandbox. When `<repo root>/target`
   exists, clone it before entering, inside the sandbox:
   ```bash
   /bin/cp -c -R <repo root>/target <repo root>/.claude/worktrees/<name>/target
   ```
   Then enter it with `EnterWorktree` (`path:` the new directory) and confirm.

4. **Finish** — when the work is done, `jj workspace remove <name>` (outside
   the sandbox) deletes the directory and its `target/`. Never
   `jj workspace forget`, which leaves both on disk.
