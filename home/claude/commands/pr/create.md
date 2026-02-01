---
description: Create a pull request with title and body based on commits
model: sonnet
---

## Language

- Task prompts to agents: **English**
- User-facing explanations, summaries, AskUserQuestion: **Japanese**
- Git artifacts (commit messages, branch names, PR titles/bodies): **preserve original language** from agent output

## Prerequisites

- The current branch MUST already be pushed to remote before this command is invoked
- **NEVER run `git push`** — this command assumes push is already done

## Workflow

1. **Analyze** - Use the Task tool (`subagent_type: "pr-create"`) to analyze commits and draft PR content. If the agent reports no changes or main branch issues, inform the user and **STOP**.

2. **Approve** - Present the PR draft to the user exactly as returned by the agent. Use AskUserQuestion to ask for approval with options: "Approve", "Edit" (let user modify), "Cancel".

3. **Create** - If approved, use the Task tool (`subagent_type: "pr-create"`) to create the PR with the approved content. The prompt MUST include: "The branch is already pushed. Do NOT run git push." Present the PR URL to the user.
