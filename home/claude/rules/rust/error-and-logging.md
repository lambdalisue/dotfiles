---
paths: "**/*.rs"
---

# Error Handling and Logging — Rust

Severity policy (when to use warn/error/debug/info, library vs application) is
shared: see `rules/code/error-and-logging.md`. This rule covers the
Rust-specific API and idioms.

## Logging API

- Use `tracing` for structured logging.
- Always use the `tracing::` prefix (e.g. `tracing::debug!`, not `debug!`).
- Decorate functions with `#[tracing::instrument]` for traceability.
- The shared severity levels map to `tracing::warn!` / `tracing::error!` / `tracing::debug!` / `tracing::info!`.

### Structured Logging Best Practices

**Always use field notation for structured logs**, not string formatting.

❌ **Bad** (string formatting):

```rust
tracing::debug!(
    "Saving persisted state to {}: last_theme={:?}, last_directory={:?}, last_sidebar_visible={:?}, last_sidebar_width={:?}, last_show_all_files={:?}",
    path,
    self.last_theme,
    self.last_directory,
    self.last_sidebar_visible,
    self.last_sidebar_width,
    self.last_show_all_files
);
```

✅ **Good** (structured fields):

```rust
tracing::debug!(%path, ?self, "Saving persisted state");
```

**Benefits of structured logging:**

- Machine-readable and searchable
- Easier to filter and analyze
- More concise and maintainable
- Automatic Display/Debug formatting with `%/?` prefix
- Can be exported to structured log aggregators

**Field notation syntax:**

- `?field` - Debug format (`field = {:?}`)
- `%field` - Display format (`field = {}`)
- `field` - Use the value directly (for types implementing `Value`)
- `field = expr` - Custom expression as field value

## Error types

- **Library crates**: use `thiserror` to define dedicated error types with context.
- **Application crates**: use `anyhow::Error`.
