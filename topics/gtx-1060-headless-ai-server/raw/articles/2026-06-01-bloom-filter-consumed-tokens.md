---
title: "Bloom and cuckoo filters — sizing for consumed-token sets"
source: https://en.wikipedia.org/wiki/Bloom_filter
type: article
tags: [bloom-filter, cuckoo-filter, consumed-set, sizing, single-use]
date: 2026-06-01
quality: 4
confidence: high
agent: adjacent
summary: "FPR ≈ (1 − e^(−kn/m))^k; optimal k = (m/n) ln 2 yields FPR ≈ 0.6185^(m/n). 'Fewer than 10 bits per element are required for a 1% false positive probability.' Standard Bloom filters do not support deletion; counting Bloom filters use 3-4× space; cuckoo filters support deletion and beat Bloom in space at low FPR. Bitcoin's Bloom-filter wallet sync was abandoned for privacy reasons."
---

# Bloom / cuckoo filter sizing for consumed-token sets

If we ever need a memory-only consumed-set (no DB), Bloom or cuckoo filters are the right primitive. **For homelab scale, they're overkill** — redb is plenty.

## Bloom filter math

```
FPR ≈ (1 − e^(−kn/m))^k
```

- `m` = bits in filter
- `n` = inserted elements
- `k` = hash functions
- Optimal `k = (m/n) · ln(2)` → FPR ≈ `0.6185^(m/n)`

> "Fewer than 10 bits per element are required for a 1% false positive probability." — canonical result

## Sizing for the iroh app token

For 1M consumed tokens at 1% FPR:

```
m = 10 bits/token × 1M = 10 Mbit ≈ 1.25 MB
```

→ trivially fits in RAM on a 16 GB GTX 1060 server.

For 100M consumed tokens (homelab is years old, accumulated history) at 1% FPR: ~125 MB — still fine.

## False-positive cost is bounded

| FP scenario | Effect |
|-------------|--------|
| Filter says "consumed" but token is fresh | Legitimate caller re-mints. Annoying, not a security bypass. |
| Filter says "fresh" but token is consumed | Token is double-spent. **This is the security bypass.** |

→ **Bloom direction is safe**: the membership-test direction has FPs (annoying), the absence-test direction is exact (no FN).

Wait — Bloom filters have **no false negatives** but **may have false positives**:

- "in filter" → may or may not be in set
- "not in filter" → definitively not in set

For consumed-set use:
- Insert when consumed
- Test "is this consumed?"
- FP = "looks consumed but isn't" → reject legitimate token (DoS-ish, not bypass)
- FN doesn't exist — **safe direction**

## Cuckoo filter alternative

Pros:
- Supports **deletion** (Bloom does not)
- Beats Bloom on space at low FPR

Cons:
- Slightly more complex insertion (cuckoo eviction)
- Bounded load factor (~95% before insertions fail)

For the iroh app token use case, **deletion** is the killer feature: as tokens age out (past their expiry), we can remove them from the filter. With Bloom, the filter grows monotonically.

## When to actually use this

For the iroh app token wrapper, **default to redb**. Use Bloom/cuckoo if:

1. The consumed-set is too large for disk (millions+ entries with constant churn)
2. You want a memory-only fast path before redb lookup (bloom = "definitely fresh, skip DB"; bloom hit → check DB authoritatively)

## Bitcoin Bloom-filter cautionary tale

Bitcoin's Bloom-filter wallet sync (BIP 37) was deprecated for **privacy** reasons:

- Per-recipient filter lets server learn which addresses the wallet cares about
- FP rate became a privacy knob, not just an efficiency knob

→ For a server-side consumed-set, this is **not a concern** (server already knows everything). But for any iroh-app pattern that asks the server to filter a user's events, the privacy concern applies.

## See also

- [[2026-06-01-redb-sled-token-persistence]] — preferred default
- [[2026-06-01-fly-api-tokens-survey]] — random-opaque + DB pattern
