---
allowed-tools: Bash(npx:*), Bash(npm:*)
description: Run format, lint, and type check for TypeScript project
model: haiku
---

## Workflow

1. **Format** - Run `npx prettier --write .` first (sequential)
2. **Check** - Run in parallel:
   - `npx eslint .`
   - `npx tsc --noEmit`
3. **Summarize** - Deduplicate and report issues

## Begin

Run format, then execute lint and type check in parallel. Summarize unique issues found.
