---
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Bash(git remote:*), Bash(gh pr:*)
description: Create a pull request with title and body based on commits
model: haiku
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

1. **Analyze** - Review commits and diffs from `origin/main`
2. **Detect Language** - Check commit message language, default to English
3. **Draft** - Create PR title and body summarizing the WHY
4. **Confirm** - Show draft to user
5. **STOP** - Wait for user approval before creating PR (use AskUserQuestion)
6. **Create** - Only after approval, use `gh pr create` with approved content

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

**IMPORTANT**: After drafting the PR content, you MUST ask the user for approval using AskUserQuestion before executing `gh pr create`. Never create a PR without explicit user confirmation.
