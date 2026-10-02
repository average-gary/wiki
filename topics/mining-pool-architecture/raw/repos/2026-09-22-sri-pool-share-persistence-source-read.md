---
title: "SRI pool role share persistence — source read of sv2-apps and stratum"
source: "https://github.com/stratum-mining/sv2-apps"
related_sources: ["https://github.com/stratum-mining/stratum"]
type: repos
ingested: 2026-09-22
tags: [stratum-v2, sri, share-persistence, share-accounting, in-memory-only, monitoring-api, prometheus, seen-shares, rejected-shares, unbounded-hashmap, job-store, dos-surface, validation-cost, source-read]
summary: "Resolves round 1's biggest open question by reading the code: the SRI pool role has NO persistence layer at all. No database crate in pool-apps/pool/Cargo.toml, no file I/O, no serialization. Share state lives in a per-channel ShareAccounting struct (shares_accepted, rejected_shares, share_work_sum, seen_shares, best_diff, blocks_found) and is lost entirely on restart, including seen_shares — so cross-restart replay is possible against a still-valid job. The intended accounting integration point is an HTTP monitoring API (/metrics Prometheus plus /api/v1/clients/{id}/channels JSON) that an external system must poll; there is no batch export, DB hook, or callback. This makes the reference pool a share-validation frontend, not a complete pool. ALSO CORRECTS round 1: the bounded-storage caps added in the 2026 hardening work are CLIENT-side only (MAX_FUTURE_JOBS = 16, rejected_shares bucketed into 9 known error codes plus 'unknown'); the pool SERVER's JobStore still uses unbounded HashMaps for future_template_to_job_id, future_jobs, past_jobs and stale_jobs, stale_jobs appear never to be cleared, and server-side rejected_shares is an unbounded HashMap keyed by the attacker-suppliable error_code string. Confirms this session's corrected validation-cost estimate from the code: standard channels hash the header only (merkle root pre-computed in the job) = 1 double-SHA256; extended channels recompute the coinbase txid and walk the merkle path = (1 + N) double-SHA256 for N = ceil(log2(tx_count)), so ~12 for a 2048-tx block."
commits_read:
  - "stratum: 9b0454ec (v1.11.1 + 124 commits, dated 2026-09-02)"
  - "sv2-apps: 3f902060 (v0.1.0 + 1079 commits)"
credibility: high
credibility_score: 5
credibility_rationale: "Direct read of the source at named commits with path:line citations and code excerpts throughout. This is the strongest class of evidence in the topic — not a claim about the code but the code itself. Downgraded from 6 only because a single agent performed the read and its memory arithmetic contained an error (corrected below), so other derived figures deserve the same scrutiny."
confidence: high
research_round: 2
research_agent: "B1 (source read)"
corrects: "raw/repos/2026-09-21-sv2-apps-pool-role-architecture.md (persistence 'undocumented' — now answered); raw/repos/2026-09-21-sri-and-sv2-apps-hardening-releases-2026.md and wiki/concepts/share-accounting-and-durability.md (both said job storage was bounded 'on every axis' — true only client-side)"
extraction_note: "Agent read the two public upstream checkouts only. One derived figure in the original report was wrong and is corrected inline under 'Memory arithmetic, checked'."
---

# SRI pool role share persistence — source read

Read at **`stratum` @ `9b0454ec`** (v1.11.1 + 124 commits, 2026-09-02) and
**`sv2-apps` @ `3f902060`** (v0.1.0 + 1079 commits).

## 1. Does the pool role persist shares? No.

- `sv2-apps/pool-apps/pool/Cargo.toml:20-29` — **no persistence dependency of any kind**: no `sqlx`,
  `diesel`, `rusqlite`, `sled`, `redb`, `rocksdb`, `tokio-postgres`, `redis`.
- `sv2-apps/pool-apps/pool/src/` — grepping `File|Write|persist|save|store|database` yields only Noise
  TCP writes and a log-file path config. **No file I/O, no serialization to disk.**
- `sv2-apps/pool-apps/pool/src/lib/config.rs:28-53` — `PoolConfig` has no persistence fields.

## 2. Where share state lives

`stratum/sv2/channels-sv2/src/server/share_accounting.rs:79-92`:

