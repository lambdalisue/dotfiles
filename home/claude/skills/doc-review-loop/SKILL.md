---
name: doc-review-loop
disable-model-invocation: true
allowed-tools: Skill, Read, Edit, Write, Glob, Grep, Agent, Bash(deno run:*), Bash(ls:*), AskUserQuestion
argument-hint: "<path-or-keyword>"
description: Repeat /doc-review and apply its findings until the document is clean, with a per-round nitpick self-check
---

## Arguments

`$ARGUMENTS` = `{path-or-keyword}` — same forms as `/doc-review`: a file path, a
search keyword, or `latest`.

For the codex-based reviewer instead, use `/doc-review-codex-loop`. For code, use
`/code-review-loop` or `/code-review-codex-loop`.

## Language

- All user-facing output is **Japanese**. The templates below are structural
  skeletons: render every sentence in Japanese, keeping the shape.

## Principles

- **One invocation, many rounds.** The loop runs entirely in this context — never
  via `/loop`, `ScheduleWakeup`, or a background task. The findings ledger lives in
  this context, and nothing here waits on external state, so there is nothing to poll.
- **The loop owns verification and fixing.** Invoke `/doc-review` read-only (never
  with `--fix`) and apply the fixes yourself in Step D. `--fix` would re-verify on
  its own and re-open findings the ledger has already closed.
- **Same output shape as the bundled `/code-review`.** Each round reports the
  findings list with verdicts and outcomes, exactly as `/doc-review --fix` would.
  The loop adds one line per round: the self-check answer.
- **Never commit or push.** Commits belong to the `/git-commit` family on explicit
  user request. End by reporting the document is ready.
- **Diminishing returns is a stop condition, not a nuisance.** Every round must
  answer, in writing, whether it has degenerated into nitpicking — Step C.
- **Carry findings forward in a ledger.** Convergence is judged against the ledger
  (Step E), not against whatever the latest single report happened to surface.
- **Substance only.** Formatting, typos and Markdown lint belong to `/doc-check` and
  must never drive a round of this loop.

## Review scope across rounds

Resolve the document to an **absolute path once**, in round 1, and pass that same
path to `/doc-review` on every subsequent round. Never re-resolve from the keyword
mid-loop — a keyword can match a different document once the text changes.

Scope never narrows: Step D edits the document in place and the reviewer re-reads
the whole file each round, so every round sees the current document in full. Line
numbers shift after edits — match ledger entries by finding, not by line.

## Round structure

Repeat rounds until a convergence condition in Step E fires. Hard cap: **4 rounds**.

### Step A: Review

Invoke `/doc-review` via the Skill tool (`skill: "doc-review"`), passing
`$ARGUMENTS` on round 1 and the resolved absolute path on every round after. Never
pass `--fix`.

If the document cannot be found, stop and report that.

### Step B: Verify

Reviewer findings are not automatically correct. For each finding in the report,
read the section and any code it references and mark it:

- `CONFIRMED` — the problem is demonstrable from the document and its references
- `PLAUSIBLE` — cannot be ruled out, but not demonstrated
- `WRONG` — does not hold (record why); it never enters Step D

Cross-check the ledger: a finding already closed in an earlier round (fixed, wrong,
or no change needed) stays closed. Do not re-litigate it.

### Step C: Self-check — is this nitpicking?

**Mandatory every round. Answer in the user-facing output — never silently.**

Ask yourself: "Has this loop degenerated into nitpicking?" Judge by:

1. Are this round's findings different **in kind** from earlier rounds, or the same
   concerns restated at a smaller scale?
2. Is a section being rewritten to satisfy taste rather than to fix a substantive
   gap?
3. Would a reader who never saw the earlier rounds still call these worth fixing?
4. Is the document getting longer and more hedged without getting more correct?

If the answer is *yes, this is nitpicking* → **stop the loop** and report.

**Guard both directions**: this check may NOT be used to bail out while a
`CONFIRMED` `accuracy` or `consistency` finding is open — real gaps are never
nitpicks. Equally, do not answer "no" reflexively just to earn another round.

### Step D: Apply fixes

Apply every `CONFIRMED` finding yourself with Edit:

1. Re-read the section and any code it references.
2. Make the change, keeping the document's existing structure and voice.
3. Record the outcome: `fixed`, or `no change needed` with the reason when the
   document already covers the point elsewhere.

`PLAUSIBLE` findings get the outcome `skipped` and stay open in the ledger; the
bundled `/code-review --fix` applies only what it is confident in, and so does this
loop.

### Step E: Ledger update and convergence check

Update the findings ledger, then stop if **any** condition holds:

1. Step A raised no findings.
2. Step B confirmed nothing — every finding was `PLAUSIBLE` or `WRONG`.
3. Step D applied **zero** edits.
4. Some finding has survived **2** fix attempts — stop and escalate it to the user
   rather than trying a third time.
5. Step C answered "this is nitpicking" (subject to its guard).
6. The 4-round cap is reached.

Otherwise start the next round at Step A.

## Findings ledger

Maintain across rounds and print it in the final report:

| # | Finding | Location | Category | Verdict | Outcome | Attempts | First seen |
|---|---------|----------|----------|---------|---------|----------|------------|

- Outcome: `fixed` / `skipped` / `no change needed` / `wrong` / `recurred`
- `recurred` means the finding reappeared after a fix attempt — bump the attempt
  count, and at 2 trigger convergence condition 4.

## Output format

Per round, before moving on — the findings list in the shape `/doc-review --fix`
reports, plus the self-check line:

```
Round N. Reviewed `{path}` ({document_type}).

1. `{path}:line` — One sentence stating what is wrong or missing. [accuracy] CONFIRMED → fixed
   What changed: one sentence.
2. `{path}:88` — One sentence. [completeness] PLAUSIBLE → skipped
   Why: not demonstrated.
3. `{path}:120` — One sentence. [assumption] WRONG
   Why: one sentence.

Nitpicking? {No | Yes} — one or two sentences. Must be "No" while a CONFIRMED accuracy or consistency finding is open.
```

Final:

```
Loop finished after N rounds. Stop reason: {the convergence condition, verbatim}.

(findings ledger table)

Open items: unresolved or escalated findings with reasons, or "none".
Updated `{path}`. Nothing was committed.
```

## Anti-patterns

- **Do not use `/loop` or `ScheduleWakeup`** — the ledger lives in this context, and
  there is no external state to wait on.
- **Do not re-resolve a keyword after round 1** — pass the absolute path resolved in
  round 1, or the loop can silently switch documents.
- **Do not invoke `/doc-review --fix` from the loop** — it verifies on its own and
  would re-open findings the ledger has closed. The loop applies fixes in Step D.
- **Do not skip Step C, or answer it silently** — the self-check is the point of the
  loop, and its answer belongs in the output.
- **Do not act on cosmetic findings** — `/doc-check` owns formatting, typos and lint.
- **Do not apply a finding you could not confirm** — an unverified finding that
  gets "fixed" makes the document worse, not better.
- **Do not commit or push.**

## Begin

Parse `$ARGUMENTS`, resolve the document path, then execute round 1 from Step A.
