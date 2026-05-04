# Git Safety Rules

## Commit Restriction (top-level)

**Top-level Claude MUST NOT run `git commit` directly via Bash on its own
initiative.** Commits only run via one of these slash commands:

- `/git-commit` — analyze working tree and create atomic commits
- `/git-commit-staged` — commit already-staged changes
- `/git-commit-fixup` — map working tree changes to existing commits as fixup
- `/git-commit-staged-fixup` — map staged changes to existing commits as fixup

Before invoking any of the above:

- MUST use AskUserQuestion to confirm intent
- Permission is valid for ONE invocation only
- ONLY proceed when the user explicitly says "commit" in the CURRENT message

## Plan-then-execute architecture

Each commit slash command works in two phases:

1. **Plan** — a planner subagent (`git-commit`, `git-commit-staged`,
   `git-commit-fixup`, `git-commit-staged-fixup`) reads the working tree /
   staging area and returns a structured plan. The subagent runs **read-only
   git commands only** and never executes `git add` / `git commit` / `git reset`.
2. **Execute** — after the user approves the plan via AskUserQuestion, the
   slash command body (top-level Claude) runs `git add` and `git commit`
   directly via Bash, scoped to **exactly the approved plan**.

**Why this split**: a single approval grants execution authority for one
specific plan. The planner has no write tools; the executor (top-level) only
acts on plans the user just approved in this turn. There is no "subagent
carve-out" — the only place commits run is the slash command body, after
explicit user approval.

## Forbidden Staging Commands (always)

NEVER use these in ANY commit workflow:

- `git add -A` / `git add .` — may include .env, credentials, large binaries
- `git commit -a` / `git commit --all` — bypasses explicit staging

ALWAYS stage files explicitly by name. If nothing is staged when a
staged-only flow expects staged changes, report error and stop.

## Backup Before Destructive Operations

ALWAYS backup before: `git restore`, `git reset`, `git checkout` (with
uncommitted changes), file deletion of uncommitted work.

Prefer `git backup "<reason>"` (alias) when available; otherwise
`git branch backup/$(date +%s) HEAD`.

## Git Stash Forbidden

NEVER use `git stash` (shared across worktrees → contamination). Use a backup
branch instead.

## Stay in Worktree Directory

If starting in `.worktrees/{branch}/` (or any worktree path), ALL operations
stay there. Use absolute paths to inspect root state without leaving.
