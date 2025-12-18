---
allowed-tools: Bash(deno:*)
description: Run format, lint, and type check for Deno project
model: haiku
---

## Workflow

1. **Format** - Run `deno fmt` first (sequential)
2. **Check** - Run in parallel:
   - `deno lint`
   - `deno check --doc`
   - `deno check --doc-only **/*.md`
3. **Summarize** - Deduplicate and report issues

## Begin

Run format, then execute lint and type check in parallel. Summarize unique issues found.
