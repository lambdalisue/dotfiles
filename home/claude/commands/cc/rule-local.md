---
allowed-tools: Read, Write, Glob, Bash(ls:*), Bash(mkdir:*), Bash(pwd:*)
argument-hint: [pattern] rule content...
description: Create a project-local Claude Code rule in .claude/rules
model: opus
---

## Arguments

`$ARGUMENTS` = `[{path-pattern}] {rule content...}`

Parse the arguments:

- **Path pattern**: Optional glob pattern - first token only, if it starts with `*` or contains `/` or `{`
- **Rule content**: Everything else (no quotes needed)

## Target Directory

`.claude/rules/` (relative to project root)

## Workflow

1. **Parse** - Extract rule content and optional path-pattern from arguments
2. **Locate** - Find project root (look for `.git`, `package.json`, `Cargo.toml`, `deno.json`, etc.)
3. **Analyze** - Determine appropriate category and filename based on rule content:
   - Categories: Based on project type or rule domain
   - Filename: kebab-case, descriptive, `.md` extension
4. **Draft** - Create the rule file content:
   - If path-pattern provided: Add frontmatter with `globs` field
   - Write clear, concise rule in Markdown format
5. **Confirm** - Show the proposed file path and content
6. **STOP** - Wait for user approval (use AskUserQuestion)
7. **Create** - Only after approval, create the rule file

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

**Input**: `/cc:rule-local Use project-specific error types`
**Output**: `{project-root}/.claude/rules/errors/project-error-types.md`

**Input**: `/cc:rule-local *.ts Run deno fmt before commit`
**Output**: `{project-root}/.claude/rules/deno/format-on-commit.md` with `globs: *.ts`

**Input**: `/cc:rule-local src/**/*.tsx Use functional components only`
**Output**: `{project-root}/.claude/rules/react/functional-components.md` with `globs: src/**/*.tsx`

## Begin

Parse `$ARGUMENTS`, locate project root, and create the appropriate rule file. Ask for user approval before writing.
