---
title: "eclair #2861 + Phoenix — on-the-fly funding (splice OR dual-fund toward client) DEPLOYED"
source: "https://github.com/ACINQ/eclair/pull/2861"
source_secondary: "https://acinq.co/blog/phoenix-splicing-update"
source_tertiary: "https://bitcoinops.org/en/topics/liquidity-advertisements/"
type: article
subtype: impl-docs
retrieved: 2026-07-23
merged: 2024-09-25
tags: [lightning, eclair, phoenix, on-the-fly-funding, splicing, dual-funding, liquidity-ads, lsp, deployed]
credibility: high-med
evidence_strength: implementation
direction: "supports (thesis #3 mechanism) BUT bounds the actor — the deployed reality is a WALLET-LSP (Phoenix/phoenixd), not a mining pool"
bears_on: [pool-provisions-miner-inbound-via-splice]
summary: "The mechanism thesis #3 names is not merely spec'd but MERGED and SHIPPED. ACINQ/eclair PR #2861 ('Implement on-the-fly funding based on splicing and liquidity ads') merged 2024-09-25; it is the engine behind Phoenix via lightning-kmp. On an incoming payment that can't be relayed for lack of liquidity, eclair proposes funding (will_add_htlc), signs a splice (if a channel exists) or a dual-funded open (if not) toward the client, waits for channel_ready/splice_locked, then relays the held payment inward collecting the liquidity fee from it. Phoenix: on-chain deposits splice into the existing channel or dual-fund a new one; the fee is now just the on-chain mining fee (dropped from 1%/3000 sat). Optech confirms. But every deployment is a wallet-LSP; NO mining pool does this."
---

# eclair #2861 + Phoenix — on-the-fly funding, deployed

The proof that thesis #3's mechanism is shipped, not hypothetical — but that the shipping
actor is a **wallet-LSP**, not a mining pool.

## eclair PR #2861 — MERGED 2024-09-25

> (PR desc) "Implement the on-the-fly funding protocol specified in lightning/blips#36:
> when a payment cannot be relayed because of a liquidity issue... we send a funding
> proposal (`will_add_htlc`)... Once a matching funding transaction is signed... we wait
> for the additional liquidity to be available (once the channel is ready or the splice
> locked). We will then frequently try to relay the payment to get paid our liquidity
> fees."

Corroboration in ACINQ/lightning-kmp (Phoenix's engine): `HtlcTlv.kt` comment — "When
on-the-fly funding is used, the liquidity fees may be taken from HTLCs relayed after
funding"; `LiquidityPolicy.kt` / `Peer.kt` handle "accept on-the-fly funding requests."

Optech: "Eclair #2861 implements on-the-fly funding using liquidity ads with either
dual-funding or splicing." (https://bitcoinops.org/en/topics/liquidity-advertisements/)

## Phoenix — the shipped wallet

> (ACINQ blog) "If there is already a channel, the funds will be spliced in and the
> capacity of the channel will grow by that amount. Otherwise, a new channel will be
> created using dual-funding."

Fee model shift: "the 1% / 3000 sat fee is replaced by the mining fee for the underlying
on-chain transaction"; "mining fees are paid by the user"; "we are moving from N
UTXOs/user to 1 UTXO/user." `phoenixd` "is the server equivalent of the popular phoenix
wallet."

## Bearing on thesis #3

- **Supports the mechanism:** a funder can, in production today, splice *or* dual-fund
  *toward* a recipient who lacks inbound and net the cost from the incoming payment.
- **Bounds the actor:** this is Phoenix/phoenixd — a **wallet-LSP**. The pool-as-LSP
  specialization (funder = pool, client = miner, payment = payout) is *unbuilt*. See the
  [[2026-07-23-no-pool-does-this-negative-result|negative-result note]].
- **Fee incidence:** in Phoenix the **receiver** (miner-analog) pays the mining fee. For
  the thesis to *benefit* the miner, the pool must eat that fee or net it against a payout
  the miner would want inbound for anyway.

Cross-refs:
[[../papers/2026-07-23-blip36-on-the-fly-funding|bLIP-36]] ·
[[../papers/2026-07-23-blip52-jit-and-pushmsat-omitted|bLIP-52 + push_msat]] ·
[[../../wiki/concepts/pool-as-lsp-inbound-provisioning|pool-as-LSP provisioning]]
