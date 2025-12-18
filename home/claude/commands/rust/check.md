---
allowed-tools: Bash(cargo:*)
description: Run format, check, clippy, and tests for Rust workspace
model: haiku
---

## Workflow

1. **Format** - Run `cargo fmt` first (sequential)
2. **Check** - Run all checks in parallel:
   - `cargo check --workspace --all-features --all-targets`
   - `cargo clippy --workspace --all-features --all-targets -- -D warnings`
3. **Summarize** - Deduplicate and report issues

## Begin

Run format, then execute all checks in parallel. Summarize unique issues found.
