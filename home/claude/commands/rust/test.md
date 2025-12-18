---
allowed-tools: Bash(cargo:*)
description: Run all tests for Rust workspace
model: haiku
---

## Workflow

1. **Test** - Run in parallel:
   - `cargo test --workspace`
   - `cargo test --workspace --doc`
2. **Summarize** - Report failures with context

## Begin

Run all tests in parallel. Summarize any failures found.
