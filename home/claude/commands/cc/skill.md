---
allowed-tools: Read, Write, Glob, Bash(ls:*), Bash(mkdir:*)
argument-hint: name description...
description: Create a global Claude Code skill in ~/.claude/skills
model: opus
---

## Arguments

`$ARGUMENTS` = `{name} {description...}`

Parse the arguments:

- **Name**: Skill name (first token) - will become the directory name
- **Description**: What the skill provides (everything else)

## Target Directory

`~/.claude/skills/{name}/SKILL.md`

## Workflow

1. **Parse** - Extract name and description from arguments
2. **Analyze** - Determine:
   - Core conventions and patterns to include
   - Key practices and anti-patterns
   - Testing approach if applicable
3. **Draft** - Create the skill file with:
   - Frontmatter: `name`, `description`
   - Concise, actionable conventions
   - Code examples where helpful
4. **Confirm** - Show the proposed file path and content
5. **STOP** - Wait for user approval (use AskUserQuestion)
6. **Create** - Only after approval, create the skill directory and SKILL.md

## Skill Format

```markdown
---
name: {name}
description: {Brief description ending with period}
---

## Conventions

- **Key Area**: Guidance
- ...

## Patterns

{Code examples if applicable}

## Anti-patterns

- Avoid X because Y
```

## Examples

**Input**: `/cc:skill python Python idioms and best practices`
**Output**: `~/.claude/skills/python/SKILL.md`

**Input**: `/cc:skill react React component patterns and hooks`
**Output**: `~/.claude/skills/react/SKILL.md`

## Begin

Parse `$ARGUMENTS` and create the appropriate skill file. Ask for user approval before writing.
