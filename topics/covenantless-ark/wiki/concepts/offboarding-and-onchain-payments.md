---
title: "Offboarding, on-chain payments, and offboard swaps"
type: concept
created: 2026-07-17
updated: 2026-07-17
confidence: high
volatility: hot
verified: 2026-07-17
sources:
  - raw/articles/2026-07-17-second-docs-learn-offboard.md
  - raw/articles/2026-07-17-second-docs-learn-payments-on-chain.md
  - raw/articles/2026-07-17-bark-repo-docs-offboard-swaps.md
tags: [ark, clark, bark, hark, offboard, on-chain-payment, cooperative-exit, connector, forfeit, swap, withdrawal]
aliases: [offboarding, off-boarding, on-chain payments, offboard swaps, connector swaps, cooperative exit]
summary: "The cooperative way out of Ark: on-chain payments and offboarding both work by the server building a transaction with the destination output plus a connector, the user signing connector-linked forfeits, and the server broadcasting a single tx. Since the January 2026 hArk update these broadcast immediately. hArk breaks the old in-round offboard trick (forfeits now commit only to a preimage/hash), motivating proposed connector swaps that make offboards instant and deprecate round-based offboards."
---

# Offboarding, on-chain payments, and offboard swaps

> **Offboarding** is the standard, cooperative way to move value out of an Ark to an on-chain address, and it is mechanically **identical to an on-chain payment** — the only difference is that the destination is your own wallet. Both are single-transaction, server-assisted flows that users should always prefer over the multi-step [[unilateral-exit-and-timeouts|emergency exit]] ([emergency exit](../concepts/unilateral-exit-and-timeouts.md)) except when the server is unresponsive. The now-live hArk enhancement changed the plumbing here, which is why bark is designing **connector swaps** to keep offboards instant.

## On-chain payments and offboards are the same flow

An **on-chain payment** sends Ark value to an arbitrary bitcoin address; an **offboard** sends it to your own wallet (a "specific whole VTXO or your entire Ark balance"). They run the same cooperative process ([bark docs/offboard](../../raw/articles/2026-07-17-second-docs-learn-offboard.md), [bark docs/payments-on-chain](../../raw/articles/2026-07-17-second-docs-learn-payments-on-chain.md)):

1. The user specifies a recipient address + amount.
2. The server builds a transaction carrying the **requested output** *and* a **connector output**.
3. The user validates and signs **[[forfeit-and-connectors|forfeit transactions]]** ([forfeits](../concepts/forfeit-and-connectors.md)) linked to that connector.
4. The server signs and broadcasts the transaction.

**Connector atomicity**: because the user's forfeit is linked to the connector output, "the forfeit is only valid once the payment transaction is broadcast." Either the payment completes and the forfeit is valid, or neither happens — the same connector-binding used for on-chain forfeits elsewhere in clArk. If the amount does not exactly match the user's VTXO(s), the **change returns as a new VTXO**.

### The January 2026 hArk update: immediate broadcast

Since the **January 2026 hArk update**, on-chain payments (and therefore offboards) "broadcast immediately upon completion." Recipients then wait for normal blockchain confirmation (speed set by the chosen on-chain fee). This is a concrete, dated confirmation that [[clark-vs-covenant-ark|hArk is live in bark, not a proposal]] ([hArk](../topics/clark-vs-covenant-ark.md)).

## Offboarding vs emergency exit

| Aspect | Offboarding (cooperative) | Emergency exit (unilateral) |
|---|---|---|
| Server requirement | **Required** | Not required |
| Transaction count | **Single** | Multiple (tree traversal) |
| Confirmation time | One tx | Multiple sequential confirmations |
| Primary use | Normal withdrawals | Server unresponsiveness |

Offboarding is "the standard, cooperative way," and users "should always prefer offboarding" — the [[unilateral-exit-and-timeouts|emergency exit]] ([emergency exit](../concepts/unilateral-exit-and-timeouts.md)) is the costly fallback reserved for when the server will not cooperate. Fees for both offboards and on-chain payments are the same category: [[vtxo-lifetime-and-expiry|liquidity cost]] ([liquidity cost](../concepts/vtxo-lifetime-and-expiry.md)) + on-chain network fee + Ark server fees.

