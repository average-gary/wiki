---
title: "Block subsidy formula + coinbase value consensus ceiling (GetBlockSubsidy, bad-cb-amount)"
source_url: https://github.com/bitcoin/bitcoin/blob/master/src/validation.cpp
source_url_2: https://en.bitcoin.it/wiki/Controlled_supply
type: paper
retrieved: 2026-07-21
credibility: high
corroboration: "gap-3 agent (verbatim from Bitcoin Core source)"
tags: [bitcoin, subsidy, halving, GetBlockSubsidy, bad-cb-amount, consensus, coinbase-value, satoshis]
summary: "The exact Bitcoin Core subsidy formula (50*COIN >> (height/210000)), the consensus rule that coinbase value must be <= subsidy+fees (bad-cb-amount), the current-epoch value (3.125 BTC at height ~900k), and the per-era satoshi table."
---

# Block subsidy + coinbase value ceiling

## GetBlockSubsidy (Bitcoin Core src/validation.cpp, verbatim)

```cpp
CAmount GetBlockSubsidy(int nHeight, const Consensus::Params& consensusParams)
{
    int halvings = nHeight / consensusParams.nSubsidyHalvingInterval;
    if (halvings >= 64) return 0;              // right-shift >= width is UB; guard
    CAmount nSubsidy = 50 * COIN;              // COIN = 100,000,000 sat → 5,000,000,000
    nSubsidy >>= halvings;                     // integer-satoshi truncating shift
    return nSubsidy;
}
```

`nSubsidyHalvingInterval = 210000` (mainnet). Compute in **integer satoshis**, never
floats.

## Consensus ceiling (the "expected value" bound)

`blockReward = nFees + GetBlockSubsidy(...)`; block is invalid (**`bad-cb-amount`**) if
`coinbase.GetValueOut() > blockReward`. The coinbase may pay **less** than subsidy+fees
(pools sometimes do), but never **more**.

## Current epoch + era table

- **Height ~900,000 (mid-2026): halvings = 900000/210000 = 4 → 5,000,000,000 >> 4 =
  312,500,000 sat = 3.125 BTC.** (Epoch 4 = blocks 840,000–1,049,999; 4th halving April 2024.)
- Era 0: 50 BTC (5,000,000,000) · Era 1: 25 · Era 2: 12.5 · Era 3: 6.25 (625,000,000) ·
  **Era 4: 3.125 (312,500,000)** · Era 5: 1.5625 (156,250,000). Halving heights: 210k,
  420k, 630k, 840k, 1,050k, 1,260k...
- Subsidy → 1 sat at Era 33, then 0. The `>= 64` guard is UB-safety, not the economic zero.
  Asymptotic supply ≈ 20,999,999.9769 BTC (satoshi truncation).

## Relevance

The daemon computes the subsidy purely from the block height (read from the
[[../sv2-coinbase-verify-daemon/wiki/concepts/coinbase-transaction-anatomy|BIP34 coinbase]]
or `SetNewPrevHash`) — zero trust, zero dependencies. Fees, however, require a template
(see the SV2 Template Distribution `coinbase_tx_value_remaining` path).
