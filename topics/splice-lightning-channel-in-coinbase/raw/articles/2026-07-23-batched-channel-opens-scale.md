---
title: "Batched channel opens & multi-channel splices — the scale axis for pool-as-LSP"
source: "https://raw.githubusercontent.com/lightning/bolts/master/02-peer-protocol.md"
source_secondary: "https://github.com/lightning/blips/blob/master/blip-0051.md"
source_tertiary: "https://lightning.engineering/api-docs/api/lnd/lightning/batch-open-channel/"
source_quaternary: "https://github.com/ElementsProject/lightning/pull/8450"
type: article
subtype: impl-docs
retrieved: 2026-07-23
tags: [lightning, interactive-tx, batching, batch-open-channel, multi-channel-splice, lsps1, scale, lnd, cln]
credibility: high-med
evidence_strength: spec+impl
direction: "supports (thesis #3 scale) — the strongest genuine 'pro'; a pool CAN batch many toward-miner opens/splices into few txs, per spec AND shipping impls"
bears_on: [pool-provisions-miner-inbound-via-splice]
summary: "The strongest genuine pro for thesis #3 and the axis the parent left open: batching. BOLT #2 interactive-tx is 'expressly designed to allow for parallel, multi-party sessions to collectively construct a single transaction... open multiple channels in a single transaction.' bLIP-51/LSPS1: an LSP 'MAY open channels in batches, opening multiple channels in one transaction.' LND BatchOpenChannel ships atomic multi-channel (single-funded) opens today. CLN PR #8450 adds multi (3+) channel splices in one tx. So a pool could provision/refill many miners' inbound in one on-chain footprint. Caveat: each channel is still its own 2-party negotiation needing all counterparties online/quiescent, and atomic batches abort wholesale if any one peer fails — coordination fragility scales with N."
---

# Batched channel opens & multi-channel splices — scale axis

The strongest genuine **pro** for [[../../wiki/topics/pool-splices-toward-miner-verdict|thesis #3]],
and the scale question thesis #2's verdict left open.

## Spec: interactive-tx multiplexes many opens into one tx

BOLT #2, Interactive Transaction Construction:

> "This protocol is expressly designed to allow for parallel, multi-party sessions to
> collectively construct a single transaction. This preserves the ability to open multiple
> channels in a single transaction."

Each channel remains its own 2-party negotiation, but N negotiations can be multiplexed
into one funding transaction.

## LSPS1 (bLIP-51): LSPs MAY batch

> "MAY open channels in batches, opening multiple channels in one transaction."

And the dual construction that makes payout+inbound-in-one-order real:

> "`lsp_balance_sat` — How many satoshi the LSP will provide on their side." (= miner
> inbound) / "`order_total_sat` ... MUST be the `fee_total_sat` plus the
> `client_balance_sat` requested." (`client_balance_sat` = value pushed to the client.)

Note the fee model is *inverted* from a payout context: in LSPS1 the **client** pays
`fee_total_sat` upfront. In a payout, the pool would net the fee out of what it owes.

## Shipping implementations

- **LND `BatchOpenChannel`** — "attempts to open multiple single-funded channels in a
  single transaction in an atomic way... either all channel open requests succeed at once
  or all attempts are aborted if any of them fail." *Caveat: single-funded — all capacity
  from the pool, giving miners inbound with no push unless combined with a routed payment.*
- **CLN PR #8450** — "Enables multi channel splices in splice script"; "Added support for
  multi (ie 3+) channel splices." *The existing-channel refill branch can also be batched.*

## Bearing on thesis #3

- **Materially strengthens scale:** batching is real per spec and in two shipping impls, so
  the O(1 tx per batch) provisioning footprint is achievable.
- **But:** atomicity is double-edged — one failing/offline peer aborts the whole batch, and
  splices additionally require each channel quiescent with both peers live. Coordination
  fragility grows with N (rhymes with the n-of-n dropout problem in
  [[../../../ark-boarding-sv2-mining/_index|ark-boarding-sv2-mining]]).
- **Footprint still capex, not per-payout:** even batched, this is one-time
  capacity-provisioning, not zero-on-chain-per-payout value transfer — it does not "beat"
  BOLT12 on per-payout footprint; they operate at different layers.

Cross-refs:
[[../../wiki/concepts/pool-as-lsp-inbound-provisioning|pool-as-LSP provisioning]] ·
[[2026-07-23-eclair-2861-phoenix-on-the-fly-deployed|eclair/Phoenix deployed]]
