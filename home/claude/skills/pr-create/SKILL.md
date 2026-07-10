---
name: pr-create
disable-model-invocation: true
allowed-tools: Bash(git branch:*), Bash(git log:*), Bash(git diff:*), Bash(git ls-remote:*), Bash(gh pr:*)
description: Create a pull request with title and body based on commits
---

## When to use

The user invoking `/pr-create` IS the explicit intent to create the PR — do NOT ask for approval.

**Self-contained**: this skill reads git and runs `gh pr create` directly from
the top-level session. Do NOT spawn a subagent.

## Safety

**ABSOLUTELY NEVER run `git push` or any git write command — not directly, not
through Bash, not under any circumstances.** The branch is expected to be
already pushed. NEVER use `gh pr create --push`.

## Knowledge

- **Scope**: analyze only the `origin/<base>..HEAD` diff.
- **Title**: concise, imperative mood.
- **Body**: explain WHY, not just WHAT. Detect language from the commit messages (default English).
- **Line breaks**: do NOT hard-wrap. Write each paragraph as a single continuous line and let the renderer wrap it; break only between paragraphs, list items, or headings.

## Language

- User-facing explanations, summaries: **Japanese**
- Git artifacts (PR title/body): **preserve original language** (repo's existing language)

## Workflow

1. **Analyze** (read-only):
   1. `git branch --show-current`, `git log --oneline origin/<base>..HEAD`, `git diff --stat origin/<base>..HEAD`.
   2. If on the base branch with no divergence (no commits), inform the user in Japanese and **STOP**.
   3. Detect language from the commits and draft the PR title and body:
      ```
      Title: <concise summary>

      ## Summary
      - <bullet points>

      ## Why
      <explanation of WHY>

      ## Test Plan
      - [ ] <items>
      ```

2. **Verify remote branch** - `git ls-remote --exit-code origin refs/heads/<branch>`.
   - If the branch is NOT on the remote, inform the user in Japanese that the branch must be pushed first and **STOP immediately**. Do NOT push, do NOT suggest push workarounds.

3. **Create** - Run `gh pr create` directly with the drafted title and body (pass the body via a HEREDOC to preserve formatting). Do NOT ask for approval — the `/pr-create` invocation is the explicit permission. NEVER pass `--push`. Present the PR URL to the user.
