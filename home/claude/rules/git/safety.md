# Git Safety Rules

These rules apply to the **top-level (main) Claude session**. Subagents invoked
from the approved commit slash commands operate under their own agent
definition (see "Subagent carve-out" below) — do NOT re-apply these top-level
rules inside them.

## Commit Restriction (top-level only)

**Top-level Claude MUST NOT run `git commit` directly via Bash.** All commits
go through one of these slash commands:

- `/git-commit` — analyze working tree and create atomic commits
- `/git-commit-staged` — commit already-staged changes
- `/git-commit-fixup` — map working tree changes to existing commits as fixup
- `/git-commit-staged-fixup` — map staged changes to existing commits as fixup

Before invoking any of the above:

- MUST use AskUserQuestion to confirm intent
- Permission is valid for ONE invocation only
- ONLY proceed when the user explicitly says "commit" in the CURRENT message

## Subagent carve-out

When a subagent (e.g. `git-commit`, `git-commit-staged`, `git-commit-fixup`,
`git-commit-staged-fixup`) is invoked **by one of the approved slash commands
above**, the user has already granted explicit permission at the slash-command
layer. Inside the subagent:

- DO follow the subagent's own definition (analyze / plan / execute)
- DO run `git commit` (and `git commit --fixup=<sha>`) as planned
- DO NOT ask the user for additional approval
- DO NOT block on AskUserQuestion — approval is the caller's responsibility

The "ABSOLUTELY NEVER COMMIT WITHOUT EXPLICIT USER PERMISSION" intent is
satisfied by the slash command at the top level. Re-asking inside the
subagent breaks the workflow.

## Forbidden Staging Commands (always)

NEVER use these in ANY commit workflow, top-level or subagent:

- `git add -A` / `git add .` — may include .env, credentials, large binaries
- `git commit -a` / `git commit --all` — bypasses explicit staging

ALWAYS stage files explicitly by name. If nothing is staged when staged-only
flow expects staged changes, report error and stop.

## Backup Before Destructive Operations

ALWAYS backup before: `git restore`, `git reset`, `git checkout` (with
uncommitted changes), file deletion of uncommitted work.

## Git Stash Forbidden

NEVER use `git stash` (shared across worktrees → contamination). Use a backup
branch instead.

## Stay in Worktree Directory

If starting in `.worktrees/{branch}/` (or any worktree path), ALL operations
stay there. Use absolute paths to inspect root state without leaving.
