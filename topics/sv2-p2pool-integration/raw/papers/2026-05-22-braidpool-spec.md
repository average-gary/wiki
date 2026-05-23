---
title: "Braidpool Protocol Specification"
source_url: https://github.com/braidpool/braidpool/blob/master/docs/braidpool_spec.md
type: protocol-spec
ingested: 2026-05-22
quality: 5
confidence: high
tags: [braidpool, dag, share-chain, decentralized-pool, sv2]
---

# Braidpool Protocol Specification

Authoritative protocol spec for the closest design-space competitor to p2poolv2. Critical for understanding the architectural fork in the road for decentralized SV2-aligned pools.

## Core design
- **DAG ("braid") of "beads"** rather than a linear share chain. Some beads are real Bitcoin blocks.
- **SSDW (Simple Sum of Descendant Work)** replaces longest-chain rule.
- PPLNS with **N=2016** (one Bitcoin difficulty epoch).
- Share value adjusted by cohort probability `s = 1 / (x(1 - P>=2))` to handle simultaneous-block orphan risk.

## "Committed mempool"
Each share commits to 2-5 transactions, letting peers deterministically reconstruct templates — bandwidth optimization. This is the mechanism by which Braidpool cuts share-propagation cost.

## Stratum V2 alignment
Designed to **build upon SV2's Template Provider**. Explicitly factorizes:
- Transaction selection (delegated to SV2 TP / miner)
- Pool consensus (the braid)

This contrasts with p2poolv2, which today has *no SV2 integration at all*.

## Largest unsolved problem
**Threshold-signature coinbase payout authorization.** Brings cryptographic-protocol complexity (FROST-style) that p2poolv2 sidesteps via direct-coinbase payouts to top-N miners.

## Variance / participation
Braidpool's general considerations doc:
- Targets ~1-second consensus (~600× faster than Bitcoin) → ~600× variance reduction vs solo
- Admits this is *still insufficient* for individual modern ASICs
- Proposes sub-pools as escape hatch
- Discusses tradeoff: all signers must remain online; restart on any failure

## Why ingest
Captures the rationale and tradeoffs that p2poolv2 will inevitably face: variance vs participation, signing scalability, sub-pools, threshold-signed payouts. The most important architectural alternative to p2poolv2's chain-with-uncles + direct-coinbase model.
