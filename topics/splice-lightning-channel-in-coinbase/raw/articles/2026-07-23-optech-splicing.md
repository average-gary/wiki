---
title: "Bitcoin Optech — Splicing (topic page)"
source: "https://bitcoinops.org/en/topics/splicing/"
type: article
subtype: authoritative-aggregator
retrieved: 2026-07-23
tags: [lightning, splicing, splice-in, splice-out, optech, implementation-timeline]
credibility: high
evidence_strength: authoritative-secondary
direction: "supports definitional framing; silent on coinbase"
bears_on: [B, C]
summary: "Optech's canonical definition of splicing (moving funds into/out of a live channel without a confirmation delay to spend the channel's other funds) plus the cross-implementation shipping timeline (Eclair, Core Lightning, LDK, Phoenix). Notably, Optech has no 'coinbase transactions' topic page — the coinbase×splice intersection is a non-topic in the authoritative literature."
---

# Bitcoin Optech — Splicing

- Definition: splicing is **"the act of transferring funds from onchain outputs
  into a payment channel, or from a payment channel to independent onchain outputs,
  without … having to wait for a confirmation delay to spend the channel's other
  funds."** (splice-in / splice-out)
- Shipping timeline: **Eclair** (2023–2026, incl. RBF + public-channel splicing),
  **Core Lightning** (experimental → Eclair interop), **LDK** (completed, incl.
  splice-out, 2025–2026), **Phoenix** wallet (via quiescence, 2024). LND is not
  listed as shipped in this data.
- **No coinbase-specific constraint** is documented, and **Optech has no "coinbase
  transactions" topic page** (`/en/topics/coinbase-transactions/` → 404; the topic
  index lists Coinjoin/Coinswap/Coinpools but no Coinbase entry).

## Bearing on the thesis

- Confirms cross-implementation consensus on the *meaning* of splicing (moving funds
  in/out of an **existing** channel). A splice presupposes a live channel — it is not
  a channel-open primitive, reinforcing that "splice in a coinbase" can only mean
  Reading C (splice-in a matured coinbase UTXO).
- The literature's silence on coinbase reflects that the intersection is simply not
  a recognized construction.
