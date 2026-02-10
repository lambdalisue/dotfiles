---
description: Create a Conventional Commit from already staged changes
args: "[context]"
model: sonnet
---

## Arguments

- `context` (optional): Additional context for the commit message (e.g., "Fix #123", "Performance improvement", "Refactor for clarity"). This context will be used to generate a more accurate and meaningful commit message.

## Language

- Task prompts to agents: **English**
- User-facing explanations, summaries, AskUserQuestion: **Japanese**
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
   - If the agent reports nothing is staged (this should NOT happen after pre-check), inform the user and **STOP**.

3. **Approve** - Present the proposed commit message to the user exactly as returned by the agent. Use AskUserQuestion to ask for approval with options: "Approve", "Edit" (let user modify the message), "Cancel".

4. **Execute** - If approved, use the Task tool (`subagent_type: "git-commit-staged"`) to execute the commit with the approved (or edited) message. Present the result to the user.
