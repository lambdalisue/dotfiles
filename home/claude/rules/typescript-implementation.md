# TypeScript Implementation Rules

## Private Fields

**Use JavaScript private fields (`#`) instead of TypeScript `private` keyword**

Forbidden: `private field: string`
Required: `#field: string`

### Rationale

- JavaScript private fields (`#`) provide true runtime privacy
- TypeScript `private` is only a compile-time check and disappears after transpilation
- `#` prefix prevents access even through type assertions or runtime manipulation
- Better encapsulation and security for sensitive data

### Example

```typescript
// ❌ Avoid
class User {
  private password: string;

  constructor(password: string) {
    this.password = password;
  }
}

// ✅ Prefer
class User {
  #password: string;

  constructor(password: string) {
    this.#password = password;
  }
}
```

## Warnings

**Avoid using `@ts-ignore` and `@ts-expect-error` without justification**

If absolutely necessary, explain the reason and obtain user permission first.
Use `@ts-expect-error` over `@ts-ignore` when suppression is required, as it will error if the issue is resolved.
