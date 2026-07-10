---
paths: "**/*.ts,**/*.tsx,**/*.mts,**/*.cts"
---

# Error Handling and Logging — TypeScript

Severity policy (when to use warn/error/debug/info, library vs application) is
shared: see `rules/code/error-and-logging.md`. This rule covers the
TypeScript-specific API and idioms.

## Logging API

- Use `console` or the project's logger (e.g. `@logtape/logtape`).
- The shared severity levels map to `console.warn` / `console.error` / `console.debug` / `console.info`.

## Error types

- **Library modules**: define custom `Error` subclasses that carry context.
- **Application modules**: use standard `Error` or custom errors as appropriate.
