---
paths: "**/*.rs"
---

# Error Handling and Logging

## Common

- Use `tracing` for structured logging
- Always use `tracing::` prefix (e.g., `tracing::debug!`, not `debug!`)
- Decorate functions with `#[tracing::instrument]` for traceability
- Do NOT log when returning errors. Use `tracing::debug!` only if context would be lost
- Avoid excessive logging

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

## Library Crates

**Error Handling:**

- Use `thiserror` to define dedicated error types with context

**Logging:**

- `tracing::warn!` / `tracing::error!` are prohibited — let caller decide severity
- `tracing::debug!` for debugging information
- `tracing::info!` only for critical flow tracking

## Application Crates

**Error Handling:**

- Use `anyhow::Error`

**Logging:**

- `tracing::warn!` for recoverable errors (continue execution)
- `tracing::error!` for fatal errors (stop execution)
- `tracing::debug!` for debugging information
- `tracing::info!` for flow tracking
