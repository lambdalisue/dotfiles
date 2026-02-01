---
name: deno
description: Deno-specific conventions and patterns.
---

## Conventions

- **Imports**: Explicit extensions (`.ts`), JSR > @std > npm
- **Config**: `deno.json` for imports, tasks, lint, fmt
- **Tools**: `deno fmt/lint/check/test` (not Prettier/ESLint/Vitest)
- **No node_modules**

## Module Structure

- `mod.ts` only at top level; submodules use `{module}.ts` not `{module}/mod.ts`

## JSR Package Docs

Use `deno doc jsr:{package}` to retrieve package documentation.

## Testing

```typescript
Deno.test("behavior description", async (t) => {
  await t.step("specific case", () => {
    // AAA pattern, @std/assert
  });
});
```

## Permissions

Document in JSDoc: `@requires --allow-read`
