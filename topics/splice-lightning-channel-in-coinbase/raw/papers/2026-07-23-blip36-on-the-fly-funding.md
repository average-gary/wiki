---
title: "bLIP-36 — On-the-fly channel funding (dual-funding OR splicing toward a recipient, fee from the relayed payment)"
source: "https://github.com/lightning/blips/pull/36"
type: paper
subtype: spec
retrieved: 2026-07-23
verified_verbatim: false
verification_note: "Quotes captured by the Supporting agent from the in-flight bLIP-36 PR text (t-bast/blips@on-the-fly-funding). Treat as spec-draft; the funding_fee TLV type number and payment_type constants may shift before merge. The mechanism is corroborated verbatim by the merged eclair impl (#2861) and by bLIP-52."
tags: [lightning, blip36, on-the-fly-funding, dual-funding, splicing, liquidity-ads, funding-fee-tlv, inbound, fusion]
credibility: high
evidence_strength: spec-draft
direction: "supports (thesis #3) — specifies verbatim a funder creating an on-chain tx (dual-fund OR splice) TOWARD a recipient lacking inbound, then relaying the held payment inward minus the funding fee"
bears_on: [pool-provisions-miner-inbound-via-splice]
summary: "bLIP-36 'On-the-fly channel funding' (Bastien Teinturier / ACINQ) is the strongest FOR source for thesis #3's mechanism. It specifies a funder creating an on-chain tx on-the-fly — 'using dual-funding, splicing and liquidity ads' — before relaying a payment to a recipient who lacks inbound, then collecting the funding cost from that same payment via a funding_fee TLV on update_add_htlc. This is a single-on-chain-footprint construction that fuses inbound provisioning with value delivery and deducts the cost from the first payment. The pool-as-LSP / miner-as-client / payout-as-incoming-payment mapping is a direct specialization — but bLIP-36 describes wallet-LSPs, not mining pools."
---

# bLIP-36 — On-the-fly channel funding

The strongest supporting source for [[../../wiki/topics/pool-splices-toward-miner-verdict|thesis #3]]'s
mechanism. Quotes captured by the Supporting agent from the in-flight PR; the mechanism is
independently corroborated by the **merged** eclair implementation
([[../articles/2026-07-23-eclair-2861-phoenix-on-the-fly-deployed|#2861]]) and by the
active [[2026-07-23-blip52-jit-and-pushmsat-omitted|bLIP-52 JIT spec]].

## What it specifies

> (Abstract) "Payments sent to mobile wallets often fail because the recipient doesn't have
> enough inbound liquidity to receive it. This bLIP adds a mechanism to create an on-chain
> transaction on-the-fly before relaying such payments, to allow them to be relayed once
> the on-chain transaction is accepted by both peers."

> (PR body) "This protocol uses dual-funding, splicing and liquidity ads, leveraging
> liquidity ads' extensions for paying funding fees."

## Fee is netted from the relayed payment (the fusion)

> "We define a TLV field for `update_add_htlc` that allows a relaying node to relay a
> smaller amount than the amount encoded in the onion... type: 41041 (`funding_fee`) ...
> The amount encoded in the onion will be equal to the sum of the `amount_msat` field from
> `update_add_htlc` and `fee_msat`."

> (`from_future_htlc`, payment_type 128) "When using `from_future_htlc`, the funding fees
> are not paid during the `interactive-tx` session, because the buyer doesn't have enough
> funds to do so. Fees are instead paid from HTLCs that will be relayed once liquidity has
> been added, using the `funding_fee` field."

> (flow) "After exchanging `channel_ready`: MUST relay the HTLCs matching those
> `payment_hash`es. MUST set `funding_fee` in `update_add_htlc` to collect the liquidity
> fees." (the identical requirement is given for the `splice_locked` path.)

## Why it matters for thesis #3

This is the crux resolution. The funder opens (dual-fund) **or** splices (existing
channel) via interactive-tx; the channel becomes ready; then the held-back payment is
relayed inward **minus the funding fee**. One on-chain footprint; capacity-provisioning
and value-transfer fuse *because the payment is what pays for the capacity*. The pool is a
special case: **funder = LSP, miner = client, payout = the incoming payment**.

**Caveat (see [[2026-07-23-blip52-jit-and-pushmsat-omitted|push_msat note]]):** even here
the on-chain tx supplies *capacity*; the value crosses as the relayed (off-chain) HTLC.
And bLIP-36 targets **mobile-wallet LSPs**, not mining pools — the pool-as-LSP mapping is
a novel, unbuilt specialization.

Cross-refs:
[[2026-07-23-blip52-jit-and-pushmsat-omitted|bLIP-52 JIT + push_msat omission]] ·
[[../articles/2026-07-23-eclair-2861-phoenix-on-the-fly-deployed|eclair #2861 / Phoenix]] ·
[[../../wiki/concepts/pool-as-lsp-inbound-provisioning|pool-as-LSP provisioning]]
