---
name: code-review-codex-loop
disable-model-invocation: true
allowed-tools: Skill, Read, Edit, Write, Glob, Grep, Bash(git diff:*), Bash(git log:*), Bash(git status:*), Bash(git branch:*), Bash(git merge-base:*), Bash(git rev-parse:*), Bash(gh pr:*), Bash(codex exec:*), Bash(wc:*)
argument-hint: "[base]"
description: Repeat /code-review-codex and apply its findings until the change set is clean, with a per-round nitpick self-check
---

## Arguments

- `base` (optional): Base branch/ref, forwarded to `/code-review-codex` on round 1
  only. Auto-detected if omitted.

For documents instead of code, use `/doc-review-codex-loop`. For the bundled
reviewer instead of codex, use `/code-review-loop`.

## Language

- All user-facing output is **Japanese**. The templates below are structural
  skeletons: render every sentence in Japanese, keeping the shape.

## Principles

- **One invocation, many rounds.** The loop runs entirely in this context — never
  via `/loop`, `ScheduleWakeup`, or a background task. The findings ledger lives in
  this context, and nothing here waits on external state, so there is nothing to poll.
- **The loop owns verification and fixing.** Invoke `/code-review-codex` read-only
  (never with `--fix`) and apply the fixes yourself in Step D. `--fix` would
  re-verify on its own and re-open findings the ledger has already closed.
- **Same output shape as the bundled `/code-review`.** Each round reports the
  findings list with verdicts and outcomes, exactly as `/code-review-codex --fix`
  would. The loop adds one line per round: the self-check answer.
- **Never commit or push.** Commits belong to the `/git-commit` family on explicit
  user request. End by reporting that the working tree is ready.
- **Diminishing returns is a stop condition, not a nuisance.** Every round must
  answer, in writing, whether it has degenerated into nitpicking — Step C.
- **Carry findings forward in a ledger.** Convergence is judged against the ledger
  (Step E), not against whatever the latest single report happened to surface.

## Review scope across rounds

Step D leaves its fixes **uncommitted**, which changes what the next round sees.
Determine the mode once in round 1 and state the scope in every round header.

- **Uncommitted mode** (round 1 found a dirty tree): every round invokes
  `/code-review-codex` with no `base`. Each round re-detects uncommitted mode, so
  the original changes and the applied fixes both stay in scope. No drift.
- **Committed mode** (round 1 found a clean tree and a base): round 1 reviews
  `merge-base(base, HEAD)..HEAD`. From round 2 on, invoke `/code-review-codex` with
  **no `base`**, so it reviews the working tree — i.e. the applied fixes.
  Re-reviewing `..HEAD` instead would re-report findings already fixed on disk and
  loop forever. This narrowing is deliberate: **say so in the round header**, and
  rely on the ledger to keep the round-1 findings tracked.

Never pass `base` on rounds 2+. Never silently change mode mid-loop.

## Round structure

Repeat rounds until a convergence condition in Step E fires. Hard cap: **4 rounds**.

### Step A: Review

Invoke `/code-review-codex` via the Skill tool (`skill: "code-review-codex"`),
passing `base` only on round 1 in committed mode. Never pass `--fix`.

If it reports no reviewable changes, stop and report that.

### Step B: Verify

Codex findings are not automatically correct. For each finding in the report, read
the code and its callers and mark it:

- `CONFIRMED` — the scenario reproduces from the code as written
- `PLAUSIBLE` — cannot be ruled out, but not demonstrated
- `WRONG` — does not hold (record why); it never enters Step D

Cross-check the ledger: a finding already closed in an earlier round (fixed, wrong,
or no change needed) stays closed. Do not re-litigate it.

### Step C: Self-check — is this nitpicking?

**Mandatory every round. Answer in the user-facing output — never silently.**

Ask yourself: "Has this loop degenerated into nitpicking?" Judge by:

1. Are this round's findings different **in kind** from earlier rounds, or the same
   concerns restated at a smaller scale?
2. Is a file being re-edited to satisfy taste rather than to fix a defect?
3. Would a reviewer who never saw the earlier rounds still call these worth fixing?
4. Would the resulting fixes add more churn than the findings' impact justifies?

If the answer is *yes, this is nitpicking* → **stop the loop** and report.

**Guard both directions**: this check may NOT be used to bail out while a
`CONFIRMED` `correctness` or `security` finding is open — real defects are never
nitpicks. Equally, do not answer "no" reflexively just to earn another round.

### Step D: Apply fixes

Apply every `CONFIRMED` finding yourself with Edit/Write:

1. Read the relevant source files and their callers.
2. Make the change, following the established patterns of the surrounding code.
3. Record the outcome: `fixed`, or `no change needed` with the reason when reading
   the code shows the existing shape is intentional.

`PLAUSIBLE` findings get the outcome `skipped` and stay open in the ledger; the
bundled `/code-review --fix` applies only what it is confident in, and so does this
loop. Leave everything uncommitted.

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

Per round, before moving on — the findings list in the shape `/code-review-codex
--fix` reports, plus the self-check line:

```
Round N. Reviewed {uncommitted changes | changes since `{base}` | applied fixes only (base diff tracked in the ledger)}.

1. `path/to/file:line` — One sentence stating the defect. [correctness] CONFIRMED → fixed
   What changed: one sentence.
2. `path/to/other.ts:88` — One sentence. [efficiency] PLAUSIBLE → skipped
   Why: not demonstrated from the code.
3. `path/to/third.ts:12` — One sentence. [design] WRONG
   Why: one sentence.

Nitpicking? {No | Yes} — one or two sentences. Must be "No" while a CONFIRMED correctness or security finding is open.
```

Final:

```
Loop finished after N rounds. Stop reason: {the convergence condition, verbatim}.

(findings ledger table)

Changed files: `path/to/file`, `path/to/another`.
Open items: unresolved or escalated findings with reasons, or "none".
Nothing was committed. Run a `/git-commit` skill if needed.
```

## Anti-patterns

- **Do not use `/loop` or `ScheduleWakeup`** — the ledger lives in this context, and
  there is no external state to wait on.
- **Do not pass `base` on rounds 2+** — it would review `..HEAD` while the fixes
  live in the working tree, re-reporting issues already fixed and looping forever.
- **Do not invoke `/code-review-codex --fix` from the loop** — it verifies on its
  own and would re-open findings the ledger has closed. The loop applies fixes in
  Step D.
- **Do not skip Step C, or answer it silently** — the self-check is the point of the
  loop, and its answer belongs in the output.
- **Do not commit or push**, and do not run `/git-commit` on the user's behalf.
- **Do not re-litigate closed findings** — once marked wrong or no change needed
  with a reason, they stay closed for the rest of the loop.
- **Do not apply a finding you could not confirm** — an unverified finding that
  gets "fixed" is a regression, not a fix.

## Begin

Parse `$ARGUMENTS`, determine the review mode, then execute round 1 from Step A.
