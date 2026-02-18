# Variable Scoping and Code Consistency

## Block Expressions for Scoping Temporaries

When temporary variables are needed only to construct a single value, wrap them in a block expression `let x = { ... };`. This keeps readable names while preventing scope leakage.

When two operations are logically inseparable (e.g., create + guard), combine them in a single block so the intermediate value never leaks into the outer scope.

### Good

```rust
// Create + guard are inseparable — intermediate `new_index` stays scoped
let new_index = {
    let elasticsearch = elasticsearch.clone();
    let new_index = Document::create_versioned_index(&elasticsearch).await?;
    scopeguard::guard(new_index, move |index| {
        cleanup_versioned_index_blocking(&elasticsearch, &index);
    })
};

// Builder dependencies don't leak into outer scope
let builder = {
    let pool = DuoPgPool::builder(pg.raw_client().clone())
        .skip_rls_verification(true)
        .build();
    let repository = Arc::new(MyRepository::new(pool));
    Arc::new(MyBuilder::new(repository))
};

// Clone for move closure stays scoped
let stream = stream.inspect({
    let counter = counter.clone();
    move |_| {
        counter.fetch_add(1, Ordering::Relaxed);
    }
});
```

### Bad

```rust
// Inseparable operations split across outer scope — unguarded value exposed
let new_index = Document::create_versioned_index(&elasticsearch).await?;
let new_index = {
    let elasticsearch = elasticsearch.clone();
    scopeguard::guard(new_index, move |index| {
        cleanup_versioned_index_blocking(&elasticsearch, &index);
    })
};

// Temporary leaks into function scope with a purpose-named variable
let es_for_cleanup = elasticsearch.clone();
let new_index = scopeguard::guard(new_index, move |index| {
    cleanup_versioned_index_blocking(&es_for_cleanup, &index);
});

// Intermediates pollute function scope
let pool = DuoPgPool::builder(...).build();
let repository = Arc::new(MyRepository::new(pool.clone()));
let builder = Arc::new(MyBuilder::new(repository));
// `pool` and `repository` still visible but never used again

// Clone with a different name obscures intent
let counter_for_log = counter.clone();
let stream = stream.inspect(move |_| {
    counter_for_log.fetch_add(1, Ordering::Relaxed);
});
```

## Declare Variables Near Usage

Place variable declarations as close as possible to where they are used. When a variable is only needed at the end of a function, don't declare it at the top.

### Good

```rust
// tenant_ids declared right before its only usage
Document::refresh_index(&elasticsearch, &new_index).await?;

let tenant_ids = fetch_tenant_ids(&pool).await?;
Document::switch_aliases_to(&elasticsearch, &new_index, &tenant_ids).await?;
```

### Bad

```rust
// tenant_ids declared 80 lines above its usage
let tenant_ids = fetch_tenant_ids(&pool).await?;

// ... 80 lines of unrelated processing ...

Document::switch_aliases_to(&elasticsearch, &new_index, &tenant_ids).await?;
```

## Prefer `From`/`Into` Over `FromStr` for Infallible Conversions

When a newtype wraps `String` and implements `From<String>`, use `From`/`Into` instead of `FromStr`. `FromStr` returns `Result`, which forces unnecessary error handling on infallible conversions.

### Good

```rust
let tenant_id = TenantId::from(record.tenant_id);
```

### Bad

```rust
// Unnecessary error handling for an infallible conversion
let tenant_id = match TenantId::from_str(&record.tenant_id) {
    Ok(id) => id,
    Err(e) => {
        tracing::warn!(error = ?e, "invalid tenant_id");
        return None;
    }
};
```

## Consistent Expression Style

When multiple values are at the same abstraction level, write them in the same style — either all inline or all with variable bindings.

### Good

```rust
// Both inline
Some((
    TenantId::from(record.tenant_id),
    BackOrderId::from(record.back_order_id),
))

// Both bound (when expressions are complex)
let tenant_id = resolve_tenant(&record)?;
let order_id = resolve_order(&record)?;
Some((tenant_id, order_id))
```

### Bad

```rust
// Inconsistent: one bound, one inline
let tenant_id = TenantId::from(record.tenant_id);
Some((tenant_id, BackOrderId::from(record.back_order_id)))
```

## Use Imports to Avoid Redundant Path Prefixes

When a crate path is repeated, add a `use` import instead.

### Good

```rust
use lib_elasticsearch::{Elasticsearch, ElasticsearchParams};

let es = Elasticsearch::new(ElasticsearchParams::from(config))?;
```

### Bad

```rust
let es = lib_elasticsearch::Elasticsearch::new(
    lib_elasticsearch::ElasticsearchParams::from(config),
)?;
```
