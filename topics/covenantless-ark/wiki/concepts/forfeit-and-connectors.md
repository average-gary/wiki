---
title: "Forfeit transactions and connectors"
type: concept
created: 2026-07-16
updated: 2026-07-17
confidence: high
volatility: hot
verified: 2026-07-17
sources:
  - raw/papers/2026-07-16-foundations-ark-litepaper.md
  - raw/articles/2026-07-16-implementations-arkade-os-docs.md
  - raw/repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md
  - raw/repos/2026-07-16-implementations-arkd-go-source.md
  - raw/articles/2026-07-16-foundations-roose-delving-clark-policies.md
  - raw/articles/2026-07-16-evolution-roose-hark-erk.md
  - raw/articles/2026-07-17-second-docs-learn-forfeits.md
  - raw/articles/2026-07-17-bark-repo-docs-offboard-swaps.md
tags: [ark, clark, forfeit, connector, hashlock, atomicity, sighash-all, anchor, refresh, hark, preimage]
aliases: [forfeit transaction, connector, hash-lock forfeit]
summary: "How a user hands back an old VTXO atomically with receiving a new one: the forfeit transaction, made valid only when the round/payment confirms via a connector output (arkd, and bark on-chain payments) or a hash-lock preimage (bark rounds/hArk). Also the fraud-penalty mechanism. Under the live January-2026 hArk, round forfeits commit only to a preimage/hash rather than the whole funding tx."
---

# Forfeit transactions and connectors

When a user **refreshes** a VTXO in a [[clark-round-lifecycle.md|round]], they receive a new VTXO (a leaf in the new [[vtxo-and-vtxo-tree.md|tree]]) and hand their **old** VTXO back to the ASP. The **forfeit transaction** is how the user relinquishes the old VTXO, and **connectors** (or hash-locks) are what make that exchange **atomic** — the ASP can only claim the old VTXO if the new round transaction confirms.

## The trust problem being solved

Without an atomicity mechanism, a user might forfeit an old VTXO but never receive the new one (or vice-versa). The forfeit must become valid **only when the reissuing round's on-chain transaction confirms**.

## Forfeit transaction structure

Two inputs, and (in arkd) two outputs ([[../../raw/articles/2026-07-16-implementations-arkade-os-docs.md|Arkade docs]], [[../../raw/repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md|DeepWiki]], [[../../raw/repos/2026-07-16-implementations-arkd-go-source.md|arkd source]]):

- **Input 1**: the VTXO being forfeited
- **Input 2**: a **connector** output the operator controls
- **Output 1**: forfeit output to the operator
- **Output 2**: anchor output (arkd builds forfeits at **transaction version 3 / TRUC** with a P2A anchor for CPFP fee-bumping)

"Each forfeit transaction requires exactly two inputs" — the connector requirement is what enforces atomicity. In the litepaper's construction, Bob signs the forfeit with `SIGHASH_ALL`, so "Bob's signature is only valid for this specific forfeit transaction, containing the anchor output. In other words, the forfeit transaction is only valid if [the commitment tx] is included onchain" ([[../../raw/papers/2026-07-16-foundations-ark-litepaper.md|litepaper §4.4]]).

## Connectors (litepaper Def 4.8)

A **connector** is a Taproot output with an unspendable key path whose spend tree has leaves that are dust **anchor outputs**. The connector tree hangs off the commitment tx's **output index 1** ([[../../raw/repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md|DeepWiki]]). Because "a connector thus encapsulates all the anchor outputs serving as inputs to forfeit transactions that can only be included onchain if the commitment transaction containing that connector is included onchain," the forfeit is bound to the round's confirmation. Unlike the VTXO tree, the connector tree's virtual transactions are **signed only by the operator**. arkd builds it via `BuildConnectorTree` with **connector tree radix = 4**.

