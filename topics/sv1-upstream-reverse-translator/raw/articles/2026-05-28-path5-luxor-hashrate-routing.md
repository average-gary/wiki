---
title: "Luxor — hashrate routing and SV2 silence"
source: https://luxor.tech
type: articles
tags: [luxor, hashrate-broker, hashrate-derivatives, sv2-absent]
summary: "Luxor runs an SV1 stratum endpoint (stratum+tcp://btc.global.luxor.tech:700), settles $500M+ OTC hashrate derivatives at ~25 EH/s/day, and has zero public mention of SV2 in product pages or docs. Architecturally an ideal reverse-translator customer; commercially the slowest mover."
confidence: medium
ingested: 2026-05-28
ingested_by: path5
quality_score: 3
---

# Luxor — hashrate routing without SV2

## Footprint

- Stratum endpoint: `stratum+tcp://btc.global.luxor.tech:700` (SV1).
- Hashrate derivatives business: $500M+ OTC, ~25 EH/s/day settled.
- Zero public mention of SV2 in product page or docs.

## Why a reverse translator fits Luxor's business

A hashrate broker fundamentally fans hashrate across multiple pools. If they expose an SV2-front to customers and route to multiple SV1 backends (Foundry, Antpool, etc.), they:
1. Get internal Noise-encrypted transport.
2. Can charge customers as the "SV2 entry point."
3. Preserve SV1 backend compatibility with all pools.

The reverse translator is the obvious primitive for this product.

## Why they haven't built it

- Their existing SV1 stack works.
- SV2 customers are still small.
- They make money on derivatives spread, not on protocol features.

## Verdict

Architecturally an ideal customer; commercially the slowest mover. **2027–2028 customer if SV2 reaches escape velocity; otherwise never.**

## See also

- [[2026-05-28-path5-pool-software-landscape]]
- [[2026-05-28-path5-customer-segments]]
