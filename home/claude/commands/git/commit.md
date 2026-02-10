---
description: Analyze working tree changes, plan logically minimal commits per hunk, and execute them
args: "[context]"
model: sonnet
---

## Arguments

- `context` (optional): Additional context for the commit messages (e.g., "Fix #123", "Performance improvement", "Refactor for clarity"). This context will be used to generate more accurate and meaningful commit messages for all planned commits.

## Language

- Task prompts to agents: **English**
- User-facing explanations, summaries, AskUserQuestion: **Japanese**
- Git artifacts (commit messages, branch names, PR titles/bodies): **preserve original language** from agent output

## Workflow

1. **Analyze** - Use the Task tool (`subagent_type: "git-commit"`) to analyze all working tree changes and create a commit plan.
   - If context argument is provided, include it in the prompt: "Analyze all working tree changes and create a commit plan. Additional context: {context}"
   - If no context is provided, simply: "Analyze all working tree changes and create a commit plan."
   - If the agent reports nothing to commit, inform the user and **STOP**.

2. **Approve** - Present the commit plan to the user exactly as returned by the agent. Use AskUserQuestion to ask for approval with options: "Approve", "Modify" (let user adjust the plan), "Cancel".

3. **Execute** - If approved, use the Task tool (`subagent_type: "git-commit"`) to execute the approved commit plan. Include the full approved plan in the prompt. Present the summary to the user.
