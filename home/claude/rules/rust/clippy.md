---
paths: "**/*.rs"
---

# Clippy

## Absolute Rule

**Trust clippy unconditionally.**

- Always run `cargo clippy --all-targets --all-features` before committing
- Fix all clippy warnings immediately — no exceptions
- If clippy suggests a change, apply it without questioning
- Clippy knows better than you about Rust idioms and best practices

## Workflow

1. Write code
2. Run clippy
3. Fix all warnings
4. Repeat until clean

Never argue with clippy. Never suppress warnings without excellent justification (and document why).
