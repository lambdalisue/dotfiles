---
allowed-tools: Read, Edit, Write, Glob, Grep
description: Sync documentation with implementation
model: sonnet
---

## Workflow

1. **Analyze** - Compare implementation with documentation
2. **Identify** - Find discrepancies between code and docs
3. **Decide** - Determine if implementation or documentation needs correction
4. **STOP** - If implementation seems wrong, ask user for clarification (use AskUserQuestion)
5. **Update** - After confirmation, fix documentation to match implementation

## Begin

Check for implementation-documentation drift. Update docs to match code.

**IMPORTANT**: If the implementation appears incorrect rather than the documentation, you MUST ask the user for clarification using AskUserQuestion before making changes. Never assume which is correct.
