---
description: Create a Conventional Commit from already staged changes
model: sonnet
---

## Language

- Task prompts to agents: **English**
- User-facing explanations, summaries, AskUserQuestion: **Japanese**
- Git artifacts (commit messages, branch names, PR titles/bodies): **preserve original language** from agent output

## Workflow

1. **Analyze** - Use the Task tool (`subagent_type: "git-commit"`) to analyze staged changes and draft a commit message. If the agent reports nothing is staged, inform the user and **STOP**.

2. **Approve** - Present the proposed commit message to the user exactly as returned by the agent. Use AskUserQuestion to ask for approval with options: "Approve", "Edit" (let user modify the message), "Cancel".

3. **Execute** - If approved, use the Task tool (`subagent_type: "git-commit"`) to execute the commit with the approved (or edited) message. Present the result to the user.
