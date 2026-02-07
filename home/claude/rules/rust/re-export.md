---
paths: "**/src/**/*.rs"
---

# Prefer glob re-exports (`pub use mod::*`) with fine-grained visibility on items

To reduce maintenance cost, use **glob re-exports** (`pub use xxx::*;`) instead of listing individual items.
Control the public API surface by setting visibility on each item (`pub(self)`, `pub(crate)`, `pub(super)`, `pub`) rather than filtering at the re-export site.

## Own Modules

Use `pub use module::*;` and control visibility at the definition site.

### Good

```rust
// lib.rs
pub use config::*;
pub use error::*;

// config.rs
pub struct Config { /* ... */ }          // public API
pub(crate) fn load_defaults() { /* ... */ } // crate-internal
```

### Bad

```rust
// lib.rs — manually listing items is fragile and high-maintenance
pub use config::{Config};
pub use error::{Error, Result};
```

## Third-Party / External Crates

When you **cannot** control item visibility at the source, explicitly list the minimal set of items needed.

### Good

```rust
pub use serde::{Deserialize, Serialize};
pub use tokio::sync::{Mutex, RwLock};
```

### Bad

```rust
pub use serde::*;  // exposes everything from serde — too broad
```

## Summary

| Source              | Re-export Style          | Visibility Control        |
| ------------------- | ------------------------ | ------------------------- |
| Own modules         | `pub use module::*;`     | On each item definition   |
| Third-party crates  | `pub use crate::{items}` | At the re-export site     |
