---
title: "Lightning integration — the Ark server as gateway"
type: concept
created: 2026-07-17
updated: 2026-07-17
confidence: high
volatility: hot
verified: 2026-07-17
sources:
  - raw/articles/2026-07-17-second-docs-learn-payments-lightning.md
  - raw/articles/2026-07-17-second-docs-learn-intro.md
tags: [ark, clark, bark, lightning, htlc, gateway, preimage, ephemeral-key, receive-vtxo, liquidity]
aliases: [Lightning gateway, Ark Lightning, HTLC, Lightning payments]
summary: "How Ark connects to the Lightning Network: the Ark server runs its own Lightning node(s) as a gateway, so users spend VTXOs into HTLCs to send and receive incoming Lightning payments as fresh VTXOs — no channels or inbound liquidity for the user. Sending is trustless via preimage atomicity; receiving carries an ephemeral-key trust caveat, and receive VTXOs have a short ~3-day lifetime."
---

# Lightning integration — the Ark server as gateway

> A major selling point of Ark over raw Lightning is that a user gets Lightning reach **without running a Lightning node, opening channels, or sourcing inbound liquidity**. The [[clark-overview|Ark server (ASP)]] ([Ark server](../concepts/clark-overview.md)) operates its own Lightning node(s) and acts as a **gateway**: the user holds ordinary [[vtxo-and-vtxo-tree|VTXOs]] ([VTXOs](../concepts/vtxo-and-vtxo-tree.md)) at rest and spends them into **HTLCs** to send, or receives incoming Lightning value as freshly issued VTXOs. This is the mechanism behind bark's "single balance for Ark, Lightning, and on-chain" positioning.

## Architecture — the gateway model

"The Ark server operates its own Lightning node(s) and acts as a gateway between Ark users and the Lightning Network" ([bark docs/payments-lightning](../../raw/articles/2026-07-17-second-docs-learn-payments-lightning.md)). Consequences:

- Users never manage channels or perform rebalancing; the server absorbs all Lightning-side complexity.
- A brand-new user can pay a Lightning invoice **immediately**, with no on-chain setup transaction first.
- This is the same client-server simplification that defines the rest of clArk — convenience and pooled liquidity in exchange for a liveness/trust dependency on the operator (see [[clark-limitations-and-trust|limitations and trust]] ([limitations and trust](../topics/clark-limitations-and-trust.md))).

## Sending over Lightning

Sending is a four-step cooperative flow that turns a VTXO into a **Hash Time-Locked Contract (HTLC)**:

1. The user provides a Lightning invoice / address.
2. The wallet and server **cooperatively spend a VTXO into an HTLC**.
3. The server routes the payment over the Lightning Network.
4. The server obtains the **preimage** as proof of delivery.

The HTLC has **three spend paths**, covering each failure mode:

- **Cooperative revocation** — the payment fails and the VTXO is returned;
- **Server safeguard** — protects the server if the user attempts a malicious exit *after* the payment was delivered;
- **User safeguard** — protects the user if the payment fails *and* the server is uncooperative.

**Atomicity via preimage**: the preimage "only exists if the Lightning payment was delivered, and without it the server cannot prevent you from reclaiming your bitcoin." This is the same hash-lock logic that binds [[forfeit-and-connectors|forfeits in hArk rounds]] ([forfeits](../concepts/forfeit-and-connectors.md)) — the preimage is the shared secret that makes the exchange trustless for the sender.

## Receiving over Lightning

Incoming Lightning value arrives as **VTXOs**, with **no channels and no inbound liquidity** required of the user. The server prepares an HTLC from its own VTXO pool, routes the incoming payment, and reveals the preimage so the user can claim.

### The ephemeral-key trust caveat

Receiving is **not** fully trustless: "you are trusting that the server actually deleted the ephemeral key. If retained, the server could double-spend the HTLC input." The recommended mitigation is to **refresh received Lightning payments in a subsequent round** (see [[clark-round-lifecycle|round lifecycle]] ([round lifecycle](../concepts/clark-round-lifecycle.md))), which anchors the VTXO to an on-chain commitment and removes the exposure — the same "refresh to harden" pattern as [[out-of-round-payments|arkoor payments]] ([arkoor payments](../concepts/out-of-round-payments.md)).

### Short receive-VTXO lifetime

VTXOs created by **receiving** over Lightning carry a much shorter lifetime — roughly **3 days**, versus the standard **~28-day** round-VTXO lifetime (see [[vtxo-lifetime-and-expiry|VTXO lifetime and expiry]] ([VTXO lifetime](../concepts/vtxo-lifetime-and-expiry.md))). The short window pushes the user to refresh promptly, both to keep the funds and to shed the ephemeral-key trust caveat.

## Fees and liquidity

- **Sending** costs = [[vtxo-lifetime-and-expiry|liquidity cost]] ([liquidity cost](../concepts/vtxo-lifetime-and-expiry.md)) + Lightning routing fees + Ark server fees.
- **Receiving is currently free** on Second's server.
- Lightning is one of the three liquidity-consuming operations for the server (alongside [[clark-round-lifecycle|refreshes]] ([refreshes](../concepts/clark-round-lifecycle.md)) and [[offboarding-and-onchain-payments|offboards]] ([offboards](../concepts/offboarding-and-onchain-payments.md))). Because the server responds dynamically instead of pre-funding channels, bark frames its liquidity use as more precise than Lightning's.

## See Also

- [[vtxo-and-vtxo-tree|VTXOs and the VTXO tree]] ([VTXOs and the VTXO tree](../concepts/vtxo-and-vtxo-tree.md)) — what a Lightning receive produces
- [[vtxo-lifetime-and-expiry|VTXO lifetime and expiry]] ([VTXO lifetime and expiry](../concepts/vtxo-lifetime-and-expiry.md)) — the ~3-day receive lifetime and the liquidity cost formula
- [[out-of-round-payments|Out-of-round (arkoor) payments]] ([Out-of-round payments](../concepts/out-of-round-payments.md)) — the refresh-to-harden trust pattern that also applies to Lightning receives
- [[offboarding-and-onchain-payments|Offboarding and on-chain payments]] ([Offboarding and on-chain payments](../concepts/offboarding-and-onchain-payments.md)) — the other server-mediated payment paths
- [[ark-addresses-and-delivery|Ark addresses and VTXO delivery]] ([Ark addresses and delivery](../concepts/ark-addresses-and-delivery.md)) — BOLT-11/12 receiving is a planned mailbox event
- [[clark-overview|clArk overview]] ([clArk overview](../concepts/clark-overview.md)) — where the Lightning gateway sits in the whole system
- [[clark-limitations-and-trust|clArk limitations and trust model]] ([limitations and trust](../topics/clark-limitations-and-trust.md)) — the gateway trust surface

## Sources

- [Lightning payments (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-payments-lightning.md) — gateway architecture, HTLC send/receive flows, ephemeral-key caveat, ~3-day receive lifetime, fees
- [Intro to the Ark protocol (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-intro.md) — Lightning via the server's gateway in the overall model
