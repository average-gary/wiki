---
title: "Ark: Offchain Transaction Batching in Bitcoin (Keer, Maffei, Argentieri, Camilleri, Avarikioti — arXiv 2605.20952)"
authors: [Pim Keer, Matteo Maffei, Marco Argentieri, Andrew Camilleri, Zeta Avarikioti]
publication: arXiv
url: https://arxiv.org/abs/2605.20952
pdf: https://arxiv.org/pdf/2605.20952
date: 2026-05-20
type: paper
peer_reviewed: preprint (cs.DC + cs.CR)
ingested: 2026-05-26
quality: 5
credibility: high
confidence: high
tags: [ark, formal-model, arxiv, ark-labs, tu-wien, common-prefix, peer-reviewable]
---

# Ark: Offchain Transaction Batching in Bitcoin — Formal Model

First Bitcoin-compatible commit-chain with a **formal protocol model and security proof**. 32 pages, arXiv:2605.20952v1, posted 2026-05-20 — six days before this research round.

## Authors

- **Pim Keer** (TU Wien)
- **Matteo Maffei** (TU Wien)
- **Marco Argentieri** (Ark Labs — core)
- **Andrew Camilleri** (Ark Labs — core)
- **Zeta Avarikioti** (TU Wien / Common Prefix) — leading Bitcoin Layer-2 academic (commit-chains, channel factories, Lightning security)

This is the academic-industry collaboration that anchors Ark's formal positioning.

## Formal contributions

- First Bitcoin-compatible commit-chain with **proven security** under a formal model.
- **Two attacks identified on testnet**, disclosed and fixed before mainnet.
- **Constant-sized onchain commitment**: ~200 vB regardless of how many VTXOs are batched.
- **Cooperative exit**: 1 output per user.
- **Unilateral exit**: O(log n) txs of ~150 vB per VTXO.
- "Ark only requires signatures of users involved in a transaction and the operator to perform a state update" — **no all-user interaction per round** (key contrast with channel factories and CoinPool).

## Related-work positioning (Section 1.1)

Compares Ark to: PCNs, statechains (Somsen, Spark), payment pools (CoinPool), sidechains, other commit-chains (Clique), rollups, BitVM. Notes Clique's original design needed covenants Bitcoin doesn't have; Ark doesn't.

## Mining payouts: explicit gap

**The paper does NOT discuss mining payouts.** "Mining" appears only as background (miners as block producers, mining fees, MEV, timelock bribing). The mining-payout application of Ark is third-party speculation, not endorsed by either the Ark Labs core or the formal-model authors.

This is itself a finding: Ark for mining payouts has **no academic spine** as of May 2026.

## Why ingestion-worthy

The 200 vB constant commitment + O(log n) unilateral exit are the quantitative claims that AntoineP's "Ark > CTV for payouts" argument leans on. This paper makes those claims rigorous. The wiki should treat it as the canonical formal reference for any Ark/mining-payout discussion.

## See also

- [[../articles/2026-05-26-ark-burak-original-proposal-2023]] — historical primary
- [[../articles/2026-05-26-second-tech-ark-intro]] — current spec
- [[../articles/2026-05-26-ark-erik-de-smedt-ctv-csfs-delving]] — Erk/hArk variants
- [[../articles/2026-05-26-vnprc-ctv-coinbase-delving]] — applied debate (already in wiki)
