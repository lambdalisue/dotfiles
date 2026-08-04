# Commit Directly to `main` in This Repository

This repository is an explicit exception to the global "cut a worktree
before modifying the repository" rule. Work on `main`, in the main
checkout, and commit there.

## Why

`nix/home/files.nix` symlinks live configuration straight into this
checkout — `~/.claude` → `home/claude`, `~/.config/*` → `home/config/*`,
and so on. The symlinks point at the **main checkout's** paths, so a
change made in a worktree is invisible to the running environment: the
rule you just wrote does not load, the config you just edited is not the
one in effect, and nothing can be verified until the branch merges back.

Editing in the main checkout makes the change live the moment the file is
written (`just switch` is only needed when the *set* of links or packages
changes, not their contents).

There is also no review flow to serve — this is a single-maintainer
personal configuration repository, so a feature branch buys nothing.

## What still applies

- `git/safety.md` in full: back up before destructive operations, stage
  explicitly by name, never `git add -A` / `git commit -a` / `git stash`.
- Commits still go through the `/git-commit` family, never a hand-rolled
  `git commit`.
- Push to `origin/main` only when the user asks.
