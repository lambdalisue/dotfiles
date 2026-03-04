---
allowed-tools: Bash(deno run:*), Bash(ls:*), Read, Glob, Grep, Agent
argument-hint: "<path-or-keyword>"
description: Review documentation quality — AI notes, Slite notes, plans, and specifications
model: sonnet
---

## Arguments

`$ARGUMENTS` = `{path-or-keyword}`

- **File path**: Direct path to a document to review (e.g., `~/Compost/AI-Notes/2026-03/04-1200-design.md`)
- **Keyword**: Search term to find documents to review (e.g., "認証設計", "proxy")
- **"latest"**: Review the most recent AI note

## Language

- Agent prompts: **English**
- User-facing report: **Japanese**

## Principles

- **Read-only**. Do NOT modify any documents.
- Focus on **substantive quality**: logical gaps, missing considerations, technical inaccuracies, feasibility issues.
- Skip cosmetic issues (formatting, typos, Markdown lint) — those are handled by `/doc:check`.

## Workflow

### Step 1: Locate the document

Based on the argument:

1. **File path**: Read the file directly
2. **"latest"**: Run `deno run -A ~/.claude/skills/ai-notes/notes.ts list --limit 1` to get the most recent note, then read it
3. **Keyword**: Search for matching documents:
   - Search AI notes: `deno run -A ~/.claude/skills/ai-notes/notes.ts list --limit 20` and filter, or use Grep across `~/Compost/AI-Notes/`
   - If multiple matches, list them and ask the user to choose (use AskUserQuestion)

If the document cannot be found, inform the user and **STOP**.

### Step 2: Understand the document type

Determine the document type from content:

- **仕様書 (Specification)**: Defines requirements and interfaces
- **設計書 (Design document)**: Describes architecture and implementation approach
- **計画書 (Plan)**: Step-by-step implementation plan
- **メモ (Note)**: General notes, research, analysis

### Step 3: Gather context

If the document references specific code, APIs, or repositories:

1. Identify referenced files/repos from the document content
2. Read referenced source files to verify accuracy (use Read/Glob/Grep)
3. If the document references a project in a known local path, explore it

### Step 4: Launch reviewer agent

Use the Agent tool to spawn 1 agent.

```
subagent_type: "general-purpose"
model: "sonnet"
```

Prompt (adapt review criteria based on document type):

```
You are a technical document reviewer. Review the following {document_type} for quality and completeness.

## Methodology

1. Read the document carefully
2. If the document references code or implementations, use Read/Glob/Grep to verify those references are accurate
3. Check the document's internal consistency (do later sections contradict earlier ones?)

## Review criteria for {document_type}

### For 仕様書 (Specification):
- Are requirements clear and unambiguous?
- Are edge cases and error scenarios covered?
- Are interfaces and data formats fully defined?
- Is the scope clearly bounded (what is NOT included)?
- Are acceptance criteria defined?

### For 設計書 (Design document):
- Is the architectural approach sound? Are there obvious alternatives that weren't considered?
- Are component interactions and data flows clearly described?
- Are failure modes and error handling strategies addressed?
- Does the design align with referenced code/existing architecture?
- Are assumptions explicitly stated?
- Are trade-offs acknowledged?

### For 計画書 (Plan):
- Are implementation steps in a logical order?
- Are dependencies between steps identified?
- Are risks and mitigation strategies realistic?
- Is the testing strategy sufficient for the scope of changes?
- Are there missing steps that would be needed in practice?

### For all types:
- **Technical accuracy**: Do code examples, API references, and technical claims match the actual implementation?
- **Logical completeness**: Are there gaps in reasoning or missing considerations?
- **Feasibility**: Are the proposed approaches practically achievable?
- **Consistency**: Does the document contradict itself?
- **Assumptions**: Are unstated assumptions that could invalidate the plan?

## What to IGNORE
- Formatting, typos, Markdown syntax
- Writing style preferences
- Minor wording improvements

Document content:
{document content}

{referenced code context if any}

For each issue: section/heading where the issue is, Severity (Critical/Warning/Notice), what is missing or wrong, suggested improvement.
```

### Step 5: Report in Japanese

Display-only. Do NOT modify the document.

Severity:
- Critical `(★★★)`: Technical inaccuracy, logical gap that invalidates the plan
- Warning `(★★☆)`: Missing consideration, unstated assumption, feasibility concern
- Notice `(★☆☆)`: Improvement suggestion that would strengthen the document

```
## ドキュメントレビュー結果

**対象**: `{path}` | **種別**: {document_type}

---

### 1. タイトル (セクション名) (★★★)

> 問題の要約。

具体的な改善案。

---

### 2. タイトル (セクション名) (★★☆)

> 問題の要約。

...
```

- Flat numbered list sorted by severity
- If no substantive issues → report clean

## Begin

Parse `$ARGUMENTS` and execute from Step 1.
