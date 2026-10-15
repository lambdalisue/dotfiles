# Version Control Is jj — Describe First, Then Implement

Every repository is driven with **jj (Jujutsu)**, colocated on top of Git. Git
remains the storage and the wire protocol; jj is the only tool that writes
history. A PreToolUse hook (`enforce-jj.sh`) rejects history-writing `git`
commands before they run, so write the jj form the first time.

## The loop: message first, code second

A change is described **before** a single file is edited. The description is the
scope contract: write down what this change does and why, then implement exactly
that.

1. **Make sure the repository is a jj repository.** `jj root` fails in a plain
   Git checkout; run `jj git init --colocate` there once. It adds `.jj/` (which
   Git ignores) and touches nothing else.
2. **Open the change with its message.** Look at `jj log -r @` first:
   - `@` is empty and has no description → `jj describe -m "<message>"`.
   - Otherwise → `jj new -m "<message>"`. Never overwrite the description of a
     change that already has content.
3. **Implement.** jj snapshots the working copy into `@` on every `jj` command;
   there is no staging and no commit step.
4. **Keep the message true.** When the scope of the work shifts, rewrite the
   description with `jj describe -m` so it states what the change now does.
5. **A second intent gets a second change.** When the work reveals something
   that belongs in its own change (a precursor refactor, an unrelated fix),
   `jj new -m "<that message>"` before editing for it. If the edits already
   landed in `@`, split them out with `jj split -m "<message>" <paths>`.
6. **Finish** by leaving `@` described. The next task starts again at step 2.

Opening, describing, and splitting the change you are working on are part of
editing — do them without asking. The message conventions (Conventional
Commits, WHY in the body, the repository's language) are in
`~/.claude/skills/jj-commit/SKILL.md`.

## No interactive commands

Inside Claude Code the jj config sets every editor to `false`, so a command
that would open an editor or a diff editor fails at once with `Editor 'false'
exited` or `Tool exited with exit status: 1`. Do not retry it; pass the input
on the command line:

| Needs | Write |
| --- | --- |
| A description | `jj describe -m "…"`, `jj new -m "…"`, `jj commit -m "…"` |
| A subject and a body | One `-m` per paragraph: `jj describe -m "<subject>" -m "<body>" -m "<trailers>"` — jj joins them with blank lines and keeps `#` lines |
| Part of a change | `jj split -m "…" <paths>` / `jj squash --into <rev> -u <paths>` — by path, never `-i` |
| A squash | Always `-u` (keep the destination's message) or `-m "…"`, else jj asks to merge both messages |
| A conflict resolution | Edit the marker lines in the file, never `jj resolve` (see the `jj-resolve` skill) |

Selection is file-level. When one file holds hunks for two intents, move the
unwanted hunk out of the file, split, then put it back.

## Git → jj

| Git habit | jj |
| --- | --- |
| `git add` / `git commit` | Nothing to stage; `jj describe -m` / `jj new -m` |
| `git commit --amend` | Keep editing `@`; `jj describe -m` for the message |
| `git commit --fixup` + autosquash | `jj squash --into <rev> -u <paths>` or `jj absorb` |
| `git rebase -i` reword | `jj describe -r <rev> -m "…"` |
| `git rebase origin/main` | `jj git fetch` then `jj rebase -b @ -o 'trunk()'` |
| `git stash` | `jj new <base>`; the old change stays where it was |
| `git checkout <rev>` | `jj new <rev>` (or `jj edit <rev>` to amend it in place) |
| `git reset --hard` / restoring a file | `jj restore <paths>` / `jj abandon` |
| `git branch` | `jj bookmark create/move/list` |
| `git worktree add` / `git wt` | `jj workspace add` (see `jj/workspace.md`) |
| `git status` / `git log` / `git diff` | `jj st` / `jj log` / `jj diff` |

Read-only `git` (`log`, `diff`, `show`, `blame`, `ls-files`, `rev-parse`,
`ls-remote`) still works in a colocated repository and is fine to use, but note
that Git's `HEAD` is `@-`: `git diff` shows `@`'s own changes as uncommitted.

## Revisions worth knowing

- `@` the working-copy change, `@-` its parent.
- `trunk()` the remote default branch (`main@origin` and friends).
- `trunk()..@` everything this line of work adds on top of trunk.
- `conflicts()` every change that currently holds a conflict.
- Refer to a change by its **change ID** (`jj log` prints it); it survives
  rewrites, unlike the commit hash.
