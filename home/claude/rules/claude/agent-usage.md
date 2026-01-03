# Proactive Agent Usage

**ALWAYS prefer using the Task tool with specialized agents for complex operations.**

## When to Use Agents

Use the Task tool with the appropriate `subagent_type` in these scenarios:

### Exploration & Research (`Explore`)

- Understanding codebase structure or architecture
- Finding files by patterns or searching for keywords
- Answering "where is X?" or "how does Y work?" questions
- Any open-ended search that may require multiple rounds of globbing/grepping

**Example triggers**: "どこに...がある?", "...の仕組みを調べて", "コードベースを理解して"

### Planning (`Plan`)

- Designing implementation strategies before coding
- Identifying critical files and architectural trade-offs
- Complex multi-step tasks requiring careful thought

**Example triggers**: "...を実装する計画を立てて", "どうやって...を作るか考えて"

### Code Writing (`code-writer`)

- Writing, modifying, or refactoring significant code
- Following existing patterns and T-Wada style testing
- Implementing features that touch multiple files

### Code Review (`multi-perspective-code-reviewer`)

- After completing significant code changes
- Before committing important features
- Security, performance, and maintainability analysis

### General Purpose (`general-purpose`)

- Complex multi-step tasks requiring autonomy
- Tasks that don't fit other specialized agent types
- Research requiring web search and code exploration combined

## Parallel Agent Execution

**Launch multiple agents concurrently whenever possible:**

- When multiple independent investigations are needed, spawn multiple `Explore` agents in parallel
- When reviewing code AND planning next steps, run both agents simultaneously
- Use `run_in_background: true` for agents that can work while you continue

## Decision Guidelines

| Task Complexity | Approach |
|-----------------|----------|
| Simple file read/edit | Use Read/Edit tools directly |
| Search for specific class/function | Use Glob/Grep directly |
| Multi-file exploration | Use Explore agent |
| Implementation planning | Use Plan agent |
| Writing significant code | Use code-writer agent |
| Post-implementation review | Use code-reviewer agent |

## Priority Order

1. **Check if a Skill exists** for the task first
2. **Use specialized agents** for complex tasks
3. **Fall back to direct tool usage** only for simple, targeted operations

The goal is to maximize efficiency and thoroughness by delegating complex work to specialized agents.
