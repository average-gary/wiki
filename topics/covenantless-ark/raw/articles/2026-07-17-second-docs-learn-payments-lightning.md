---
title: "Lightning payments (Second/Bark docs)"
source: "https://second.tech/docs/learn/payments-lightning.md"
type: articles
ingested: 2026-07-17
tags: [ark, clark, bark, lightning, htlc, gateway, preimage, ephemeral-key, receive-vtxo]
summary: "Bark's Lightning integration — server operates its own LN node(s) as a gateway; send = cooperatively spend a VTXO into an HTLC (three spend paths); receive = incoming BTC arrives as VTXOs (no channels/inbound liquidity needed). Trust caveat: server must delete the ephemeral key or could double-spend the HTLC input. Receive VTXOs ~3-day lifetime."
---

# Lightning payments (Second/Bark docs)

Part of the [[2026-07-17-second-tech-docs-learn-manifest.md|Second Learn-section collection]].

- **Architecture**: "The Ark server operates its own Lightning node(s) and acts as a gateway between Ark users and the Lightning Network." Users hold VTXOs at rest, spend them for LN transactions — no channel management / rebalancing. New users can pay LN immediately without on-chain txs.
- **Sending** (4 steps): provide invoice/address → wallet+server cooperate to spend a VTXO into an **HTLC** → server routes over LN → server obtains preimage as proof.
  - Three HTLC spend paths: **cooperative revocation** (payment fails), **server safeguard** (user tries malicious exit after delivery), **user safeguard** (payment fails + server uncooperative).
  - Preimage ensures atomicity: "it only exists if the Lightning payment was delivered, and without it the server cannot prevent you from reclaiming your bitcoin."
- **Receiving**: incoming BTC arrives as VTXOs, no channels/inbound liquidity. Invoice → route → server prepares HTLC from its VTXO pool → preimage reveal to claim.
  - **Trust caveat**: "you are trusting that the server actually deleted the ephemeral key. If retained, the server could double spend the HTLC input." Recommend refreshing received payments in a subsequent round.
  - **Receive VTXOs ~3-day lifetime** — much shorter than standard ~28-day round VTXOs.
- **Fees**: sending = liquidity + LN routing + server fees; **receiving is currently free**.
