---
paths: "**/*.rs,**/*.ts,**/*.tsx,**/*.mts,**/*.cts,**/*.py,**/*.go,**/*.lua,**/*.sh,**/*.nix"
---

# Comments: Default to None

Code carries How, tests carry What, commits carry Why. A comment exists
only for what none of those can hold: why the obvious alternative was
NOT taken, an invariant the type system cannot express, or the external
spec / bug that forces an odd shape.

## Never write

- A restatement of the code (`// increment the counter`)
- Section banners or step numbering (`// 1. Load config`, `// --- helpers ---`)
- A narration of the current edit ("added X to fix Y") — that is the commit message
- A doc comment on a private symbol that only repeats its name
- Type or parameter descriptions the language already types

## Test before writing one

Would deleting this comment lose information that the code, the tests,
or `git blame` cannot recover? If not, do not write it.
