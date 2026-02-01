---
paths: "**/*.ts"
---
# TypeScript Code Style

## Private Fields
Use `#field` (JS private) instead of `private field` (TS keyword).

## Exports
Use `export *` and `export type *` in entry points whenever possible.
If selective exports are needed, explain reason and get permission.

## Internal Exports
For testing/internal use:
```typescript
/** @internal */
export const _internal = { helperFunction, testUtility };
```

## Prohibited Type Assertions
- `as any`, `as unknown as T`, `@ts-ignore`, `@ts-expect-error`
If necessary, explain reason and get permission.
