---
title: "On-chain payments (Second/Bark docs)"
source: "https://second.tech/docs/learn/payments-on-chain.md"
type: articles
ingested: 2026-07-17
tags: [ark, clark, bark, hark, on-chain-payment, connector, forfeit, immediate-broadcast, january-2026]
summary: "Bark's on-chain payment reference — server builds a tx with the destination output + a connector output, user signs connector-linked forfeits, server broadcasts. KEY UPDATE: as of the January 2026 hArk update, on-chain payments broadcast immediately upon completion. Change returns as a new VTXO."
---

# On-chain payments (Second/Bark docs)

Part of the [[2026-07-17-second-tech-docs-learn-manifest.md|Second Learn-section collection]].

- **Process**: user specifies recipient address + amount → server builds a tx with the requested output **and a connector output** → user validates + signs forfeit txs linked to that connector → server signs and broadcasts.
- **Connector atomicity**: "Because the user's forfeit is linked to the connector output, the forfeit is only valid once the payment transaction is broadcast." Either both the payment completes and the forfeit is valid, or neither occurs.
- **Change**: if amount ≠ user's VTXO(s) exactly, change returns as a new VTXO.
- **KEY UPDATE**: on-chain payments are "broadcast immediately upon completion **(as of the January 2026 hArk update)**." Recipients must await blockchain confirmation (speed depends on chosen on-chain fee). ← confirms hArk is LIVE, not merely proposed.
- **Fees**: liquidity cost (server deploys capital, sweeps after VTXO expiry) + on-chain fee + Ark server fees.
