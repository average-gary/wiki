---
title: "Bitcoin Optech — Zero-conf channels"
source: "https://bitcoinops.org/en/topics/zero-conf-channels/"
type: article
subtype: authoritative-aggregator
retrieved: 2026-07-23
tags: [lightning, zero-conf, option_zeroconf, confirmations, coinbase-maturity]
credibility: medium
evidence_strength: authoritative-secondary
direction: "opposes Reading B (closes the zero-conf loophole)"
bears_on: [B]
summary: "Zero-conf channels let funds move before confirmation on the funder's good-faith not to double-spend, but assume eventual confirmation is the normal path. This does NOT repair a coinbase funding output, which is not merely unconfirmed but UNSPENDABLE for 100 blocks — so even the zero-conf trust model cannot enable a force-close during the maturity window."
---

# Bitcoin Optech — Zero-conf channels

- Zero-conf lets funds move before confirmations, resting entirely on the funder's
  good faith not to double-spend; funds are **"not secure until the channel open
  transaction receives a sufficient number of confirmations."**
- The model **assumes eventual confirmation is the normal path.**

## Bearing on the thesis (closes a Reading B loophole)

- "Just treat the fresh-coinbase-funded channel as zero-conf" fails: a coinbase
  funding output isn't merely *unconfirmed* — for 100 blocks it is *unspendable*
  under consensus (`bad-txns-premature-spend-of-coinbase`). The tx that would let a
  party unilaterally force-close cannot be mined at all during that window.
- Zero-conf trust tolerates **delayed confirmation**, not **100-block
  unspendability** of the funding. So zero-conf does not rescue a fresh-coinbase-
  funded channel's enforceability.
