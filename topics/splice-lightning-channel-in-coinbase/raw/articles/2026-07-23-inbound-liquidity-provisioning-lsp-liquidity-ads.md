---
title: "Inbound liquidity provisioning — dual funding, liquidity ads, LSPS1/LSPS2"
source: "https://bitcoinops.org/en/topics/dual-funding/"
extra_sources:
  - "https://bitcoinops.org/en/topics/liquidity-advertisements/"
  - "https://github.com/lightning/blips/blob/master/blip-0051.md"
  - "https://github.com/lightning/blips/blob/master/blip-0052.md"
  - "https://river.com/learn/terms/i/inbound-liquidity/"
type: article
subtype: aggregator-spec
retrieved: 2026-07-23
tags: [lightning, inbound-liquidity, outbound-liquidity, dual-funding, liquidity-ads, lsps1, lsps2, jit-channel, bLIP-51, bLIP-52]
credibility: high-med
evidence_strength: spec
direction: "reframes follow-up thesis #3 — the actual inbound-liquidity mechanisms are NEITHER thesis option; they require a counterparty to contribute funds toward the miner"
bears_on: [splice-in-vs-bolt12-miner-liquidity]
summary: "Defines inbound vs outbound liquidity and enumerates the mechanisms that actually grant a miner INBOUND (receive) capacity: dual funding (peer contributes), liquidity advertisements (BOLT #7 option_will_fund lease), LSPS1/bLIP-51 (client purchases a channel from an LSP), and LSPS2/bLIP-52 JIT channels (LSP opens a channel in response to an incoming payment). All require a COUNTERPARTY's funds on the far side — which is exactly what splicing your own coinbase cannot do. Reframes the thesis: for the 'inbound liquidity' goal, both thesis options are the wrong tool."
---

# Inbound liquidity provisioning — the third option

## Definitions

- **Outbound liquidity = your local balance** = your capacity to **send**.
  Created when *you* fund a channel (or splice your own funds in).
- **Inbound liquidity = the counterparty's balance** = your capacity to **receive**.
  Created only when *someone else's* funds land on the far side.

> Dual funding (Optech): "receivers who open a new single funded channel can't use it
> to receive funds until they've spent funds. … One solution to this problem is to
> allow channels to be dual funded, immediately allowing spending in either direction
> once the channel opens." … "a merchant who wants to be able to receive a significant
> amount of bitcoins may only need to contribute a small part of the total channel
> capacity." *(bitcoinops.org/en/topics/dual-funding/)*

## The inbound-provisioning mechanisms (all counterparty-funded)

- **Liquidity advertisements** (BOLT #7 `option_will_fund`): "an experimental feature
  of LN that allows a node to publicize its willingness to contribute funds (liquidity)
  to a new channel requested by a remote peer." The purchaser "pays the lease fee using
  a dual-funded channel open." Eclair (#2861) implements on-the-fly funding "with
  either dual-funding **or splicing**." *(bitcoinops.org/en/topics/liquidity-advertisements/)*
- **LSPS1 / bLIP-51** — client purchases a channel from an LSP directly;
  `lsp_balance_sat` = "How many satoshi the LSP will provide on their side" (that becomes
  the client's inbound). *(github.com/lightning/blips/blob/master/blip-0051.md)*
- **LSPS2 / bLIP-52 (JIT channels)** — "A 'JIT Channel' is a channel opened in response
  to an incoming payment from the public network to a client, via the LSP. This allows a
  client with no Lightning channels to start receiving on Lightning."
  *(github.com/lightning/blips/blob/master/blip-0052.md)*

## Bearing on the thesis

This is the analytical hinge: a miner who "wants LN liquidity" **to receive payouts**
needs **inbound**, and *neither* thesis option provides it —

- **Splice-in of own coinbase** → outbound only (BOLT #2: contribution credits the
  sender's own balance).
- **Receiving a BOLT12 payout** → *consumes* inbound, doesn't create it.

The inbound must come from a **counterparty** contributing funds: an LSP, a
liquidity-ad seller, or a dual-fund/JIT peer. Elegant convergence: on-the-fly funding
can settle "with either dual-funding **or splicing**" — so a **pool splicing its own
funds toward the miner** (its side) *would* create the miner's inbound. That is the
OCEAN-style external-funding pattern, **not** self-splicing.

Cross-ref: [[../../wiki/concepts/inbound-vs-outbound-liquidity|inbound vs outbound liquidity]].
