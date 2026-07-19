---
title: p2poolv2 Accounting (deep-dive)
category: concept
created: 2026-05-24
confidence: high
tags: [p2poolv2, accounting, PPLNS, work-bounded-window, uncle-weight, atomic-swap]
volatility: warm
updated: 2026-07-15
verified: 2026-07-15
sources:
  - "raw/articles/2026-05-24-jungly-delvingbitcoin-p2share.md"
  - "raw/articles/2026-05-24-p2poolv2-pplns-with-decay-wiki.md"
  - "raw/articles/2026-05-24-p2poolv2-trading-shares-htlc.md"
  - "raw/articles/2026-05-24-p2poolv2-uncle-blocks-wiki.md"
  - "raw/repos/2026-05-24-p2poolv2-accounting-modules.md"
---

# p2poolv2 Accounting

Code-level deep-dive on the actual algorithms in `p2poolv2_lib/src/accounting/`. Companion to the higher-level [[p2pool-share-chain]] concept.

## Two implementations

`payout_distribution.rs` defines a trait `PayoutDistribution`. Two impls:

| Module | Use case | Notes |
|---|---|---|
| `simple_pplns/` | Generic proportional, no share-chain awareness | Basis-point fee deduction (`BASIS_POINT_FACTOR = 10_000`). Used by Hydrapool's basic mode. |
| `sharechain_pplns/` | Decentralized share-chain pool | Work-bounded window with uncle weighting. The "real" p2poolv2 production accounting. |

Selection is by config.

## sharechain_pplns: work-bounded window

### Constants

```rust
const MAX_PPLNS_WINDOW_SHARES: usize = 133_056;  // ~2 weeks of work
const DIFFICULTY_SCALE: u128 = 10;
const UNCLE_SCALED_WEIGHT: u128 = 9;     // 90% of base
const NEPHEW_SCALED_BONUS: u128 = 1;     // +10% per uncle referenced
```

133,056 = `6 shares/min × 60 × 24 × 14 × 1.1` (10% buffer over 2-week target).

### Data structures

- `PplnsWindow`: `VecDeque<ConfirmedEntry>` newest→oldest plus `total_accumulated_difficulty: u128`.
- `ConfirmedEntry`: `{blockhash, height, address_key, difficulty, uncle_refs, total_weighted_difficulty}`.
- `UncleEntry`: `{address_key, uncle_difficulty}`.

### Window walk (payout entry point)

```rust
fn fill_distribution_from_shares(
    &mut self,
    distribution: &mut Vec<OutputPair>,
    chain_store_handle: &ChainStoreHandle,
    total_difficulty: u128,
    remaining_total_amount: Amount,
    bootstrap_address: Address,
)
```

Walks newest→oldest, accumulating weighted difficulty until the target is crossed. Then proportional split:

```
amount_sats = (total_sats × address_weighted_difficulty / total_difficulty) as u64
```

Sorted by address string for deterministic remainder. `bootstrap_address` fallback when window empty.

### Reorg safety

A `MAX_REORG_SCAN_DEPTH` bounds the cost of deep reorgs when reorganizing the window. Allows Bitcoin-level reorg tolerance without runaway recompute.

## Uncle accounting

### Weight allocation

For a confirmed share with N referenced uncles:

| Receives credit | Weight (×10 scaled) |
|---|---|
| Confirmed share's address | `difficulty × 10 + 1 × N` |
| Each referenced uncle's address | `uncle_difficulty × 9` |

### Inclusion rules

- Up to **3 uncles per share**.
- Uncles must be within **3 share-blocks of tip**.
- No ancestor refs.
- An uncle cited by X cannot be cited by direct descendants of X (prevents double-counting).
- Uncle **coinbase outputs are spendable**; uncle non-coinbase outputs are not.

### Reorg-time chainwork

`chainwork(share) = own_work + Σ(referenced_uncles_work)`. Heaviest-tip rule for reorgs.

## Atomic-swap edge

**Trading window**: `2880 share-blocks ≤ share_age < window_expiry`.

- Shares inside the active PPLNS window cannot be traded (still earning future payouts).
- Shares older than 2880 share-blocks can be sold to market makers via HTLC.

### HTLC script forms

Both **P2WSH** (33-byte compressed pubkeys) and **P2TR** (32-byte x-only Schnorr; NUMS key-path forces script-path spending).

Three spend paths:
1. **Success** — preimage + redeemer sig. `OP_SHA256 <secretHash> OP_EQUALVERIFY` style.
2. **Mutual instant refund** — 2-of-2 cooperative cancel.
3. **Initiator refund** — `<waitTime> OP_CSV OP_DROP` then initiator sig.

### Cross-chain atomicity (Lightning bridge)

Same `payment_hash = sha256(R)` on:
- A Lightning invoice (Alice's invoice for the share value)
- A P2Pool HTLC (locking Alice's shares)

Atomic settlement when Bob pays Lightning, Alice reveals R, Bob redeems share-chain HTLC.

### What's NOT specified

- Timelock specifics: "yet to be specified."
- Market-maker fees / haircut rates: **none published**.
- Market-maker non-discrimination: **no constraint**.
- No deterministic share-buying algorithm.

## Alternative: PPLNS-with-decay

Wiki design doc, **not the production default** (used by Hydrapool's small-state path).

```
α = exp(-1/N)               # decay constant
On each share with weight w:
    D *= α                  # global decay multiplier
    S_miner[i] += w/D       # per-miner stored score
    S_total    += w/D
Real score = stored × D
Rescale when D < 1e-20
```

Memory cost: O(active miners), not O(window).

## Single-winner per share-chain block (per Jungly's delvingbitcoin summary)

- Issuance: `S = c × D_sharechain` (shares proportional to difficulty contributed).
- **Pseudorandom single-winner payout per share-chain block**: the share that satisfies share-chain difficulty becomes the payout-distributing block; previous N shares share the reward by weighted difficulty.

## Sources

- [[../../raw/repos/2026-05-24-p2poolv2-accounting-modules|p2poolv2 accounting source]] — `pplns_window.rs`, `payout.rs`, `payout_distribution.rs`
- [[../../raw/articles/2026-05-24-p2poolv2-uncle-blocks-wiki|Uncle Blocks wiki]]
- [[../../raw/articles/2026-05-24-p2poolv2-trading-shares-htlc|Trading Shares for Bitcoin]]
- [[../../raw/articles/2026-05-24-p2poolv2-pplns-with-decay-wiki|PPLNS with Decay]]
- [[../../raw/articles/2026-05-24-jungly-delvingbitcoin-p2share|Jungly's design summary]]

## See also

- [[p2pool-share-chain|p2pool / p2poolv2 share-chain (overview)]]
- [[pplns|PPLNS — original Rosenfeld 2011]]
- [[tides|TIDES (OCEAN)]] — comparison: 8×D window vs p2poolv2's 133,056 work-bounded
- [[hydrapool|Hydrapool]]
- [[../topics/p2poolv2-and-256-foundation|p2poolv2 ↔ 256 Foundation]]
