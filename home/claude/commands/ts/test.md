---
allowed-tools: Bash(npx:*), Bash(npm:*)
description: Run all tests for TypeScript project
model: haiku
---

## Workflow

1. **Test** - Run `npx vitest run` (or `npm test` if vitest unavailable)
2. **Summarize** - Report failures with context

## Begin

Run all tests. Summarize any failures found.
