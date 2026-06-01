---
title: "redb 4.1 and sled 0.34 — embedded key-value stores for consumed-token marks"
source: https://docs.rs/redb, https://docs.rs/sled
type: repo
tags: [redb, sled, embedded-kv, persistence, single-use, consumed-set]
date: 2026-06-01
quality: 4
confidence: high
agent: technical
summary: "redb 4.1.0: ACID, MVCC, copy-on-write B-tree, savepoint/rollback, single-file, zero-copy reads — modern recommendation for new code. sled 0.34.7: nice ergonomics (BTreeMap-shape, multi-tree transactions, prefix subscriptions) but stable-without-1.0 since ~2021. For consumed-token marks both are overkill vs sqlx-sqlite if cross-tool inspection is needed; redb wins for pure embedded. License: redb is MIT/Apache-2.0; sled is MIT/Apache-2.0."
---

# redb vs sled for consumed-token persistence

The single-use enforcement half of the iroh app token wrapper. **Recommendation: redb 4.1+**.

## redb 4.1.0

| Property | Status |
|----------|--------|
| ACID | Yes |
| MVCC (multi-version concurrency control) | Yes |
| Storage | Single file, copy-on-write B-tree |
| Savepoint / rollback | Yes |
| Zero-copy reads | Yes |
| License | MIT/Apache-2.0 |
| Recommended for new code | **Yes** |

```rust
use redb::{Database, TableDefinition};

const CONSUMED: TableDefinition<&[u8], u64> = TableDefinition::new("consumed_tokens");

let db = Database::create("/var/lib/farm-ai/consumed.redb")?;

let write_txn = db.begin_write()?;
{
    let mut table = write_txn.open_table(CONSUMED)?;
    if table.get(token_id)?.is_some() {
        return Err(AlreadyConsumed);
    }
    table.insert(token_id, &now_unix())?;
}
write_txn.commit()?;
```

## sled 0.34.7

| Property | Status |
|----------|--------|
| API ergonomics | BTreeMap-like; very nice |
| Multi-tree transactions | Yes |
| Prefix subscriptions | Yes |
| 1.0 release | **Not yet** (since ~2021) |
| Production caution | Yes (community-flagged) |
| License | MIT/Apache-2.0 |

```rust
let db = sled::open("/var/lib/farm-ai/consumed.sled")?;

if db.contains_key(token_id)? {
    return Err(AlreadyConsumed);
}
db.insert(token_id, &now_unix().to_le_bytes())?;
db.flush()?;
```

→ Cleaner API, but the 1.0-still-pending status is a real concern for a production-grade homelab token store.

## sqlite (sqlx) — the inspection-friendly alternative

```rust
sqlx::query!("INSERT OR FAIL INTO consumed (token_id, ts) VALUES (?, ?)", id, now)
    .execute(&pool).await?;
```

Pro: anyone with `sqlite3 consumed.db` can inspect/audit the consumed set. SQL ergonomics.
Con: heavier dep, runtime overhead, requires schema migration tooling.

## For the iroh app token wrapper

**Recommend redb** because:

1. ACID gives crash-consistency on power loss (important on a homelab box without a UPS)
2. Single file, no schema migration
3. Active maintenance (4.x is current)
4. Zero-copy reads — fast lookup path

The token-id key can be the **token's `jti` claim** (PASETO) or a hash of the bearer bytes (random-opaque scheme).

## See also

- [[2026-06-01-fly-api-tokens-survey]] — random-opaque + DB pattern
- [[2026-06-01-iroh-auth-hook-example]] — where this slots in
