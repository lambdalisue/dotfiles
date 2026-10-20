---
name: jj-commit
description: Organize the work in progress into well-described jj changes — split mixed intents apart, squash follow-up edits into the change they extend, and describe what is left
argument-hint: "[--new | --squash] [context]"
---

## Invocation contract

- The slash-command invocation IS the explicit request to reshape the changes in
  `trunk()..@` — do NOT ask for approval.
- **Self-contained**: read jj and rewrite directly from the top-level session.
  Do NOT spawn a subagent.
- Everything here is non-interactive per `~/.claude/rules/jj/workflow.md`:
  selection by path, `-m` for every description, `-u` on every squash.

## Arguments

- `--new`: never squash into existing changes; only split and describe.
- `--squash`: map edits into the existing changes they extend; whatever maps
  nowhere is still split out as its own change.
- Neither: squash where an edit extends an existing change, split otherwise.
- `context` (optional): what the work is for ("Fix #123", "this is the auth
  refactor"). Fold it into the messages and the mapping.

## Conventions

- **The repository's documented convention wins**: check `AGENTS.md`,
  `CLAUDE.md`, `CONTRIBUTING.md`, and `.gitmessage` at the repository root for a
  commit-message convention first. The defaults below apply only when the
  repository documents nothing.
- **Conventional Commits**: `<type>[scope]: <subject>` + body (the WHY) +
  footer; breaking changes use `feat!` / `fix!` only.
- **Description = WHY** (t-wada): the body explains why, not what. The message
  language follows the repository (`jj log -r '::trunk()' --limit 5`; default
  English).
- **Atomic**: split by intent, not by file. A standalone precursor (helper,
  type definition, refactor) becomes an earlier change when the tree is valid
  without what follows it.
- **Mapping**: an edit belongs to the change whose intent it extends — semantic
  intent first, file overlap second, the later change on a tie.

## Language

- User-facing explanations, summaries: **Japanese**
- Descriptions, bookmark names: **preserve the repository's language**

## Workflow

1. **Analyze** (read-only):
   1. `jj log -r 'trunk()..@'` — the mutable stack. If `trunk()..@` holds no
      change with content, inform the user and **STOP**.
   2. `jj diff --stat` / `jj diff` for `@`, and `jj show <id>` for each change
      in the stack the edits might extend.
   3. Build the plan. Each entry is one of:
      - `squash <paths> → <change id>` (not in `--new` mode)
      - `split <paths> as "<message>"` — a new change placed **before** `@`
      - `describe @ as "<message>"` — for whatever stays in `@`
      `@` already carries the describe-first message; keep it for the intent
      it names and split the other intents out of it. Also flag any change in
      the stack whose description is empty — it needs a `describe`.

2. **Execute** in plan order, one jj command per entry:
   - `jj squash --into <change id> -u <paths>`
   - `jj split -m "<subject>" -m "<body>" <paths>`
   - `jj describe -r <change id> -m "<subject>" -m "<body>"`

   When one file holds hunks for two intents, move the unwanted hunk out of
   the file with Edit, run the split, then restore the hunk.

   If a command fails, stop and report. `jj undo` reverts the last step if a
   step went wrong; never improvise around a failure.

3. **Report** `jj log -r 'trunk()..@'` and, in Japanese, which edits went where.
