---
title: "BOLT #2 — splice balance direction (funding_contribution_satoshis)"
source: "https://github.com/lightning/bolts/blob/master/02-peer-protocol.md"
raw_source: "https://raw.githubusercontent.com/lightning/bolts/master/02-peer-protocol.md"
type: paper
subtype: spec
retrieved: 2026-07-23
verified_verbatim: true
tags: [lightning, bolt2, splicing, splice-in, splice-out, channel-balance, inbound, outbound, liquidity-direction]
credibility: high
evidence_strength: spec
direction: "opposes (the 'inbound liquidity' framing of follow-up thesis #3) — spec-proves a splice-in credits the SENDER'S OWN balance = outbound, never inbound"
bears_on: [splice-in-vs-bolt12-miner-liquidity]
summary: "The BOLT #2 Channel Splicing section states verbatim that funding_contribution_satoshis is added to (splice-in) or removed from (splice-out) the SENDER'S OWN channel balance, and that each side computes its balance by adding THEIR RESPECTIVE contribution to THEIR OWN previous balance. This is the spec-level proof that splicing your own UTXO in produces outbound (send-side) capacity, never inbound — the load-bearing fact against the follow-up thesis's 'inbound liquidity' framing. Also confirms zero-downtime resume after tx_signatures."
---

# BOLT #2 — Channel Splicing: balance direction

Four verbatim passages, **re-verified against `master` on 2026-07-23** by direct
WebFetch of the raw spec (not agent recall — the verdict pivots on these):

## 1. Definition (`splice_init` message)

> "`funding_contribution_satoshis` is the amount the sender is adding to their
> channel balance (splice-in) or removing from their channel balance (splice-out)."

## 2. Splice-in requirement (positive value → sender's own balance)

> "If it is splicing funds into the channel: MUST set `funding_contribution_satoshis`
> to a positive value matching the amount that will be added to its current channel
> balance."

## 3. Per-side balance computation (`tx_complete` requirements)

> "MUST compute the channel balance for each side by adding their respective
> `funding_contribution_satoshis` to their previous channel balance."

## 4. Zero-downtime resume (after signatures)

> "Once `tx_signatures` have been exchanged, the splice transaction can be broadcast.
> The channel is no longer quiescent: normal operation can resume while waiting for
> the transaction to confirm and `splice_locked` messages to be exchanged."

## Why it's load-bearing

Quotes (1)–(3) settle the follow-up thesis's central question by construction:

- A splice-in adds sats to the **sender's own** channel balance. In LN terms, your
  side of the funding output is your **local balance = outbound (spendable-by-you)
  liquidity**.
- The spec computes each side's balance from **their respective** contribution added
  to **their previous** balance — there is *no* path by which spending your own UTXO
  credits the counterparty's side. So a miner splicing their own matured coinbase can
  only ever gain **outbound**, never **inbound**.
- The only way a splice yields the miner **inbound** is if the **counterparty**
  contributes `funding_contribution_satoshis` on *its* side (an LSP / liquidity-ad /
  dual-fund settlement) — i.e. someone else's funds, not the miner's coinbase.

Quote (4) is the genuine advantage of the splice mechanism that the supporting side
leans on: a matured UTXO can be spliced in with **zero channel downtime** and a
single on-chain footprint (vs close+reopen = two txs + downtime).

Cross-refs:
[[../../wiki/concepts/inbound-vs-outbound-liquidity|inbound vs outbound liquidity]] ·
[[../../wiki/concepts/lightning-splice-mechanics|splice mechanics]] ·
[[../../wiki/topics/splice-vs-bolt12-verdict|follow-up verdict]]
