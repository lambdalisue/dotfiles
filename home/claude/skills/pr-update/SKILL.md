---
name: pr-update
allowed-tools: Bash(git branch:*), Bash(git log:*), Bash(git diff:*), Bash(gh pr:*)
argument-hint: "[PR_NUMBER] Optional PR number to update"
description: Update the title and body of an existing pull request
---

## When to use

The user invoking `/pr-update` IS the explicit intent to update the PR — do NOT ask for approval.

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

**Line breaks**: Do NOT insert hard line breaks in the middle of a sentence or paragraph. Write each paragraph as a single continuous line and let the renderer wrap it. Only break between paragraphs (blank line), at list items, or at headings. Never hard-wrap to a fixed column width.

## Workflow

1. **Identify PR** - Determine target PR number:
   - If argument provided: use that PR number
   - Otherwise: run `gh pr view --json number --jq '.number'` to get PR for current branch
   - If no PR exists for the current branch, report it and **STOP immediately**.

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

5. **Draft Update** - Create updated title and body:
   ```
   Title: <concise summary>

   ## Summary
   - <bullet points of changes>

   ## Why
   <explanation of WHY these changes were made>

   ## Test Plan
   - [ ] <test items>
   ```

6. **Update** - Execute immediately, without asking for approval (the `/pr-update` invocation is the explicit permission). Pass the body via a HEREDOC to preserve formatting:
   ```bash
   gh pr edit <number> --title "<title>" --body "<body>"
   ```
   Present the PR URL to the user.

## Begin

Identify the target PR (from argument or current branch), fetch current title and body, analyze commits, draft updated content, and update the PR immediately. Do NOT ask for approval — the `/pr-update` invocation is the explicit permission.
