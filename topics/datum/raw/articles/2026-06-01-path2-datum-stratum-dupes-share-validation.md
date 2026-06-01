---
title: "DATUM Gateway datum_stratum_dupes.c — Composite-Key Dupe Filter"
source_url: https://raw.githubusercontent.com/OCEAN-xyz/datum_gateway/master/src/datum_stratum_dupes.c
source_type: source-file
upstream: OCEAN-xyz/datum_gateway
branch: master
date_fetched: 2026-06-01
ingested_by: path2
research_path: path2-sv1-asic-leg
quality_score: 8
tags: [datum, datum-gateway, share-validation, dupe-detection, hash-table, c-source]
related_concepts: [sv2-downstream-replacement, share-validation-pipeline]
---

# datum_stratum_dupes.c — share dedup filter, with sizing math

The dupe filter is the **fifth check** in the share validation pipeline (after
PoW, target, stale prevblock, ntime bounds; before the upstream forward).
Single-purpose module, ~1 page of code, but the data structure choice and
sizing heuristics are worth preserving in any SV2 variant.

## Composite key (six fields, all must match)

A submitted share is "the same as" a previously seen share iff all of:

1. `nonce` — full 32-bit
2. `job_index` — short (per-thread job ring index)
3. `ntime` — block timestamp
4. `version_bits` — version-rolling output
5. `extranonce_a` — first 8 bytes of full extranonce (extranonce1 lives here)
6. `extranonce_b` — bytes 8–11 of full extranonce

This composite is the **only** mechanism preventing extranonce1 collisions
from poisoning accept counts (recall: extranonce1 is just `(thread<<22 |
client) ^ 0xB10CF00D` — collision-free by construction within a gateway
instance, but the dupe key is what catches replay).

## Data structure — bucketed linked-list hash table

```
dupes->index[65536]   // hash bucket head, keyed on upper 16 bits of nonce
dupes->ptr[]          // contiguous backing array of T_DATUM_STRATUM_DUPE_ITEM
```

- Each bucket is a linked list **sorted by lower 16 bits of nonce**
- Backing storage is one contiguous array (cache-friendly)
- Source comment: *"This is more contrived than it needs to be, although
  it profiles quite well."* — performance is documented as the rationale.

## Sizing & eviction

- Initial capacity:
  `max_clients × vardiff_target_shares × stale_window_minutes × 16`
  (with defaults: `1024 × 8 × 2 × 16 = 262144` slots)
- **Grows by 25%** when full: `new_max = (max * 125) / 100`
- **Cleanup** triggered when `current >= max`: removes entries older than
  `share_stale_seconds` (default 120s)
- **Re-grows** if cleanup freed less than 5% — implicit acknowledgment that
  high-rate steady-state miners can keep the table near-full

## Thread-safety

**Not lockless, not internally locked** — the module assumes the **caller
holds the relevant per-thread lock**. Aligns with the surrounding
`T_DATUM_STRATUM_THREADPOOL_DATA` model: each thread has its own dupe
table state.

## Public API

```c
void datum_stratum_dupes_init(void *sdata_v);
bool datum_stratum_check_for_dupe(
    T_DATUM_STRATUM_THREADPOOL_DATA *t,
    unsigned int nonce,
    unsigned short job_index,
    unsigned int ntime_val,
    unsigned int version_bits,
    unsigned char *extranonce_bin
);
void datum_stratum_dupes_cleanup(T_DATUM_STRATUM_DUPES *dupes, bool full_wipe);
```

The check function returns the dupe verdict; integration in
`client_mining_submit()` is at lines 1290-1295.

## SV2-downstream relevance

The composite-key dupe filter is **protocol-agnostic** and should be
preserved as-is in an SV2 variant, with the key adjusted to:

- `(channel_id, sequence_number, ntime, version_bits, extranonce)` —
  SV2 share submissions carry a `sequence_number` per channel which
  collapses several fields.
- For `SubmitSharesExtended`, the extranonce is supplied by the miner;
  for `SubmitSharesStandard`, it's implicit per-channel.

The bucket-on-nonce-high-16 heuristic still works (32-bit nonce hasn't
changed). The 65536-bucket × linked-list pattern transfers cleanly to
Rust as `Vec<Vec<DupeEntry>>` or a `HashMap<u32, SmallVec<DupeEntry>>`.

The **sizing formula** must be re-derived: under SV2, "max_clients"
becomes "max_channels", which is potentially much larger because a
single TCP connection can host many channels (extended channels carry
many miners behind one connection). Memory pressure on the dupe table
goes up.

## Justification

Concrete recipe for the dupe-detection layer of an SV2 share-validation
pipeline. The composite key, sizing math, and per-thread locking model
are reusable; the formula needs adjustment for SV2's channel-vs-connection
asymmetry.
