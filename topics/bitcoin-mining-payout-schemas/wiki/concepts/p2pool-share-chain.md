---
title: p2pool / p2poolv2 — share-chain accounting
category: concept
created: 2026-05-23
confidence: high
tags: [p2pool, p2poolv2, share-chain, decentralized, on-chain-PPLNS, work-bounded-window]
volatility: warm
updated: 2026-07-17
verified: 2026-07-17
sources:
  - "raw/articles/2026-05-23-p2pool-historical-hashrate.md"
  - "raw/articles/2026-05-24-jungly-delvingbitcoin-p2share.md"
  - "raw/articles/2026-05-24-p2poolv2-pplns-with-decay-wiki.md"
  - "raw/articles/2026-05-24-p2poolv2-trading-shares-htlc.md"
  - "raw/articles/2026-05-24-p2poolv2-uncle-blocks-wiki.md"
  - "raw/repos/2026-05-23-p2pool-and-p2poolv2.md"
  - "raw/repos/2026-05-24-p2poolv2-accounting-modules.md"
---

# p2pool / p2poolv2 share-chain

Decentralized mining pool. Coinbase outputs of the share-chain pay miners directly — **on-chain PPLNS without a custodian**.

## p2pool original (forrestv 2011)

- Launched **June 17, 2011** on bitcointalk.
- Share-chain block time: **30 seconds**.
- Payout window: `min(shares whose total work = 3× block-work, 8640)` — up to **72 hours of shares**.
- Each share-chain block is a "share." When the share-chain block also satisfies Bitcoin difficulty, it's a real Bitcoin block — the coinbase pays the previous N share-chain contributors directly.
- Endorsed by gmaxwell (Jan 2012) as "critical for the health and welfare of the Bitcoin system."

## Why p2pool declined (2014-2017)

Documented failure modes:

- **Stale-share problem.** 30-sec share-chain is 20× faster than Bitcoin's 10-min block. DOA and orphan shares "common and expected" → direct hashrate loss vs. centralized pools.
- **Dust problem.** As miners join, individual coinbase outputs shrink below cost-to-spend.
- **Hardware incompatibilities.** Cointerra and certain Antminers lost 10-20% hashrate.
- **Operational complexity.** Full node + correct FPS/intensity tuning. UX disqualified casual miners.
- **ASIC era rewarded** the low-variance PPS/FPPS model offered by centralized pools.

## p2poolv2 (2024+) — actual accounting (corrected 2026-05-24)

Code-level truth from `p2poolv2_lib::accounting/`. *See [[../../raw/repos/2026-05-24-p2poolv2-accounting-modules|the source modules]] for the actual algorithms.*

### PPLNS window: work-bounded, 133,056 shares (~2 weeks)

```rust
const MAX_PPLNS_WINDOW_SHARES: usize = 133_056;
// 6 shares/min × 60 × 24 × 14 = 120,960 + 10% buffer
```

The window is walked newest→oldest, accumulating weighted difficulty until a `total_difficulty` threshold (typically the Bitcoin block target work) is crossed.

**It is a work-bounded window, not a fixed-N count.** The earlier "top-N large miners" framing was wrong. Many addresses can be in the window; "top-N" is more accurately "everyone whose shares fall within the work-bounded window, paid proportional to weighted difficulty."

Default deployment runs a **7-day TTL** on the window (config `pplns_share_window`).

### Uncle weighting: 90% of base difficulty

```rust
const DIFFICULTY_SCALE: u128 = 10;
const UNCLE_SCALED_WEIGHT: u128 = 9;     // uncle = 90% of base
const NEPHEW_SCALED_BONUS: u128 = 1;     // +10% per uncle referenced
```

