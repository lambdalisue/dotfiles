---
name: code-review
allowed-tools: Bash(git diff:*), Bash(git log:*), Bash(git status:*), Bash(git branch:*), Bash(git merge-base:*), Bash(git rev-parse:*), Bash(git check-attr:*), Bash(gh pr:*), Bash(cat:*), Read, Glob, Grep, Agent
argument-hint: "[base] [context]"
description: Multi-perspective code review from base branch with 3 independent reviewer agents
model: opus
---

## Arguments

- `base` (optional): Base branch/ref. Auto-detected if omitted.
- `context` (optional): Additional context (e.g., "Security fix for auth").
- **No args**: auto-detect. **One arg**: git ref → `base`, else → `context`. **Two+**: first=`base`, rest=`context`.

## Language

- Agent prompts: **English** / User-facing report: **Japanese**

## Principles

- **Read-only**. **No nits** (style/naming/formatting → `/style-review`).
- **Focus**: design mistakes, architectural misfit, best practices violations, security holes, codebase inconsistency, rule violations, logic bugs.
- Severity: **★★★** must fix / **★★☆** should fix / **★☆☆** consider

## Workflow

### Step 1: Determine review scope

**If `base` given** → `git diff <merge-base>...HEAD`.

**If no `base`** → auto-detect:
1. `git status --short` — uncommitted changes?
2. **Uncommitted** → `git diff` + `git diff --cached` (header: `**モード**: 未コミット変更`)
3. **All committed** → detect base (`gh pr view` → `git config branch.*.merge` → `main`/`master`), then `git diff <merge-base>...HEAD` + `git log --oneline <merge-base>...HEAD` (header: `**ベース**: \`{base}\``)

### Step 2: Gather material

Exclude `linguist-generated` files. Gather diff + file list per Step 1. If empty → **STOP**.

Also read **project rules**: `CLAUDE.md`, `.claude/rules/**/*.md`, `rules/**/*.md` → combine as `{project_rules}`.

### Step 3: Launch 3 agents in parallel

Spawn via Agent tool, all in one message. Each agent gets: diff, file list, commit log (if any), project rules, context.

**Shared preamble** (prepend to each):

```
MANDATORY before ANY findings: Read tool to read FULL content of every changed file + 2-3 related files (imports, callers, siblings).
IGNORE: style/naming/formatting, "consider adding" suggestions, missing docs, theoretical concerns without concrete impact, generic "error handling could be better".
```

**Shared data suffix** (append to each):

```
## Project rules — check for violations
{project_rules}

Context: {context}
Changed files: {file list}
Commit log: {commit log}
Diff: {diff}
```

#### Agent 1: Design & Architecture (`model: "sonnet"`)

```
{preamble}
Senior architect. Find design, architectural, and best-practices problems.
Methodology: Read changed files → read related files → identify codebase patterns → compare against patterns AND language/framework best practices.
Find: Architectural misfit (layer violations, wrong module), design defects (wrong data structure, over-engineering, leaky abstraction), best practices violations (anti-patterns with concrete negative consequence), API inconsistency with existing codebase, coupling problems, missing design considerations.
{data suffix}
Per issue: file:line, Severity, what is wrong and WHY, concrete fix.
```

#### Agent 2: Security & Correctness (`model: "sonnet"`)

```
{preamble}
Security engineer. Find real vulnerabilities, logic bugs, security best-practices violations. NOT theoretical risks.
Methodology: Read changed files → trace data flow (input → validation → output) → check auth/middleware for bypass → check error handling for leaks.
Find: Exploitable vulnerabilities (with concrete attack path), logic bugs (wrong conditions, race conditions, null handling), data integrity (missing atomicity, missing validation at trust boundaries), secrets exposure, unsafe operations, security best-practices violations (with concrete risk).
{data suffix}
Per issue: file:line, Severity, specific vulnerability/bug with attack/failure scenario, concrete fix.
```

#### Agent 3: Consistency & Convention (`model: "sonnet"`)

```
{preamble}
Codebase consistency specialist. Find violations of ESTABLISHED patterns.
Methodology: Read changed files → read 3-5 EXISTING files in same dirs to establish patterns (error handling, module structure, testing) → compare → check project rules.
Find: Pattern violations (cite file:line of established pattern), convention breaks, missing tests (vs existing coverage), rule violations, interface inconsistency.
IMPORTANT: Every finding MUST reference file:line of established pattern. No reference = not established = don't report.
{data suffix}
Per issue: file:line of violation, file:line of pattern, Severity, what is violated, how to fix.
```

### Step 4: Synthesize

1. Filter remaining nits. 2. Deduplicate. 3. Resolve contradictions. 4. Sort by severity.

### Step 5: Report (Japanese, display-only)

```
## コードレビュー結果

{header} | **変更ファイル数**: N

### 判断サマリー

判断が必要だったポイントのみ: エージェント間不一致、重要度調整、棄却とその理由。全員一致の指摘は含めない。

---

### 1. タイトル (`path:line`) (★★★)

> 問題の端的な説明。

対応方法。
```

## Begin

Execute from Step 1.
