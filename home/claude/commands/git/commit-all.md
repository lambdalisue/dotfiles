---
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git add:*), Bash(git reset:*), Bash(git commit:*), Bash(git backup:*), Bash(git branch:*), Bash(git checkout:*), Bash(git cherry-pick:*), Bash(deno :*), Bash(npm :*), Bash(npx :*), Bash(cargo :*), Bash(just :*), Bash(make :*), Glob, Read
description: Analyze working tree changes, plan logically minimal commits per hunk, and execute them
model: opus
---

## Context

!`git status --short`
!`git diff --stat`
!`git diff --cached --stat`
!`git log --oneline -5`

## Principles

**Conventional Commits**: `<type>[scope]: <description>` + body + footer

**Breaking Changes**: `feat!:` or `fix!:` only (other types cannot be breaking by definition)

**t-wada's Principle**: Code=HOW, Tests=WHAT, **Commit=WHY**, Comments=WHY NOT

**Atomic commits**: Each commit should be the smallest logically coherent unit. Split by intent, not by file — a single file may contribute hunks to multiple commits.

**Precursor extraction**: If a change includes prerequisites that can stand alone without breaking tests or functionality, extract them as separate prior commits. Examples:
- Helper functions/utilities added for a feature → commit the helper first, then the feature
- Type definitions or interfaces → commit types first, then the implementation using them
- Import additions or dependency setup → commit separately if they don't cause unused-import errors
- Refactoring that a bugfix depends on → commit the refactoring first, then the fix

The key test: **would the extracted commit leave the codebase in a valid, green state on its own?** If yes, extract it.

**Hunk-level granularity**: Use `git diff` to inspect individual hunks. Group hunks by logical purpose (e.g., "fix bug X", "refactor function Y", "add feature Z"), not by file path.

**Language**:
- User-facing output (plan table, explanations, summaries) → **Japanese**
- Commit messages → Detect from recent `git log`. Default to **English** if unclear

## Workflow

1. **Check** - If nothing to commit (no unstaged and no staged changes), inform user and **STOP**

2. **Backup** - Create a backup before any destructive operations:
   ```bash
   git backup "before commit-all"
   ```
   This creates a backup branch `backup/<current-branch>/<timestamp>` with all current changes, then restores the working tree to its original state via cherry-pick.

3. **Detect Quality Check** - Identify the repo's check command by looking for config files. Prefer `verify` task/script if defined, then fall back to `check`:
   - `justfile` → `just verify` (or `just check`)
   - `deno.json` / `deno.jsonc` → `deno task verify` (or `deno task check`, or `deno fmt --check && deno lint && deno check **/*.ts`)
   - `package.json` (with scripts) → `npm run verify` (or `npm run check`, `npm run lint`)
   - `Cargo.toml` → `cargo fmt --check && cargo clippy && cargo check`
   - `Makefile` → `make verify` (or `make check`)
   - Priority: `verify` > `check` > individual lint/format commands
   - If no quality check is found, skip verification steps

4. **Analyze** - Review ALL changes (both staged and unstaged) with `git diff` and `git diff --cached`:
   - Read full diffs including hunk headers
   - Identify logical groupings across files and hunks
   - Determine commit order (dependencies first)

5. **Plan** - Present the commit plan in **Japanese** as a numbered table with per-commit staging commands and a brief Japanese description of intent. Include the exact `git commit` command with the commit message in the detected repo language. Also state which quality check command will be run before each commit.

6. **STOP** - Wait for user approval of the entire plan (use AskUserQuestion)

7. **Execute** - For each planned commit, sequentially:
   a. Reset staging area: `git reset HEAD -- .` (if needed)
   b. Stage the specified hunks using `git add -p` or `git add` for whole files
   c. Verify staged content: `git diff --cached --stat`
   d. **Quality check** - Run the detected check command. If it fails:
      - Analyze the error and fix the issue (e.g., format, lint, type errors)
      - Re-stage the fixed files
      - Re-run the check until it passes
   e. Execute `git commit` with the planned message
   f. Confirm success before proceeding to next commit

8. **Summary** - Show `git log --oneline` of newly created commits

## Guidelines for Hunk Selection

When using `git add -p`, respond to each hunk prompt:
- **y** - Stage this hunk (belongs to current commit)
- **n** - Skip this hunk (belongs to a different commit or should not be staged)
- **s** - Split the hunk if it contains changes for multiple commits

When a file is entirely new (untracked), use `git add <file>` instead of `git add -p`.

## Begin

Analyze all working tree changes, plan logically minimal commits at hunk granularity, and present the full plan for user approval.

**IMPORTANT**:
1. You MUST present the complete plan and ask for user approval using AskUserQuestion before executing ANY commit
2. Re-confirm if the plan diverges during execution
3. Use `git reset HEAD -- .` before each commit's staging to ensure a clean staging area
4. All user-facing explanations and plan presentation MUST be in Japanese
5. Commit messages MUST match the language used in the target repository's existing commits (default to English if unclear)
6. Run the repo's quality check before EVERY commit. Do NOT skip this step even if changes seem trivial. If a check fails, fix the issue before committing
