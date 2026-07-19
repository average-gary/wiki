---
title: "Ark liquidity (Second/Bark docs)"
source: "https://second.tech/docs/learn/liquidity.md"
type: articles
ingested: 2026-07-17
tags: [ark, clark, bark, liquidity, asp-capital, cost-formula, opportunity-cost, capital-lockup]
summary: "Bark's liquidity model — server deploys BTC upfront and sweeps after expiry; liquidity cost = amount × (expiry_delta ÷ 365d) × opportunity_rate (worked example 100k sat, 5d, 5% → 68 sats); fresh VTXOs cost more to refresh than near-expiry ones due to longer capital lockup."
---

# Ark liquidity (Second/Bark docs)

Part of the [[2026-07-17-second-tech-docs-learn-manifest.md|Second Learn-section collection]].

- **Model**: liquidity management shifts entirely to the server, which "deploys bitcoin upfront while waiting to sweep equivalent amounts from spent VTXOs after they expire."
- **Liquidity-requiring operations**: (1) **Refreshes** — "the most common"; (2) **Offboarding**; (3) **Lightning payments**.
- **Cost formula**: `amount × (expiry_delta ÷ 365 days) × opportunity_rate = liquidity_cost`.
  - Worked example: 100,000 sat VTXO, 5 days remaining, 5% opportunity cost → **68 sats**.
- **Age→price**: "Fresh VTXOs have higher refresh costs because servers deploy liquidity for longer periods. Old VTXOs nearing the end of their lifetime cost significantly less to refresh."
- **Capital lockup**: server must "wait for the old round's timelock to expire before reclaiming the [funds] from the forfeited VTXOs—creating a temporary capital requirement." (Uses the "10 BTC" scale example seen elsewhere.)
- **Efficiency vs Lightning**: "precise liquidity usage" + no need to predict behavior; server responds dynamically rather than pre-funding channels.
