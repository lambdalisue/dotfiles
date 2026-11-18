# Workspaces — When to Cut One, and Always via `jj workspace add`

## When to Cut a Workspace

Work that **modifies the repository** starts in a dedicated jj workspace, and
every step of that work happens inside it.

- **Investigation needs no workspace.** Reading, searching, read-only commands,
  answering questions and planning stay in the current checkout.
- **Cut it before the first edit**, not after a file is already changed in the
  wrong checkout.
- **Already inside a workspace? Stay there.** Inspect the main checkout by
  absolute path.
- **The user's explicit instruction wins**, and so does a project rule that
  says to work in the main checkout.

## How to Create One

```sh
jj workspace add --name <name> -r 'trunk()' .claude/worktrees/<name>
```

- `<name>` is the planned change in kebab-case (`fix-login-timeout`): the
  workspace and directory name, not a branch. The bookmark comes at push time.
- `-r 'trunk()'` starts from the remote default branch; omit it to start from
  the current checkout's parent.
- `git.colocate = true` adds a Git worktree, so `git`, `gh` and build tools
  keep working inside. `.claude/worktrees/` is gitignored globally and is the
  one location `EnterWorktree` accepts without a prompt.
- `jj workspace add` / `remove` and `git worktree prune` write under
  `.git/worktrees/`, so they run with `dangerouslyDisableSandbox: true`.
  `enforce-jj.sh` refuses them otherwise.

When the main checkout has a Rust `target/`, clone it into the new workspace
before the first build:

```sh
cp -c -R <main checkout>/target <workspace path>/target
```

`-c` is an APFS clone that shares blocks until cargo rewrites them; without it
the copy is tens of gigabytes. Do not share one `CARGO_TARGET_DIR` instead —
parallel workspaces would fight over its build lock.

Then open the change: `jj -R <workspace path> describe -m "<message>"`.

Finish with `jj workspace remove <name>`: it deletes the directory, ignored
files included, and the Git worktree; the changes stay in the repository.
Never `jj workspace forget` — it leaves the directory and its `target/` on disk,
invisible to `jj workspace list`, until the disk fills. A forgotten directory
already there: `rm -rf` it, then `git worktree prune`.

Do NOT use `git worktree add`, `git wt`, or `EnterWorktree` with `name:` — they
make worktrees jj does not know about.

## Working in the Workspace — Switch the Session, Don't `cd` Every Call

After `jj workspace add`, enter it once with `EnterWorktree` and
**`path: <the .claude/worktrees/<name> path>`** — this rule is the explicit
authorization the tool requires. Leave with `ExitWorktree(action: "keep")`.

## The Shell cwd Resets Between Calls — Workspace or Not

A `cd` does NOT carry over to the next Bash call. A path relative to a previous
call's `cd` fails, or silently doubles the prefix (`apps/api-duo/apps/api-duo/…`).

- Address files by **absolute path**, or a tool-native directory flag:
  `jj -R`, `git -C`, `cargo --manifest-path`, `just --justfile`.
- If a `cd` is unavoidable, `cd` to an **absolute** target in the same call.

## One Bash Call, One Simple Command — Inside an Entered Workspace

An entered worktree session refuses, before running it, any Bash command it
cannot prove stays inside the worktree ("too complex to verify"). Inside one:

- **One command per call.** No `;` chains, loops, or leading `VAR=… cmd`.
- **No heredoc.** One `-m` per paragraph; Write a script or payload to the
  scratchpad and pass it by path.
- **No command substitution.** Get a value in one call, use the literal next.

## Waiting

Foreground `sleep` is blocked. Use `Bash(run_in_background)` with an `until`
loop, or `Monitor` — whose deadline parameter is `timeout_ms`, not `timeout`.
