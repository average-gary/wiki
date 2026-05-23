---
title: "Candidate academic literature: PPLNS variance, share-chain orphans, DAG consensus"
source_url: candidates-from-training-knowledge
type: candidate-list
ingested: 2026-05-22
quality: 2
confidence: low
verified: false
tags: [academic, candidates, unverified, follow-up]
---

# Candidate academic literature — PPLNS variance, share-chain orphans, DAG consensus

**Status: UNVERIFIED.** This list was returned by a research agent that hit WebFetch denials and could not validate URLs/arxiv IDs against live sources. Treat as a search seed list, not as cited references. Each entry must be verified before being treated as a real source in this wiki.

## Foundational reward-scheme variance

**Rosenfeld, M.** (2011). *Analysis of Bitcoin Pooled Mining Reward Systems*.
- Likely arxiv: `arxiv.org/abs/1112.4980`
- Defines PPLNS, PPS, proportional, score-based reward schemes; derives miner variance, pool-operator risk, hopping vulnerability. Closed-form variance formulas for PPLNS as function of window length N.
- **Why relevant**: baseline variance math any p2poolv2 vs TIDES vs Braidpool comparison must cite.

## Inclusive blockchain protocols (uncle rewards)

**Lewenberg, Y.; Sompolinsky, Y.; Zohar, A.** (FC 2015). *Inclusive Block Chain Protocols*.
- FC 2015 / Springer LNCS
- Generalizes GHOST to inclusive DAGs where off-chain blocks earn partial reward.
- **Why relevant**: directly models the "uncle rewards reduce orphan-induced variance" claim p2poolv2 and Braidpool both rely on. Gives the inclusion-rule formalism Braidpool's beads/cohorts generalize.

**Sompolinsky, Y.; Zohar, A.** (FC 2015). *Secure High-Rate Transaction Processing in Bitcoin* (GHOST).
- Likely IACR ePrint: `eprint.iacr.org/2013/881`
- Original GHOST/uncle-counting paper. Quantifies orphan rate vs block interval; foundation for Ethereum's uncle policy.
- **Why relevant**: orphan-rate model parameterizes share-chain variance (p2pool-original vs p2poolv2-with-uncles).

## DAG-consensus generalizations (Braidpool's lineage)

**Sompolinsky, Y.; Lewenberg, Y.; Zohar, A.** SPECTRE / PHANTOM / GHOSTDAG (2016-2018).
- IACR ePrint: `2016/1159` (SPECTRE), `2018/104` (PHANTOM)
- DAG-consensus generalizations; PHANTOM/GHOSTDAG give k-cluster ordering.
- **Why relevant**: Braidpool's braid is a DAG share-chain — these are the closest peer-reviewed analogs.

## Selfish mining and reward variance under orphaning

**Eyal, I.; Sirer, E.G.** (FC 2014). *Majority is not Enough: Bitcoin Mining is Vulnerable*.
- Likely: `arxiv.org/abs/1311.0243`
- Markov-chain reward-share analysis under orphaning. Math of "what fraction of work gets rewarded when blocks orphan."
- **Why relevant**: directly applicable to share-chain orphan-rate analysis.

**Eyal, I.** (IEEE S&P 2015). *The Miner's Dilemma*.
- Likely: `arxiv.org/abs/1411.7099`
- Pool block-withholding game theory. PPLNS-style schemes incentivize attacks that increase variance for honest miners.

## Decentralized pool design (closest peer-reviewed analog)

**Luu, L.; Velner, Y.; Teutsch, J.; Saxena, P.** (USENIX Security 2017). *SmartPool*.
- Likely: `eprint.iacr.org/2017/039`
- Decentralized pool design with on-chain share verification; explicit variance-vs-decentralization tradeoff discussion.
- **Why relevant**: closest peer-reviewed analog to p2poolv2/Braidpool's "decentralized share-chain delivers PPLNS-like variance" thesis.

## Empirical mining centralization

**Romiti, M.; Judmayer, A.; Zamyatin, A.; Haslhofer, B.** (WEIS 2019). *A Deep Dive into Bitcoin Mining Pools*.
- Likely: `arxiv.org/abs/1905.05999`
- Empirical centralization measurement; observed payout-scheme distributions and miner switching.
- **Why relevant**: empirical baseline for "what variance do real small miners actually experience on PPS vs FPPS vs PPLNS pools."

## Formal probability bounds on tree/DAG protocols

**Kiayias, A.; Panagiotakos, G.** (Latincrypt 2017). *On Trees, Chains and Fast Transactions in the Blockchain*.
- Likely: `eprint.iacr.org/2016/545`
- Formal analysis of tree/DAG protocols including uncle-reward economics. Rigorous probability bounds on orphan rates.
- **Why relevant**: applicable to share-chain difficulty tuning.

## Gaps the literature does NOT cover

- **No peer-reviewed paper on Ocean TIDES** — 2023+ industry scheme; only blog/spec sources exist.
- **No peer-reviewed paper on Braidpool's braid** specifically — still spec-stage.
- **p2pool's original share-chain has only informal analyses** (bitcointalk, forrestv writeups) — no FC/USENIX paper.
- The closest formal proxy for "share-chain with uncles vs flat PPLNS variance" is to **combine** Rosenfeld 2011 (PPLNS variance) + Sompolinsky-Zohar GHOST (uncle orphan rate) + Lewenberg et al. inclusive (uncle reward share).

## Action

Re-fetch each candidate above and verify the citation before treating it as evidence in any wiki article. The candidates list is a roadmap, not a research deliverable.
