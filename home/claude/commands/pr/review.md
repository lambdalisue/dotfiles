---
allowed-tools: Bash(git branch:*), Bash(gh pr:*), Bash(gh api:*), Bash(jq:*), Read, Edit, Glob, Grep, AskUserQuestion
argument-hint: [PR_NUMBER] Optional PR number to review
description: Fetch unresolved PR review comments and help address them
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
- Summarize comments in Japanese for the user
- Reply to reviewers in THEIR language (detect from original comment)
- When addressing a comment, first post a reply, then implement the fix

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

### Step 3: Summarize in Japanese

Display unresolved comments as numbered list.

Priority is shown as exactly 3 characters using filled and empty stars:

- Must address: `[★★★]`
- Should address: `[★★☆]`
- Optional: `[★☆☆]`
- Disagree: `[☆☆☆]`

Format (follow exactly):

```
## 未解決のレビューコメント (N件)

### 1. [path:line] (@author) [★★☆]
summary in Japanese
→ 理由: reason

### 2. ...
```

### Step 4: Ask user

Use AskUserQuestion with options: "All", "Select", "None"

### Step 5: Address selected comments

For each selected comment:

a. Plan the fix approach

b. Reply to the thread. Build the JSON by replacing THREAD_ID and MESSAGE with actual values:

```bash
gh api graphql --input - << 'GQLEOF'
{"query":"mutation($body:String!){addPullRequestReviewThreadReply(input:{pullRequestReviewThreadId:\"THREAD_ID\",body:$body}){comment{id body}}}","variables":{"body":"MESSAGE"}}
GQLEOF
```

c. Implement the code changes

d. Resolve the thread. Replace THREAD_ID with the actual thread node ID:

```bash
gh api graphql -f query='mutation { resolveReviewThread(input: { threadId: "THREAD_ID" }) { thread { isResolved } } }'
```

### Step 6: Summary

Show all changes made and resolved threads.

**IMPORTANT: Do NOT commit or push.** This skill only implements code changes and resolves threads. Committing and pushing are the user's responsibility.

## Begin

Execute the workflow above. Start from Step 1.
