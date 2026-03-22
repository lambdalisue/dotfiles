---
name: deal-review
allowed-tools: Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Bash(git rev-parse:*), Bash(gh pr:*), Bash(gh api:*), Bash(gh repo:*), Bash(jq:*), Read, Edit, Glob, Grep
argument-hint: "[context]"
description: Address review findings from /code-review, /style-review, /doc-review, or /pr-review
---

## Arguments

- `context` (optional): User guidance on which findings to address and how (e.g., "1, 2 は対応、3 は不要", "全部対応", "3 は指摘が間違い").

## Context

!`git branch --show-current`
!`gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null || echo 'NO_REPO'`
!`gh pr view --json number --jq '.number' 2>/dev/null || echo 'NO_PR'`

## Language

- Task prompts to agents: **English**
- User-facing output: **Japanese**

## Principles

- This command runs **after** `/code-review`, `/style-review`, `/doc-review`, or `/pr-review`. The review results are in the conversation history.
- User's `context` argument takes **highest priority** over the review's own severity judgments.
- If no `context` is provided, follow the review's recommendations (address ★★★ and ★★☆; skip ★☆☆ and ☆☆☆ unless they are trivially fixable).
- Do NOT commit or push. Only implement changes (code or document), reply to threads, and resolve threads.

## Workflow

### Step 1: Identify review type

Look at the conversation history to determine which review command was run:

- **Code review** (`/code-review`): The report starts with `## コードレビュー結果`
- **Style review** (`/style-review`): The report starts with `## スタイルレビュー結果`
- **Doc review** (`/doc-review`): The report starts with `## ドキュメントレビュー結果`
- **PR review** (`/pr-review`): The report starts with `## 未解決のレビューコメント`

If neither is found, inform the user and **STOP**.

### Step 2: Build action plan

From the review results in conversation history, extract all findings and their severity levels.

Apply user's `context` argument to override decisions:
- If user says to address a specific finding → address it regardless of severity
- If user says to skip a specific finding → skip it regardless of severity
- If user says a finding is wrong → skip it (and for PR review, reply explaining disagreement)

For findings without explicit user guidance, follow the review's recommendations:
- ★★★ and ★★☆ → address
- ★☆☆ → address only if trivially fixable
- ☆☆☆ → skip

Display the action plan in Japanese:

```
## 対応計画

| # | タイトル | 重要度 | 対応 |
|---|---------|--------|------|
| 1 | ... | ★★★ | 対応する |
| 2 | ... | ★★☆ | 対応する |
| 3 | ... | ★☆☆ | スキップ (軽微) |
| 4 | ... | ☆☆☆ | スキップ (不同意) |
```

### Step 3: Implement fixes

For each finding marked as "対応する", implement the fix:

1. Read the relevant source files or documents
2. Make changes using Edit tool (code) or Edit/Write tool (documents)
3. Briefly report what was changed

### Step 4: PR review — Reply and resolve threads (PR review only)

**Skip this step if the review was `/code-review`, `/style-review`, or `/doc-review`.**

For PR review, fetch the unresolved threads to get thread IDs:

```bash
gh api graphql -f query='{ repository(owner: "OWNER", name: "REPO") { pullRequest(number: PR_NUMBER) { reviewThreads(first: 100) { nodes { id isResolved comments(first: 10) { nodes { id body author { login } path line startLine } } } } } } }'
```

Match each unresolved thread to the findings from the review report. Then for **every** thread (both addressed and skipped):

a. **Reply** to the thread in the reviewer's language (detect from original comment):

```bash
gh api graphql --input - << 'GQLEOF'
{"query":"mutation($body:String!){addPullRequestReviewThreadReply(input:{pullRequestReviewThreadId:\"THREAD_ID\",body:$body}){comment{id body}}}","variables":{"body":"MESSAGE"}}
GQLEOF
```

Reply content guidelines:
- **Addressed findings**: Explain what was fixed and how
- **Skipped findings (disagreed)**: Politely explain why you disagree, with reasoning
- **Skipped findings (trivial/optional)**: Acknowledge the point, explain why it's deferred

b. **Resolve** the thread:

```bash
gh api graphql -f query='mutation { resolveReviewThread(input: { threadId: "THREAD_ID" }) { thread { isResolved } } }'
```

### Step 5: Summary

Display a detailed summary in Japanese. Each addressed finding must explain **what** was changed, **why** that approach was chosen, and **how** it was implemented.

```
## 対応結果

### 対応した指摘 (N件)

#### #1: 指摘タイトル (★★★)

- **何を**: `path/to/file:line` の関数Xを修正
- **なぜ**: 元のコードはYの場合にZが発生するため。レビュー指摘の通り、信頼境界での検証が欠落していた
- **どのように**: 入力値の検証をAパターンで追加。既存の `path/to/validator.ts:42` と同じ方式を採用した

#### #2: 指摘タイトル (★★☆)

- **何を**: `path/to/file:line` のモジュール構造を変更
- **なぜ**: 既存の設計パターン（`path/to/existing.ts` で確立）と不整合があったため
- **どのように**: 責務をBモジュールに移動し、インターフェースをCパターンに統一

### スキップした指摘 (N件)

- **#3** (★☆☆): 指摘タイトル — 軽微な改善であり、現状でも正しく動作するため見送り
- **#4** (☆☆☆): 指摘タイトル — 既存コードベース全体が同じアプローチを採用しており、ここだけ変更するのは不整合を生むため不同意

### 変更ファイル一覧

- `path/to/file1` — 変更概要
- `path/to/file2` — 変更概要

### 返信・解決したスレッド (N件) ← PR review only

- **#1**: @reviewer — 修正内容を説明、解決済み
- **#3**: @reviewer — 見送り理由を説明、解決済み
```

**IMPORTANT: Do NOT commit or push.** This command only implements changes (code or document) and handles PR threads.

## Begin

Execute the workflow above. Start from Step 1.
