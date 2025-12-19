---
allowed-tools: Read, Write, Glob, Bash(ls:*), Bash(mkdir:*), Bash(pwd:*)
argument-hint: name description...
description: Create a project-local Claude Code skill in .claude/skills
model: opus
---

## Arguments

`$ARGUMENTS` = `{name} {description...}`

Parse the arguments:

- **Name**: Skill name (first token) - will become the directory name
- **Description**: What the skill provides (everything else)

## Target Directory

`.claude/skills/{name}/SKILL.md` (relative to project root)

## Workflow

1. **Parse** - Extract name and description from arguments
2. **Locate** - Find project root (look for `.git`, `package.json`, `Cargo.toml`, `deno.json`, etc.)
3. **Analyze** - Determine:
   - Project-specific conventions and patterns
   - Key practices unique to this codebase
   - Testing approach if applicable
4. **Draft** - Create the skill file with:
   - Frontmatter: `name`, `description`
   - Concise, actionable conventions
   - Code examples where helpful
5. **Confirm** - Show the proposed file path and content
6. **STOP** - Wait for user approval (use AskUserQuestion)
7. **Create** - Only after approval, create the skill directory and SKILL.md

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

**Input**: `/cc:skill-local api Project API conventions and patterns`
**Output**: `{project-root}/.claude/skills/api/SKILL.md`

**Input**: `/cc:skill-local testing Testing patterns for this project`
**Output**: `{project-root}/.claude/skills/testing/SKILL.md`

## Begin

Parse `$ARGUMENTS`, locate project root, and create the appropriate skill file. Ask for user approval before writing.
