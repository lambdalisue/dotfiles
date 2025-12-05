# Rust Implementation Rules

## Module Structure

**Use `{module}.rs` instead of `{module}/mod.rs`**

Forbidden: `foo/mod.rs`
Required: `foo.rs`

## Warnings

**`#[allow()]` is prohibited by default**

If absolutely necessary, explain the reason and obtain user permission first.
