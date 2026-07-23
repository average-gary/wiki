---
title: "Mining-payout-to-Lightning designs: OCEAN BOLT12, NiceHash, Braidpool"
source: "https://ocean.xyz/docs/lightning"
source_extra:
  - "https://www.nicehash.com/support/mining-help/earnings-and-payments/nicehash-mining-lighting-network-payouts"
  - "https://pool2win.github.io/braidpool/"
type: article
subtype: project-docs
retrieved: 2026-07-23
tags: [mining, lightning, payouts, ocean, bolt12, nicehash, braidpool, one-way-channels]
credibility: medium
evidence_strength: project-docs
direction: "nuances (real designs route AROUND the naive claim)"
bears_on: [B, C]
summary: "Every production 'block-reward-to-Lightning' system avoids funding a channel from a coinbase. OCEAN and NiceHash pay mining rewards as off-chain LN payments (OCEAN via BOLT12 offers, on-chain fallback at a threshold); Braidpool uses one-way payment channels settled from accumulated matured rewards (UHPO). The pool receives block rewards on-chain, then sends sats over LN — the coinbase never funds the channel."
---

# Mining-payout-to-Lightning designs

## OCEAN / NiceHash — off-chain payout

- **OCEAN**: pays rewards over Lightning as BOLT12 offers; on-chain fallback at
  0.01048576 BTC threshold. The pool receives block rewards on-chain, then *sends
  sats over LN* — the coinbase never funds a channel.
- **NiceHash**: Lightning payouts are off-chain payments of accrued earnings, not
  coinbase-funded channels.

## Braidpool — one-way channels from matured funds

- Uses **one-way payment channels** (not standard bidirectional LN) for
  constant-blockspace miner payouts, settled from the pool's accumulated (matured)
  rewards via a UHPO (Unspent Hasher Payment Output) structure. Matured funds settle
  channels; the raw coinbase does not.

## Bearing on the thesis

- Confirms that every production "block-reward → Lightning" system routes around the
  thesis: either **off-chain payout** (no channel funded by a coinbase) or
  **matured-fund settlement** (Reading C territory). No deployed system funds or
  splices a channel with a *fresh* coinbase — reinforcing that the naive claim isn't
  how anyone does it, and revealed preference favors off-chain or matured paths.
