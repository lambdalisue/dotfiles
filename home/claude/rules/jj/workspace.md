# Workspaces — When to Cut One, and Always via `jj workspace add`

## When to Cut a Workspace

Work that **modifies the repository** — implementing a feature, fixing a bug,
refactoring, editing docs, bumping dependencies — starts in a dedicated jj
workspace, and every step of that work happens inside it. This is the default,
not an absolute: the exceptions below are real.

- **Investigation needs no workspace.** Reading code, Grep/Glob/Read, running
  read-only commands, answering questions, and planning all stay in the current
  checkout. Do not cut a workspace just to look around.
- **Cut it before the first edit.** When investigation turns into modification,
  create the workspace at that moment — not after the first file is already
  changed in the wrong checkout.
- **Already inside a workspace? Stay there.** Never leave it to work in the main
  checkout; use absolute paths to inspect the main checkout's state.
- **The user's explicit instruction wins**, and so does a project rule that
  says to work in the main checkout.

## How to Create One

```sh
jj workspace add --name <name> -r 'trunk()' .claude/worktrees/<name>
```

- `<name>` is the planned change in kebab-case (`fix-login-timeout`). It is the
  workspace name and the directory name, not a branch: the bookmark is created
  at push time.
- `-r 'trunk()'` starts from the remote default branch. Leave it out to start
  from the current checkout's parent instead.
- `git.colocate = true` makes jj create a **Git worktree** alongside the
  workspace, so `git`, `gh`, and build tools that shell out to Git keep working
  inside it, and the directory appears in `git worktree list`.
- `.claude/worktrees/` is the one location Claude Code's `EnterWorktree`
  accepts without a relocation prompt, and the global gitignore already
  excludes it, so the main checkout never snapshots a workspace's files.

Then open the change in the new workspace per `jj/workflow.md`:
`jj -R <workspace path> describe -m "<message>"`.

Remove a finished workspace with `jj workspace forget <name>` (keeps the
directory) or `jj workspace remove <name>` (deletes it). Its changes stay in
the repository either way.

Do NOT use `git worktree add`, `git wt`, or `EnterWorktree` with `name:` — the
first two make a worktree jj does not know about (jj commands fail inside it),
and the last creates a branch-named Git worktree outside jj.

## Working in the Workspace — Switch the Session, Don't `cd` Every Call

After `jj workspace add`, switch the session into it once:

- `EnterWorktree` with **`path: <the .claude/worktrees/<name> path>`** — the
  workspace is a Git worktree, so it is accepted, and the cwd reset target
  becomes the workspace. This rule is the explicit authorization the tool
  requires.
- Leave with `ExitWorktree(action: "keep")` — it never removes a
  `path:`-entered worktree.

## The Shell cwd Resets Between Calls — Workspace or Not

The shell cwd resets to the session directory after every Bash call. A `cd`
does NOT carry over, in any session. Prefixing `cd <dir> && …` onto every call
is waste, and a path relative to a *previous* call's `cd` either fails outright
on a directory that exists —

    (eval):cd:1: no such file or directory: references/knowtus

— or silently doubles the prefix: `apps/api-duo/apps/api-duo/…`.

- Address files by **absolute path**, or with a tool-native directory flag:
  `jj -R <dir>`, `git -C <dir>`, `cargo --manifest-path`, `just --justfile`,
  `rg <abs path>`.
- Never a bare relative `cd`. If one is unavoidable, `cd` to an **absolute**
  target in the same call as the command.

## One Bash Call, One Simple Command — Inside an Entered Workspace

A session that has entered a worktree refuses any Bash command it cannot prove
statically stays inside that worktree:

    This session is isolated in the worktree …, but this command is too
    complex to verify that it stays inside the worktree

The check runs *before* anything executes, so a rejected call buys nothing and
costs the turn. It rejects heredocs, `$(…)`, `for` / `while` loops, and
multi-statement chains. Inside an entered workspace:

- **One command per call.** No `;` chains, no loops, no leading `VAR=… cmd`.
- **No heredoc.** A multi-paragraph description is one `-m` per paragraph. To
  run a script or send a payload, Write it into the scratchpad first, then pass
  it by path (`python3 <path>`, `gh api --input <path>`).
- **No command substitution.** Need a change ID or a timestamp? Get it in one
  call, use the literal value in the next.
- **A directory flag, not `cd`** (`jj -R`, `git -C`, `cargo --manifest-path`).

## Waiting

Foreground `sleep` is blocked by the harness. To wait for a condition, use
`Bash(run_in_background)` with an `until` loop, or `Monitor` — whose deadline
parameter is `timeout_ms`, not `timeout`.
