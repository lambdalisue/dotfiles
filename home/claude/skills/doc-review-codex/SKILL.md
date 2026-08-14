---
name: doc-review-codex
allowed-tools: Bash(codex exec:*), Bash(deno run:*), Bash(ls:*), Bash(wc:*), Read, Glob, Grep, AskUserQuestion
argument-hint: "<path-or-keyword>"
description: Documentation review using OpenAI Codex CLI — AI notes, Slite notes, plans, and specifications
---

## Arguments

`$ARGUMENTS` = `{path-or-keyword}`

- **File path**: Direct path to a document to review (e.g., `~/Compost/AI-Notes/2026-03/04-1200-design.md`)
- **Keyword**: Search term to find documents to review (e.g., "認証設計", "proxy")
- **"latest"**: Review the most recent AI note

## Language

- User-facing report: **Japanese**

## Principles

- **Read-only**. Do NOT modify any documents.
- Focus on **substantive quality**: logical gaps, missing considerations, technical
  inaccuracies, feasibility issues.
- Skip cosmetic issues (formatting, typos, Markdown lint) — those are handled by
  `/doc-check`.
- Uses `codex exec` with a review prompt — codex reads the document and any
  referenced source files itself.

## codex exec CLI usage

**CRITICAL**: Follow these exact command patterns. Do NOT deviate or experiment.

```bash
codex exec --sandbox read-only "PROMPT" 2>&1
```

- `codex exec` runs non-interactively and prints results to stdout
- `--sandbox read-only` ensures no writes
- The PROMPT tells codex which document to review — pass the **absolute path**;
  codex reads the file and any code it references itself
- `--sandbox read-only` **does** permit reading paths outside the working
  directory. Codex sometimes claims otherwise without trying, so the prompt must
  instruct it to actually attempt the read
- AI-note filenames routinely contain spaces and Japanese characters. The path sits
  inside the prompt string, so the outer shell is fine, but tell codex to quote the
  path in any command it runs
- Do NOT pipe stdin or construct complex shell escapes — just pass a clear prompt
  string. Do NOT embed the document content in the prompt

## Workflow

### Step 1: Locate the document

Based on the argument:

1. **File path**: use it directly
2. **"latest"**: `deno run -A ~/.claude/skills/ai-notes/notes.ts list --limit 1` →
   take the most recent note
3. **Keyword**: `deno run -A ~/.claude/skills/ai-notes/notes.ts list --limit 20`
   and filter, or Grep across `~/Compost/AI-Notes/`. If multiple match, list them
   and ask the user to choose (AskUserQuestion)

Resolve to an **absolute path** (expand `~`). If the document cannot be found,
inform the user and **STOP**.

### Step 2: Determine the document type

Read the document and classify it:

- <strong>仕様書 (Specification)</strong>: Defines requirements and interfaces
- <strong>設計書 (Design document)</strong>: Describes architecture and implementation approach
- <strong>計画書 (Plan)</strong>: Step-by-step implementation plan
- <strong>メモ (Note)</strong>: General notes, research, analysis

### Step 3: Run codex exec

Build the prompt with the resolved absolute path and the type-specific criteria,
then run it:

```bash
codex exec --sandbox read-only "Review the document at the absolute path {path} for substantive quality. You CAN read files outside the current working directory with --sandbox read-only — actually attempt the read, do not refuse preemptively.

Methodology: read the document fully; if it references code, repositories, APIs or file paths, read those to verify the references are accurate; check internal consistency (do later sections contradict earlier ones?).

This document is a {document_type}. Review criteria: {criteria}

For all types also check: technical accuracy (do code examples, API references and technical claims match the actual implementation?), logical completeness (gaps in reasoning, missing considerations), feasibility, self-consistency, and unstated assumptions that could invalidate it.

IGNORE: formatting, typos, Markdown syntax, writing-style preferences, minor wording improvements.

Per finding: the section/heading it belongs to, a severity marker of exactly ★★★ (technical inaccuracy or logical gap that invalidates the document) or ★★☆ (missing consideration, unstated assumption, feasibility concern) or ★☆☆ (improvement that would strengthen it), what is missing or wrong and WHY, and a concrete suggested improvement. Sort by severity. Output findings in Japanese." 2>&1
```

Where `{criteria}` is chosen by `{document_type}`:

- <strong>仕様書</strong>: Are requirements clear and unambiguous? Are edge cases and error
  scenarios covered? Are interfaces and data formats fully defined? Is the scope
  clearly bounded (what is NOT included)? Are acceptance criteria defined?
- <strong>設計書</strong>: Is the architectural approach sound, and were obvious alternatives
  considered? Are component interactions and data flows clearly described? Are
  failure modes and error handling addressed? Does the design align with the
  referenced code and existing architecture? Are assumptions and trade-offs stated?
- <strong>計画書</strong>: Are the steps in a logical order? Are dependencies between steps
  identified? Are risks and mitigations realistic? Is the testing strategy
  sufficient for the scope of changes? Are there missing steps needed in practice?
- <strong>メモ</strong>: Are the claims supported? Are the conclusions warranted by the
  evidence presented? Are alternative explanations considered?

**Do NOT**: retry with different invocations on failure. If the command fails,
report the error as-is.

### Step 4: Report (Japanese)

Display-only. Do NOT modify the document.

```
## ドキュメントレビュー結果 (Codex)

<strong>対象</strong>: `{path}` | <strong>種別</strong>: {document_type}

---

{codex exec output}
```

`{codex exec output}` means codex's **final answer only**. Its stdout also carries
the intermediate tool trace (grep hits, file reads) and then repeats the final
answer verbatim at the end — relay the answer once and drop the trace.

If codex found no substantive issues, report that clearly.

The `## ドキュメントレビュー結果` header is what `/deal-review` matches on — keep it
verbatim.

## Anti-patterns

- **Do not embed the document content in the prompt** — codex reads the file
  itself, and inlining a long document blows up the shell argument.
- **Do not accept a preemptive "cannot read outside cwd"** from codex — the
  read-only sandbox permits reads anywhere. The prompt above already says so; if
  codex still refuses, report it rather than switching strategies.
- **Do not modify the document** — that is `/deal-review`'s job.
- **Do not report cosmetic findings** — `/doc-check` owns those.

## Begin

Parse `$ARGUMENTS` and execute from Step 1.
