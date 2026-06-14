# Git Safety Rules

## Commit Restriction (top-level)

**Top-level Claude MUST NOT run `git commit` directly via Bash on its own
initiative.** Commits only run via one of these slash commands:

- `/git-commit` — working tree: fixup into existing commits where appropriate, otherwise new atomic commits
- `/git-commit-new` — working tree: new atomic commits only (no fixup)
- `/git-commit-fixup` — working tree: map changes to existing commits as fixup
- `/git-commit-staged` — staged changes: fixup into existing commits where appropriate, otherwise a new commit
- `/git-commit-staged-new` — staged changes: a new commit only (no fixup)
- `/git-commit-staged-fixup` — staged changes: map to existing commits as fixup
- `/git-commit-amend` — amend the previous (HEAD) commit, folding in working tree changes (rewrites HEAD)

Each command above commits immediately without an in-command approval step.

Before invoking any of these commands:

- MUST use AskUserQuestion to confirm intent — EXCEPT when the user typed the
  command themselves in the CURRENT message; that explicit invocation IS the
  confirmation, so do NOT ask again.
- Permission is valid for ONE invocation only
- ONLY proceed when the user explicitly requested the commit in the CURRENT
  message. Top-level Claude must NEVER reach for one of these commands on its
  own initiative to dodge the approval prompt.

## Plan-then-execute architecture

Each commit slash command works in two phases:

1. **Plan** — a planner subagent (`git-commit`, `git-commit-staged`,
   `git-commit-fixup`, `git-commit-staged-fixup`) reads the working tree /
   staging area and returns a structured plan. The subagent runs **read-only
   git commands only** and never executes `git add` / `git commit` / `git reset`.
2. **Execute** — once intent is confirmed (the user typed the command, or
   AskUserQuestion confirmed it), the slash command body (top-level Claude)
   runs `git add` and `git commit` directly via Bash, scoped to **exactly the
   plan**.

**Why this split**: confirmed intent grants execution authority for one
specific plan. The planner has no write tools; the executor (top-level) only
acts on the plan produced in this turn. There is no "subagent carve-out" —
the only place commits run is the slash command body. The read-only planner,
explicit staging by name, and the forbidden-command list below always apply.

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
