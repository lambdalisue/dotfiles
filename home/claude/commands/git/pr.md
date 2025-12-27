---
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Bash(git remote:*), Bash(gh pr:*)
description: Create a pull request with title and body based on commits
model: sonnet
---

## Context

!`git branch --show-current`
!`git log --oneline origin/main..HEAD`
!`git diff --stat origin/main..HEAD`

## Principles

**Language**: Detect from recent commit messages. Default to English if unclear.

**Scope**: Use only `origin/main..HEAD` diff unless explicitly specified otherwise.

**Title**: Concise summary of all changes (imperative mood)

**Body**: Explain WHY these changes were made, not just WHAT changed.

## Workflow

First, create a new branch if the current branch is `main`.

1. **Analyze** - Review commits and diffs from `origin/main`
2. **Detect Language** - Check commit message language, default to English
3. **Check Remote** - Verify if current branch is pushed to remote
4. **Draft** - Create PR title and body summarizing the WHY
5. **Confirm** - Display draft title and body in a fenced code block:
   ```
   Title: <concise summary>

   ## Summary
   - <bullet points of changes>

   ## Why
   <explanation of WHY these changes were made>

   ## Test Plan
   - [ ] <test items>
   ```
6. **STOP** - Wait for user approval before creating PR (use AskUserQuestion)
7. **Push Notice** - If branch is not pushed or not up-to-date, instruct user to push manually
8. **Create** - Only after user confirms push is complete, use `gh pr create` with approved content

## Example

```
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

Analyze commits from `origin/main`, detect language, and draft PR content for user approval.

**IMPORTANT**:
1. After drafting the PR content, you MUST ask the user for approval using AskUserQuestion before creating the PR
2. Never push to remote - always instruct the user to run `git push` manually
3. Only execute `gh pr create` after confirming the user has pushed the branch
