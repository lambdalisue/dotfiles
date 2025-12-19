---
allowed-tools: Read, Write, Glob, Bash(ls:*), Bash(mkdir:*)
argument-hint: name description...
description: Create a global Claude Code slash command in ~/.claude/commands
model: opus
---

## Arguments

`$ARGUMENTS` = `{name} {description...}`

Parse the arguments:

- **Name**: Command name (first token) - will become the filename (without `.md`)
- **Description**: What the command should do (everything else)

## Target Directory

`~/.claude/commands/`

## Workflow

1. **Parse** - Extract name and description from arguments
2. **Analyze** - Determine:
   - Category subdirectory if applicable (e.g., `git/`, `deno/`)
   - Appropriate `allowed-tools` based on description
   - Appropriate `model` (haiku for simple, sonnet for moderate, opus for complex)
3. **Draft** - Create the command file with:
   - Frontmatter: `allowed-tools`, `argument-hint` (if needed), `description`, `model`
   - Clear workflow steps
   - Examples if helpful
4. **Confirm** - Show the proposed file path and content
5. **STOP** - Wait for user approval (use AskUserQuestion)
6. **Create** - Only after approval, create the command file

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

**Input**: `/cc:command test-runner Run project tests and report failures`
**Output**: `~/.claude/commands/test-runner.md`

**Input**: `/cc:command git/sync Sync current branch with remote`
**Output**: `~/.claude/commands/git/sync.md`

## Begin

Parse `$ARGUMENTS` and create the appropriate command file. Ask for user approval before writing.
