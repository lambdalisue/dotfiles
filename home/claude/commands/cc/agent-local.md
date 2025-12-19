---
allowed-tools: Read, Write, Glob, Bash(ls:*), Bash(mkdir:*), Bash(pwd:*)
argument-hint: name description...
description: Create a project-local Claude Code agent in .claude/agents
model: opus
---

## Arguments

`$ARGUMENTS` = `{name} {description...}`

Parse the arguments:

- **Name**: Agent name (first token) - will become the filename (kebab-case, without `.md`)
- **Description**: What the agent does (everything else)

## Target Directory

`.claude/agents/` (relative to project root)

## Workflow

1. **Parse** - Extract name and description from arguments
2. **Locate** - Find project root (look for `.git`, `package.json`, `Cargo.toml`, `deno.json`, etc.)
3. **Analyze** - Determine:
   - Agent's core purpose for this project
   - Appropriate model (sonnet for most, opus for complex reasoning)
   - Color for visual distinction
   - Project-specific principles and workflow
4. **Draft** - Create the agent file with:
   - Frontmatter: `name`, `description`, `model`, `color`
   - Brief persona/expertise statement
   - Principles (numbered list)
   - Prohibitions if applicable
   - Workflow steps
5. **Confirm** - Show the proposed file path and content
6. **STOP** - Wait for user approval (use AskUserQuestion)
7. **Create** - Only after approval, create the agent file

## Agent Format

```markdown
---
name: {name}
description: {Brief description ending with period}
model: {sonnet|opus}
color: {blue|green|yellow|red|purple|cyan}
---

{One-line persona/expertise statement}

## Principles

1. **Key Principle**: Explanation
2. ...

## Prohibitions

- **No X**: Reason

## Workflow

1. **Phase**: Actions
2. ...

## When Uncertain

{How to handle ambiguity}
```

## Available Colors

blue, green, yellow, red, purple, cyan, magenta, orange, white

## Examples

**Input**: `/cc:agent-local migrator Handle database migrations for this project`
**Output**: `{project-root}/.claude/agents/migrator.md`

**Input**: `/cc:agent-local e2e-tester Run and debug E2E tests`
**Output**: `{project-root}/.claude/agents/e2e-tester.md`

## Begin

Parse `$ARGUMENTS`, locate project root, and create the appropriate agent file. Ask for user approval before writing.
