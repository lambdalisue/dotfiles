# Module Structure

## mod.ts

- `mod.ts` is only allowed at the top level
- Submodules use `{module}.ts` not `{module}/mod.ts`

**Good:**

```
src/
  mod.ts          # Top level - OK
  foo.ts          # Submodule entry
  foo/
    bar.ts
```

**Bad:**

```
src/
  mod.ts
  foo/
    mod.ts        # Submodule mod.ts - NG
    bar.ts
```
