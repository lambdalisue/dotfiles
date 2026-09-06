---
name: doc-review-codex
allowed-tools: Bash(codex exec:*), Bash(deno run:*), Bash(ls:*), Bash(wc:*), Read, Glob, Grep, Edit, Write, AskUserQuestion
argument-hint: "<path-or-keyword> [--fix]"
description: Documentation review using OpenAI Codex CLI — AI notes, Slite notes, plans, and specifications; --fix applies the findings to the document
---

## Arguments

`$ARGUMENTS` = `{path-or-keyword} [--fix]`

- **File path**: Direct path to a document to review (e.g., `~/Compost/AI-Notes/2026-03/04-1200-design.md`)
- **Keyword**: Search term to find documents to review (e.g., "auth design", "proxy")
- **"latest"**: Review the most recent AI note
- `--fix` (optional flag): After reporting, verify and apply the findings to the
  document (see Step 5). Without it the skill is read-only. Same meaning as the
  bundled `/code-review --fix`.
- Strip `--fix` first; whatever remains is `{path-or-keyword}`.

## Language

- All user-facing output is **Japanese**. The templates below are structural
  skeletons: render every sentence in Japanese, keeping the shape.

## Principles

- **Read-only unless `--fix`.**
- Focus on **substantive quality**: logical gaps, missing considerations, technical
  inaccuracies, feasibility issues.
- Skip cosmetic issues (formatting, typos, Markdown lint) — those are handled by
  `/doc-check`.
- Uses `codex exec` with a review prompt — codex reads the document and any
  referenced source files itself.
- **Same output shape as the bundled `/code-review`**: a findings list ranked most
  severe first, no headers, no severity markers. See "Output shape".
- **Never commit or push**, even with `--fix`.

## Output shape

This is the shape the bundled `/code-review` reports in. Every report from this
skill uses it, so code and document reviews read the same in a conversation.

```
Codex review. N findings, most severe first. Reviewed `{path}` ({document_type}).

1. `{path}:line` — One sentence stating what is wrong or missing. [accuracy]
   Scenario: what goes wrong for a reader or implementer who follows the document as written.
   Fix: what to change.
2. `{path}:88` — One sentence. [completeness]
   Scenario: …
   Fix: …
```

- `line` is the first line of the affected section or claim, from Read.
- Categories are short kebab-case tags: `accuracy` (claim contradicts the
  implementation), `consistency` (the document contradicts itself),
  `completeness` (missing consideration, edge case, or step), `feasibility`,
  `assumption` (unstated premise that could invalidate the document). One per
  finding.
- Rank by severity: `accuracy` and `consistency` first, then `feasibility` and
  `assumption`, then `completeness`. Within a tier, the more consequential first.
- With nothing to report, the whole report is one line: `Codex review. No
  findings. Reviewed \`{path}\` ({document_type}).`
- After `--fix`, each finding is reported again with an outcome suffix (see Step 5).

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

- **Specification**: Defines requirements and interfaces
- **Design document**: Describes architecture and implementation approach
- **Plan**: Step-by-step implementation plan
- **Note**: General notes, research, analysis

### Step 3: Run codex exec

Build the prompt with the resolved absolute path and the type-specific criteria,
then run it:

```bash
codex exec --sandbox read-only "Review the document at the absolute path {path} for substantive quality. You CAN read files outside the current working directory with --sandbox read-only — actually attempt the read, do not refuse preemptively.

Methodology: read the document fully; if it references code, repositories, APIs or file paths, read those to verify the references are accurate; check internal consistency (do later sections contradict earlier ones?).

This document is a {document_type}. Review criteria: {criteria}

For all types also check: technical accuracy (do code examples, API references and technical claims match the actual implementation?), logical completeness (gaps in reasoning, missing considerations), feasibility, self-consistency, and unstated assumptions that could invalidate it.

IGNORE: formatting, typos, Markdown syntax, writing-style preferences, minor wording improvements.

Per finding: the section heading and the line number of the affected claim, one of the categories accuracy / consistency / completeness / feasibility / assumption, one sentence stating what is missing or wrong, the concrete consequence for a reader who follows the document as written, and a suggested improvement. Order from most to least consequential. Output findings in Japanese." 2>&1
```

Where `{criteria}` is chosen by `{document_type}`:

- **Specification**: Are requirements clear and unambiguous? Are edge cases and
  error scenarios covered? Are interfaces and data formats fully defined? Is the
  scope clearly bounded (what is NOT included)? Are acceptance criteria defined?
- **Design document**: Is the architectural approach sound, and were obvious
  alternatives considered? Are component interactions and data flows clearly
  described? Are failure modes and error handling addressed? Does the design align
  with the referenced code and existing architecture? Are assumptions and
  trade-offs stated?
- **Plan**: Are the steps in a logical order? Are dependencies between steps
  identified? Are risks and mitigations realistic? Is the testing strategy
  sufficient for the scope of changes? Are there missing steps needed in practice?
- **Note**: Are the claims supported? Are the conclusions warranted by the evidence
  presented? Are alternative explanations considered?

**Do NOT**: retry with different invocations on failure. If the command fails,
report the error as-is.

### Step 4: Report

Codex's stdout carries the intermediate tool trace (grep hits, file reads) and then
its final answer. Take the final answer only, and do not relay it verbatim —
restate every finding in the "Output shape" above: one entry per finding with
`{path}:line`, a one-sentence problem, a category tag, the scenario, and the fix.
Drop anything cosmetic. Read the document yourself to fill in a line number codex
omitted.

Without `--fix`, **STOP here**.

### Step 5: Apply the findings (`--fix` only)

Codex findings are not automatically correct. Before touching the document:

1. **Verify** each finding by reading the section and any code it references,
   and mark it `CONFIRMED` (the problem is demonstrable from the document and its
   references) or `PLAUSIBLE` (cannot be ruled out, but not demonstrated).
2. **Apply** every `CONFIRMED` finding with Edit, keeping the document's existing
   structure and voice. Leave `PLAUSIBLE` findings unapplied, the way the bundled
   `/code-review --fix` applies only what it is confident in. Substance only —
   leave formatting and wording to `/doc-check`.

Then report the same list again, each entry carrying its verdict and outcome:

```
Codex review, fixes applied. Reviewed `{path}` ({document_type}).

1. `{path}:line` — One sentence. [accuracy] CONFIRMED → fixed
   What changed: one sentence.
2. `{path}:88` — One sentence. [completeness] PLAUSIBLE → skipped
   Why: not demonstrated; left for the author.
3. `{path}:120` — One sentence. [assumption] CONFIRMED → no change needed
   Why: the premise is stated two sections earlier.

Updated `{path}`. Nothing was committed.
```

Outcomes are exactly `fixed`, `skipped`, or `no change needed`.

## Anti-patterns

- **Do not embed the document content in the prompt** — codex reads the file
  itself, and inlining a long document blows up the shell argument.
- **Do not accept a preemptive "cannot read outside cwd"** from codex — the
  read-only sandbox permits reads anywhere. The prompt above already says so; if
  codex still refuses, report it rather than switching strategies.
- **Do not modify the document without `--fix`.**
- **Do not report or fix cosmetic findings** — `/doc-check` owns those.

## Begin

Parse `$ARGUMENTS` and execute from Step 1.
