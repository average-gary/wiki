---
title: "Measurement and Analysis of the Bitcoin Networks: A View from Mining Pools"
source: "https://arxiv.org/abs/1902.07549"
type: papers
ingested: 2026-09-21
tags: [measurement-study, pool-concentration, empty-blocks, spv-mining, transaction-selection, feerate-policy, mempool-crawling, hashrate-estimation, methodology]
summary: "Wang, Chu & Yang (HKBU / Harbin Institute of Technology), arXiv 2019. Longitudinal measurement of 156,000 blocks and 257M transactions (Feb 2016 - Jan 2019) plus 120.25M unconfirmed transactions crawled from the mempool at a 2-second polling interval (Mar 2018 - Jan 2019); 98.18% of blocks attributed to a known pool using BTC.com and Blockchain.info labels. Three findings bear on pool software design: (1) top-four concentration — AntPool 27,026 blocks, F2Pool 19,282, BTC.com 17,488, ViaBTC 12,100 over the window; (2) empty blocks have a significantly SHORTER block interval than non-empty ones, i.e. empty-block production is a deliberate latency strategy, not noise; (3) transaction selection is feerate-dominated with a sharp cliff — roughly 90% inclusion probability if a transaction's feerate ranks inside the top X (X = transactions in the next block), below 5% outside the top 2X. Also documents the measurement methodology (multi-node capture into MongoDB, a single reference clock to defeat drift) that any pool-side observability effort re-derives."
authors: [Canhui Wang, Xiaowen Chu, Qin Yang]
affiliation: "Hong Kong Baptist University; Harbin Institute of Technology"
published: 2019-02
venue: "arXiv preprint (v2)"
publication_status: "Preprint; not peer-reviewed at a tier-1 venue, but methodologically explicit"
credibility: medium
credibility_score: 3
credibility_rationale: "Primary large-scale data with stated methodology, but a preprint, and the measurement window ends January 2019 — pool market shares are seven years stale as of 2026. The mechanisms (feerate cliff, empty-block latency strategy, clock-drift handling) age better than the numbers."
confidence: medium
research_round: 1
research_agent: academic
staleness_warning: "Concentration figures describe 2016-2019. Do NOT cite as current pool market share; that needs a 2026 source."
extraction_note: "Subagent extraction. Table-level detail beyond the four named pools was not captured. The hashrate formula below is as reported by the agent and should be checked against the paper."
---

# Measurement and Analysis of the Bitcoin Networks: A View from Mining Pools

**Canhui Wang, Xiaowen Chu (Hong Kong Baptist University), Qin Yang (Harbin Institute of Technology)**
— arXiv:1902.07549, February 2019 (v2)

## Methodology (reusable)

- **Block/transaction history**: 156,000 blocks, 257M transactions, **Feb 2016 – Jan 2019**.
- **Mempool capture**: 120.25M unconfirmed transactions, **Mar 2018 – Jan 2019**, via a custom Python
  crawler polling every **2 seconds** with `bitcoin-cli getrawtransaction` against Bitcoin Core
  0.14.2 with `txindex=1`, maintaining an observation-timestamp list per unconfirmed transaction.
- **Storage**: multiple Bitcoin full nodes syncing over the P2P protocol; historical transactions in
  MongoDB (DB1), unconfirmed transactions in DB2.
- **Pool attribution**: labels crawled from BTC.com and Blockchain.info; **98.18% of blocks labelled**.
- **Clock discipline**: used BTC.com's system clock as the single reference to compute consistent
  block intervals across distributed nodes — an explicit correction for clock drift. Any pool
  building latency observability across regions hits this same problem.
- **Hashrate estimate** (as reported): `H = (D × 2⁴⁸) / ((2¹⁶ − 1) × 600 s)`, with difficulty
  retargeting every 2016 blocks.

## Findings that constrain pool design

### 1. Concentration (2016–2019 window — stale, mechanism only)

"A few mining pool entities continuously control most of the computing resources." Top 25 pools
identified; the leaders over the window: **AntPool 27,026 blocks, F2Pool 19,282, BTC.com 17,488,
ViaBTC 12,100**.

### 2. Empty blocks are a latency strategy

"The block interval of empty blocks is significantly lower than the block interval of non-empty
blocks." An empty block contains only the coinbase. A *shorter* interval is the signature of starting
work on the successor before having validated or assembled a full template — SPV/header-first mining.
This is the measured counterpart to the 2015 SPV-mining fork incident: the incentive is real and
visible in the chain, so any pool architecture that optimises time-to-first-job must decide
explicitly whether it will emit a transaction-free template in the gap.

### 3. The feerate cliff in transaction selection

"Feerate plays a dominating role in transaction collection strategy for the top mining pools."
Quantified: acceptance probability is **~90% when a transaction's feerate ranks within the top X**
(where X = the number of transactions in the next block), and falls **below 5% outside the top 2X**.

Architecturally this says top pools run a near-pure feerate-greedy selector with little
customisation. It is the empirical baseline against which any claim about template
quality/censorship/custom selection must be measured — and it is what a Job-Declaration or DATUM
miner is choosing to deviate from.

### 4. Economics noted in passing

A "prisoner's dilemma" of hashrate expansion against falling unit profit; a "Malthusian trap" where
incentives cannot sustain exponential compute growth; and the finding that "the market price and
transaction fees are not sensitive to the event of halving block rewards." Out of scope here, recorded
for completeness.

## Limits

- **No protocol-level architecture.** The paper measures behaviour from chain and mempool data; it
  says nothing about share validation, work distribution, or pool server internals. It constrains the
  *policy* layer, not the *plumbing*.
- **Attribution depends on third-party labels** (BTC.com, Blockchain.info), which are themselves
  heuristics over coinbase tags.
- **Window ends Jan 2019.** Treat every share-of-hashrate number as historical.