- **Confirmed share weight** = `difficulty × 10 + 1 × nephew_count`
- **Uncle weight** (credited to uncle's address) = `difficulty × 9`
- All values `u128` (integer-scaled to avoid floats)

### Uncle inclusion rules

- A share may cite **up to 3 uncles**.
- Uncles must be within **3 share-blocks of tip**.
- No ancestor refs.
- An uncle cited by share X cannot be cited by direct descendants of X.
- Uncle coinbase outputs are **spendable**; non-coinbase outputs in uncles are not.

### Payout distribution (strict proportional)

```
amount_sats = (total_sats × address_weighted_difficulty / total_difficulty) as u64
```

Sorted by address string for deterministic remainder routing. Bootstrap fallback: if `total_difficulty == 0`, all reward goes to a configured `bootstrap_address`.

### Atomic-swap edge for small miners

Coinbase output count is constrained at the deployment level (Antminer firmware caps coinbase outputs at ~12-20). p2poolv2 issue #248 targets **500**; Hydrapool ships **100**.

Small miners outside the cap get paid via **HTLC outputs on the share-chain** (P2WSH or P2TR, three branches: success / mutual instant refund / initiator refund). Cross-chain atomicity with Lightning via shared `payment_hash`. *See [[../../raw/articles/2026-05-24-p2poolv2-trading-shares-htlc|the HTLC docs]].*

**Two-window constraint**: shares are tradable only after ~2880 share-blocks (≈1 BTC day) AND before they fall inside the active PPLNS accounting window.

**Critical caveat**: timelock specifics are explicitly "yet to be specified"; market-maker fees / non-discrimination guarantees are **not formalized**.

### Alternative: PPLNS-with-decay (small-state path)

For deployments that can't afford to store every share: `α = exp(-1/N)`, score `S_miner[i] += w/D` per share, rescale when `D < 1e-20`. **Hydrapool uses this**, not the production work-bounded window.

## Two distinct systems share the codebase

| | p2poolv2 (protocol) | Hydrapool (256 Foundation) |
|---|---|---|
| Operator model | None — peer-to-peer share-chain via libp2p | Single operator (256 Foundation) |
| Custody | None (coinbase splits) | None (coinbase splits) |
| Audit | On-chain coinbase | On-chain coinbase + `/pplns_shares` API |
| Coinbase output cap | 500+ via atomic swaps (target) | ~100 in coinbase, no atomic-swap edge |
| Lead | pool2win (Jungly) | Jungly (same person) + econoalchemist |
| Status | v0.10.16, signet-default | v2.5.8, mainnet test instance |

p2poolv2 is the protocol; Hydrapool is one deployment of the same accounting library.

## Position in the post-2024 decentralization stack

Each project removes a different point of trust:

| Project | Removes |
|---|---|
| OCEAN TIDES + DATUM | Pool's custody of payouts and template construction |
| DMND SLICE | Pool's choice of block content |
| hashpool eHash | Pool's per-miner ledger |
| **p2poolv2** | **Pool operator entirely** |
| **Hydrapool** | **Pool's audit opacity** (publishes share log via API) |

## Sources

- [[../../raw/repos/2026-05-23-p2pool-and-p2poolv2|p2pool / p2poolv2 repo notes]]
- [[../../raw/repos/2026-05-24-p2poolv2-accounting-modules|p2poolv2 accounting source modules]] — primary
- [[../../raw/articles/2026-05-23-p2pool-historical-hashrate|p2pool historical hashrate]]
- [[../../raw/articles/2026-05-24-p2poolv2-uncle-blocks-wiki|Uncle blocks rules]]
- [[../../raw/articles/2026-05-24-p2poolv2-trading-shares-htlc|Trading Shares (HTLCs)]]
- [[../../raw/articles/2026-05-24-p2poolv2-pplns-with-decay-wiki|PPLNS with Decay variant]]
- [[../../raw/articles/2026-05-24-jungly-delvingbitcoin-p2share|Jungly's design summary]]

## See also

- [[p2poolv2-accounting|p2poolv2 accounting deep-dive]] — concept article on the actual algorithms
- [[hydrapool|Hydrapool — 256 Foundation pool]]
- [[../topics/payout-design-space|Payout Design Space]]
- [[../topics/decentralization-and-pool-concentration|Decentralization & Pool Concentration]]
- [[../topics/p2poolv2-and-256-foundation|p2poolv2 ↔ 256 Foundation relationship]]
- [[ctv-coinbase-payout-tree|CTV Coinbase Payout Tree]] ([CTV Coinbase Payout Tree](../concepts/ctv-coinbase-payout-tree.md)) — the CTV coinbase fanout whose MuSig-node endgame targets a P2Pool reboot; both attack the coinbase output-count cap
- Sister wiki: [[../../../sv2-p2pool-integration/_index|sv2-p2pool-integration]]
