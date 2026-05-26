---
title: "Pool Formation in Oceanic Games: Shapley Value and Proportional Sharing (Kiayias, Koutsoupias, Markakis, Tsamopoulos — AFT 2025)"
authors: [Aggelos Kiayias, Elias Koutsoupias, Evangelos Markakis, Tsamopoulos]
publication: AFT 2025 (Schloss Dagstuhl LIPIcs)
url: https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.AFT.2025.21
date: 2025-10
type: paper
peer_reviewed: yes
ingested: 2026-05-26
quality: 5
credibility: high
confidence: high
tags: [shapley-value, oceanic-games, formal-analysis, sybil-resistance, peer-reviewed]
---

# Pool Formation in Oceanic Games — Shapley vs Proportional (AFT 2025)

Peer-reviewed cooperative-game-theoretic analysis of pool reward design.

## Contribution

- First adaptation of the **Shapley value** to mining pool reward design under an **oceanic games** model: large stakeholders + a continuum of small ones.
- **Price of Stability** analysis comparing Shapley-based vs. proportional reward sharing.
- Considers **superadditive and subadditive** stake-weighting variants of proportional.

## Key results

- **Sybil resistance**: Shapley dominates proportional sharing. Proportional is Sybil-vulnerable; Shapley is "not far from optimal" decentralization while resisting Sybil splits.
- Provides theoretical scaffolding the wiki currently lacks beyond Rosenfeld 2011 and Schrijvers 2016.

## Why ingestion-worthy

Modernizes the formal-analysis foundation of the wiki. Directly bears on whether schemes like **Parasite Pool** (proportional residual after a flat finder bounty) are Sybil-vulnerable in the way classical proportional schemes are.

## See also

- [[2026-05-23-rosenfeld-2011-pool-reward-analysis]]
- [[2026-05-23-schrijvers-2016-incentive-compatibility]]
- [[../../wiki/concepts/parasite-pool]]
