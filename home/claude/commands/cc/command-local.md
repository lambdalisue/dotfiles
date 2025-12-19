---
allowed-tools: Read, Write, Glob, Bash(ls:*), Bash(mkdir:*), Bash(pwd:*)
argument-hint: name description...
description: Create a project-local Claude Code slash command in .claude/commands
model: opus
---

## Arguments

`$ARGUMENTS` = `{name} {description...}`

Parse the arguments:

- **Name**: Command name (first token) - will become the filename (without `.md`)
- **Description**: What the command should do (everything else)

## Target Directory

`.claude/commands/` (relative to project root)

## Workflow

1. **Parse** - Extract name and description from arguments
2. **Locate** - Find project root (look for `.git`, `package.json`, `Cargo.toml`, `deno.json`, etc.)
3. **Analyze** - Determine:
   - Category subdirectory if applicable
   - Appropriate `allowed-tools` based on description
   - Appropriate `model` (haiku for simple, sonnet for moderate, opus for complex)
4. **Draft** - Create the command file with:
   - Frontmatter: `allowed-tools`, `argument-hint` (if needed), `description`, `model`
   - Clear workflow steps
   - Examples if helpful
5. **Confirm** - Show the proposed file path and content
6. **STOP** - Wait for user approval (use AskUserQuestion)
7. **Create** - Only after approval, create the command file

## Command Format

```markdown
---
allowed-tools: {tools}
argument-hint: {hint if needed}
description: {brief description}
model: {haiku|sonnet|opus}
---

## Workflow

1. **Step** - Description
2. ...

## Begin

{Instructions to start}
```

## Examples

**Input**: `/cc:command-local deploy Deploy this project to staging`
**Output**: `{project-root}/.claude/commands/deploy.md`

**Input**: `/cc:command-local db/migrate Run database migrations`
**Output**: `{project-root}/.claude/commands/db/migrate.md`

## Begin

Parse `$ARGUMENTS`, locate project root, and create the appropriate command file. Ask for user approval before writing.
