---
title: "p2poolv2 accounting modules — pplns_window.rs, payout.rs, payout_distribution.rs"
publication: github.com/p2poolv2/p2poolv2
url: https://github.com/p2poolv2/p2poolv2/blob/main/p2poolv2_lib/src/accounting/payout/sharechain_pplns/pplns_window.rs
url2: https://github.com/p2poolv2/p2poolv2/blob/main/p2poolv2_lib/src/accounting/payout/sharechain_pplns/payout.rs
url3: https://github.com/p2poolv2/p2poolv2/blob/main/p2poolv2_lib/src/accounting/payout/payout_distribution.rs
type: repo
ingested: 2026-05-24
quality: 5
credibility: high
confidence: high
tags: [p2poolv2, accounting, PPLNS, code-level, source-truth]
---

# p2poolv2 Accounting — Code-Level Truth

The actual algorithms shipped in `p2poolv2_lib/src/accounting/`. Replaces wiki framings of "top-N" and "8×D" with the real production parameters.

## PPLNS window: 133,056 shares (~2 weeks of share-chain work)

From `pplns_window.rs`:

```rust
const MAX_PPLNS_WINDOW_SHARES: usize = 133_056;
// At 6 shares per minute over 2 weeks:
// 6 * 60 * 24 * 14 = 120,960
// Provide a 10% buffer: 120,960 * 1.1 = 133,056
```

**This is roughly one Bitcoin retarget period of share-chain work, not a fixed-N like classic p2pool's 8640.**

The payout function walks the window newest→oldest, accumulating weighted difficulty until a `total_difficulty` threshold (passed by the caller — typically the Bitcoin block's target work) is crossed. **It's a work-bounded cumulative window, not a fixed-share-count top-N.**

Default config (`config.sample.toml`): `pplns_share_window` is parameterized; default value is **7 days TTL** in the operational config — so the *default deployment* has miners' shares expire after ~7 days even though the data structure can hold 14 days' worth. The 256 Foundation Hydrapool deployment runs 7-day window.

## Uncle weighting: 90% of base difficulty

```rust
const DIFFICULTY_SCALE: u128 = 10;
const UNCLE_SCALED_WEIGHT: u128 = 9;
const NEPHEW_SCALED_BONUS: u128 = 1;
```

Integer-scaled to avoid floats. Every base difficulty is multiplied by 10. The decomposition:

- **Confirmed share weight** = `difficulty × 10 + 1 × nephew_count` — i.e. the share itself contributes 10/10ths of its base, plus a bonus of 1/10th per uncle it references (the "nephew bonus").
- **Uncle weight** (credited to the uncle's address) = `difficulty × 9` — i.e. 9/10ths = 90%.

Total system weight per share is thus: `10 × diff + 9 × Σuncles_diff + 1 × #uncles`. Sum stays inside `u128`.

### Uncle referencing rules (from project wiki "Uncle Blocks" page)

- A share may cite up to **3 uncles**.
- Uncles must be **within 3 share-blocks of tip** (recent, not ancient).
- No ancestor refs allowed.
- An uncle cited by share X cannot be cited by direct descendants of X.
- Uncle coinbase outputs are spendable; non-coinbase outputs in uncle blocks are not. Constrains accounting surface.

## Payout distribution: strict proportional

From `payout.rs::fill_distribution_from_shares`:

```
amount_sats = (total_sats × address_weighted_difficulty / total_difficulty) as u64
```

Strict proportional split by weighted difficulty inside the window. Sorted by **address string** so integer-truncation remainder is always assigned deterministically to the same address.

**Bootstrap fallback**: if `total_difficulty == 0` or the chain is empty, the entire payout goes to a configured `bootstrap_address`. This is what the signet config's `tb1qyazxde6558qj6z3d9np5e6msmrspwpf6k0qggk` address is for.

## Two implementations, selectable by config

`payout_distribution.rs` defines a trait `PayoutDistribution`. Two implementations:

| Module | Use case | Behavior |
|---|---|---|
| `simple_pplns/` | No share-chain awareness | Generic proportional distributor with `BASIS_POINT_FACTOR = 10_000` for fee deduction |
| `sharechain_pplns/` | Production decentralized pool | Work-bounded window with uncle weighting (above) |

`OutputPair { address: bitcoin::Address, amount: bitcoin::Amount }` is the wire format that flows directly into the coinbase tx outputs.

## Alternative payout formulation: PPLNS-with-decay

From the project wiki "Payouts PPLNS With Decay" page — an *alternative* shipped as a design doc but **not currently the default in the production crates**.

State:
- Per-miner stored score `S_miner[i]`
- Global stored total `S_total`
- Global multiplier `D` (starts at 1)

On each share with weight `w`:
```
D *= α            # where α = exp(-1/N), N = effective window size
S_miner[i] += w / D
S_total    += w / D
```

Real score = `stored_score × D`. Inactive miners' rows never need updating; their effective score decays automatically by virtue of D shrinking.

**Rescale** when `D < 1e-20` (or every ~1e6 shares): multiply every stored score by D, reset D = 1, to prevent f64 underflow.

This variant is appropriate when storing every share is too expensive — e.g. **Hydrapool's small-state path** uses this rather than the production work-bounded window.

## What this changes vs. earlier wiki claims

The earlier `p2pool-share-chain.md` article said:

> "Coinbase pays top-N large miners (non-custodial). Smaller miners paid via atomic-swap support transactions where market makers buy small shares for virgin coinbase coins."

**Corrections**:

1. **"Top-N" is misleading.** The actual mechanism is a **work-bounded PPLNS window** of ≤133,056 shares (~2 weeks). The window is walked until accumulated weighted-difficulty crosses `total_difficulty` — not "pick top N miners." Many addresses can be in the window; "top-N" is more accurately "everyone whose shares fall within the work-bounded window."
2. **Top-20 figure** (per Jungly on delvingbitcoin): coinbase output count is constrained at the *deployment* level (firmware caps Antminer coinbase outputs at ~12-20). Hydrapool currently caps at **100 users per coinbase**; p2poolv2 issue #248 targets **500**.
3. **"Atomic swap support transactions"** = HTLC outputs (P2WSH or P2TR, three branches: success / mutual instant refund / initiator refund). See `docs/atomic-swap/htlc_scripts.md` and the Lightning example in the same dir. NOT yet a fully-shipped protocol — timelock specifics are explicitly marked "yet to be specified."

## See also

- [[../articles/2026-05-24-p2poolv2-pplns-with-decay-wiki|p2poolv2 wiki: Payouts PPLNS With Decay]]
- [[../articles/2026-05-24-p2poolv2-uncle-blocks-wiki|p2poolv2 wiki: Uncle Blocks]]
- [[../articles/2026-05-24-p2poolv2-trading-shares-htlc|p2poolv2 wiki: Trading Shares For Bitcoin (HTLCs)]]
