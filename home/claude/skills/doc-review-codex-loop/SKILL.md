---
name: doc-review-codex-loop
disable-model-invocation: true
allowed-tools: Skill, Read, Edit, Write, Glob, Grep, Bash(codex exec:*), Bash(deno run:*), Bash(ls:*), Bash(wc:*), AskUserQuestion
argument-hint: "<path-or-keyword>"
description: Repeat /doc-review-codex and /deal-review until the document is clean, with a per-round nitpick self-check
---

## Arguments

`$ARGUMENTS` = `{path-or-keyword}` — same forms as `/doc-review-codex`: a file path,
a search keyword, or `latest`.

For code instead of documents, use `/code-review-codex-loop`.

## Language

- Skill-internal reasoning and sub-prompts: **English** / User-facing output: **Japanese**

## Principles

- **One invocation, many rounds.** The loop runs entirely in this context — never
  via `/loop`, `ScheduleWakeup`, or a background task. `/deal-review` reads the
  review report out of conversation history, so the report and the fix must share
  one context. Nothing here waits on external state, so there is nothing to poll.
- **Never commit or push.** `/deal-review` forbids it, and commits belong to the
  `/git-commit` family on explicit user request. End by reporting the document is
  ready.
- **Diminishing returns is a stop condition, not a nuisance.** Every round must
  answer, in writing, whether it has degenerated into nitpicking (重箱の隅) — Step C.
- **Carry findings forward in a ledger.** Convergence is judged against the ledger
  (Step E), not against whatever the latest single report happened to surface.
- **Substance only.** Formatting, typos and Markdown lint belong to `/doc-check` and
  must never drive a round of this loop.

## Review scope across rounds

Resolve the document to an **absolute path once**, in round 1, and pass that same
path to `/doc-review-codex` on every subsequent round. Never re-resolve from the
keyword mid-loop — a keyword can match a different document once the text changes.

Unlike the code loop, scope never narrows: `/deal-review` edits the document in
place and codex re-reads the whole file each round, so every round sees the current
document in full.

## Round structure

Repeat rounds until a convergence condition in Step E fires. Hard cap: **4 rounds**.

### Step A: Review

Invoke `/doc-review-codex` via the Skill tool (`skill: "doc-review-codex"`), passing
`$ARGUMENTS` on round 1 and the resolved absolute path on every round after.

If the document cannot be found, stop and report that.

### Step B: Triage

`/doc-review-codex` asks codex for ★ severities, but **verify them rather than
trusting them** — read the document (and any code it references) and re-rank:

- **★★★** must fix — technical inaccuracy, or a logical gap that invalidates the
  document
- **★★☆** should fix — missing consideration, unstated assumption, feasibility
  concern
- **★☆☆** consider — a real improvement, low impact
- **☆☆☆** reject — wording preference, cosmetic issue, speculative concern, or the
  finding is simply wrong (record why)

Cross-check the ledger: a finding already marked スキップ in an earlier round stays
skipped. Do not re-litigate it.

### Step C: 自問 — 重箱の隅を突いていないか？

**Mandatory every round. Answer in the user-facing output — never silently.**

Ask yourself, verbatim: 「これは重箱の隅を突くようなループに陥っていないか？」 Judge by:

1. Are this round's findings different **in kind** from earlier rounds, or the same
   concerns restated at a smaller scale?
2. Is a section being rewritten to satisfy taste rather than to fix a substantive
   gap?
3. Would a reader who never saw the earlier rounds still call these worth fixing?
4. Is the document getting longer and more hedged without getting more correct?

If the answer is *yes, this is nitpicking* → **stop the loop** and report.

**Guard both directions**: this check may NOT be used to bail out while any ★★★ or
★★☆ finding is unresolved — real gaps are never 重箱の隅. Equally, do not answer
"no" reflexively just to earn another round.

### Step D: Apply fixes

Invoke `/deal-review` via the Skill tool (`skill: "deal-review"`), passing the
Step B triage as its `context` argument in Japanese. That argument is `/deal-review`'s
documented override and takes priority over any severity it would judge on its own.

`/deal-review` finds the review report by scanning conversation history, and from
round 2 on **every earlier round's report is still there**. So the `context` must
(a) scope itself to the newest report and (b) name each finding by title, never by
bare number:

```
最新のレビュー結果（ラウンド N）のみを対象とする。過去ラウンドの指摘は対応済みまたはスキップ済みなので無視すること。

- #1「タイトル」→ 対応
- #2「タイトル」→ スキップ（文言の好み）
- #3「タイトル」→ スキップ（指摘が誤り: 参照先の実装は既にこの形）
```

If Skill-tool invocation is refused because `/deal-review` sets
`disable-model-invocation: true`, read `~/.claude/skills/deal-review/SKILL.md` and
follow it verbatim in this context. Never hand-roll a substitute.

### Step E: Ledger update and convergence check

Update the findings ledger, then stop if **any** condition holds:

1. Step B produced no finding above ☆☆☆.
2. Every finding this round was triaged as skip — nothing left to do.
3. `/deal-review` applied **zero** edits.
4. Some finding has survived **2** fix attempts — stop and escalate it to the user
   rather than trying a third time.
5. Step C answered "this is nitpicking" (subject to its ★★★/★★☆ guard).
6. The 4-round cap is reached.

Otherwise start the next round at Step A.

## Findings ledger

Maintain across rounds and print it in the final report:

| # | 指摘 | セクション | 重要度 | 状態 | 試行 | 初出 |
|---|------|-----------|--------|------|------|------|

- <strong>状態</strong>: `対応済み` / `未対応` / `スキップ` / `再発`
- <strong>再発</strong> means the finding reappeared after a fix attempt — bump 試行, and at 2
  trigger convergence condition 4.

## Output format (Japanese)

Per round, before moving on:

```
## ラウンド N

<strong>対象</strong>: `{path}` | <strong>種別</strong>: {document_type}

### 指摘の仕分け

| # | 指摘 | 重要度 | 対応 |
|---|------|--------|------|

### 自問: 重箱の隅を突いていないか？

<strong>{いいえ | はい}</strong> — 判断理由を1〜2文で。★★★/★★☆ の未対応があるなら必ず「いいえ」。

### 適用した修正

（/deal-review の結果を要約）
```

Final:

```
## ループ完了（N ラウンド）

<strong>終了理由</strong>: {収束条件をそのまま書く}

### 指摘台帳

（上記の表）

### 残課題

- 未対応・エスカレーションした指摘とその理由。無ければ「なし」。

`{path}` を更新しました。コミットはしていません。
```

## Anti-patterns

- **Do not use `/loop` or `ScheduleWakeup`** — `/deal-review` needs the review
  report in the same context, and there is no external state to wait on.
- **Do not re-resolve a keyword after round 1** — pass the absolute path resolved in
  round 1, or the loop can silently switch documents.
- **Do not pass bare finding numbers** to `/deal-review` — earlier rounds' reports
  are still in conversation history, so numbers alone are ambiguous. Scope to the
  newest report and name each finding by title.
- **Do not let `/deal-review` triage for itself** — always pass Step B's verified
  triage as `context`.
- **Do not skip Step C, or answer it silently** — the self-check is the point of the
  loop, and its answer belongs in the output.
- **Do not act on cosmetic findings** — `/doc-check` owns formatting, typos and lint.
- **Do not trust a codex severity without reading the document** — an unverified
  finding that gets "fixed" makes the document worse, not better.
- **Do not commit or push.**

## Begin

Parse `$ARGUMENTS`, resolve the document path, then execute round 1 from Step A.
