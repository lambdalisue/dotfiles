---
name: ts
description: TypeScript conventions and type-safe patterns.
---

## Conventions

- **Types**: `strict: true`, type guards over assertions
- **Null Safety**: Optional chaining (`?.`), nullish coalescing (`??`)
- **Style**: `interface` for objects, `type` for unions, `import type` for types
- **Tools**: oxlint for linting, Vitest for testing

## Testing

```typescript
describe("feature", () => {
  it("behavior description", () => {
    // AAA pattern, expect API
  });
});
```
