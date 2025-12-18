---
allowed-tools: Bash(cargo:*), Read, Edit, Write, Glob, Grep
description: Run check and test, fix issues until all green
model: sonnet
---

## Workflow

1. **Check** - Run `/rust:check`
2. **Test** - Run `/rust:test`
3. **Fix** - If issues found, fix them. Ask user when unclear.
4. **Repeat** - Loop until all green

## Begin

Run check and test. Fix issues iteratively until all pass. Ask user for clarification when needed.
