---
name: pr-update
disable-model-invocation: true
allowed-tools: Bash(jj log:*), Bash(jj diff:*), Bash(gh as:*)
argument-hint: "[PR_NUMBER] Optional PR number to update"
description: Update the title and body of an existing pull request
---

## When to use

The user invoking `/pr-update` IS the explicit intent to update the PR — do NOT ask for approval.

## Context

!`jj log --no-graph -r 'heads(::@ & bookmarks())' -T '"Bookmark: " ++ local_bookmarks.map(|b| b.name()).join(" ") ++ "\n"'`
!`gh as -q gh pr view "$(jj log --no-graph -r 'heads(::@ & bookmarks())' -T 'local_bookmarks.map(|b| b.name()).join(" ")')" --json number,title,body,baseRefName,headRefName --jq '"\(.number) \(.headRefName) -> \(.baseRefName)\nTitle: \(.title)\nBody:\n\(.body)"' 2>/dev/null || echo "No PR found for the current bookmark"`

## Principles

**Target PR**:
- If PR number is provided as argument, use that PR
- Otherwise, find the PR whose head is the nearest bookmark at or below `@` (`gh as -q gh pr view <bookmark>`) — a jj checkout has no current branch

**Language**: Match the language of the existing PR title and body. Default to English if unclear.

**Scope**: Use only the `<base>@origin..<bookmark>` range for analysis.

**Title**: Concise summary of all changes (imperative mood)

**Body**: Explain WHY these changes were made, not just WHAT changed. Preserve existing structure if the body already follows a consistent format.

**Line breaks**: Do NOT insert hard line breaks in the middle of a sentence or paragraph. Write each paragraph as a single continuous line and let the renderer wrap it. Only break between paragraphs (blank line), at list items, or at headings. Never hard-wrap to a fixed column width.

## Workflow

1. **Identify PR** - Determine target PR number:
   - If argument provided: use that PR number
   - Otherwise: run `gh as -q gh pr view <bookmark> --json number --jq '.number'`, where `<bookmark>` is the nearest bookmark at or below `@` (see Context)
   - If there is no bookmark or no PR for it, report it and **STOP immediately**.

2. **Fetch Current PR** - Get current title, body, and base branch:
   ```bash
   gh as -q gh pr view <number> --json title,body,baseRefName,headRefName
   ```

3. **Analyze Changes** - Review the changes and diffs on top of the base branch:
   ```bash
   jj log -r '<base>@origin..<bookmark>'
   jj diff --stat -r '<base>@origin..<bookmark>'
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

6. **Update** - Execute immediately, without asking for approval (the `/pr-update` invocation is the explicit permission). Write the body to a scratchpad file with the Write tool to preserve formatting:
   ```bash
   gh as -q gh pr edit <number> --title "<title>" --body-file <file>
   ```
   Present the PR URL to the user.

## Begin

Identify the target PR (from argument or current branch), fetch current title and body, analyze the changes, draft updated content, and update the PR immediately. Do NOT ask for approval — the `/pr-update` invocation is the explicit permission.
