---
name: git-commit-staged-now
description: Create a Conventional Commit from already staged changes WITHOUT asking for approval
argument-hint: "[context]"
---

## Arguments

- `context` (optional): Additional context for the commit message (e.g., "Fix #123", "Performance improvement", "Refactor for clarity"). This context will be used to generate a more accurate and meaningful commit message.

## When to use

This is the non-interactive variant of `/git-commit-staged`. The user invoking `/git-commit-staged-now` IS the explicit intent to commit — do NOT ask for approval. Use the interactive `/git-commit-staged` when the user wants to review the message first.

## Language

- Task prompts to agents: **English**
- User-facing explanations, summaries: **Japanese**
- Git artifacts (commit messages, branch names, PR titles/bodies): **preserve original language** from agent output

## Workflow

1. **Pre-check** - BEFORE calling the agent, verify staging status:
   ```bash
   git diff --cached --quiet && echo "NOTHING_STAGED" || echo "HAS_STAGED_CHANGES"
   ```
   If output is "NOTHING_STAGED", inform the user: "ステージングされた変更がありません。先に `git add <file>` でファイルをステージングしてください。" and **STOP**. Do NOT proceed to the agent.

2. **Analyze** - Use the Task tool (`subagent_type: "git-commit-staged"`) to analyze staged changes and draft a commit message.
   - If context argument is provided, include it in the prompt: "Analyze the staged changes and draft a commit message. Additional context: {context}"
   - If no context is provided, simply: "Analyze the staged changes and draft a commit message."
   - The agent returns a draft message only — it does NOT execute the commit.
   - If the agent reports nothing is staged (this should NOT happen after pre-check), inform the user and **STOP**.

3. **Execute** - Execute `git commit` **directly via the Bash tool** (do NOT delegate to the agent for execution). Do NOT ask for approval — the `/git-commit-staged-now` invocation is the explicit permission.

   Procedure:
   1. Verify staging is still intact: `git diff --cached --stat`
   2. Run `git commit -m "<drafted message>"` (use a heredoc for multi-line messages). NEVER use `-a` / `--all`.
   3. Report `git log --oneline -1` to the user.

   If the commit fails (e.g., pre-commit hook), stop and report — do NOT improvise around the failure.
