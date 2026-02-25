---
description: Summarize branch changes from base branch in 4 perspectives (Context, Changes, Impact, Open)
model: sonnet
---

## Language

- Task prompts to agents: **English**
- User-facing output: **user's conversation language**

## Tool Restrictions

**This command MUST only use the Task tool** (with `subagent_type: "git-describe"`).

**NEVER use Bash directly.** All git operations are delegated to the agent.

## Workflow

1. **Analyze** — Use the Task tool (`subagent_type: "git-describe"`) to analyze branch changes and produce a summary.
   - Prompt: "Analyze the current branch changes from the base branch and produce a 4-section summary."
   - If the agent reports no changes or main branch, inform the user and **STOP**.

2. **Present** — Display the agent's summary to the user exactly as returned.
