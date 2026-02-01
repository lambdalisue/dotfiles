---
allowed-tools: Bash(git branch:*), Bash(git log:*), Bash(git diff:*), Bash(gh pr:*), AskUserQuestion
argument-hint: [PR_NUMBER] Optional PR number to update
description: Update the title and body of an existing pull request
model: sonnet
---

## Context

!`git branch --show-current`
!`gh pr view --json number,title,body,baseRefName,headRefName --jq '"\(.number) \(.headRefName) -> \(.baseRefName)\nTitle: \(.title)\nBody:\n\(.body)"' 2>/dev/null || echo "No PR found for current branch"`

## Principles

**Target PR**:
- If PR number is provided as argument, use that PR
- Otherwise, find PR associated with current branch via `gh pr view`

**Language**: Match the language of the existing PR title and body. Default to English if unclear.

**Scope**: Use only `origin/<base>..HEAD` diff for analysis.

**Title**: Concise summary of all changes (imperative mood)

**Body**: Explain WHY these changes were made, not just WHAT changed. Preserve existing structure if the body already follows a consistent format.

## Workflow

1. **Identify PR** - Determine target PR number:
   - If argument provided: use that PR number
   - Otherwise: run `gh pr view --json number --jq '.number'` to get PR for current branch

2. **Fetch Current PR** - Get current title, body, and base branch:
   ```bash
   gh pr view <number> --json title,body,baseRefName,headRefName
   ```

3. **Analyze Changes** - Review commits and diffs from base branch:
   ```bash
   git log --oneline origin/<base>..HEAD
   git diff --stat origin/<base>..HEAD
   ```

4. **Detect Language** - Check the language of the existing PR title/body

5. **Draft Update** - Create updated title and body, displayed in a fenced code block:
   ```
   Title: <concise summary>

   ## Summary
   - <bullet points of changes>

   ## Why
   <explanation of WHY these changes were made>

   ## Test Plan
   - [ ] <test items>
   ```

6. **Show Diff** - Clearly show what changed from the current PR:
   - Current title → New title
   - Summarize body changes

7. **STOP** - Wait for user approval before updating (use AskUserQuestion)

8. **Update** - Only after user confirms, execute:
   ```bash
   gh pr edit <number> --title "<title>" --body "<body>"
   ```

## Example Output

```
### Current
Title: Add new feature

### Proposed
Title: Add OAuth2 support for GitHub login

## Summary
- Add GitHub OAuth2 authentication flow
- Store tokens securely with encryption

## Why
Users requested GitHub login to avoid creating separate accounts.
OAuth2 chosen over OAuth1 for simpler flow and short-lived tokens.

## Test Plan
- [ ] Test login flow with valid GitHub account
- [ ] Verify token refresh works correctly
```

## Begin

Identify the target PR (from argument or current branch), fetch current title and body, analyze commits, and draft updated content for user approval.

**IMPORTANT**:
1. After drafting the updated PR content, you MUST ask the user for approval using AskUserQuestion before updating the PR
2. Show clearly what will change (current vs proposed)
3. Pass the body via a HEREDOC to `gh pr edit` to preserve formatting
