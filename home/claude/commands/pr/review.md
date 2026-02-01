---
allowed-tools: Bash(git branch:*), Bash(gh pr:*), Bash(gh api:*), Read, Edit, Glob, Grep, AskUserQuestion
argument-hint: [PR_NUMBER] Optional PR number to review
description: Fetch unresolved PR review comments and help address them
model: sonnet
---

## Context

!`git branch --show-current`
!`gh repo view --json nameWithOwner --jq '.nameWithOwner'`

## Principles

**Target PR Resolution**:
- If PR number is provided as argument, use that PR
- Otherwise, find PR associated with current branch via `gh pr view`

**Comment Filtering**: Only show unresolved review comments (threads not marked as resolved)

**Response Language**:
- Summarize comments in Japanese for the user
- Reply to reviewers in THEIR language (detect from original comment: English → English, Japanese → Japanese)

**Review Comment Reply**: When addressing a comment, first post a reply describing the approach in the reviewer's language, then implement the fix

## Workflow

1. **Identify PR** - Determine target PR number:
   - If argument provided: use that PR number
   - Otherwise: run `gh pr view --json number --jq '.number'` to get PR for current branch

2. **Fetch Repository Info** - Get owner/repo from `gh repo view --json nameWithOwner`

3. **Fetch Review Threads** - Use GraphQL to get review threads with resolved status:
   ```bash
   gh api graphql -f query='
     query($owner: String!, $repo: String!, $pr: Int!) {
       repository(owner: $owner, name: $repo) {
         pullRequest(number: $pr) {
           reviewThreads(first: 100) {
             nodes {
               id
               isResolved
               comments(first: 10) {
                 nodes {
                   id
                   body
                   author { login }
                   path
                   line
                   startLine
                   diffHunk
                 }
               }
             }
           }
         }
       }
     }
   ' -f owner=OWNER -f repo=REPO -F pr=NUMBER
   ```

4. **Filter Unresolved** - Extract only threads where `isResolved: false`

5. **Summarize in Japanese** - Display unresolved comments with:
   - Numbered list (1, 2, 3...)
   - File path and line number
   - Comment author
   - Brief Japanese summary of the feedback (no original text needed)

   Format:
   ```
   ## 未解決のレビューコメント (N件)

   ### 1. [ファイルパス:行番号] (@author)
   <Japanese summary of the comment>

   ### 2. ...
   ```

6. **STOP** - Ask user which comments to address using AskUserQuestion:
   - Option: "All" - Address all comments
   - Option: "Select" - Let user specify numbers (e.g., "1, 3, 5")
   - Option: "None" - Cancel

7. **For Each Selected Comment**:
   a. **Plan** - Analyze the feedback and determine the fix approach
   b. **Detect Language** - Check if original comment is in English, Japanese, or other language
   c. **Reply** - Post a review thread reply in the SAME language as the original comment using GraphQL:
      ```bash
      gh api graphql -f query='
        mutation($threadId: ID!, $body: String!) {
          addPullRequestReviewThreadReply(input: {
            pullRequestReviewThreadId: $threadId
            body: $body
          }) {
            comment { id body }
          }
        }
      ' -f threadId="THREAD_NODE_ID" -f body="Will fix: <approach description>"
      ```
   d. **Implement** - Make the necessary code changes
   e. **Confirm** - Show the changes made
   f. **Resolve** - Mark the review thread as resolved using GraphQL:
      ```bash
      gh api graphql -f query='
        mutation($threadId: ID!) {
          resolveReviewThread(input: { threadId: $threadId }) {
            thread { isResolved }
          }
        }
      ' -f threadId="THREAD_NODE_ID"
      ```

8. **Summary** - After addressing all selected comments, show summary of changes made and resolved threads

## Example Output

```
## 未解決のレビューコメント (3件)

### 1. [src/utils.ts:42] (@reviewer1)
エラーハンドリングが不足している。try-catchで囲むべき

### 2. [src/api.ts:15] (@reviewer2)
型定義が any になっている。適切な型を指定すべき

### 3. [tests/utils.test.ts:28] (@reviewer1)
エッジケースのテストが不足している
```

## Begin

Identify the target PR (from argument or current branch), fetch unresolved review comments, and present them in Japanese.

**IMPORTANT**:
1. Always use GraphQL API to properly detect resolved/unresolved status
2. Post a reply comment BEFORE making code changes to communicate intent
3. Match the reply language to the reviewer's original comment language
4. Ask user confirmation via AskUserQuestion before addressing comments
5. After implementing and confirming each fix, resolve the thread using the `resolveReviewThread` GraphQL mutation with the thread's node ID (fetched in step 3)
