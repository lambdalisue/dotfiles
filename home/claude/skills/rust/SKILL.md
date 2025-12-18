---
name: rust
description: Rust idiomatic patterns and conventions.
---

## Conventions

- **Ownership**: Minimize cloning, prefer borrowing
- **Traits**: Derive `Debug`, `Clone`, `PartialEq` where appropriate
- **Style**: Iterators over loops, effective pattern matching

## Testing

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn behavior_description() {
        // AAA pattern
    }
}
```