```rust
pub struct ShareAccounting {
    last_share_sequence_number: u32,
    shares_accepted: u32,
    rejected_shares: HashMap<String, u32>,  // keyed by error_code string
    share_work_sum: f64,
    last_batch_accepted: u32,
    last_batch_work_sum: f64,
    batch_acknowledged: bool,
    share_batch_size: usize,
    seen_shares: HashSet<Hash>,            // duplicate detection
    best_diff: f64,
    blocks_found: u32,
}
```

Held per channel — `StandardChannel::share_accounting` (`standard.rs:98`) and the extended equivalent.

**`seen_shares` is flushed only on chain-tip change** — `flush_seen_shares()` at
`share_accounting.rs:161`, called from `standard.rs:584` and `extended.rs:628,678`. Keying the flush to
`prev_hash` is *correct by design*: that is the work-uniqueness boundary. But it has two consequences,
one benign and one not:

- Between blocks the set grows unbounded (bounded in practice by the ~10-minute interblock time).
- **It is not persisted, so a restart empties it** — see §6.

## 3. CORRECTION: the bounded-storage caps are client-side only

Round 1 recorded, from release notes, that the 2026 hardening bounded job storage "on every axis
(future templates, past jobs, replaced group jobs, per-client future jobs, `seen_shares`,
`rejected_shares`)". **The source says those bounds live on the client side.**

**Client-side bounds that do exist** (`channels-sv2/src/client/`):

| Knob | Default | Scope | Citation |
|---|---|---|---|
| `MAX_FUTURE_JOBS` | **16** | per client channel, evicts oldest | `client/mod.rs:21` |
| `rejected_shares` bucketing | 9 known error codes + an `"unknown"` bucket | per client channel | `client/share_accounting.rs:20-41` |

Added by commits `9ef8f9af` (the constant), `76db56a9` / `f5463740` / `96a0613f` (bound future jobs for
client extended/standard/group), `42aad83e` (bound client `rejected_shares`).

**Server-side: no bounds found.** `channels-sv2/src/server/jobs/job_store.rs:24-31` holds four
unbounded `HashMap`s:

```rust
future_template_to_job_id: HashMap<u64, u32>   // no cap
future_jobs:               HashMap<u32, T>     // no cap
past_jobs:                 HashMap<u32, T>     // no cap
stale_jobs:                HashMap<u32, T>     // no cap
```

Lifecycle: `future_jobs` clear when a future job activates (`job_store.rs:113-114`); `past_jobs` move to
`stale_jobs` on chain-tip change via `mark_past_jobs_as_stale()` (`job_store.rs:129-131`); and
**`stale_jobs` are never cleared anywhere in the reviewed code.** A pool accumulates stale job state for
as long as it runs.

**The sharper finding is server-side `rejected_shares`.** It is an unbounded `HashMap<String, u32>`
**keyed by the `error_code` string from `SubmitSharesError`**. If a miner can cause arbitrary or varied
error codes, each distinct string allocates a new map entry that is never evicted. The client side was
explicitly hardened against this in `42aad83e`; the server side was not. That asymmetry — hardening the
client against a hostile pool while leaving the pool unhardened against hostile miners — is the wrong way
round for a pool server, and it is a plain memory-exhaustion surface rather than a theoretical one.

*Unverified: whether a downstream can actually induce arbitrary `error_code` strings, or whether the set
is constrained to a protocol enum in practice. That determines whether this is a live DoS or a latent
one, and it is the first thing to check.*

## 4. Validation cost, confirmed from the code

This session's round-1 correction (~1 µs standard / ~10 µs extended, against an agent's original
50–100 µs) is **confirmed by the implementation**.

**Standard channel** — `standard.rs:686-696`. The merkle root is already computed in the job
(`job.get_merkle_root()`, `standard.rs:654`); validation only builds the header and hashes it:

```rust
let header = Header { version, prev_blockhash, merkle_root, time: share.ntime, bits: nbits, nonce: share.nonce };
let share_hash = header.block_hash();   // 1 double-SHA256
```

→ **1 double-SHA256 (2 SHA-256 passes), ~0.5 µs.**

