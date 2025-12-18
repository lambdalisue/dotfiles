---
allowed-tools: Bash(npx:*), Bash(deno:*), Bash(ls:*), Bash(test:*)
description: Run format, lint, and spell check for documentation
model: haiku
---

## Workflow

1. **Detect** - Check if `deno.json` or `deno.jsonc` exists
2. **Format** - Run formatter (sequential):
   - Deno project: `deno fmt "**/*.md"`
   - Otherwise: `npx prettier --write "**/*.md"`
3. **Check** - Run in parallel:
   - `npx textlint "**/*.md"`
   - `npx cspell "**/*.md"`
4. **Summarize** - Deduplicate and report issues

## Begin

Detect project type, run appropriate formatter, then execute checks in parallel. Summarize unique issues found.
