---
title: "Wesh-style seed rotation for the iroh app token wrapper"
type: concept
created: 2026-06-01
updated: 2026-06-01
verified: 2026-06-01
volatility: hot
confidence: high
sources:
  - raw/papers/2026-06-01-rfc-6238-totp.md
  - raw/papers/2026-06-01-rfc-6819-oauth-threats.md
  - raw/repos/2026-06-01-blake3-keyed-hash-rust.md
  - raw/articles/2026-06-01-langley-no-revcheck.md
  - raw/articles/2026-06-01-wesh-berty-rendezvous.md
  - raw/articles/2026-06-01-w3c-bitstring-status-list.md
  - raw/articles/2026-06-01-signal-sealed-sender.md
tags: [seed-rotation, revocation, blake3, totp, family-revocation, short-ttl]
---

# Seed rotation — revocation by rotating the derivation key

The pattern: **rotate the underlying secret = invalidate all derived tokens.** No CRL, no OCSP, no revocation list. Per [[langley-no-revcheck]]: short-lived + cheap reissue beats revocation oracles every time.

## The construction (algorithmic parallel to TOTP)

```rust
fn rendezvous_tag(seed: &[u8; 32], endpoint_id: &EndpointId, bucket: u64) -> blake3::Hash {
    let mut hasher = blake3::Hasher::new_keyed(seed);
    hasher.update(endpoint_id.as_bytes());
    hasher.update(&bucket.to_le_bytes());
    hasher.finalize()
}

fn current_bucket() -> u64 {
    // bucket = week number since epoch
    let now_secs = SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_secs();
    now_secs / (7 * 24 * 3600)
}
```

→ Same shape as TOTP's `T = floor((now - T0) / X)` (per [[rfc-6238-totp]]); BLAKE3 keyed-hash replaces HMAC-SHA1; bucket size is **a week** instead of 30 seconds.

## Sizing the bucket

| Bucket | Use case |
|--------|----------|
| 30 sec | Interactive 2FA (TOTP). Too churn-y for app tokens. |
| 1 hour | Aggressive rotation. Drift tolerance needed (±1). |
| 1 day  | Daily rotation. Fine for paranoid setups. |
| **1 week** | **Default for iroh app token.** Coarse enough to need no drift tolerance. |
| 1 month | Lazy rotation. Operator forgets to rotate. |

## Drift tolerance

Per [[rfc-6238-totp]] guidance, accept current and previous bucket:

```rust
fn validate(seed: &[u8; 32], endpoint_id: &EndpointId, claimed: &Hash) -> ValidationResult {
    let cur = current_bucket();
    for offset in 0..=1 {
        let bucket = cur - offset;
        let expected = rendezvous_tag(seed, endpoint_id, bucket);
        if &expected == claimed {
            return ValidationResult::Accept { staleness: offset };
        }
    }
    // Check 2 buckets back — tag arrived very late, suspicious
    let two_back = rendezvous_tag(seed, endpoint_id, cur - 2);
    if &two_back == claimed {
        return ValidationResult::AcceptButLog;
    }
    ValidationResult::Reject
}
```

For a week-sized bucket, requiring `staleness <= 1` means: **a leaked QR is valid for at most 2 weeks** (depending on when in the bucket it was issued).

## Family-revocation via stale-tag detection

Per [[rfc-6819-oauth-threats]] §5.2.1.1 / §5.2.2.3: if a rotated-out tag is presented after rotation, that's leak evidence. Burn the seed.

```rust
fn handle_pairing_request(seed: &[u8; 32], claimed_tag: Hash, claimed_bucket: u64) -> Action {
    let cur = current_bucket();
    let stale = cur.saturating_sub(claimed_bucket);
    match stale {
        0 | 1 => Action::Accept,           // current or previous bucket — fine
        2 => Action::AcceptButLog,          // late arrival, suspicious
        _ => {
            log::warn!("rotated-out tag presented; rotating seed");
            rotate_seed_immediately();
            Action::Reject
        }
    }
}
```

→ Adversary using a rotated-out tag triggers immediate seed rotation, invalidating any other tags they might have.

## What rotation does and doesn't invalidate