Roose describes the connector as "a special-purpose descendant of the next round's funding tx," giving the same guarantee: "the server can only enforce the forfeit if the next round successfully confirmed" ([[../../raw/articles/2026-07-16-foundations-roose-delving-clark-policies.md|Delving #1602]]).

## The forfeit's two spend paths (bark)

bark's newer docs make the forfeit's own script explicit ([[../../raw/articles/2026-07-17-second-docs-learn-forfeits.md|bark forfeits]]): a forfeit is "pre-signed transactions used in refreshes and on-chain payments to grant the Ark server control over the VTXOs being spent," and the underlying exit transaction has **two spend paths**:

- **Path 1 (server-controlled)** — a **2-of-2 multisig (user + server) with no timelock**. The user pre-signs *this* path as the forfeit, so the server can broadcast immediately if the user's exit appears on-chain.
- **Path 2 (user emergency exit)** — controlled solely by the user, behind a relative **CSV timelock of `vtxo_exit_delta` blocks**.

The no-timelock server path being broadcastable *before* the user's CSV-delayed exit matures is exactly what makes the fraud penalty enforceable (see below).

## Two atomicity designs — the key implementation divergence

The two clArk lineages differ on how a forfeit is bound to confirmation ([[../../raw/articles/2026-07-17-second-docs-learn-forfeits.md|bark forfeits]]):

- **arkd / Arkade**: connectors are used for **both** round forfeits and on-chain payments.
- **Second's `bark`**: **rounds use hash-locks** — "the server generates a preimage for each VTXO, sharing only its hash," and both the new VTXO and the forfeit carry hash-lock conditions so "neither can be used on-chain without providing the preimage." Crucially this is symmetric: if the server withholds the preimage the user can still exit their old VTXO, and the server revealing the preimage on-chain to claim the old VTXO **simultaneously grants the user access to their new VTXO**. **On-chain payments (and offboards) still use connectors** — "connectors ensure that a user's forfeit is only valid if the corresponding on-chain payment is confirmed."

### hArk changes what the round forfeit commits to

Under the **live January-2026 hArk** enhancement, "forfeits only commit to a single unlock **preimage/hash**" — the hash guarding release of the newly issued VTXOs — rather than committing to the entire round funding tx as connector-bound forfeits did ([[../../raw/articles/2026-07-17-bark-repo-docs-offboard-swaps.md|offboard-swaps]]). This is the mechanism enabling hArk's **non-interactive refresh**, but it also breaks the old trick of bundling an offboard into a round (the forfeit no longer automatically commits to an added offboard output), which is why bark proposes **connector swaps** for instant offboards — see [[offboarding-and-onchain-payments.md|offboarding and on-chain payments]] and [[../topics/clark-vs-covenant-ark.md|clArk vs covenant Ark]].

## Forfeit vs exit — the penalty mechanism

The forfeit path is also clArk's **fraud penalty**. If a user tries to unilaterally exit a VTXO they already forfeited in a later round, the operator uses the forfeit tx (via the connector + a `MultisigClosure`/`CLTVMultisigClosure` requiring both signatures) to claim those funds. An honest unilateral exit instead uses the `CSVMultisigClosure` path. Correct ordering is guaranteed by the relative timelock `Δt`: the forfeit must be broadcastable *before* the exit branch matures ([[../../raw/repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md|DeepWiki]], [[../../raw/articles/2026-07-16-evolution-roose-hark-erk.md|Roose hArk/Erk]]). See [[unilateral-exit-and-timeouts.md|unilateral exit]].

## See also

- [[clark-round-lifecycle.md|Round lifecycle]]
- [[unilateral-exit-and-timeouts.md|Unilateral exit and timeouts]]
- [[checkpoint-transactions.md|Checkpoint transactions]]
- [[offboarding-and-onchain-payments.md|Offboarding and on-chain payments]]
- [[../topics/clark-vs-covenant-ark.md|clArk vs covenant-based Ark]]
- [[../topics/clark-round-transaction-mechanics.md|Round transaction mechanics (synthesis)]]

## Sources

- [Ark litepaper §4.4](../../raw/papers/2026-07-16-foundations-ark-litepaper.md) — SIGHASH_ALL forfeit binding, connector Def 4.8
- [Arkade docs](../../raw/articles/2026-07-16-implementations-arkade-os-docs.md) — forfeit two-input/two-output structure
- [DeepWiki — exit and rounds](../../raw/repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md) — connector tree at output index 1, forfeit-vs-exit penalty ordering
- [arkd Go source](../../raw/repos/2026-07-16-implementations-arkd-go-source.md) — TRUC/v3 forfeits, `BuildConnectorTree` radix 4
- [Roose, Delving #1602](../../raw/articles/2026-07-16-foundations-roose-delving-clark-policies.md) — connector as a descendant of the next round's funding tx
- [Roose — hArk / Erk](../../raw/articles/2026-07-16-evolution-roose-hark-erk.md) — forfeit ordering relative to the exit timelock
- [Ark forfeits (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-forfeits.md) — two exit-tx spend paths; hash-lock (rounds) vs connector (payments) atomicity
- [Offboard Swaps (bark docs/offboard-swaps.md)](../../raw/articles/2026-07-17-bark-repo-docs-offboard-swaps.md) — hArk forfeits commit only to a preimage/hash
