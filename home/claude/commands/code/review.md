---
allowed-tools: Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Bash(git merge-base:*), Bash(git rev-parse:*), Bash(gh pr:*), Read, Glob, Grep, Task
argument-hint: "[base] [context]"
description: Multi-perspective code review from base branch with 3 independent reviewer agents
model: opus
---

## Arguments

- `base` (optional): Base branch/ref to diff against. Defaults to the base branch of the current branch.
- `context` (optional): Additional context about the changes (e.g., "Performance optimization", "Security fix for auth").

### Argument Parsing Rules

- **No args**: Detect base branch automatically, no additional context.
- **One arg**: If it matches a valid git ref (`git rev-parse --verify <arg>` succeeds), treat as `base`. Otherwise treat as `context`.
- **Two+ args**: First token is `base`, remaining tokens joined as `context`.

## Language

- Task prompts to agents: **English**
- User-facing report and summaries: **Japanese**

## Principles

- This command performs **read-only review**. Do NOT modify any files.
- Focus on **improvements and concerns**, not praise. Skip "good points".
- Each agent reviews independently with a distinct lens.
- When agents contradict each other, the orchestrator resolves the conflict and explains the reasoning.
- Severity levels:
  - **Critical** `[★★★]`: Must fix before merge — bugs, vulnerabilities, data loss risks
  - **Warning** `[★★☆]`: Should fix — design issues, performance concerns, maintainability problems
  - **Notice** `[★☆☆]`: Consider fixing — style, minor improvements, optional enhancements

## Workflow

### Step 1: Parse arguments and determine base

1. Parse the provided arguments according to the rules above.
2. If no `base` specified, detect the base branch:
   ```bash
   git rev-parse --abbrev-ref HEAD
   ```
   Then determine the upstream/base branch. Try in order:
   - `gh pr view --json baseRefName --jq '.baseRefName'` (if PR exists)
   - `git config branch.<current>.merge` (tracking branch)
   - Fall back to `main` or `master` (whichever exists on remote)
3. Compute the merge base:
   ```bash
   git merge-base <base> HEAD
   ```

### Step 2: Gather review material

Run in parallel:

```bash
# Changed files list
git diff --name-status <merge-base>...HEAD

# Full diff
git diff <merge-base>...HEAD

# Commit log
git log --oneline --no-decorate <merge-base>...HEAD
```

If the diff is empty, inform the user and **STOP**.

### Step 3: Launch 3 reviewer agents in parallel

Use the Task tool to spawn exactly 3 agents **in parallel** (all in a single message). Each agent receives the same diff, changed file list, and commit log, but reviews from a different perspective.

**IMPORTANT**: All 3 Task calls MUST be in the same message to run in parallel.

#### Agent 1: Security & Reliability Reviewer

```
subagent_type: "general-purpose"
model: "sonnet"
```

Prompt template:

```
You are a Security & Reliability code reviewer. Review the following changes for:

- Security vulnerabilities (injection, XSS, CSRF, auth bypass, secrets exposure)
- Error handling gaps (unhandled exceptions, missing validation, race conditions)
- Edge cases and boundary conditions
- Data integrity risks
- Unsafe operations (file I/O, network, process execution)

Context: {context if provided}
Base: {base}

Changed files:
{file list}

Commit log:
{commit log}

Diff:
{diff}

For each issue found, report:
1. File path and line number(s)
2. Severity: Critical / Warning / Notice
3. Description of the issue
4. Suggested fix approach

If you need to read full file contents for context, use the Read tool.
Report ONLY issues and concerns. Do NOT list positive aspects.
Return your findings as a structured list.
```

#### Agent 2: Performance & Architecture Reviewer

```
subagent_type: "general-purpose"
model: "sonnet"
```

Prompt template:

```
You are a Performance & Architecture code reviewer. Review the following changes for:

- Performance regressions (unnecessary allocations, O(n^2) algorithms, blocking operations)
- Architectural concerns (tight coupling, layer violations, incorrect abstractions)
- Scalability issues
- Resource leaks (memory, file handles, connections)
- API design problems (breaking changes, inconsistent interfaces)

Context: {context if provided}
Base: {base}

Changed files:
{file list}

Commit log:
{commit log}

Diff:
{diff}

For each issue found, report:
1. File path and line number(s)
2. Severity: Critical / Warning / Notice
3. Description of the issue
4. Suggested fix approach

If you need to read full file contents for context, use the Read tool.
Report ONLY issues and concerns. Do NOT list positive aspects.
Return your findings as a structured list.
```

#### Agent 3: Maintainability & Standards Reviewer

```
subagent_type: "general-purpose"
model: "sonnet"
```

Prompt template:

```
You are a Maintainability & Standards code reviewer. Review the following changes for:

- Code complexity (deeply nested logic, overly long functions, unclear control flow)
- Naming and readability issues
- Missing or inadequate tests for new/changed behavior
- Inconsistency with existing codebase patterns and conventions
- Documentation gaps for public APIs or complex logic
- Dead code or unnecessary changes
- DRY violations

Context: {context if provided}
Base: {base}

Changed files:
{file list}

Commit log:
{commit log}

Diff:
{diff}

For each issue found, report:
1. File path and line number(s)
2. Severity: Critical / Warning / Notice
3. Description of the issue
4. Suggested fix approach

If you need to read full file contents for context, use the Read tool.
Report ONLY issues and concerns. Do NOT list positive aspects.
Return your findings as a structured list.
```

### Step 4: Synthesize and resolve conflicts

After all 3 agents complete:

1. **Deduplicate**: Merge findings that refer to the same issue from different perspectives.
2. **Resolve contradictions**: If agents disagree (e.g., one says "add abstraction" while another says "keep it simple"), evaluate the context and make a judgment call. Note the disagreement and your reasoning.
3. **Prioritize**: Sort by severity (Critical > Warning > Notice), then by file path.

### Step 5: Report to user in Japanese

This command is **display-only**. Do NOT offer to take any actions after displaying the report.

Severity levels (exactly 3 characters using filled and empty stars):

- Critical (must fix): `(★★★)`
- Warning (should fix): `(★★☆)`
- Notice (optional): `(★☆☆)`
- Disagree (not an issue): `(☆☆☆)`

Format the final report. Each finding uses the following structure:

```
## コードレビュー結果

**ベース**: `{base}` | **変更ファイル数**: N | **レビュアー**: 3/3 完了

---

### 1. 指摘のタイトル (`path/to/file:line`) (★★★)

> 指摘事項の要約をここに記述する。何が問題なのかを簡潔にまとめる。

指摘に対してどう考えるか。対応するべきか、対応不要か、その理由を述べる。

対応する場合は対応方法の概要を簡潔に記述する。

---

### 2. 指摘のタイトル (`path/to/file:line`) (★★☆)

> 指摘事項の要約をここに記述する。何が問題なのかを簡潔にまとめる。

...

---

### 3. 指摘のタイトル (`path/to/file:line`) (★☆☆)

> 指摘事項の要約をここに記述する。何が問題なのかを簡潔にまとめる。

...
```

Notes:
- Sort by severity (★★★ > ★★☆ > ★☆☆ > ☆☆☆), then by file path
- The opinion section should include your own judgment: agree/disagree with the finding, whether it's worth fixing, and why
- If agents disagreed on a finding, mention the disagreement and your reasoning in the opinion section
- Do NOT group findings by severity heading — use a flat numbered list sorted by severity

If no issues are found, report:

```
## コードレビュー結果

レビュー対象の変更に問題は見つかりませんでした。
```

## Begin

Execute the workflow above. Start from Step 1.
