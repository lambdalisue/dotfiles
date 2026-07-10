# Git Safety Rules

## Commit Restriction (top-level)

**Top-level Claude MUST NOT run `git commit` directly via Bash on its own
initiative.** Commits only run via one of these slash commands:

- `/git-commit` — fixup into existing commits where appropriate, otherwise new atomic commits
- `/git-commit-new` — new atomic commits only (no fixup)
- `/git-commit-fixup` — map changes to existing commits as fixup
- `/git-commit-reword` — review commit messages since base and add reword fixup commits where needed

Each command above commits immediately without an in-command approval step.

Before invoking any of these commands:

- MUST use AskUserQuestion to confirm intent — EXCEPT when the user typed the
  command themselves in the CURRENT message; that explicit invocation IS the
  confirmation, so do NOT ask again.
- Permission is valid for ONE invocation only
- ONLY proceed when the user explicitly requested the commit in the CURRENT
  message. Top-level Claude must NEVER reach for one of these commands on its
  own initiative to dodge the approval prompt.

**Policy-level, not permission-enforced.** `settings.json` intentionally
pre-approves `git commit` / `git add` / `git reset` / `git restore` so the
commit skills run without a permission prompt each step. That means this
restriction is NOT enforced by the permission layer — it is Claude's discipline.
A stray `git commit` would not be blocked, so the rules above must be honored
deliberately.

## Plan-then-execute (in one context)

Each commit slash command is **self-contained**: it plans with read-only git,
then executes `git add` / `git commit` scoped to **exactly the plan** — same
context, no planner subagent. Confirmed intent grants execution authority for
one specific plan; explicit staging by name and the forbidden-command list
below always apply. (Details: `skills/git-commit/COMMON.md`.)

## Forbidden Staging Commands (always)

NEVER use these in ANY commit workflow:

- `git add -A` / `git add .` — may include .env, credentials, large binaries
- `git commit -a` / `git commit --all` — bypasses explicit staging

ALWAYS stage files explicitly by name.

## Backup Before Destructive Operations

ALWAYS backup before: `git restore`, `git reset`, `git checkout` (with
uncommitted changes), file deletion of uncommitted work.

Prefer `git backup "<reason>"` (alias) when available; otherwise
`git branch backup/$(date +%s) HEAD`.

## Git Stash Forbidden

NEVER use `git stash` (shared across worktrees → contamination). Use a backup
branch instead.

## Stay in Worktree Directory

If starting in `.wt/{branch}/` (or any worktree path), ALL operations
stay there. Use absolute paths to inspect root state without leaving.
