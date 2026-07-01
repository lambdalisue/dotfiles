# Creating Worktrees — Always Use `git wt`

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
