---
name: pr-review
allowed-tools: Bash(git branch:*), Bash(gh pr:*), Bash(gh api:*), Bash(gh repo:*), Bash(jq:*), Read, Glob, Grep, Edit, Write
argument-hint: "[PR_NUMBER] [--fix] [context]"
description: Fetch unresolved PR review comments and display analysis; --fix applies the findings, replies to the threads, and resolves them
---

## Arguments

- `PR_NUMBER` (optional): PR to review. Defaults to the PR of the current branch.
- `--fix` (optional flag): After the analysis, implement the findings, reply to
  every unresolved thread, and resolve it (see Step 4). Without it the skill is
  display-only. Same meaning as the bundled `/code-review --fix`.
- `context` (optional, `--fix` only): Guidance on which findings to address and
  how (e.g., "address 1 and 2, skip 3", "address all", "3 is wrong"). Overrides
  the severity-based default.
- Parse: strip `--fix`; a leading all-digit token is `PR_NUMBER`; the rest is
  `context`.

## Context

!`git branch --show-current`
!`gh repo view --json nameWithOwner --jq '.nameWithOwner'`
!`gh pr view --json number --jq '.number' 2>/dev/null || echo 'NO_PR'`

## Language

- All user-facing output is **Japanese**. The templates below are structural
  skeletons: render every sentence in Japanese, keeping the shape.
- Thread replies are written in the **reviewer's language**, detected from the
  original comment — never in Japanese by default.

## Principles

- If PR number is provided as argument, use that number
- If no argument, use the PR number from Context above
- Only show unresolved review comments (threads not marked as resolved)
- Without `--fix` this command is **display-only**. Do NOT modify files, reply to
  threads, resolve threads, or ask the user for actions
- **Same output shape as the bundled `/code-review`**: a findings list ranked most
  severe first, no headers, no severity markers. Here a finding is a reviewer's
  unresolved comment plus your verdict on it. See "Output shape".
- **Never commit or push**, even with `--fix`. Commits belong to the `/git-commit`
  family on explicit user request

## Output shape

This is the shape the bundled `/code-review` reports in. Every report from this
skill uses it, so a PR-comment review reads the same as a diff review.

```
N unresolved comments, most severe first. PR #{number}.

1. `path/to/file:line` — One sentence restating the reviewer's point. [correctness] @reviewer — agree
   Scenario: the concrete consequence the reviewer is pointing at, verified against the code.
   Fix: what to change.
   Reply: the message to post, in the reviewer's language.
2. `path/to/other.ts:88` — One sentence. [style] @reviewer — disagree
   Why: one sentence, verified against the code.
   Reply: …
```

- Categories are short kebab-case tags describing the comment's subject:
  `correctness`, `security`, `design`, `consistency`, `reuse`, `simplification`,
  `efficiency`, `test-coverage`, `style`, `question`. One per finding.
- The verdict after the reviewer's handle is exactly `agree`, `agree, minor`, or
  `disagree`, and it is yours: read the code before deciding. `agree, minor`
  means the point holds but is not worth a change on its own.
- Rank by severity of the underlying issue, not by comment order: security and
  correctness first, then design and consistency, then cleanups, then style and
  questions.
- With nothing unresolved, the whole report is one line: `No unresolved
  comments. PR #{number}.`
- After `--fix`, each finding is reported again with an outcome suffix (see Step 5).

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

Keep each thread's `id` — Step 4 needs it.

### Step 3: Analyze and display

Read the relevant source files for each comment to understand the full context before analyzing.

Report the unresolved comments in the "Output shape" above — one entry per
thread with `path:line`, a one-sentence restatement, a category tag, the
reviewer's handle, your verdict, the scenario or reason, the fix if any, and the
reply you would post. The reply MUST be in the reviewer's language, detected
from the original comment.

Without `--fix`, **STOP here**. Do NOT offer to take any actions after displaying the report.

### Step 4: Address the threads (`--fix` only)

**Decide** what to do with each finding. The user's `context` has the highest
priority:

- A finding the user says to address → address it regardless of your verdict
- A finding the user says to skip → skip it regardless of your verdict
- A finding the user says is wrong → skip it and reply explaining the disagreement

Without guidance, follow your verdicts: address `agree`; address `agree, minor`
only when trivially fixable; skip `disagree`.

**Implement** each finding to address: read the relevant source files, make the
change with Edit, and note what was changed. Leave everything uncommitted.

**Reply** to every unresolved thread — addressed and skipped alike — in the
reviewer's language, using the thread `id` from Step 2:

```bash
gh api graphql --input - << 'GQLEOF'
{"query":"mutation($body:String!){addPullRequestReviewThreadReply(input:{pullRequestReviewThreadId:\"THREAD_ID\",body:$body}){comment{id body}}}","variables":{"body":"MESSAGE"}}
GQLEOF
```

- Addressed: explain what was fixed and how
- Skipped (disagreed): politely explain why, with reasoning
- Skipped (trivial/optional): acknowledge the point and explain why it is deferred

**Resolve** each thread after replying:

```bash
gh api graphql -f query='mutation { resolveReviewThread(input: { threadId: "THREAD_ID" }) { thread { isResolved } } }'
```

### Step 5: Summary (`--fix` only)

Report the same list again, each entry carrying its outcome, the way the bundled
`/code-review` re-reports findings after fixing them:

```
Fixes applied, threads replied and resolved. PR #{number}.

1. `path/to/file:line` — One sentence. [correctness] @reviewer — agree → fixed
   What changed: one sentence.
2. `path/to/other.ts:88` — One sentence. [style] @reviewer — agree, minor → skipped
   Why: deferred; explained in the reply.
3. `path/to/third.ts:12` — One sentence. [design] @reviewer — disagree → no change needed
   Why: one sentence; explained in the reply.

Changed files: `path/to/file`. All N threads replied and resolved. Nothing was committed.
```

Outcomes are exactly `fixed`, `skipped`, or `no change needed`.

## Begin

Parse `$ARGUMENTS` and execute the workflow above. Start from Step 1.