| Entity | Effect of seed rotation |
|--------|--------------------------|
| Outstanding QRs (unscanned) | **Invalidated** — old seed no longer derives valid tags |
| Already-paired devices | **Unchanged** — they're on the EndpointID allowlist (file-based) |
| Server's identity (EndpointID) | **Unchanged** — independent of seed |
| In-flight pairings (mid-handshake) | Fail (rejected); user re-scans new QR |

→ Seed rotation is the **right primitive for revoking outstanding QRs without disrupting paired devices.** Compare to identity rotation (changing EndpointID) which would force every paired device to re-pair.

## Implementation in Rust

```rust
use blake3;
use redb::{Database, TableDefinition};

const SEED_TABLE: TableDefinition<&str, [u8; 32]> = TableDefinition::new("seed");

struct SeedManager {
    db: Database,
}

impl SeedManager {
    fn current_seed(&self) -> Result<[u8; 32]> {
        let txn = self.db.begin_read()?;
        let table = txn.open_table(SEED_TABLE)?;
        match table.get("current")? {
            Some(s) => Ok(*s.value()),
            None => Err(NotInitialized),
        }
    }

    fn rotate(&self) -> Result<[u8; 32]> {
        let new_seed: [u8; 32] = rand::random();
        let txn = self.db.begin_write()?;
        {
            let mut table = txn.open_table(SEED_TABLE)?;
            // also save previous for the staleness=1 grace window
            if let Some(cur) = table.get("current")? {
                table.insert("previous", *cur.value())?;
            }
            table.insert("current", new_seed)?;
        }
        txn.commit()?;
        log::info!("seed rotated");
        Ok(new_seed)
    }

    fn validate_with_drift(&self, endpoint_id: &EndpointId, claimed: &blake3::Hash, claimed_bucket: u64) -> Result<bool> {
        let cur_bucket = current_bucket();
        let cur_seed = self.current_seed()?;

        // Try current seed, current bucket
        let expected = rendezvous_tag(&cur_seed, endpoint_id, cur_bucket);
        if &expected == claimed { return Ok(true); }

        // Try current seed, previous bucket (drift tolerance)
        if claimed_bucket == cur_bucket - 1 {
            let prev_bucket_expected = rendezvous_tag(&cur_seed, endpoint_id, claimed_bucket);
            if &prev_bucket_expected == claimed { return Ok(true); }
        }

        // Try previous seed, recent bucket (rotation grace window)
        let txn = self.db.begin_read()?;
        let table = txn.open_table(SEED_TABLE)?;
        if let Some(prev) = table.get("previous")? {
            let prev_seed: [u8; 32] = *prev.value();
            for offset in 0..=1 {
                let bucket = cur_bucket - offset;
                let expected = rendezvous_tag(&prev_seed, endpoint_id, bucket);
                if &expected == claimed { return Ok(true); }
            }
        }

        Ok(false)
    }
}
```

## Operational schedule

```
[Crontab on the GTX 1060 server]
# rotate the seed weekly, on Sunday at 03:00 local time
0 3 * * 0 farm-ai rotate-seed

# OR: rotate manually on suspicion of QR leak
farm-ai admin rotate-seed --reason "shared QR on slack accidentally"
```

## What this does NOT replace

The seed rotation invalidates **outstanding QR codes** (unscanned, in-the-world). It does **not**:

1. Revoke already-paired devices — that's the file-based EndpointID allowlist (per [[tor-onion-v3-client-auth]] pattern)
2. Revoke specific in-flight tokens — that's the consumed-set in redb (per [[fly-api-tokens-survey]])

→ Three layers of defense:

| Layer | What it gates | Revocation |
|-------|---------------|------------|
| EndpointID allowlist (file) | Who can connect at all | Delete file → next connect rejected |
| Consumed-set (redb) | Whether a single-use token has been spent | Insert into table |
| Seed rotation | Outstanding QRs (unscanned) | Rotate seed |

## See also

- [[iroh-app-token-design]] — the token format
- [[iroh-app-token-integration]] — how to plug into iroh
- [[wesh-berty-rendezvous]] — the originating pattern
- [[langley-no-revcheck]] — the design justification
