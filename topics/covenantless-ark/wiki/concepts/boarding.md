---
title: "Boarding — getting on-chain funds into a VTXO"
type: concept
created: 2026-07-16
updated: 2026-07-17
confidence: high
volatility: warm
verified: 2026-07-17
sources:
  - raw/articles/2026-07-16-implementations-second-bark-docs.md
  - raw/papers/2026-07-16-foundations-ark-litepaper.md
  - raw/repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md
  - raw/articles/2026-07-17-second-docs-learn-board.md
tags: [ark, clark, boarding, board-vtxo, funding-tx, exit-tx, cooperative, timelock, six-confirmations, chain-anchor]
aliases: [boarding, board transaction, board VTXO, onboarding]
summary: "How on-chain bitcoin enters an Ark as a board VTXO: a round-independent cooperative flow where user and server build a funding tx and pre-sign an exit tx, so the user can always exit unilaterally. The board VTXO activates after six confirmations of the funding tx (its chain anchor); atomic — funding and VTXO creation succeed or fail together."
---

# Boarding — getting on-chain funds into a VTXO

**Boarding** is how a user brings ordinary on-chain bitcoin into the Ark as a **board VTXO**. It happens **outside the normal round schedule** and is a cooperative two-transaction setup with the ASP ([[../../raw/articles/2026-07-17-second-docs-learn-board.md|bark board docs]], [[../../raw/papers/2026-07-16-foundations-ark-litepaper.md|litepaper §4.5]]). The board tx becomes the VTXO's **chain anchor** — the on-chain output its validity depends on.

## The boarding output script (litepaper)

`Taproot(False; checkSig_{pk_O ⊕ pk_A}, checkSig_{pk_A} ∧ relTimelock(t_b))`:
- **cooperative path**: Alice + operator (used to fund the VTXO into a round);
- **exit path**: Alice alone after a boarding timeout `t_b`.

The operator verifies the boarding output cannot be spent by Alice alone (only after the timeout), then includes it as an input to the next commitment tx to fund `vtxo_A`. arkd's boarding exit delay default is **7776000 s (~90 days)** — much longer than the in-Ark exit delay ([[../../raw/repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md|DeepWiki]]).

## Flow (bark) — five steps

The user and server cooperatively build a **funding transaction** and an **exit transaction** with special spending conditions, then both **pre-sign the exit tx** (which spends the funding output) so the user can exit unilaterally without server cooperation. The user broadcasts the funding tx and stores the pre-signed exit tx off-chain. The board VTXO "becomes active and spendable" after **six confirmations** of the funding tx ([[../../raw/articles/2026-07-17-second-docs-learn-board.md|bark board docs]]):

1. **Transaction creation** — user + server construct funding tx and exit tx.
2. **Exit pre-signing** — both pre-sign the exit tx.
3. **Broadcast** — user broadcasts the funding tx; stores the exit tx off-chain.
4. **Confirmation wait** — await six confirmations.
5. **VTXO activation** — the board VTXO becomes active.

Boarding is **atomic** because "the funding transaction that spends the user's on-chain bitcoin also creates the VTXO tree that grants the user emergency exit rights" — so "either both the on-chain funding and VTXO creation succeed together, or both fail together." Fees: on-chain network fee now, a future on-chain sweep fee (server covers after the board VTXO expires — see [[vtxo-lifetime-and-expiry.md|VTXO lifetime and expiry]]), and Ark server operational fees.

## See also

- [[vtxo-and-vtxo-tree.md|VTXOs and the VTXO tree]]
- [[clark-round-lifecycle.md|Round lifecycle]]
- [[unilateral-exit-and-timeouts.md|Unilateral exit and timeouts]]
- [[vtxo-lifetime-and-expiry.md|VTXO lifetime and expiry]]

## Sources

- [Ark boarding (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-board.md) — five-step flow, six confirmations, atomicity, fees
- [Ark litepaper §4.5](../../raw/papers/2026-07-16-foundations-ark-litepaper.md) — boarding output script, cooperative + exit paths
- [DeepWiki — exit and rounds](../../raw/repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md) — arkd boarding exit delay (~90 days)
- [Second/Bark docs (superseded single-file summary)](../../raw/articles/2026-07-16-implementations-second-bark-docs.md) — original boarding summary (retained for provenance; superseded by the Learn collection)