## How hArk broke the old in-round offboard, and offboard swaps

Before hArk, offboards were trivial to bundle into a round: "the server simply adds an output to the round's funding tx and because the **connectors commit to the entire funding tx**, users commit to the offboard in their forfeit tx" ([bark docs/offboard-swaps](../../raw/articles/2026-07-17-bark-repo-docs-offboard-swaps.md)).

hArk changes the forfeit's commitment. "With hArk, forfeits only commit to a single unlock **preimage/hash**" that guards release of the newly issued VTXOs — "there is no longer an automatic commit to the entire funding tx." So an in-round hArk offboard would need an **extra hash-based condition** on the offboard output, "making them significantly less attractive because an additional on-chain tx must be made." This is the offboard-side counterpart to how hArk reshapes forfeits generally (see [[forfeit-and-connectors|forfeits and connectors]] ([forfeits and connectors](../concepts/forfeit-and-connectors.md))).

Two proposed fixes:

- **Hash-locked swaps (naive)** — the server sends the on-chain amount to a hash-locked output; the user signs a forfeit forcing the server to reveal the preimage. Problem: the user still needs an **extra on-chain tx** to unlock.
- **Connector swaps (preferred)** — the server creates an offboard tx delivering funds to the user **plus a connector output** (the change output can double as the connector); before signing, the user signs a forfeit valid only when spent with that connector; once the server holds it, the server signs and broadcasts. Result: **instant offboards** with no round wait.

Implementation notes: new gRPC endpoints for offboard requests and forfeit-signature exchange, plus a dedicated offboard wallet (or precautions so unconfirmed offboard chains do not age enough to impede rounds). The stated end-goal is that **"round-based offboards can then be entirely deprecated."**

## See Also

- [[forfeit-and-connectors|Forfeit transactions and connectors]] ([Forfeit transactions and connectors](../concepts/forfeit-and-connectors.md)) — the connector-binding these payments rely on, and how hArk reshapes it
- [[unilateral-exit-and-timeouts|Unilateral exit and timeouts]] ([Unilateral exit and timeouts](../concepts/unilateral-exit-and-timeouts.md)) — the non-cooperative fallback offboarding is preferred over
- [[out-of-round-payments|Out-of-round (arkoor) payments]] ([Out-of-round payments](../concepts/out-of-round-payments.md)) — the off-chain sibling of on-chain payments
- [[lightning-integration|Lightning integration]] ([Lightning integration](../concepts/lightning-integration.md)) — the other server-mediated payment path and shared liquidity cost
- [[vtxo-lifetime-and-expiry|VTXO lifetime and expiry]] ([VTXO lifetime and expiry](../concepts/vtxo-lifetime-and-expiry.md)) — the liquidity cost shared by these flows
- [[clark-vs-covenant-ark|clArk vs covenant-based Ark]] ([clArk vs covenant Ark](../topics/clark-vs-covenant-ark.md)) — hArk, now live, drives the offboard-swap redesign
- [[clark-evolution|clArk evolution]] ([clArk evolution](../topics/clark-evolution.md)) — connector swaps as a reduced-interactivity step
- [[clark-round-transaction-mechanics|Round transaction mechanics]] ([Round transaction mechanics](../topics/clark-round-transaction-mechanics.md)) — where offboards sit in the end-to-end flow

## Sources

- [Ark offboarding (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-offboard.md) — offboard = on-chain payment; offboard vs emergency-exit table; prefer offboarding
- [On-chain payments (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-payments-on-chain.md) — connector-linked forfeit flow, change VTXO, January 2026 hArk immediate-broadcast update
- [Offboard Swaps (bark docs/offboard-swaps.md)](../../raw/articles/2026-07-17-bark-repo-docs-offboard-swaps.md) — why hArk breaks in-round offboards; hash-locked swaps vs connector swaps; deprecating round-based offboards
