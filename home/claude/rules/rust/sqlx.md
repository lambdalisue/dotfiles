# SQLx Query Rules

## Always use compile-time checked macros

Use `sqlx::query!` / `sqlx::query_as!` / `sqlx::query_scalar!` instead of `sqlx::query` / `sqlx::query_as` / `sqlx::query_scalar`.

The macro versions perform compile-time SQL validation against the database schema, catching errors early.

### Good

```rust
sqlx::query!("SELECT id, name FROM users WHERE id = $1", user_id)
    .fetch_one(pool)
    .await?;

sqlx::query_as!(User, "SELECT id, name FROM users WHERE id = $1", user_id)
    .fetch_one(pool)
    .await?;

sqlx::query_scalar!("SELECT count(*) FROM users")
    .fetch_one(pool)
    .await?;
```

### Bad

```rust
sqlx::query("SELECT id, name FROM users WHERE id = $1")
    .bind(user_id)
    .fetch_one(pool)
    .await?;
```

## Exception: Dynamic queries with QueryBuilder

When building dynamic SQL (e.g., bulk inserts with variable bind counts), `sqlx::QueryBuilder` is acceptable since macros cannot handle dynamic SQL.

```rust
let mut qb = sqlx::QueryBuilder::new("INSERT INTO users (name, email) ");
qb.push_values(&records, |mut b, r| {
    b.push_bind(&r.name).push_bind(&r.email);
});
qb.build().execute(pool).await?;
```
