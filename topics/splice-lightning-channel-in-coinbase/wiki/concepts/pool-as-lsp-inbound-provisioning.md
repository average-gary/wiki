---
title: "Pool-as-LSP: provisioning miner inbound via toward-miner channel ops"
type: concept
created: 2026-07-23
updated: 2026-07-23
tags: [lightning, lsp, inbound-liquidity, on-the-fly-funding, jit-channel, splicing, dual-funding, mining-pool, push-msat, fusion]
summary: "The mechanism behind follow-up thesis #3: a funder (pool/LSP) contributing funds on ITS OWN side of a shared channel gives the counterparty (miner) inbound. Spec'd (bLIP-36 on-the-fly funding, bLIP-52 JIT, liquidity ads) and DEPLOYED as wallet-LSPs (Phoenix/eclair #2861). But 'unifying payout delivery + inbound provisioning in one on-chain footprint' is precise only in the JIT/on-the-fly variant, where an incoming payment triggers the open and the fee is netted from it — the on-chain tx supplies CAPACITY while VALUE crosses as an off-chain HTLC. Pure dual-funding/splice cannot carry value to the miner because push_msat is OMITTED from open_channel2. And no MINING POOL actually does this."
---

# Pool-as-LSP: provisioning miner inbound

The mechanism at the heart of [[../topics/pool-splices-toward-miner-verdict|follow-up thesis #3]].
View is always **the miner's node**; the pool plays the role a wallet-LSP plays for a
mobile wallet.

Builds directly on [[inbound-vs-outbound-liquidity|inbound vs outbound liquidity]]: only a
**counterparty** contributing funds on the far side creates the miner's inbound. Thesis #3
asks whether the *pool* can be that counterparty **and** deliver the payout in the same
on-chain footprint.

## The direction is correct

BOLT #2 credits each contribution to the contributor's own side (verified verbatim,
[[../../raw/papers/2026-07-23-bolt2-splice-balance-direction|splice balance direction]]):

> "MUST compute the channel balance for each side by adding their respective
> `funding_contribution_satoshis` to their previous channel balance."

So if the **pool** is the splice/dual-fund contributor, its funds land on the **pool's**
side of the shared channel = the **miner's inbound**. Correct direction. Interactive-tx
even lets the miner contribute `funding_satoshis` of zero — the pool can fund 100%.

## But contribution ≠ value delivered

There is **no field to credit the counterparty** in a v2 open or a splice. `push_msat`
(the only "opener unconditionally gives the receiver initial balance" primitive) is
**omitted from `open_channel2`** (verified verbatim,
[[../../raw/papers/2026-07-23-blip52-jit-and-pushmsat-omitted|push_msat note]]):

> "Note that `push_msat` has been omitted."

So a pool contributing on its side gives the miner **receive-capacity** and **zero
spendable value**. The payout must arrive as a **separate HTLC**. Within one funding
output, sats are *either* on the pool's side (miner inbound, but the pool's money — not a
payout) *or* pushed to the miner's side (a payout, but the miner's outbound — not inbound).
**The literal thesis wording — "payouts settled as funds on the pool's side" — is a
category error.**

## The one genuine fusion: JIT / on-the-fly funding

The fusion is real in exactly one construction —
[[../../raw/papers/2026-07-23-blip36-on-the-fly-funding|bLIP-36 on-the-fly funding]] /
[[../../raw/papers/2026-07-23-blip52-jit-and-pushmsat-omitted|bLIP-52 JIT]] — because the
**incoming payment itself** triggers the open and pays the fee:

> "A 'JIT Channel' is a channel opened in response to an incoming payment... have the cost
> of their inbound liquidity be deducted from their first received payment."

The funder opens (dual-fund) or splices toward the client, the channel becomes ready, then
the held payment is relayed inward **minus the funding fee** (`funding_fee` / `extra_fee`
TLV; non-standard forwards). One on-chain footprint, **one economic event** — provisioning
and payment fuse *because the payment pays for the capacity*. The precise statement:

> The on-chain tx supplies **capacity**; the payout **value** crosses as the forwarded
> off-chain HTLC that pushes balance onto the miner's side.

So "unified in one footprint" is true at the level of *one tx + one economic act* — not
"one tx literally carries the payout onto the miner's side."

## Deployed — but only as wallet-LSPs

[[../../raw/articles/2026-07-23-eclair-2861-phoenix-on-the-fly-deployed|eclair #2861]]
(merged 2024-09-25) ships this in Phoenix: on-chain deposits splice into the existing
channel or dual-fund a new one; the fee is now just the on-chain mining fee. Every
deployment is a **wallet-LSP**. No **mining pool** does it
([[../../raw/articles/2026-07-23-no-pool-does-this-negative-result|negative result]]);
OCEAN does the opposite (miner must supply their own inbound + a BOLT12 offer).

## Scale: batching works

A pool could batch many toward-miner opens/splices into few txs — BOLT #2 interactive-tx
"open multiple channels in a single transaction," LSPS1 batch opens, LND
`BatchOpenChannel`, CLN multi-channel splice
([[../../raw/articles/2026-07-23-batched-channel-opens-scale|batching note]]). But atomic
batches abort wholesale on any peer failure, and splices need every channel quiescent with
both peers live — coordination fragility scales with N. And even batched, this is
capacity-provisioning **capex**, not zero-on-chain-per-payout value transfer.

## The reframing that makes it hold

Read literally ("funds on the pool's side = the payout") → **category error**. Read as *one
economic act (JIT/on-the-fly) that opens/splices toward the miner and nets the fee from the
payout* → **real, spec'd, deployed** (as a wallet-LSP). The pool-as-LSP specialization
(funder = pool, client = miner, payment = payout) is a genuinely **novel, unbuilt**
synthesis with real conditions (fee incidence, coinbase maturity, custody, whether the
miner will *use* the inbound).
