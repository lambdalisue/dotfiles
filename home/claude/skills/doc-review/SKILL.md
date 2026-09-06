---
name: doc-review
allowed-tools: Bash(deno run:*), Bash(ls:*), Read, Glob, Grep, Agent, Edit, Write, AskUserQuestion
argument-hint: "<path-or-keyword> [--fix]"
description: Review documentation quality — AI notes, Slite notes, plans, and specifications; --fix applies the findings to the document
---

## Arguments

`$ARGUMENTS` = `{path-or-keyword} [--fix]`

- **File path**: Direct path to a document to review (e.g., `~/Compost/AI-Notes/2026-03/04-1200-design.md`)
- **Keyword**: Search term to find documents to review (e.g., "auth design", "proxy")
- **"latest"**: Review the most recent AI note
- `--fix` (optional flag): After reporting, verify and apply the findings to the
  document (see Step 6). Without it the skill is read-only. Same meaning as the
  bundled `/code-review --fix`.
- Strip `--fix` first; whatever remains is `{path-or-keyword}`.

## Language

- Agent prompts: **English**
- All user-facing output is **Japanese**. The templates below are structural
  skeletons: render every sentence in Japanese, keeping the shape.

## Principles

- **Read-only unless `--fix`.**
- Focus on **substantive quality**: logical gaps, missing considerations, technical inaccuracies, feasibility issues.
- Skip cosmetic issues (formatting, typos, Markdown lint) — those are handled by `/doc-check`.
- **Same output shape as the bundled `/code-review`**: a findings list ranked most
  severe first, no headers, no severity markers. See "Output shape".
- **Never commit or push**, even with `--fix`.

## Output shape

This is the shape the bundled `/code-review` reports in. Every report from this
skill uses it, so code and document reviews read the same in a conversation.

```
N findings, most severe first. Reviewed `{path}` ({document_type}).

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
- With nothing to report, the whole report is one line: `No findings. Reviewed
  \`{path}\` ({document_type}).`
- After `--fix`, each finding is reported again with an outcome suffix (see Step 6).

## Workflow

### Step 1: Locate the document

Based on the argument:

1. **File path**: Read the file directly
2. **"latest"**: Run `deno run -A ~/.claude/skills/ai-notes/notes.ts list --limit 1` to get the most recent note, then read it
3. **Keyword**: Search for matching documents:
   - Search AI notes: `deno run -A ~/.claude/skills/ai-notes/notes.ts list --limit 20` and filter, or use Grep across `~/Compost/AI-Notes/`
   - If multiple matches, list them and ask the user to choose (use AskUserQuestion)

Resolve to an **absolute path** (expand `~`). If the document cannot be found, inform the user and **STOP**.

### Step 2: Understand the document type

Determine the document type from content:

- **Specification**: Defines requirements and interfaces
- **Design document**: Describes architecture and implementation approach
- **Plan**: Step-by-step implementation plan
- **Note**: General notes, research, analysis

### Step 3: Gather context

If the document references specific code, APIs, or repositories:

1. Identify referenced files/repos from the document content
2. Read referenced source files to verify accuracy (use Read/Glob/Grep)
3. If the document references a project in a known local path, explore it

### Step 4: Launch reviewer agent

Use the Agent tool to spawn 1 agent.

```
subagent_type: "general-purpose"
```

Prompt (adapt review criteria based on document type):

```
You are a technical document reviewer. Review the following {document_type} for quality and completeness.

## Methodology

1. Read the document carefully
2. If the document references code or implementations, use Read/Glob/Grep to verify those references are accurate
3. Check the document's internal consistency (do later sections contradict earlier ones?)

## Review criteria for {document_type}

### For a specification:
- Are requirements clear and unambiguous?
- Are edge cases and error scenarios covered?
- Are interfaces and data formats fully defined?
- Is the scope clearly bounded (what is NOT included)?
- Are acceptance criteria defined?

### For a design document:
- Is the architectural approach sound? Are there obvious alternatives that weren't considered?
- Are component interactions and data flows clearly described?
- Are failure modes and error handling strategies addressed?
- Does the design align with referenced code/existing architecture?
- Are assumptions explicitly stated?
- Are trade-offs acknowledged?

### For a plan:
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

For each issue: the section heading and the line number of the affected claim, one of the categories accuracy / consistency / completeness / feasibility / assumption, one sentence stating what is missing or wrong, the concrete consequence for a reader who follows the document as written, and a suggested improvement. Order from most to least consequential.
```

### Step 5: Report

Restate the agent's findings in the "Output shape" above — one entry per
finding with `{path}:line`, a one-sentence problem, a category tag, the
scenario, and the fix. Drop anything cosmetic.

Without `--fix`, **STOP here**.

### Step 6: Apply the findings (`--fix` only)

Reviewer findings are not automatically correct. Before touching the document:

1. **Verify** each finding by re-reading the section and any code it references,
   and mark it `CONFIRMED` (the problem is demonstrable from the document and its
   references) or `PLAUSIBLE` (cannot be ruled out, but not demonstrated).
2. **Apply** every `CONFIRMED` finding with Edit, keeping the document's existing
   structure and voice. Leave `PLAUSIBLE` findings unapplied, the way the bundled
   `/code-review --fix` applies only what it is confident in. Substance only —
   leave formatting and wording to `/doc-check`.

Then report the same list again, each entry carrying its verdict and outcome:

```
Fixes applied. Reviewed `{path}` ({document_type}).

1. `{path}:line` — One sentence. [accuracy] CONFIRMED → fixed
   What changed: one sentence.
2. `{path}:88` — One sentence. [completeness] PLAUSIBLE → skipped
   Why: not demonstrated; left for the author.
3. `{path}:120` — One sentence. [assumption] CONFIRMED → no change needed
   Why: the premise is stated two sections earlier.

Updated `{path}`. Nothing was committed.
```

Outcomes are exactly `fixed`, `skipped`, or `no change needed`.

## Begin

Parse `$ARGUMENTS` and execute from Step 1.
