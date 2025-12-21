---
paths: "**/src/**/*.rs"
---

# Use AsRef<T> and Into<T> for public APIs

For public APIs, use `impl AsRef<T>` or `impl Into<T>` to make them more permissive.
This makes the API easier to use by allowing it to accept both `String` and `&str`, for example.

This rule is not necessary for private APIs. It's okay to use concrete types.

## Good Example (Public API)

```rust
pub fn print_message<T: AsRef<str>>(message: T) {
    println!("{}", message.as_ref());
}

// Both of the following calls are possible:
// print_message("Hello, world!");
// print_message("Hello, world!".to_string());
```

## Bad Example (Public API)

```rust
pub fn print_message(message: &str) {
    println!("{}", message);
}

// In this case, an extra step is required to pass a `String`.
```

## Private API

For private APIs that are only used within the project, it's fine to use concrete types like `&str`.

```rust
fn internal_process(data: &str) {
    // ...
}
```