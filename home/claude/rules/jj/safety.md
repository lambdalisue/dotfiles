# jj Safety Rules

## What needs the user's request

Describing and splitting the change you are working on is part of editing (see
`jj/workflow.md`). Everything below reaches past that change, and runs only when
the user asked for it in the current message, or through a skill the user
invoked:

- **Pushing**: `jj git push` in any form. Never push on your own initiative.
- **Rewriting other changes**: `jj squash --into`, `jj absorb`, `jj rebase`,
  `jj describe -r`, `jj abandon` aimed at changes other than `@`. The
  `jj-commit`, `jj-reword`, `jj-rebase`, and `jj-resolve` skills are the
  sanctioned paths.
- **Moving bookmarks** that track a remote branch (`jj bookmark move/set/delete`).

A request is valid for one operation; it does not extend to the next.

## Never rewrite what others have

`trunk()` and everything a remote already holds is immutable to jj by default
and must stay that way. Never pass `--ignore-immutable`. If a command refuses
because a change is immutable, stop and report.

## No backup step — the operation log is the backup

Every jj command is recorded in the operation log, so there is nothing to back
up before a rewrite. To recover:

- `jj undo` reverts the last operation.
- `jj op log` lists operations; `jj op restore <op-id>` returns the whole repo
  to that point.

Do not call `git backup` or create `backup/*` branches in a jj repository.

## Check what is about to be recorded

jj tracks new files automatically, honouring `.gitignore`. Before pushing, read
`jj st` / `jj diff --stat -r 'trunk()..@'` for files that must not leave the
machine (credentials, `.env`, large binaries). Add them to `.gitignore` and run
`jj file untrack <path>`.

## Git hooks do not run

jj never runs `pre-commit` or `commit-msg` hooks. When a repository relies on
them (`.pre-commit-config.yaml`, `lefthook.yml`, `.husky/`, `core.hooksPath`),
run the checks they would have run — its `just` / `make` / `npm` check target —
before reporting the change as done.

## Git commands that are blocked

The `enforce-jj.sh` hook rejects history- and index-writing Git commands in any
Git repository: `commit`, `add`, `rm`, `mv`, `reset`, `restore`, `checkout`,
`switch`, `rebase`, `merge`, `cherry-pick`, `revert`, `stash`, `pull`, `push`,
`am`, `tag`, `branch` writes, `worktree` writes, `wt`, `backup`. Its message
names the jj form. `git clone` and read-only commands pass.
