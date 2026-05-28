---
title: "braidpool/braidpool — DAG-sharechain decentralized pool"
url: https://github.com/braidpool/braidpool
docs_spec: https://github.com/braidpool/braidpool/blob/main/docs/braidpool_spec.md
docs_consensus: https://github.com/braidpool/braidpool/blob/main/docs/braid_consensus.md
docs_general: https://github.com/braidpool/braidpool/blob/main/docs/general_considerations.md
roadmap: https://github.com/braidpool/braidpool/blob/main/docs/roadmap.md
license: AGPL-3.0
type: repo
status: prototype (v0.01 CPUnet)
ingested: 2026-05-26
quality: 5
credibility: high
confidence: high
tags: [braidpool, dag-sharechain, mcelrath, decentralized-pool, primary-spec]
---

# Braidpool — DAG Sharechain Decentralized Pool

Bob McElrath's decentralized mining pool research project. Active development through 2025-2026; McElrath remains primary committer. AGPL-3.0. 289 commits on main, 55 open issues, 34 PRs.

## DAG mechanics (vs p2pool's linear chain)

- Shares are **beads** with multiple parents (no-incest rule: parents may not be ancestors of other parents).
- **Cohorts** = sets of beads bounded by graph cuts where global consensus emerges.
- Optimal target: **~2.42 beads per cohort** — mathematically derived to minimize cohort time given network latency.
- Cohort time `T(x) = 1/(λx) + a·e^(aλx)`.
- Targets fastest-possible consensus given global network latency (~600ms practical floor).
- Critique of p2pool (30s) and Monero p2pool (10s): insufficient variance reduction (~600x) for small miners.

## Consensus

**Simple Sum of Descendant Work (SSDW)** — analogous to Bitcoin's highest-work rule, summed across DAG descendants. Ties broken by hash ("luck").

McElrath quote: *"Graph structure is manipulable at zero cost, therefore we must have a conflict resolution algorithm that is independent of graph structure."*

## Payout

**Full Proportional** over a 2016-block (one difficulty epoch / ~2 weeks) window. Share value `s = 1 / (x · (1 - P_≥2))`. Explicitly rejects PPLNS as arbitrary smoothing. Designed so shares are tradeable assets (hashprice derivatives / hashrate futures).

## Stratum stance

Builds on **Stratum V2's encrypted comms and template provider**. Critique: *"simply allowing hashers to do transaction selection is insufficient, as centralized pools can withhold payment unless hashers select transactions according to pool rules."*

## Critiques of competitors (in `general_considerations.md`)

- **CTV-only "covenant pools"**: *"does not sample hashrate any faster than bitcoin blocks, and is incapable of reducing variance. It is therefore not a 'pool' in the usual sense."*
- **p2pool**: vulnerable to "latency and connectivity games" incentivizing geographic centralization.
- **FROST/ROAST federations** (Radpool): *"51% attack (or 67% attack) on the pool... could steal all funds"* — motivates the covenant-based RCA/UHPO custody design.

## Unsolved: payout authorization at scale

- McElrath's **RCA (Rolling Coinbase Aggregation) → UHPO (Unspent Hasher Payout Object)** design needs **APO+CTV** covenants.
- AaronZhang demoed a working three-leaf Taproot construction on signet in April 2026.
- No mainnet path until at least one of {APO, CTV} activates.

## Status

- v0.01 — CPU-mining prototype on CPUnet.
- Mainnet launch is "Version 0.5" milestone; no dates.
- Languages: Jupyter (88.8% — simulators), TypeScript (dashboard), Python (sim), Rust (node).
- Recent contributors: Calisto-Mathias, Sansh2356, zaidmstrr, u32luke + McElrath.

## DAA innovation

Per zawy + McElrath (Feb 2025 Delving thread):
`D = D_parents · (1 + parents/100 − 2/100)`. Targets ~1.44 parents → consensus at 2.718× network latency.

## Sources / docs to cross-reference

- [[../articles/2026-05-26-braidpool-covenants-delving]] — covenant/custody discussion thread
- [[../articles/2026-05-26-radpool-delvingbitcoin]] — competing decentralized FPPS proposal
- [[../articles/2026-05-24-jungly-delvingbitcoin-p2share]] — p2poolv2 design
