---
title: "Ark offboarding (Second/Bark docs)"
source: "https://second.tech/docs/learn/offboard.md"
type: articles
ingested: 2026-07-17
tags: [ark, clark, bark, offboard, cooperative-exit, forfeit, connector, withdrawal]
summary: "Bark's offboarding reference — cooperative withdrawal that functions identically to on-chain payments (server required, single tx); the standard preferred path vs the multi-tx emergency exit reserved for an unresponsive server."
---

# Ark offboarding (Second/Bark docs)

Part of the [[2026-07-17-second-tech-docs-learn-manifest.md|Second Learn-section collection]].

- **Core flow**: functions identically to on-chain payments. Withdraw "a specific whole VTXO or your entire Ark balance" to your own wallet via a cooperative process requiring server participation. (Uses forfeit + connector like on-chain payments — see [[2026-07-17-second-docs-learn-payments-on-chain.md|on-chain payments]].)
- **Offboard vs emergency exit**:

| Aspect | Offboarding | Emergency Exit |
|---|---|---|
| Server requirement | Required | Not required |
| Transaction count | Single | Multiple |
| Confirmation time | One tx | Multiple sequential |
| Primary use | Normal withdrawals | Server unresponsiveness |

- "the standard, cooperative way" — users "should always prefer offboarding" except when the server is unresponsive.
- **Fees**: same as on-chain payment fees (no separate schedule on this page).
