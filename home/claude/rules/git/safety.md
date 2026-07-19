# Git Safety Rules

## Commit Restriction (top-level)

Commits run via one of these skills. Top-level Claude MAY invoke them itself
(Skill tool or the matching slash command) — never hand-roll `git commit` via
Bash outside them:

- `/git-commit` — fixup into existing commits where appropriate, otherwise new atomic commits
- `/git-commit-new` — new atomic commits only (no fixup)
- `/git-commit-fixup` — map changes to existing commits as fixup
- `/git-commit-reword` — review commit messages since base and add reword fixup commits where needed

Each command above commits immediately without an in-command approval step.

Rules for invoking any of them:

- ONLY invoke when the user explicitly requested the commit in the CURRENT
  message — either by typing the slash command OR by a clear natural-language
  request (e.g. "commit this", "これを fixup で"). That explicit request IS the
  approval, so do NOT ask again with AskUserQuestion.
- Absent an explicit request in the current message, do NOT commit. Top-level
  Claude must NEVER self-initiate a commit the user did not ask for — instead
  report that the changes are ready and let the user request it.
- Permission is valid for ONE invocation only.

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
