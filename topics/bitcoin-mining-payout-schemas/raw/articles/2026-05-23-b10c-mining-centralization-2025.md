---
title: "Bitcoin Mining Centralization in 2025"
author: 0xB10C
publication: b10c.me
date: 2025-04-15
url: https://b10c.me/blog/015-bitcoin-mining-centralization/
type: article
ingested: 2026-05-23
quality: 5
credibility: high
confidence: high
tags: [centralization, pool-concentration, AntPool-and-friends, proxy-pooling]
---

# Bitcoin Mining Centralization (b10c, 2025-04)

Rigorous on-chain forensic analysis of pool concentration. Methodology: coinbase tags, payout addresses, template similarity. The empirical foundation for "why payout-scheme reform matters."

## Headline numbers (April 2025)

- **Foundry**: ~30%
- **AntPool**: ~19%
- **ViaBTC**: ~14.5%
- **F2Pool**: ~10%
- **MARA Pool**: ~5%
- **Top 5**: ~78%
- **6 pools mine >95% of blocks**
- **Top 4 = 75%** of network hashrate

## Proxy-pooling finding

Smaller-branded pools relay AntPool's templates while branding their own coinbase tag. **"AntPool & friends"** approaches **~40%** of network share — rivaling Foundry. Means the surface concentration (pool-share charts) understates the real concentration.

## Trend

Mining decentralization **peaked in 2017** (top-2 < 30%) and has **monotonically degraded** since. Concentration is structural, not incidental.

## Implication for the wiki

Without decentralization at the *pool layer*, choice between FPPS / PPLNS / TIDES / SLICE / eHash is rearranging deck chairs — censorship resistance still depends on the 2-4 pools that template-construct most blocks. This is the framing that motivates:

- DATUM (OCEAN) — let miners build own templates.
- Job Declaration in SV2 — same goal, protocol-level.
- p2poolv2 — eliminate the operator entirely.
- hashpool — eliminate the per-miner ledger.

A payout scheme alone does not solve centralization. A payout scheme that *requires* decoupled template construction (PPLNS-JD, SLICE, TIDES + DATUM, eHash) does.
