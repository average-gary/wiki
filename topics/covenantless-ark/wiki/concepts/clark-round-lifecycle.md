---
title: "The clArk round lifecycle"
type: concept
created: 2026-07-16
updated: 2026-07-17
confidence: high
volatility: warm
verified: 2026-07-17
sources:
  - raw/articles/2026-07-16-implementations-arkade-os-docs.md
  - raw/repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md
  - raw/articles/2026-07-16-foundations-roose-delving-clark-policies.md
  - raw/repos/2026-07-16-implementations-arkd-go-source.md
  - raw/articles/2026-07-17-second-docs-learn-rounds.md
tags: [ark, clark, round, batch-swap, lifecycle, musig2, forfeit, commitment-tx, cadence]
aliases: [round, batch swap, round lifecycle, round transaction, commitment transaction]
summary: "The periodic n-of-n ceremony that produces one on-chain round/commitment transaction rooting a fresh VTXO tree. Five phases (intent, assembly, MuSig2 tree signing, forfeit, broadcast); the load-bearing ordering (users sign tree+forfeits first, ASP broadcasts last); atomic all-or-nothing abort. bark cadence ~1-2h; arkd intent window ~30s."
---

# The clArk round lifecycle

A **round** (Ark Labs term: **batch swap**) is the periodic ceremony that produces one on-chain transaction — the **round transaction** / **commitment transaction** — whose n-of-n batch output roots a freshly pre-signed [[vtxo-and-vtxo-tree.md|VTXO tree]]. Users join a round mainly to **refresh** expiring VTXOs (spend them back to themselves) and to convert [[out-of-round-payments.md|out-of-round]] balances into canonical batch-confirmed VTXOs.

Rounds run on a configurable interval — Second's `bark` docs now state its server "is expected to conduct rounds **every 1-2 hours**, though this may vary based on demand and server policy"; arkd's intent-collection window defaults to **30 seconds** ([[../../raw/articles/2026-07-17-second-docs-learn-rounds.md|bark rounds]], [[../../raw/repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md|DeepWiki]]). All VTXOs created in one round "share the same expiry time."

## The phases (arkd's four / bark's five)

Combining both implementations' descriptions ([[../../raw/articles/2026-07-16-implementations-arkade-os-docs.md|Arkade docs]], [[../../raw/articles/2026-07-17-second-docs-learn-rounds.md|bark rounds]], [[../../raw/repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md|DeepWiki]]). bark's own five-phase list is: **(1) submit intent** — wallet comes online and submits VTXOs to refresh; **(2) tree construction** — server builds the tree and the wallet signs its exit branches; **(3) funding** — server broadcasts the round tx on-chain; **(4) forfeit** — wallet signs a forfeit to complete the refresh; **(5) claim** — the new VTXO is immediately accessible. Note bark uses **Taproot + MuSig** so "this complex script appear[s] on-chain as a simple single-signature transaction," and its round forfeits are **hash-locked** (see [[forfeit-and-connectors.md|forfeits and connectors]]).

1. **Intent collection / registration.** Users come online and submit an **intent**: the VTXOs they want to swap, the desired parameters for their new VTXOs (scripts, amounts), and **cosigner keys** (ephemeral, per-round). In Arkade these intents are BIP322 message-signed ownership proofs. Default window: 30 s (arkd).
2. **Batch assembly / commitment construction.** The operator closes registration and builds the **unsigned** commitment tx with two outputs — a **batch output** (encapsulating all participants' new VTXOs) and a **connector output** — plus the unsigned VTXO tree and connector tree.
3. **Tree signing (MuSig2).** Clients "create random nonces for every branch transaction"; the server aggregates nonces, requests partial signatures, and combines them into one Schnorr signature per tree node. See [[tree-presigning-musig2.md|tree presigning]].
4. **Forfeit linking / sign-off.** Each old input VTXO is linked via a **forfeit transaction** the user signs; the operator can only claim the old VTXO if the new commitment tx confirms. See [[forfeit-and-connectors.md|forfeits and connectors]].
5. **Broadcast & confirmation.** Only *after* it holds every forfeit does the operator sign and broadcast the commitment tx: "Once all users have signed forfeit txs for their input vtxos, the server can sign the funding tx and broadcast it" ([[../../raw/articles/2026-07-16-foundations-roose-delving-clark-policies.md|Roose, Delving #1602]]). On confirmation the new VTXOs become valid and the old ones are invalidated via forfeit.

## Signing-session ordering (the load-bearing detail)

The ordering is deliberate and is the crux of clArk's safety: **users pre-sign the tree and their forfeits FIRST; the ASP broadcasts the on-chain funding tx LAST.** This guarantees the operator never has a confirmed funding tx without the forfeits that let it reclaim the inputs, and users never forfeit an old VTXO before the tree granting the new one is fully signed. Atomicity across the swap is enforced by [[forfeit-and-connectors.md|connectors (arkd) or hash-locks (bark)]].

Concrete MuSig2 ordering ([[../../raw/repos/2026-07-16-implementations-arkd-go-source.md|arkd source]]): submit intents + cosigner pubkeys → server builds unsigned tree + commitment tx + connector tree → clients `GenNonces` per branch tx → `AggregateNonces` → clients `Sign` (partial, sorted keys + taproot sweep tweak) → `CombineSigs` → server signs commitment tx → clients `SubmitSignedForfeitTxs` → server broadcasts.

## Atomicity: all-or-nothing

A round either completes fully or aborts with **no on-chain footprint** — "If any participant fails to submit, the round is aborted" ([[../../raw/repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md|DeepWiki]]). Honest users simply retry in a later round. This atomicity is exactly what makes the round vulnerable to [[dropout-and-round-abort.md|dropout/griefing]].

## See also

- [[n-of-n-batch-output.md|The n-of-n batch output]]
- [[tree-presigning-musig2.md|Tree presigning (MuSig2)]]
- [[forfeit-and-connectors.md|Forfeit transactions and connectors]]
- [[dropout-and-round-abort.md|Dropout and round abort]]
- [[vtxo-lifetime-and-expiry.md|VTXO lifetime and expiry]]
- [[../topics/clark-round-transaction-mechanics.md|Round transaction mechanics (synthesis)]]

## Sources

- [Arkade docs](../../raw/articles/2026-07-16-implementations-arkade-os-docs.md) — arkd batch-swap phases, BIP322 intents
- [DeepWiki — exit and rounds](../../raw/repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md) — round abort, intent window, atomicity
- [Roose, Delving #1602](../../raw/articles/2026-07-16-foundations-roose-delving-clark-policies.md) — "server signs the funding tx and broadcasts it" only after holding forfeits
- [arkd Go source](../../raw/repos/2026-07-16-implementations-arkd-go-source.md) — concrete MuSig2 ordering
- [Ark rounds (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-rounds.md) — bark's five-phase lifecycle, Taproot/MuSig single-sig appearance, hash-locked forfeits, 1-2h cadence, shared expiry
