---
description: Rebase current branch onto the latest remote base branch
model: haiku
---

## Language

- Task prompts to agents: **English**
- User-facing explanations, summaries: **Japanese**

## Workflow

Use the Task tool (`subagent_type: "git-rebase"`) to fetch and rebase onto the remote base branch autonomously. Present the agent's result to the user in Japanese. If conflicts occur, inform the user and suggest `/git:resolve`.
