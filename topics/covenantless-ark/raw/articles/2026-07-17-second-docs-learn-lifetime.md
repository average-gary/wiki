---
title: "VTXO lifetime (Second/Bark docs)"
source: "https://second.tech/docs/learn/lifetime.md"
type: articles
ingested: 2026-07-17
tags: [ark, clark, bark, vtxo-lifetime, expiry, sweep, refresh, liveness]
summary: "Bark's VTXO-lifetime reference — on expiry the server can sweep via timelock paths; users keep concurrent spend/exit rights unless forfeited; spending inherits the original expiry; refresh gets a fresh lifetime; server honesty is incentivized by detectability."
---

# VTXO lifetime (Second/Bark docs)

Part of the [[2026-07-17-second-tech-docs-learn-manifest.md|Second Learn-section collection]].

- **Expiry**: at expiry height "the server gains the ability to sweep any remaining bitcoin to its own wallet through the timelock spend paths." Users keep concurrent rights to spend or emergency-exit unless they've forfeited the VTXO.
- **Options to keep control**: spend (inherits original expiry), refresh in a round (gets "a new refresh VTXO with a fresh lifetime"), cooperative exit, or emergency broadcast.
- **Liveness**: "users shouldn't need to worry about VTXO lifetime as long as their wallet app comes online regularly." Well-designed wallets auto-prioritize older VTXOs and refresh those near expiry.
- **Server incentives**: claiming non-forfeited bitcoin "would be quickly identifiable by users," causing offboarding and business loss — an economic honesty incentive.
- NOTE: this page gives no numeric expiry; other Bark pages state ~28-30 day standard lifetime and ~3-day Lightning-receive lifetime.
