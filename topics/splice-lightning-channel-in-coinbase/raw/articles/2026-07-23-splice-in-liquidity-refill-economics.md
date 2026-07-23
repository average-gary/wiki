---
title: "Splice-in for liquidity refill — economics, zero-downtime, one-UTXO self-custody"
source: "https://acinq.co/blog/phoenix-splicing-update"
extra_sources:
  - "https://bitcoinops.org/en/topics/splicing/"
  - "https://docs.corelightning.org/reference/splicein"
  - "https://www.spark.money/research/splicing-lightning-channels"
  - "https://www.lightspark.com/glossary/splicing"
type: article
subtype: impl-docs-practitioner
retrieved: 2026-07-23
tags: [splicing, splice-in, phoenix, acinq, core-lightning, liquidity-refill, capital-efficiency, self-custody, mining-fee]
credibility: med-high
evidence_strength: docs
direction: "supports the splice side of follow-up thesis #3 — zero downtime, single on-chain footprint, one-UTXO self-custody; but each splice costs an on-chain fee"
bears_on: [splice-in-vs-bolt12-miner-liquidity]
summary: "Splice-in tops up a live channel from an on-chain UTXO with zero downtime and a single on-chain tx (vs close+reopen = two txs + downtime). ACINQ's Phoenix uses splice-in to move from N UTXOs/user to 1 UTXO/user ('current optimum for self-custody'), replacing the 1%/3000-sat channel-open fee with just the mining fee. CLN splicein takes funds from your own wallet into your side (outbound). The cost model: one on-chain fee PER splice event — cheap for large infrequent rewards, uneconomic for dust-sized frequent ones."
---

# Splice-in for liquidity refill

## The mechanism's advantages (splice side)

- **Zero downtime / funds stay usable while confirming** — Optech: splicing transfers
  funds between on-chain and channel "without the channel participants having to wait
  for a confirmation delay to spend the channel's other funds";
  "the channel participants can safely spend the old funds within the channel while
  waiting for the close and open transactions to confirm."
  *(bitcoinops.org/en/topics/splicing/)*
- **One on-chain tx instead of two (close+reopen)** — Lightspark: "your channel remains
  active for sending and receiving payments throughout the entire resizing procedure.
  This means no downtime."
- **Self-custody consolidation to 1 UTXO/user** — ACINQ Phoenix: "The new version will
  not create new channels, instead it will 'splice-in' funds to your existing channel."
  … "we are moving from N UTXOs/user to 1 UTXO/user. It is simply the current optimum
  for self-custody on Bitcoin." … "the 1% / 3000 sat fee is replaced by the mining fee
  for the underlying on-chain transaction." *(acinq.co/blog/phoenix-splicing-update)*
- **CLN `splicein`** — "the command to add funds to a channel. It takes `amount` funds
  from your onchain wallet and places them into `channel`."
  *(docs.corelightning.org/reference/splicein)* → funds land on **your** side = outbound.
- **Refill from realized rewards** — Spark: "A routing node operator can monitor channel
  utilization and splice in additional funds when a channel consistently routes near its
  capacity limit." *(spark.money/research/splicing-lightning-channels)*

## The cost model (the against-side within the splice option)

- Each splice-in is an **on-chain transaction paying a mining fee** (ACINQ, above). So
  **splice cadence = on-chain-tx cadence**. This is cheap when the reward dwarfs the fee
  (industrial farm, block-sized matured payout) and **uneconomic** when the per-payout
  accrual is smaller than the fee (small/solo miner) — see
  [[2026-07-23-inbound-liquidity-provisioning-lsp-liquidity-ads|inbound provisioning]]
  and Optech "uneconomical outputs" (dust limit ~546 sats).
- Multi-implementation maturity: CLN native `splicein`/`spliceout`, ACINQ eclair/Phoenix,
  LDK, and LND all ship splicing (LND version attribution via secondary sources —
  treat as med).

## Bearing on the thesis

Splice-in genuinely wins on **finality, self-custody, no-downtime, single-tx capital
efficiency** — but only for **outbound** capacity from **larger, less-frequent matured**
rewards. It adds *no inbound* and costs an on-chain fee per event, so **frequent
dust-sized payouts favor off-chain BOLT12 accrual**. This is the crux of the
conditions map. See [[../../wiki/topics/splice-vs-bolt12-verdict|verdict]].
