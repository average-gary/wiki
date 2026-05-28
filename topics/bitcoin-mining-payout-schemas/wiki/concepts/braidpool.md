---
title: Braidpool
type: concept
created: 2026-05-26
updated: 2026-05-26
confidence: medium
tags: [braidpool, mcelrath, dag-sharechain, decentralized-pool, full-proportional, covenants]
---

# Braidpool

Bob McElrath's decentralized mining pool research project. Replaces p2pool's **linear sharechain** with a **DAG of beads** grouped into **cohorts** separated by graph cuts. Active development through 2025–2026; AGPL-3.0; currently a **prototype** (v0.01 CPUnet) — mainnet launch is the v0.5 milestone with no dates.

## What's novel vs p2pool

- **DAG** instead of linear chain. Beads have multiple parents (no-incest rule: parents may not be ancestors of other parents).
- **Cohorts** = sets of beads bounded by graph cuts where global consensus emerges.
- Optimal target: **~2.42 beads per cohort**, mathematically derived to minimize cohort time given network latency.
- Cohort time `T(x) = 1/(λx) + a·e^(aλx)`, targeting the ~600 ms practical floor of global network latency.
- Critique of p2pool (30 s shares) and Monero p2pool (10 s): both leave too much variance for small miners (~600× residual).

## Consensus

**Simple Sum of Descendant Work (SSDW)** — analogous to Bitcoin's highest-work rule, summed across DAG descendants. Ties broken by hash ("luck"). McElrath: *"Graph structure is manipulable at zero cost, therefore we must have a conflict resolution algorithm that is independent of graph structure."*

## Payout: Full Proportional

- Window: **2016 blocks** (one difficulty epoch / ~2 weeks).
- Share value `s = 1 / (x · (1 − P_≥2))`.
- **Explicitly rejects PPLNS** as arbitrary smoothing.
- Designed so shares are **tradeable assets** — hashprice derivatives / hashrate futures.

## Custody — the open problem

Braidpool's load-bearing unsolved problem: **how to authorize payouts from a DAG sharechain without a federation and without n-of-n key aggregation breaking when miners disconnect**.

McElrath's design:
- **RCA (Rolling Coinbase Aggregation)** → **UHPO (Unspent Hasher Payout Object)**.
- Each new block's coinbase aggregates prior unspent payouts forward.
- The UHPO is covenant-locked; any hasher can sweep their portion when entitled.
- Requires **APO + CTV** to express the recursive forward-rolling commitment.

**AaronZhang demoed a working three-leaf Taproot construction on signet in April 2026** — proves the pattern is implementable today *on signet* (where APO + CTV are activated for testing). Mainnet blocked on activation politics.

## Stratum stance

Builds on **Stratum V2** encrypted comms and template provider. McElrath critique: *"simply allowing hashers to do transaction selection is insufficient, as centralized pools can withhold payment unless hashers select transactions according to pool rules."*

## Critiques of the rest of the design space

| Target | Critique |
|---|---|
| CTV-only "covenant pools" | "Does not sample hashrate any faster than bitcoin blocks, and is incapable of reducing variance. It is therefore not a 'pool' in the usual sense." |
| p2pool / p2poolv2 | Vulnerable to "latency and connectivity games" incentivizing geographic centralization. |
| FROST/ROAST federations (Radpool) | "51% attack (or 67% attack) on the pool... could steal all funds." |

This last critique is the canonical McElrath ↔ jungly dispute and is the reason Braidpool insists on covenant-based custody.

## Position in the taxonomy

| Axis | Braidpool |
|---|---|
| Variance to | Miner (faster sampling reduces it) |
| Custody | Covenant-locked (UHPO via APO+CTV) |
| Hop-resistant | Yes (Full Proportional over 2016 blocks) |
| IC-provable | Open — Full Proportional is IC under standard assumptions |
| Operator reserve req | None |
| Auditable on-chain | Yes (UHPO + DAG of beads) |
| Template control | Miner (SV2 + JD) |
| Activation gate | **APO + CTV** (currently signet-only) |

## Status

- v0.01 CPUnet prototype.
- Languages: Jupyter (88.8% — simulators), TypeScript (dashboard), Python, Rust (node).
- Recent contributors: Calisto-Mathias, Sansh2356, zaidmstrr, u32luke + McElrath.

## Sources

- [[../../raw/repos/2026-05-26-braidpool-github|braidpool/braidpool repo + docs]]
- [[../../raw/articles/2026-05-26-braidpool-covenants-delving|McElrath's Covenants for Braidpool challenge thread]]

## See also

- [[p2pool-share-chain]] — linear-sharechain ancestor
- [[p2poolv2-accounting]] — competing modern decentralized pool
- [[radpool]] — competing decentralized FPPS (the FROST design McElrath critiques)
- [[parasite-pool]] — non-decentralized novel scheme for contrast
- [[payout-schema-taxonomy]]
