---
allowed-tools: Bash(git branch:*), Bash(gh pr:*), Bash(gh api:*), Bash(jq:*), Read, Glob, Grep
argument-hint: [PR_NUMBER] Optional PR number to review
description: Fetch unresolved PR review comments and display analysis
model: sonnet
---

## Context

!`git branch --show-current`
!`gh repo view --json nameWithOwner --jq '.nameWithOwner'`
!`gh pr view --json number --jq '.number' 2>/dev/null || echo 'NO_PR'`

## Principles

- If PR number is provided as argument, use that number
- If no argument, use the PR number from Context above
- Only show unresolved review comments (threads not marked as resolved)
- This command is **display-only**. Do NOT modify files, reply to threads, resolve threads, or ask the user for actions
- Summarize and analyze comments in Japanese for the user
- Show planned reply content in the REVIEWER's language (detect from original comment)

## Workflow

### Step 1: Determine PR number and repo

Use the values already resolved in Context section above.
Split nameWithOwner by "/" to get OWNER and REPO.
If argument was provided, use that as PR_NUMBER instead.

### Step 2: Fetch review threads

Build the query by replacing OWNER, REPO, PR_NUMBER with actual values.
Embed values directly in the query. Do NOT use GraphQL variables.

```bash
gh api graphql -f query='{ repository(owner: "OWNER", name: "REPO") { pullRequest(number: PR_NUMBER) { reviewThreads(first: 100) { nodes { id isResolved comments(first: 10) { nodes { id body author { login } path line startLine diffHunk } } } } } } }'
```

Pipe the result to filter unresolved threads:

```bash
| jq '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false)]'
```

### Step 3: Analyze and display in Japanese

Read the relevant source files for each comment to understand the full context before analyzing.

Display unresolved comments as a numbered list. Each finding uses the following structure:

Severity levels (exactly 3 characters using filled and empty stars):

- Must address: `(★★★)`
- Should address: `(★★☆)`
- Optional: `(★☆☆)`
- Disagree: `(☆☆☆)`

Format (follow exactly):

```
## 未解決のレビューコメント (N件)

---

### 1. 指摘のタイトル (`path/to/file:line`) (★★☆)

> 指摘事項の要約をここに記述する。何が指摘されているのかを簡潔にまとめる。

指摘に対してどう考えるか。対応するべきか、対応不要か、その理由を述べる。

対応する場合は対応方法の概要を簡潔に記述する。

**返信内容** (@reviewer_name へ、レビュワーの言語で):

> Reply content in the reviewer's language here.
> This should be the actual message you would post as a thread reply.

---

### 2. ...
```

Notes:
- Sort by severity (★★★ > ★★☆ > ★☆☆ > ☆☆☆)
- The opinion section should include your own judgment: agree/disagree with the reviewer, whether it's worth fixing, and why
- The 返信内容 section MUST be in the reviewer's language (detected from the original comment), NOT Japanese
- Do NOT offer to take any actions after displaying the report

## Begin

Execute the workflow above. Start from Step 1.
