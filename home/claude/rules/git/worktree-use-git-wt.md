# Worktrees — When to Cut One, and Always via `git wt`

## When to Cut a Worktree

Work that **modifies the repository** — implementing a feature, fixing a bug,
refactoring, editing docs, bumping dependencies — starts by cutting a dedicated
worktree with `git wt <branch>`, and every step of that work happens inside it.
This is the default, not an absolute: the exceptions below are real.

- **Investigation needs no worktree.** Reading code, Grep/Glob/Read, running
  read-only commands, answering questions, and planning all stay in the current
  checkout. Do not cut a worktree just to look around.
- **Cut it before the first edit.** When investigation turns into modification,
  create the worktree at that moment — not after the first file is already
  changed in the wrong checkout.
- **Already inside a worktree? Stay there.** See the "Stay in Worktree
  Directory" rule in `git/safety.md`.
- **The user's explicit instruction wins.** If they ask for the change right
  here in the current checkout, do it there.

## How to Create One

When creating a git worktree, ALWAYS use the `git wt` subcommand
(the `git-wt` helper on PATH) rather than raw `git worktree add`.

- Create/switch: `git wt <branch>` — creates the worktree and branch
  under the configured `wt.basedir` (default `.wt/<branch>` in-repo).
- Different branch name: `git wt -b <branch> <worktree>`.
- From a start-point: `git wt <branch> <start-point>` (e.g. `origin/main`).
- Delete (safe): `git wt -d <branch|worktree|path>...`.
- List: `git wt` with no arguments.

Do NOT hand-roll `git worktree add`, pick ad-hoc paths, or `mkdir` a
base directory yourself — `git wt` owns path layout, branch tracking,
and configured file-copy behavior. This applies even when a skill or
workflow proposes a raw `git worktree add`; prefer `git wt`.
