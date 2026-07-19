---
title: "Ark payments / arkoor (Second/Bark docs)"
source: "https://second.tech/docs/learn/payments.md"
type: articles
ingested: 2026-07-17
tags: [ark, clark, bark, arkoor, out-of-round, spend-vtxo, double-spend, trust-model, statechain]
summary: "Bark's Ark-payments reference — arkoor (out-of-round) spend VTXOs enable instant payments and offline receiving; until refresh, receiver trusts sender+server not to collude; double-spend deterred by detectability, reputation, collusion requirement, and fee-drain on competing exits."
---

# Ark payments / arkoor (Second/Bark docs)

Part of the [[2026-07-17-second-tech-docs-learn-manifest.md|Second Learn-section collection]].

- **Arkoor (out-of-round)**: users create new spend VTXOs with the server without waiting for a round → "instant payments at any time" + "offline receiving capability."
- **Trust trade-off**: "until a receiver refreshes their received balance, they must trust that the sender and Ark server don't collude to double-spend." Refreshing converts spend VTXOs → refresh VTXOs with improved (trustless) security.
- **Security vs cost**: early refresh = more secure, more costly; late refresh = cheaper, temporary exposure. Exposure is time-bounded since all VTXOs must refresh before expiring (~30 d).
- **Double-spend deterrents**: (1) detection inevitability — multiple refresh attempts reveal double-spends; duplicate signatures publicly provable; (2) reputational risk; (3) collusion requirement (both sender AND server); (4) fee consumption — emergency exits trigger competing txs that drain the VTXO in miner fees.
- **Payment chains & change**: a received spend VTXO can be spent onward. Change inherits the source VTXO's trust properties (trustless if from refresh VTXOs, since senders can't collude against themselves).
