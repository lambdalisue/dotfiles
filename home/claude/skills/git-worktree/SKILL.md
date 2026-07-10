---
name: git-worktree
disable-model-invocation: true
description: Create a git worktree with an appropriate branch name (location configured via git config wt.basedir, defaults to ../{gitroot}-wt)
---

## Behavior

Proposes a worktree path and conventionally named branch from the current
changes, gets approval, and creates it. **Self-contained**: this skill reads git
and creates the worktree directly from the top-level session. Do NOT spawn a
subagent.

## Convention

- Branch name: `<type>/<short-description>` — type is one of `feat`, `fix`, `refactor`, `docs`, `test`, `chore`.
- Location: `<basedir>/<branch-name>`, where `basedir` comes from `git config --get wt.basedir` (fall back to `../<gitroot-basename>-wt` — a sibling of the repo root — when unset).
- Uncommitted changes do NOT carry into the new worktree.

## Language

- User-facing explanations, summaries, AskUserQuestion: **Japanese**
- Git artifacts (branch names): **preserve original language** (repo's existing language)

## Workflow

1. **Analyze** (read-only) - `git rev-parse --show-toplevel`, `git config --get wt.basedir`, `git branch --show-current`, `git worktree list`, `git status --short`, `git diff --stat origin/main`. Determine the basedir — the `wt.basedir` config value, or else `$(dirname <repo-root>)/$(basename <repo-root>)-wt` (a `../<gitroot-basename>-wt` sibling) — and a branch name, then propose:
   ```
   Branch: <type>/<short-description>
   Path: <basedir>/<type>/<short-description>

   Reason: <brief explanation>
   ```

2. **Approve** - Present the proposal with AskUserQuestion, options: "Approve", "Edit" (let the user modify), "Cancel".

3. **Create** - If approved, run directly via Bash and confirm. Resolve `basedir` to an absolute path first (a relative `wt.basedir` is relative to the repo root):
   ```bash
   mkdir -p <resolved-basedir>
   git worktree add <resolved-basedir>/<branch-name> -b <branch-name>
   ```
   (Never use `git stash`.)
