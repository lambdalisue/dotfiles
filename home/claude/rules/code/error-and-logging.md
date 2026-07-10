---
paths: "**/*.rs,**/*.ts,**/*.tsx,**/*.mts,**/*.cts"
---

# Error Handling and Logging — shared policy

Severity policy shared across languages. For the concrete logging API and
language idioms, see the language-specific rule (`rules/rust/error-and-logging.md`
for Rust `tracing::*`, `rules/ts/error-and-logging.md` for TypeScript `console.*`).

## Common

- Do NOT log when returning/throwing an error — emit a debug-level log only if the context would otherwise be lost.
- Avoid excessive logging.

## Library modules/crates

- Define dedicated error types that carry context.
- **warn / error level logging is prohibited** — let the caller decide severity.
- Use debug for debugging information; info ONLY for critical flow tracking.

## Application modules/crates

- warn for recoverable errors (execution continues).
- error for fatal errors (execution stops).
- debug for debugging information; info for flow tracking.
