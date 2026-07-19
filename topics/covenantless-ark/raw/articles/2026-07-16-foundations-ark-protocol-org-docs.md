---
title: "Ark Protocol docs (ark-protocol.org): clArk, VTXOs, Connectors"
source_url: https://ark-protocol.org/intro/clark/
type: article
publisher: ark-protocol.org (canonical protocol docs, public-domain)
ingested: 2026-07-16
research_path: foundations
credibility: high
confidence: high
quality_score: 4
tags: [ark, clark, covenantless, pseudo-covenant, ephemeral-keys, key-deletion, vtxo, connector, forfeit, oor, arkoor, timelocks]
summary: Canonical protocol docs on the pseudo-covenant (all-of-all presigning + ephemeral-key deletion), concrete VTXO timelock values (24h leaf / 14d node expiry), the round transaction / connector atomicity, and Out-of-Round (OOR) payments.
---

# Ark Protocol docs (ark-protocol.org)

Pages: `/intro/clark/`, `/intro/vtxos/`, `/intro/connectors/`. Canonical, public-domain protocol docs maintained alongside Second/Arkade.

## Pseudo-covenant via presigning (clArk page)
- "If all parties that are affected by the covenant come together and create a multisig address and then pre-sign the desired transactions using an all-of-all signature scheme" then a covenant-like constraint emerges. No OP_CTV, no consensus change.
- Security holds "as long as at least one user in the entire group commits to deleting their key" — ephemeral-key deletion is what makes the presigned tree irreversible (no alternative spend can ever be signed).

## Ephemeral keys
- Participating users and the Ark server EACH generate ephemeral keys, sign the tree, then delete those keys; this deletion is the trust-minimizing core of the covenant emulation.
- During a refresh, all participating users sign their forfeit transactions; all refreshing users plus the server each generate a fresh private key, sign the VTXO tree with it, then delete that key.

## VTXO policies with concrete timelock values (VTXOs page)
- **Leaf (forfeit) clause**: `(A + S) OR (A after 24h)` — joint user+server spend immediately, or unilateral user spend after **24 hours**.
- **Intermediate node**: `cov OR (S after 14d)` — spend via covenant, or server reclaims after **14 days** (batch expiry). Users must "refresh" (spend VTXOs back to themselves) before expiry to reset the timer.

## Round / round transaction (connectors page)
- "Each successful round results in the creation of an **Ark round transaction**. This transaction contains an output that creates a new covenant tree." The round batches all participating users' VTXO refreshes into one on-chain output subdividing into a tree of output VTXOs.

## Forfeit + connector atomicity (verbatim)
- "The round transaction will create another covenant tree that contains one leaf for each input VTXO. These leaves are called **connector outputs** and will have no real value, but if the users take one of these connectors into their forfeit transaction, that means that **the forfeit transaction is only valid if the Ark round transaction confirms** on the chain." Solves the trust problem where a user forfeits their old VTXO but has no guarantee of receiving the new one.

## Liveness requirement
- "Users must periodically refresh their VTXOs to avoid them expiring. This creates a liveness requirement, because users must ensure they are regularly online to catch at least one round before their VTXOs expire."

## Out-of-Round (OOR / arkoor) payments
- Rather than routing every payment through a round, clArk uses instant P2P "Out-of-Round" transactions (each requiring sender + server co-signature), later refreshing OOR VTXOs into a future round to get canonical batch-confirmed VTXOs.

## NOTE on timelock values
- ark-protocol.org cites 24h leaf / 14d node; arkd code default is ~7d (604672s) VTXO tree expiry / 24h exit delay; Second's bark docs cite ~30d VTXO lifetime. Values are implementation- and deployment-configurable.
