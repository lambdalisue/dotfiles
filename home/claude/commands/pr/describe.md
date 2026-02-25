---
description: Summarize current PR changes with PR metadata (title, body, comments, linked issues) in 4 perspectives (Context, Changes, Impact, Open)
model: sonnet
---

## Language

- Task prompts to agents: **English**
- User-facing output: **user's conversation language**

## Tool Restrictions

**This command MUST only use the Task tool** (with `subagent_type: "pr-describe"`).

**NEVER use Bash directly.** All git/gh operations are delegated to the agent.

## Workflow

1. **Analyze** — Use the Task tool (`subagent_type: "pr-describe"`) to analyze the current PR and produce a summary.
   - Prompt: "Analyze the current PR with its metadata (title, body, comments, linked issues) and produce a 4-section summary."
   - If the agent reports no PR found, inform the user and **STOP**.

2. **Present** — Display the agent's summary to the user exactly as returned.
