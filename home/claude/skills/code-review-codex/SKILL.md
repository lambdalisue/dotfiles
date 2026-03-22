---
name: code-review-codex
allowed-tools: Bash(git diff:*), Bash(git log:*), Bash(git status:*), Bash(git branch:*), Bash(git merge-base:*), Bash(git rev-parse:*), Bash(git check-attr:*), Bash(gh pr:*), Bash(cat:*), Bash(codex review:*), Read, Glob, Grep
argument-hint: "[base] [context]"
description: Code review using OpenAI Codex CLI with project context (rules, diff, conventions)
---

## Arguments

- `base` (optional): Base branch/ref. Auto-detected if omitted.
- `context` (optional): Additional context (e.g., "Security fix for auth").
- **No args**: auto-detect. **One arg**: git ref → `base`, else → `context`. **Two+**: first=`base`, rest=`context`.

## Language

- Codex prompt: **English** / User-facing report: **Japanese**

## Principles

- **Read-only**. **No nits** (style/naming/formatting → `/style-review`).
- **Focus**: design mistakes, architectural misfit, best practices violations, security holes, codebase inconsistency, rule violations, logic bugs.
- Gathers diff + project rules, then passes everything as a single prompt to `codex review`.

## Workflow

### Step 1: Determine review scope and collect diff

**If `base` given** → `git diff $(git merge-base {base} HEAD)...HEAD` (header: `**ベース**: \`{base}\``)

**If no `base`** → auto-detect:
1. `git status --short` — uncommitted changes?
2. **Uncommitted** → `git diff` + `git diff --cached` (header: `**モード**: 未コミット変更`)
3. **All committed** → detect base (`gh pr view --json baseRefName -q .baseRefName` → `git config branch.*.merge` → `main`/`master`), then `git diff $(git merge-base {base} HEAD)...HEAD` + `git log --oneline $(git merge-base {base} HEAD)...HEAD` (header: `**ベース**: \`{base}\``)

Store the diff as `{diff}`, file list as `{files}`, commit log (if any) as `{log}`.
If diff is empty → **STOP** with "レビュー対象の変更がありません".

### Step 2: Gather project rules

Read **project rules**: `CLAUDE.md`, `.claude/rules/**/*.md`, `rules/**/*.md` → combine as `{project_rules}`.

### Step 3: Run codex review

Pass the diff, project rules, and review instructions as a single prompt via stdin:

```bash
cat <<'REVIEW_PROMPT' | codex review -
You are a senior code reviewer. Review the diff below with focus on:
- Design mistakes and architectural misfit
- Security vulnerabilities with concrete attack paths
- Logic bugs (wrong conditions, race conditions, null handling)
- Best practices violations with concrete negative consequences
- Codebase inconsistency and convention violations
- Rule violations against the project rules below

DO NOT report: style/naming/formatting nits, "consider adding" suggestions, missing docs, theoretical concerns without concrete impact, generic "error handling could be better".

For each issue found, provide:
- File path and line number
- Severity: ★★★ (must fix) / ★★☆ (should fix) / ★☆☆ (consider)
- What is wrong and WHY
- Concrete fix suggestion

If no issues found, respond with exactly: "No issues found."

## Project Rules — check for violations
{project_rules}

## Additional Context
{context}

## Changed Files
{files}

## Commit Log
{log}

## Diff
{diff}
REVIEW_PROMPT
```

### Step 4: Report (Japanese)

Display codex review output to the user with a Japanese header:

```
## コードレビュー結果 (Codex)

{header} | **変更ファイル数**: N

{codex review output}
```

If codex review found no issues, report that clearly.

## Begin

Execute from Step 1.
