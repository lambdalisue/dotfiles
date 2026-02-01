---
paths: "**/*.rs"
---
# Clippy and Warnings

**Trust clippy unconditionally.**

- Run `cargo clippy --all-targets --all-features` before committing
- Fix all warnings immediately — no exceptions
- Never suppress warnings (`#[allow(dead_code)]` etc.) without excellent justification
- Remove unused code instead of suppressing warnings
