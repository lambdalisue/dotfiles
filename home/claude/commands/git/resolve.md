---
description: Analyze and logically resolve git merge/rebase conflicts
model: sonnet
---

## Language

- Task prompts to agents: **English**
- User-facing explanations, summaries, AskUserQuestion: **Japanese**
- Git artifacts (commit messages, branch names, PR titles/bodies): **preserve original language** from agent output

## Workflow

1. **Analyze** - Use the Task tool (`subagent_type: "git-resolve"`) to analyze conflicts and create a resolution plan. If the agent reports no conflicts, inform the user and **STOP**.

2. **Approve** - Present the resolution plan to the user exactly as returned by the agent. Use AskUserQuestion to ask for approval with options: "Approve all", "Select" (let user choose which to apply), "Cancel".

3. **Execute** - If approved, use the Task tool (`subagent_type: "git-resolve"`) to execute the approved resolutions. Include which resolutions were approved in the prompt. Present the summary to the user (files resolved, no commit made).
