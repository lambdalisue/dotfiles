---
name: code-review
allowed-tools: Bash(git diff:*), Bash(git log:*), Bash(git status:*), Bash(git branch:*), Bash(git merge-base:*), Bash(git rev-parse:*), Bash(gh pr:*), Read, Glob, Grep, Agent
argument-hint: "[base] [context]"
description: Multi-perspective code review from base branch with 3 independent reviewer agents
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

### Step 3: Launch 3 agents in parallel

Spawn via Agent tool (`subagent_type: "general-purpose"`, `model: "sonnet"`), all in one message. Each agent reads the codebase and diff itself — do NOT pass diff content in the prompt.

**Shared instructions** (include in each agent prompt):

```
You are reviewing code in this repository. {review_target}
MANDATORY: Use Read tool to read FULL content of every changed file + 2-3 related files (imports, callers, siblings) before making any findings.
IGNORE: style/naming/formatting, "consider adding" suggestions, missing docs, theoretical concerns without concrete impact, generic "error handling could be better".
Also read CLAUDE.md and .claude/rules/ for project rules — check for violations.
Context: {context}
Per issue: file:line, Severity (★★★/★★☆/★☆☆), what is wrong and WHY, concrete fix.
```

Where `{review_target}` is:
- Committed: `Review changes between {base} and HEAD. Run: git diff $(git merge-base {base} HEAD) to see the diff, git diff --name-only $(git merge-base {base} HEAD) for changed files.`
- Uncommitted: `Review uncommitted changes. Run: git diff and git diff --cached to see the diff.`

#### Agent 1: Design & Architecture

```
{shared instructions}
Role: Senior architect. Find design, architectural, and best-practices problems.
Methodology: Read changed files → read related files → identify codebase patterns → compare against patterns AND language/framework best practices.
Find: Architectural misfit (layer violations, wrong module), design defects (wrong data structure, over-engineering, leaky abstraction), best practices violations (anti-patterns with concrete negative consequence), API inconsistency with existing codebase, coupling problems, missing design considerations.
```

#### Agent 2: Security & Correctness

```
{shared instructions}
Role: Security engineer. Find real vulnerabilities, logic bugs, security best-practices violations. NOT theoretical risks.
Methodology: Read changed files → trace data flow (input → validation → output) → check auth/middleware for bypass → check error handling for leaks.
Find: Exploitable vulnerabilities (with concrete attack path), logic bugs (wrong conditions, race conditions, null handling), data integrity (missing atomicity, missing validation at trust boundaries), secrets exposure, unsafe operations, security best-practices violations (with concrete risk).
```

#### Agent 3: Consistency & Convention

```
{shared instructions}
Role: Codebase consistency specialist. Find violations of ESTABLISHED patterns.
Methodology: Read changed files → read 3-5 EXISTING files in same dirs to establish patterns (error handling, module structure, testing) → compare → check project rules.
Find: Pattern violations (cite file:line of established pattern), convention breaks, missing tests (vs existing coverage), rule violations, interface inconsistency.
IMPORTANT: Every finding MUST reference file:line of established pattern. No reference = not established = don't report.
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

Where `{header}` is:
- Committed: `**ベース**: \`{base}\``
- Uncommitted: `**モード**: 未コミット変更`

## Begin

Execute from Step 1.
