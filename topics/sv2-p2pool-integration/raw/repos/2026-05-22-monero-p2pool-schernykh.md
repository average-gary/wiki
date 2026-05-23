---
title: "SChernykh/p2pool — Monero P2Pool"
source_url: https://github.com/SChernykh/p2pool
type: repo
ingested: 2026-05-22
quality: 5
confidence: high
tags: [monero, p2pool-lineage, c++, comparator]
---

# SChernykh/p2pool — Monero P2Pool

Most successful active P2Pool descendant. C++ rewrite (not based on Forrest's Python code; design-inspired fork).

## Status
- Active protocol upgrades since **2022-08-13**
- Latest hard fork: **2024-10-12**
- >1,797 commits

## Innovations vs original P2Pool
- **PPLNS window** for share-payout fairness
- **Uncle block support** — reduces orphans, recovers near-misses
- **1-second blocks** — much smaller variance than original P2Pool's 30-second target

## Why relevant for sv2-p2pool integration
- Demonstrates P2Pool design lineage surviving on a different chain.
- The chain-with-uncles model + 1-second target is what p2poolv2 inherits architecturally.
- **Note**: Monero ASICs are minimal (RandomX is CPU-friendly), so variance dynamics differ from Bitcoin. The model's success on XMR doesn't fully transfer.
