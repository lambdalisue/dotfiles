---
name: code-review-codex
allowed-tools: Bash(git diff:*), Bash(git log:*), Bash(git status:*), Bash(git branch:*), Bash(git merge-base:*), Bash(git rev-parse:*), Bash(gh pr:*), Bash(codex exec:*), Bash(wc:*), Read, Glob, Grep
argument-hint: "[base]"
description: Code review using OpenAI Codex CLI with project context (rules, diff, conventions)
---

## Arguments

- `base` (optional): Base branch/ref. Auto-detected if omitted.
- **No args**: auto-detect. **One arg**: treated as `base`.

## Language

- User-facing report: **Japanese**

## Principles

- **Read-only**. **No nits** (style/naming/formatting → `/style-review`).
- **Focus**: design mistakes, architectural misfit, best practices violations, security holes, codebase inconsistency, rule violations, logic bugs.
- Uses `codex exec` with a review prompt — codex reads the codebase and diff itself.

## codex exec CLI usage

**CRITICAL**: Follow these exact command patterns. Do NOT deviate or experiment.

```bash
codex exec --sandbox read-only "PROMPT" 2>&1
```

- `codex exec` runs non-interactively and prints results to stdout
- `--sandbox read-only` ensures no writes to the repository
- The PROMPT tells codex what to review — codex has full access to read the repo and run git commands itself
- Do NOT pipe stdin or construct complex shell escapes — just pass a clear prompt string

## Workflow

### Step 1: Determine review mode and base branch

**If `base` given** → use that as `{base}`.

**If no `base`** → auto-detect:
1. `git status --short` — any uncommitted changes?
2. **Uncommitted** → set `{mode}` to `uncommitted`
3. **All committed** → detect base: `gh pr view --json baseRefName -q .baseRefName 2>/dev/null` → fallback to default branch (`main`/`master`). Set `{base}` to detected branch and `{mode}` to `committed`.

If `{mode}` is `committed`, verify diff is non-empty:
```bash
git diff --stat "$(git merge-base {base} HEAD)"
```
If empty → **STOP** with "レビュー対象の変更がありません".

### Step 2: Collect metadata for report header

Run in parallel:
- `git diff --name-only "$(git merge-base {base} HEAD)"` (or `git diff --name-only` + `git diff --cached --name-only` for uncommitted) → count changed files
- `git log --oneline "$(git merge-base {base} HEAD)..HEAD"` (committed mode only) → `{log}`

### Step 3: Run codex exec

Build the prompt and run `codex exec`:

**Committed changes**:
```bash
codex exec --sandbox read-only "Review the code changes between {base} and HEAD. Focus on: design mistakes, architectural misfit, best practices violations, security holes, logic bugs. Ignore style/naming/formatting nits. Output findings in Japanese." 2>&1
```

**Uncommitted changes**:
```bash
codex exec --sandbox read-only "Review the uncommitted changes (staged and unstaged). Focus on: design mistakes, architectural misfit, best practices violations, security holes, logic bugs. Ignore style/naming/formatting nits. Output findings in Japanese." 2>&1
```

**Do NOT**: retry with different invocations on failure. If the command fails, report the error as-is.

### Step 4: Report (Japanese)

Display results:

```
## コードレビュー結果 (Codex)

{header} | **変更ファイル数**: N

{codex exec output}
```

Where `{header}` is:
- Committed: `**ベース**: \`{base}\``
- Uncommitted: `**モード**: 未コミット変更`

If codex found no issues, report that clearly.

## Begin

Execute from Step 1.
