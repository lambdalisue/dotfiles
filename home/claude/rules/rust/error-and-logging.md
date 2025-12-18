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
