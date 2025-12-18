---
paths: "**/*.ts"
---
# Error Handling and Logging

## Common

- Use `console` or project's logger (e.g., `@logtape/logtape`)
- Do NOT log when throwing errors. Use `console.debug` only if context would be lost
- Avoid excessive logging

## Library Modules

**Error Handling:**

- Define custom `Error` subclasses with context

**Logging:**

- `console.warn` / `console.error` are prohibited — let caller decide severity
- `console.debug` for debugging information
- `console.info` only for critical flow tracking

## Application Modules

**Error Handling:**

- Use standard `Error` or custom errors as appropriate

**Logging:**

- `console.warn` for recoverable errors (continue execution)
- `console.error` for fatal errors (stop execution)
- `console.debug` for debugging information
- `console.info` for flow tracking
