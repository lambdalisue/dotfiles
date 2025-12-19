---
allowed-tools: Read, Write, Glob, Bash(ls:*), Bash(mkdir:*)
argument-hint: name description...
description: Create a global Claude Code agent in ~/.claude/agents
model: opus
---

## Arguments

`$ARGUMENTS` = `{name} {description...}`

Parse the arguments:

- **Name**: Agent name (first token) - will become the filename (kebab-case, without `.md`)
- **Description**: What the agent does (everything else)

## Target Directory

`~/.claude/agents/`

## Workflow

1. **Parse** - Extract name and description from arguments
2. **Analyze** - Determine:
   - Agent's core purpose and expertise
   - Appropriate model (sonnet for most, opus for complex reasoning)
   - Color for visual distinction
   - Key principles and workflow
3. **Draft** - Create the agent file with:
   - Frontmatter: `name`, `description`, `model`, `color`
   - Brief persona/expertise statement
   - Principles (numbered list)
   - Prohibitions if applicable
   - Workflow steps
4. **Confirm** - Show the proposed file path and content
5. **STOP** - Wait for user approval (use AskUserQuestion)
6. **Create** - Only after approval, create the agent file

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

**Input**: `/cc:agent api-designer Design RESTful APIs following best practices`
**Output**: `~/.claude/agents/api-designer.md`

**Input**: `/cc:agent security-reviewer Review code for security vulnerabilities`
**Output**: `~/.claude/agents/security-reviewer.md`

## Begin

Parse `$ARGUMENTS` and create the appropriate agent file. Ask for user approval before writing.
