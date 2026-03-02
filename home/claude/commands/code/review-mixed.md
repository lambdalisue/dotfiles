---
allowed-tools: Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Bash(git merge-base:*), Bash(git rev-parse:*), Bash(git check-attr:*), Bash(gh pr:*), Bash(gh copilot:*), Bash(command -v:*), Read, Glob, Grep, Agent
argument-hint: "[base] [context]"
description: Multi-tool code review consolidating findings from Codex, GitHub Copilot, and Claude Code
model: opus
---

## Arguments

- `base` (optional): Base branch/ref to diff against (auto-detected if omitted).
- `context` (optional): Additional context about the changes.
- **No args**: auto-detect base. **One arg**: git ref → `base`, otherwise → `context`. **Two+**: first=`base`, rest=`context`.

## Principles

- **Read-only**. Do NOT modify files.
- Focus on concerns only. Skip praise.
- Missing tool binary → show install command, skip that reviewer.
- **Consensus filtering**: multi-source findings carry more weight; single-source Notice → omit if trivial.
- Severity: **★★★** Critical (must fix) / **★★☆** Warning (should fix) / **★☆☆** Notice (consider) / **☆☆☆** Disagree
- Report in **Japanese**. Agent prompts in **English**.

## Workflow

### Step 1: Determine base

If no `base` given, detect (in order): `gh pr view --json baseRefName` → `git config branch.<current>.merge` → `main`/`master`. Then `git merge-base <base> HEAD`.

### Step 2: Check tool availability

```bash
command -v codex 2>/dev/null
command -v gh 2>/dev/null && gh copilot --version 2>/dev/null
```

Report status table to user. For missing tools show:
- **Codex**: `npm install -g @openai/codex`
- **GitHub Copilot**: `gh extension install github/gh-copilot`

Claude Code is always available (internal sub-agent).

### Step 3: Gather review material

Exclude `linguist-generated` files via `git check-attr`. Run `git diff --name-status <merge-base>...HEAD`. If empty → **STOP**.

### Step 4: Launch reviewers in parallel

Spawn all available reviewers via Agent tool **in a single message**. Build pathspec exclusions from Step 3.

#### Codex (if available)

`subagent_type: "general-purpose"`, `model: "haiku"`

```
Run this command and return its COMPLETE output:
codex review --base {merge_base} "For each issue report: file path, line, severity (Critical/Warning/Notice), description, fix. Issues only. {context}"
If it fails, return the error.
```

#### GitHub Copilot (if available)

`subagent_type: "general-purpose"`, `model: "haiku"`

```
Run this command and return its COMPLETE output:
gh copilot -p "Review code changes from {merge_base} to HEAD. Run 'git diff {merge_base}...HEAD {pathspec}' to see changes. For each issue report: file path, line, severity (Critical/Warning/Notice), description, fix. Issues only. {context}" --allow-tool 'shell(git:*)'
If it fails, return the error.
```

#### Claude Code (always)

`subagent_type: "general-purpose"`, `model: "opus"`

```
Review code changes from {merge_base} to HEAD. {context}
Run: git diff {merge_base}...HEAD {pathspec} and git log --oneline {merge_base}...HEAD
Use Read tool for additional context if needed.
For each issue: file path, line, severity (Critical/Warning/Notice), description, fix. Issues only.
```

### Step 5: Synthesize

1. **Deduplicate & label**: Merge same-issue findings across reviewers. Tag sources. Use highest severity.
2. **Consensus filter**: Multi-source → keep. Single-source Critical/Warning → keep (note single). Single-source Notice → omit if trivial.
3. **Sort**: severity → consensus count → file path.

### Step 6: Report

```
## コードレビュー結果

**ベース**: `{base}` | **変更ファイル数**: N | **レビュアー**: X/3 完了 ({names})

---

### 1. 指摘タイトル (`path/to/file:line`) (★★★)

**検出**: Codex, Claude Code (2/3 一致)

> 要約

判断と理由。対応方法。

---

### 2. 指摘タイトル (`path/to/file:line`) (★☆☆)

**検出**: Claude Code (1/3)

> 要約

...
```

Display-only. Do NOT offer actions. Flat numbered list sorted by severity.

## Begin

Start from Step 1.
