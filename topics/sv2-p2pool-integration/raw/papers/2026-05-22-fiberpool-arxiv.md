---
title: "FiberPool: Leveraging Multiple Blockchains for Decentralized Pooled Mining"
source_url: https://arxiv.org/html/2501.15459v1
type: academic-paper
ingested: 2026-05-22
quality: 5
confidence: high
tags: [academic, arxiv, p2pool-critique, share-chain, scalability]
---

# FiberPool — Leveraging Multiple Blockchains for Decentralized Pooled Mining

Rare academic articulation of *why* the original p2pool died and whether DAG variants actually escape its constraints.

## Direct quote
> P2Pool faces two main issues. The first is scalability: as a blockchain, the share chain has limited capacity for generating shares.

i.e. small miners get pushed off as difficulty climbs.

## Key claims
- Variance for small miners on a single share chain remains structurally high.
- Multi-chain workaround proposed — implicitly arguing single-DAG approaches (Braidpool, p2poolv2) inherit a related ceiling.
- The diagnosis applies to any single-share-chain protocol regardless of consensus rule (longest-chain, DAG, braid).

## Implication for p2poolv2 + SV2
SV2 integration alone does not solve the share-chain capacity problem. JDP makes mining-job declaration efficient, but the share-chain still has to absorb every share at every miner's submission rate. p2poolv2's chain-with-uncles design likely has the same ceiling as the original.
