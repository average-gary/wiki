---
title: "Ark Protocol: Shared UTXOs and Virtual Channels for Bitcoin (Spark research)"
source_url: https://www.spark.money/research/ark-protocol-explained
type: article
authors: [bcNeutron]
publisher: Spark (spark.money research)
date: 2026-02-20
ingested: 2026-07-16
research_path: criticism
credibility: medium
confidence: medium
quality_score: 4
tags: [ark, clark, criticism, liquidity, asp-capital, liveness, unilateral-exit-cost, dust, mass-exit, censorship]
summary: Quantified engineering critique of covenantless Ark — online-requirement per round, ASP capital-fronting burden (~10 BTC for 10k users), offline-too-long fund loss, unilateral exit cost exceeding small-VTXO value, ASP censorship/liveness trust point, and mass-exit congestion feedback loop. Competitor bias (Spark is a rival L2) noted; mechanisms corroborated by primary sources.
---

# Ark Protocol: Shared UTXOs and Virtual Channels for Bitcoin (Spark research)

bcNeutron, 2026-02-20. Most complete single catalogue of criticisms with concrete numbers. CAVEAT: Spark is a competing L2 (competitive angle) — but numbers and mechanisms are sound and corroborated by primary sources.

## Covenantless design re-introduces the online requirement
- "every participant in a round must be online and co-sign the pool transaction. This significantly limits the number of users per round," and it "reintroduces the kind of online-requirement that Ark was designed to eliminate."

## ASP must front the full value of all new VTXOs
- The operator "must fund the entire value of all new vTXOs from its own capital. It recovers this capital only when the old vTXOs expire...or when users forfeit their old vTXOs." Capital locked for the whole expiry window.
- Quantified: "An ASP serving 10,000 users with an average balance of 100,000 sats needs to maintain roughly 10 BTC in active liquidity, plus additional capital," and "The cost of maintaining this liquidity ultimately gets passed to users as fees."

## Offline too long = fund loss
- "If a user goes offline for longer than the timeout period without refreshing, they risk losing their funds," a "liveness requirement that does not exist in Lightning."

## Unilateral exit can cost more than the VTXO is worth
- During high fees "the cost of unilateral exit could exceed the value of small vTXOs, creating an economic constraint similar to the dust problem."

## ASP is a liveness/censorship trust point
- The ASP can "Refuse to include users in future rounds" and "Go offline, halting new round creation."

## Mass-exit congestion feedback loop
- "If many users attempt to exit simultaneously...the resulting on-chain transaction volume could be substantial," creating "a negative feedback loop similar to fee market dynamics during periods of high demand."