**Extended channel** — `extended.rs:770-778` calls `merkle_root_from_path(...)`, which per
`channels-sv2/src/merkle_root.rs:24-65` does: (1) `coinbase.compute_txid()` = 1 double-SHA256
(`merkle_root.rs:43`), then (2) one `DHash(root || node)` per merkle-path node
(`merkle_root.rs:58-62`).

→ **(1 + N) double-SHA256 for N = ⌈log₂(tx_count)⌉.** For a 2,048-transaction block N = 11, so 12
double-SHA256 ≈ **6–12 µs.**

So the cost gap between channel types is structural: an extended channel pays for letting the miner vary
the coinbase, and it is roughly an order of magnitude, exactly as the sizing model states.

## 5. How accounting gets out: an HTTP polling API

The pool exposes accounting over HTTP when `monitoring_address` is configured
(`pool/src/lib/pool_runtime.rs:521-529`). Routes at
`sv2-apps/stratum-apps/src/monitoring/routes.rs`:

- `/metrics` — Prometheus text (`stratum-apps/src/monitoring/prometheus_metrics.rs`)
- `/api/v1/clients` — all SV2 clients
- `/api/v1/clients/{client_id}` — client detail
- `/api/v1/clients/{client_id}/channels` — **per-channel share accounting**

Per-channel payload (`pool/src/lib/monitoring.rs:24-50`): `shares_accepted`, `shares_rejected`,
`shares_rejected_by_reason`, `share_work_sum`, `best_diff`, `blocks_found`.

**No batch export, no database insert hook, no callback interface.** An operator polls and persists
externally.

## 6. On restart, everything is lost

- No persistence (§1); `ShareAccounting::new()` (`share_accounting.rs:98-112`) zeroes every counter; no
  recovery path.
- `PoolRuntime` (`pool_runtime.rs:1-100`) bootstraps an empty `ChannelManager`.

Consequences:

- `shares_accepted`, `rejected_shares`, `share_work_sum`, `blocks_found` all reset to zero.
- Job state (active / past / stale / future) is lost.
- **`seen_shares` is empty, so replay protection does not survive a restart.** A miner that retains
  pre-restart shares can resubmit them and be credited again, provided the job is still valid. Round 1
  identified "dedup state must not be scoped to something an adversary can cause to roll over" —
  process lifetime is exactly such a thing, and **an adversary who can crash or trigger a restart can
  roll it over deliberately.** SmartPool's persisted `last_max` monotonic counter is the contrasting
  design that survives this.
- The external accounting system's polling interval **is** the data-loss window on a crash.

## Memory arithmetic, checked

The reporting agent wrote: "for a pool handling 1000 shares/sec, that's 600,000 hashes × 32 bytes =
19 MB per channel per 10 minutes. Multiplied by 100 channels, that's 1.9 GB."

**That double-counts.** 1,000 shares/sec is an *aggregate* rate across all channels, not a per-channel
rate; the 600,000 entries accumulated over 10 minutes are the total across the pool, not per channel.
Multiplying by the channel count inflates it by 100×. Corrected: **~600k entries ≈ 19 MB of raw hashes**,
or perhaps **30–45 MB** allowing for `HashSet`/hashbrown overhead above the bare 32-byte key. That is
unremarkable, and it fits the round-1 sizing model (share rate is `connections / vardiff interval`, so
1,000/sec corresponds to ~10,000 connections at a 10 s target).

**So `seen_shares` being unbounded between blocks is not the real risk** — the interblock time bounds
it at a modest size. The real risks from this read are the **never-cleared `stale_jobs`** and the
**unbounded `rejected_shares` keyed on a client-supplied string.**

## What this settles, and what it opens

**Settles**: the SRI pool role is a **share-validation frontend**, not a complete pool. Validation,
in-RAM accounting, and an HTTP read surface. Payout, persistence and reward calculation are outside it
by design.

**Opens**:

- Is the stateless-frontend-plus-external-backend split the intended production model, or is persistence
  simply not written yet? No design document was found either way.
- Is there any reference external accounting service that consumes the monitoring API? If not, every
  operator writes that integration themselves — and the polling interval becomes their data-loss window.
- Can a downstream induce arbitrary `error_code` strings? (Decides whether §3's DoS is live.)
- Are `stale_jobs` pruned by some task outside `job_store.rs`?
- Where is payout logic expected to live in the SRI architecture?
