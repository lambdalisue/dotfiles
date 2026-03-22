---
name: style-review
allowed-tools: Bash(git diff:*), Bash(git log:*), Bash(git status:*), Bash(git branch:*), Bash(git merge-base:*), Bash(git rev-parse:*), Bash(git check-attr:*), Bash(gh pr:*), Read, Glob, Grep, Agent
argument-hint: "[base]"
description: Style and naming review — formatting, naming conventions, readability, code hygiene
---

## Arguments

- `base` (optional): Base branch/ref to diff against. Auto-detected if omitted.

### Argument Parsing Rules

- **No args**: Detect base branch automatically.
- **One arg**: Treat as `base`.

## Language

- Agent prompt: **English**
- User-facing report: **Japanese**

## Principles

- **Read-only**. Do NOT modify any files.
- This review covers what `/code-review` intentionally skips: style, naming, formatting, readability.
- Focus on **actionable improvements**, not personal taste. Only flag issues where the codebase has an established convention being broken or where readability is materially impacted.
- Severity:
  - **★★☆** Should fix: Naming that actively confuses, readability that hinders understanding
  - **★☆☆** Consider: Minor style inconsistencies, small readability improvements

## Workflow

### Step 1: Determine review scope

1. **If `base` is explicitly provided** → use `git diff <merge-base>...HEAD` (committed changes from base).

2. **If no `base` provided** → auto-detect scope:
   a. Run `git status --short` to check for uncommitted changes (staged + unstaged)
   b. **If uncommitted changes exist** → review working tree changes only:
      - Diff: `git diff` + `git diff --cached`, combined
      - Report header: `**モード**: 未コミット変更`
   c. **If no uncommitted changes** → review all commits from base branch:
      - Detect base: `gh pr view --json baseRefName --jq '.baseRefName'` → `git config branch.$(git rev-parse --abbrev-ref HEAD).merge` → `main`/`master`
      - Compute: `git merge-base <base> HEAD`
      - Diff: `git diff <merge-base>...HEAD`
      - Report header: `**ベース**: \`{base}\``

### Step 2: Gather material

Exclude `linguist-generated` files via `git check-attr`.

Gather the diff and file list based on the scope determined in Step 1:

- **Working tree mode**: `git diff --name-status` + `git diff --cached --name-status` and `git diff` + `git diff --cached`
- **Base branch mode**: `git diff --name-status <merge-base>...HEAD` and `git diff <merge-base>...HEAD`

If diff is empty → **STOP**.

### Step 3: Launch reviewer agent

Use the Agent tool to spawn 1 agent.

```
subagent_type: "general-purpose"
```

Prompt:

```
You are a code style and readability reviewer. Find style and naming issues in these changes.

## Methodology

1. Read the FULL content of every changed file using the Read tool
2. Read 2-3 existing files in the same directories to establish the codebase's style conventions
3. Compare the new code's style against the established conventions

## What to find

- **Naming inconsistencies**: Variable/function/type names that don't match the codebase's naming convention (cite existing examples)
- **Readability issues**: Deeply nested logic that could be flattened, overly long functions, unclear variable names that require mental mapping
- **Formatting breaks**: Inconsistent indentation, spacing, or organization compared to surrounding code
- **Code hygiene**: Leftover debug code, commented-out code, TODO without context, unused imports/variables
- **Misleading names**: Names that suggest wrong behavior (e.g., `isValid` that doesn't validate, `getUser` that creates)

## What to IGNORE

- Personal style preferences that the codebase doesn't enforce
- Minor differences that don't affect readability
- Issues in code that wasn't changed in this diff

Changed files:
{file list}

Diff:
{diff}

For each issue: file:line, Severity (Warning/Notice), the style issue, how to fix it. Reference existing code (file:line) when citing established conventions.
```

### Step 4: Report in Japanese

Display-only. Do NOT offer actions.

```
## スタイルレビュー結果

**ベース**: `{base}` or **モード**: 未コミット変更 | **変更ファイル数**: N

---

### 1. タイトル (`path/to/file:line`) (★★☆)

> 概要。

対応方法。

---
```

- Flat numbered list sorted by severity
- If no issues → report clean

## Begin

Execute from Step 1.
