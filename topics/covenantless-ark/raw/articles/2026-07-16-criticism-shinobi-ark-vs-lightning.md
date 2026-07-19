---
title: "What Ark Could Potentially Learn From Lightning (Shinobi / Bitcoin Magazine)"
source_url: https://digkrypton.com/index.php/2024/10/28/what-ark-could-potentially-learn-from-lightning/
type: article
authors: [Shinobi]
publisher: Bitcoin Magazine (republished at digkrypton.com)
date: 2024-10-28
ingested: 2026-07-16
research_path: criticism
credibility: medium
confidence: medium
quality_score: 3
tags: [ark, clark, criticism, asp-liquidity, n-of-n, inbound-liquidity, cross-asp, contagion, lightning-comparison]
summary: Shinobi's essay comparing Ark unfavorably to Lightning — the trustless n-of-n signing burden at creation, ASP fronting liquidity for every open payment, fees spiking as liquidity runs dry, receiving needing inbound liquidity, and cross-ASP payments interlinking Arks (contagion risk analogous to channel jamming). NOTE: fetched via a scraped republish; cite the Bitcoin Magazine original if locatable.
---

# What Ark Could Potentially Learn From Lightning (Shinobi)

Original by Shinobi in Bitcoin Magazine, 2024-10-28 (fetched via digkrypton.com republish — treat intellectual source as Shinobi/Bitcoin Magazine).

## Trustless clArk requires a massive interactive n-of-n signing at creation
- "the requirement in a trustless version for every user inside of an individual Ark to collaboratively sign the exit transactions in a massive n-of-n multisig when it is created."

## ASP must front liquidity for every open payment
- "For every payment floating on an Ark that hasn't been closed yet, the ASP must front liquidity for those payments."

## Fees spike as ASP liquidity runs dry
- "When the ASP gets to a point where it is running out of liquidity, its fees must necessarily start skyrocketing."

## Receiving still needs inbound liquidity, like Lightning
- "both require participants to have excess liquidity in order to receive payments" (Ark's mitigation is a shared pool rather than per-user channels).

## Cross-ASP routing links Arks and amplifies exit risk
- "payments across ASPs like this essentially interlink Arks across different ASPs, meaning non-cooperative closes would necessitate the closure of Arks operated by multiple entities," a risk "analogous to the channel jamming problem of Lightning."
