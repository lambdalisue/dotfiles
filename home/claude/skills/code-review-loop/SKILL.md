---
name: code-review-loop
disable-model-invocation: true
allowed-tools: Skill, Read, Glob, Grep, Bash(git diff:*), Bash(git log:*), Bash(git status:*), Bash(git branch:*), Bash(git merge-base:*), Bash(git rev-parse:*)
argument-hint: "[low|medium|high|xhigh|max] [pr#|branch|path]"
description: Repeat the bundled /code-review --fix until the change set is clean, with a per-round nitpick self-check
---

## Arguments

`$ARGUMENTS` is forwarded verbatim to the bundled `/code-review --fix` on every
round, so it takes the same shape:

- Effort level (optional): `low`, `medium`, `high`, `xhigh`, or `max`. When
  omitted, `/code-review` reuses the level the user typed last.
- Target (optional): a PR number, branch name, or path. When omitted,
  `/code-review` reviews the branch's commits ahead of upstream **plus uncommitted
  changes**, which is what keeps the applied fixes in scope across rounds.

`ultra` is rejected: it is a billed cloud review the user launches themselves, and
its five-to-ten-minute runs do not fit a fix loop. Report that and **STOP**.

For the codex reviewer instead, use `/code-review-codex-loop`. For documents, use
`/doc-review-loop` or `/doc-review-codex-loop`.

## Language

- All user-facing output is **Japanese**. The templates below are structural
  skeletons: render every sentence in Japanese, keeping the shape.

## Principles

- **One invocation, many rounds.** The loop runs entirely in this context — never
  via `/loop`, `ScheduleWakeup`, or a background task. The findings ledger lives in
  this context.
- **`/code-review --fix` owns review, verification, and fixing.** The loop does not
  re-implement any of it and does not edit files itself. Its job is to decide,
  round by round, whether another pass is still worth running.
- **Relay, do not reformat.** `/code-review` already reports in the findings-list
  shape with outcomes. Each round relays that report as-is and adds one line: the
  self-check answer.
- **Never commit or push.** Commits belong to the `/git-commit` family on explicit
  user request. End by reporting that the working tree is ready.
- **Diminishing returns is a stop condition, not a nuisance.** Every round must
  answer, in writing, whether it has degenerated into nitpicking — Step C.
- **Carry findings forward in a ledger.** Convergence is judged against the ledger
  (Step D), not against whatever the latest single report happened to surface.

## Review scope across rounds

`--fix` leaves its edits **uncommitted**, and the default target includes
uncommitted changes, so every round sees the original change set and every fix
applied so far. Nothing narrows and nothing needs re-targeting.

With an explicit target this may not hold — a ref range or another branch does not
include the working tree. If the user gave one, say so in the round-1 header and
watch for the symptom: a finding reported as fixed that keeps coming back untouched
means the target is not seeing the fixes. Stop and report rather than looping.

`--fix` edits happen outside the checkpoint system, so `/rewind` cannot undo them.
Record `git diff --stat` before round 1 so the final report can show exactly what
the loop changed.

## Round structure

Repeat rounds until a convergence condition in Step D fires. Hard cap: **4 rounds**.

### Step A: Review and fix

Invoke the bundled `/code-review` via the Skill tool (`skill: "code-review"`) with
args `--fix {$ARGUMENTS}`.

The review runs as a background subagent. **Wait for its completion notification**
before continuing — do not poll, and do not start another round in the meantime.

If it reports nothing to review, stop and report that.

### Step B: Read the round

From the review's report, record for the ledger:

- every finding it raised, with `path:line`, its one-sentence summary, and its
  category
- the outcome it reported for each under `--fix`: `fixed`, `skipped`, or `no change
  needed`, with the reason it gave
- `git diff --stat` after the round, to confirm edits actually landed

Do not re-verify — `/code-review` already did. A finding it left `skipped` stays
open in the ledger with its stated reason.

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
`correctness` finding is open — real defects are never nitpicks. Equally, do not
answer "no" reflexively just to earn another round.

### Step D: Ledger update and convergence check

Update the findings ledger, then stop if **any** condition holds:

1. The round raised no findings.
2. The round applied **zero** edits (`git diff --stat` unchanged) — every remaining
   finding is one `/code-review` will not fix on its own; escalate them.
3. Some finding has survived **2** fix attempts — stop and escalate it to the user
   rather than trying a third time.
4. Step C answered "this is nitpicking" (subject to its guard).
5. The 4-round cap is reached.

Otherwise start the next round at Step A.

## Findings ledger

Maintain across rounds and print it in the final report:

| # | Finding | Location | Category | Outcome | Attempts | First seen |
|---|---------|----------|----------|---------|----------|------------|

- Outcome: `fixed` / `skipped` / `no change needed` / `recurred`
- `recurred` means the finding reappeared after a fix attempt — bump the attempt
  count, and at 2 trigger convergence condition 3.

## Output format

Per round, before moving on — the `/code-review --fix` report relayed as-is, plus
the self-check line:

```
Round N. Reviewed {commits ahead of upstream + uncommitted changes | explicit target `{target}` (uncommitted fixes may be out of scope)}.

(the /code-review --fix report, verbatim)

Nitpicking? {No | Yes} — one or two sentences. Must be "No" while a correctness finding is open.
```

Final:

```
Loop finished after N rounds. Stop reason: {the convergence condition, verbatim}.

(findings ledger table)

Changed files: `path/to/file`, `path/to/another` (compared with `git diff --stat` before round 1).
Open items: unresolved or escalated findings with reasons, or "none".
Nothing was committed. Run a `/git-commit` skill if needed.
```

## Anti-patterns

- **Do not pass `ultra`** — billed, user-launched, and far too slow for a loop.
- **Do not use `/loop` or `ScheduleWakeup`** — the ledger lives in this context, and
  the review's completion arrives as a notification, not as external state to poll.
- **Do not edit files yourself** — `--fix` owns the edits. If a finding needs a
  hand-made fix, escalate it under open items instead.
- **Do not start a round before the previous review's notification arrives** — two
  concurrent `--fix` runs edit the same working tree.
- **Do not skip Step C, or answer it silently** — the self-check is the point of the
  loop, and its answer belongs in the output.
- **Do not commit or push**, and do not run `/git-commit` on the user's behalf.

## Begin

Parse `$ARGUMENTS`, reject `ultra`, record `git diff --stat`, then execute round 1
from Step A.
