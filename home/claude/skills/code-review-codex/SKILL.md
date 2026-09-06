---
name: code-review-codex
allowed-tools: Bash(git diff:*), Bash(git log:*), Bash(git status:*), Bash(git branch:*), Bash(git merge-base:*), Bash(git rev-parse:*), Bash(gh pr:*), Bash(codex exec:*), Bash(wc:*), Read, Glob, Grep, Edit, Write
argument-hint: "[base] [--fix]"
description: Code review using OpenAI Codex CLI with project context (rules, diff, conventions); --fix applies the findings to the working tree
---

## Arguments

- `base` (optional): Base branch/ref. Auto-detected if omitted.
- `--fix` (optional flag): After reporting, verify and apply the findings to the
  working tree. Without it the skill is read-only. Same meaning as the bundled
  `/code-review --fix`.
- Strip `--fix` from `$ARGUMENTS` first; whatever remains is `base`.

## Language

- All user-facing output is **Japanese**. The templates below are structural
  skeletons: render every sentence in Japanese, keeping the shape.

## Principles

- **Read-only unless `--fix`.** **No nits** (style/naming/formatting are out of scope).
- **Focus**: design mistakes, architectural misfit, best practices violations, security holes, codebase inconsistency, rule violations, logic bugs.
- Uses `codex exec` with a review prompt — codex reads the codebase and diff itself.
- **Same output shape as the bundled `/code-review`**: a findings list ranked most
  severe first, no headers, no severity markers. Each finding is one line of
  `` `path:line` — one-sentence defect `` plus a category tag, followed by the
  concrete failure scenario. See "Output shape".
- **Never commit or push**, even with `--fix`. Commits belong to the `/git-commit`
  family on explicit user request.

## Output shape

This is the shape the bundled `/code-review` reports in, and the shape its
`ReportFindings` tool encodes. Every report from this skill uses it, so the two
reviewers read the same in a conversation.

```
N findings, most severe first. Reviewed {scope}.

1. `path/to/file:line` — One sentence stating the defect. [correctness]
   Scenario: concrete inputs or state → wrong output or crash.
   Fix: what to change.
2. `path/to/other.ts:88` — One sentence. [efficiency]
   Scenario: …
   Fix: …
```

- Categories are short kebab-case tags: `correctness`, `security`, `design`,
  `consistency`, `reuse`, `simplification`, `efficiency`. One per finding.
- `Scenario` is mandatory for `correctness` and `security`; for the rest, include
  it when a concrete consequence exists and drop the line otherwise.
- Rank by severity: security and correctness first, then design and consistency,
  then cleanups. Within a tier, the more consequential first.
- With nothing to report, the whole report is one line: `No findings. Reviewed
  {scope}.`
- After `--fix`, each finding is reported again with an outcome suffix (see Step 5).

## codex exec CLI usage

**CRITICAL**: Follow these exact command patterns. Do NOT deviate or experiment.

```bash
codex exec --sandbox read-only "PROMPT" 2>&1
```

- `codex exec` runs non-interactively and prints results to stdout
- `--sandbox read-only` ensures no writes to the repository
- The PROMPT tells codex what to review — codex has full access to read the repo and run git commands itself
- Do NOT pipe stdin or construct complex shell escapes — just pass a clear prompt string

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
If empty → **STOP** and tell the user there are no changes to review.

### Step 2: Collect metadata for report header

Run in parallel:
- `git diff --name-only "$(git merge-base {base} HEAD)"` (or `git diff --name-only` + `git diff --cached --name-only` for uncommitted) → count changed files
- `git log --oneline "$(git merge-base {base} HEAD)..HEAD"` (committed mode only) → `{log}`

### Step 3: Run codex exec

Build the prompt and run `codex exec`:

**Committed changes**:
```bash
codex exec --sandbox read-only "Review the code changes between {base} and HEAD. Focus on: design mistakes, architectural misfit, best practices violations, security holes, logic bugs. Ignore style/naming/formatting nits. Output findings in Japanese." 2>&1
```

**Uncommitted changes**:
```bash
codex exec --sandbox read-only "Review the uncommitted changes (staged and unstaged). Focus on: design mistakes, architectural misfit, best practices violations, security holes, logic bugs. Ignore style/naming/formatting nits. Output findings in Japanese." 2>&1
```

**Do NOT**: retry with different invocations on failure. If the command fails, report the error as-is.

### Step 4: Report

Codex output is prose in whatever shape codex chose. Do not relay it verbatim —
restate every finding in the "Output shape" above: one entry per finding with
`path:line`, a one-sentence defect, a category tag, and the scenario. Drop
anything codex reported that is a style/naming/formatting nit. Use codex's
`{scope}` wording: `changes since {base}` or `uncommitted changes`.

Prefix the report with one line so the reader knows which reviewer spoke:
`Codex review.`

Without `--fix`, **STOP here**.

### Step 5: Apply the findings (`--fix` only)

Codex findings are not automatically correct. Before touching anything:

1. **Verify** each finding against the actual code (Read the file and its callers)
   and mark it `CONFIRMED` (the scenario reproduces from the code as written) or
   `PLAUSIBLE` (cannot be ruled out, but not demonstrated).
2. **Apply** every `CONFIRMED` finding with Edit/Write, following the established
   patterns of the surrounding code. Leave `PLAUSIBLE` findings unapplied — the
   bundled `/code-review --fix` applies only what it is confident in, and so does
   this skill. A finding that turns out to be wrong is not applied either.
3. Leave everything uncommitted.

Then report the same list again, each entry carrying its verdict and outcome, the
way the bundled `/code-review` re-reports findings after fixing them:

```
Codex review, fixes applied. Reviewed {scope}.

1. `path/to/file:line` — One sentence stating the defect. [correctness] CONFIRMED → fixed
   What changed: one sentence.
2. `path/to/other.ts:88` — One sentence. [efficiency] PLAUSIBLE → skipped
   Why: not demonstrated from the code; left for the author.
3. `path/to/third.ts:12` — One sentence. [design] CONFIRMED → no change needed
   Why: the existing shape is intentional (see `path/to/sibling.ts:40`).

Changed files: `path/to/file`, `path/to/another`. Nothing was committed.
```

Outcomes are exactly `fixed`, `skipped`, or `no change needed`.

## Begin

Parse `$ARGUMENTS` and execute from Step 1.
