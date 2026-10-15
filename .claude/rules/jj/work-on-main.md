# Work on Top of `main` in the Main Checkout

This repository is an explicit exception to the global "cut a workspace
before modifying the repository" rule. Work in the main checkout, with
your changes stacked directly on top of `main`.

## Why

`nix/home/files.nix` symlinks live configuration straight into this
checkout — `~/.claude` → `home/claude`, `~/.config/*` → `home/config/*`,
and so on. The symlinks point at the **main checkout's** paths, so a
change made in another workspace is invisible to the running environment:
the rule you just wrote does not load, the config you just edited is not
the one in effect, and nothing can be verified until it lands back here.

Editing in the main checkout makes the change live the moment the file is
written (`just switch` is only needed when the *set* of links or packages
changes, not their contents).

There is also no review flow to serve — this is a single-maintainer
personal configuration repository, so a side bookmark buys nothing.

## How

- Open each change with `jj new -m "<message>"` (or `jj describe -m` on an
  empty `@`) per `~/.claude/rules/jj/workflow.md`; the stack grows on top of
  `main`.
- jj does not advance `main` by itself. When the user asks to push, move it
  to the newest finished change and push it:
  `jj bookmark move main --to <change id>` then `jj git push -b main`.

## What still applies

- `~/.claude/rules/jj/safety.md` in full.
- Push only when the user asks.
