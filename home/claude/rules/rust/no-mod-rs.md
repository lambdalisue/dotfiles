---
paths: "**/mod.rs"
---

# Prefer the modern module file naming convention (Rust 2018+) over `mod.rs`

- If you created `mod.rs`, rename it to match the module name
- If existing code uses `mod.rs`:
  - **During refactoring tasks**: Apply the modern style
  - **During unrelated changes**: Mention the opportunity but don't change

## Preferred Style

```
src/
├── main.rs
├── foo.rs          # defines module `foo`
└── foo/
    └── bar.rs      # submodule `foo::bar`
```

## Avoid

```
src/
├── main.rs
└── foo/
    ├── mod.rs      # discouraged
    └── bar.rs
```

## Exceptions

- **Large legacy codebases**: Suggest migration incrementally, not all at once
- **User preference**: When explicitly requested to use `mod.rs` style

## Rationale

- Supported since **Rust 2018 edition** (stabilized in Rust 1.31)
- Filenames directly indicate module names (clearer navigation)
- No ambiguous "mod.rs" tabs in editors
- Better tooling support (rust-analyzer, IDE search)
