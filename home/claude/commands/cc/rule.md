---
allowed-tools: Read, Write, Glob, Bash(ls:*), Bash(mkdir:*)
argument-hint: [pattern] rule content...
description: Create a global Claude Code rule in ~/.claude/rules
model: opus
---

## Arguments

`$ARGUMENTS` = `[{path-pattern}] {rule content...}`

Parse the arguments:

- **Path pattern**: Optional glob pattern - first token only, if it starts with `*` or contains `/` or `{`
- **Rule content**: Everything else (no quotes needed)

## Target Directory

`~/.claude/rules/`

## Workflow

1. **Parse** - Extract rule content and optional path-pattern from arguments
2. **Analyze** - Determine appropriate category and filename based on rule content:
   - Categories: `tools/`, `git/`, `documents/`, `deno/`, `rust/`, `ts/`, or create new if needed
   - Filename: kebab-case, descriptive, `.md` extension
3. **Draft** - Create the rule file content:
   - If path-pattern provided: Add frontmatter with `globs` field
   - Write clear, concise rule in Markdown format
4. **Confirm** - Show the proposed file path and content
5. **STOP** - Wait for user approval (use AskUserQuestion)
6. **Create** - Only after approval, create the rule file

## Rule Format

### Without path-pattern

```markdown
# Rule Title

Rule content here.
```

### With path-pattern

```markdown
---
globs: { path-pattern }
---

# Rule Title

Rule content here.
```

## Examples

**Input**: `/cc:rule Use descriptive variable names`
**Output**: `~/.claude/rules/code/descriptive-variables.md`

**Input**: `/cc:rule *.py Always use type annotations`
**Output**: `~/.claude/rules/python/type-annotations.md` with `globs: *.py`

**Input**: `/cc:rule src/**/*.ts Use strict null checks`
**Output**: `~/.claude/rules/ts/strict-null-checks.md` with `globs: src/**/*.ts`

## Begin

Parse `$ARGUMENTS` and create the appropriate rule file. Ask for user approval before writing.
