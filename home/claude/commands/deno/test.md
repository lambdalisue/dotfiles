---
allowed-tools: Bash(deno:*)
description: Run all tests for Deno project
model: haiku
---

## Workflow

1. **Test** - Run `deno test -A --shuffle --parallel`
2. **Summarize** - Report failures with context

## Begin

Run all tests. Summarize any failures found.
