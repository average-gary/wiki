# papers Index

> Raw papers sources for mining-pool-architecture.

Last updated: 2026-09-21

## Contents

| File | Summary | Tags | Updated |
|------|---------|------|---------|
| [2026-09-21-hardening-stratum-bedrock-pets2017.md](2026-09-21-hardening-stratum-bedrock-pets2017.md) | Recabarren & Carbunar, PETS 2017. The only rigorous protocol-level security analysis of Stratum V1: 138 MB of live capture, the six message types and coinbase field layout, then three working attacks — StraTap (hashrate/payout inference from share count × difficulty), ISP Log (same from packet metadata alone, −9.49% mean error, exploiting a fixed initial difficulty of 1024), and BiteCoin (TCP hijack rewriting the share's username). Bedrock defence: a per-miner cookie in the coinbase's unused prev-hash field, 12.03 s/day at 16,000 miners vs 1.01 h/day for TLS. | stratum-v1, protocol-security, hashrate-inference, share-hijacking, bedrock, mining-cookie | 2026-09-21 |
| [2026-09-21-withholding-and-power-splitting-attack-economics.md](2026-09-21-withholding-and-power-splitting-attack-economics.md) | Luu et al. (IEEE CSF 2015) + Velner et al. (IACR 2017/230). Block withholding stays profitable under existing reward schemes over long horizons, and equilibrium is a *mixed* strategy — rational miners probabilistically attack. A smart contract paying others to withhold lets an adversary with 0.0000002% of network hashpower zero a large PPS pool's revenue at no cost, vs >1% needed classically for a 5% dent. The reward scheme, not the wire protocol, chooses this attack surface. | block-withholding, pps-vulnerability, game-theory, mixed-strategy-equilibrium, reward-scheme-design | 2026-09-21 |
| [2026-09-21-bip22-bip23-getblocktemplate.md](2026-09-21-bip22-bip23-getblocktemplate.md) | BIP 22/23 (Luke Dashjr, 2012-02-28, Deployed). The node returns the full candidate block so work generation can live outside the validating node — the separation every pool is built on. BIP 23 adds pooled-mining extensions whose stated purpose is countering mining centralisation: block proposal, expiry, custom target, a mutation set, submission abbreviation, two conformance levels. Specified miner template control twelve years before it was adopted. | getblocktemplate, bip22, bip23, template-sourcing, miner-autonomy, submitblock, block-proposal | 2026-09-21 |
| [2026-09-21-smartpool-decentralized-pooled-mining.md](2026-09-21-smartpool-decentralized-pooled-mining.md) | Luu, Velner, Teutsch & Saxena (IACR 2017/019). Two transferable mechanisms: batched commitment (one Merkle root claims ~1M shares, breaking the "messages scale with shares" ceiling the paper identifies as p2pool's core defect) and probabilistic verification (sampling k of n detects cheating at 1 − (m/n)^k; an all-or-nothing penalty makes the cheater's expected payout exactly m). Plus an augmented Merkle tree with a monotonic counter and persisted last_max for duplicate prevention. Mainnet: 105 blocks, 0.6% fees vs 3%. | decentralised-pooling, probabilistic-verification, augmented-merkle-tree, batched-claims, p2pool-critique | 2026-09-21 |
| [2026-09-21-bip310-stratum-extensions.md](2026-09-21-bip310-stratum-extensions.md) | BIP 310 (Moravec, Čapek) — extension negotiation retrofitted onto Stratum V1. `mining.configure` as the first message, before `mining.subscribe`, with namespaced parameters and a server result map. `version-rolling` (invariant `version_bits & ~last_mask == 0`) is what makes modern ASIC search spaces viable; `minimum-difficulty` is what lets one endpoint serve a Bitaxe and a 10 PH/s farm. Records its own hazard: servers that close connections on unknown messages. | bip310, version-rolling, minimum-difficulty, feature-negotiation, asicboost, backwards-compatibility | 2026-09-21 |
| [2026-09-21-measurement-bitcoin-networks-from-mining-pools.md](2026-09-21-measurement-bitcoin-networks-from-mining-pools.md) | Wang, Chu & Yang (arXiv 2019). 156k blocks, 257M transactions, 120.25M mempool observations at 2 s polling; 98.18% pool attribution. Three findings that constrain design: top-four concentration; empty blocks have *shorter* intervals than non-empty (the on-chain signature of SPV mining); and a sharp feerate cliff in transaction selection — ~90% inclusion inside the top X, below 5% outside the top 2X. Concentration figures are stale (window ends Jan 2019); the mechanisms are not. | measurement-study, pool-concentration, empty-blocks, spv-mining, feerate-cliff, methodology | 2026-09-21 |

## Categories

- **protocol-security**: hardening-stratum-bedrock-pets2017
- **attack-economics**: withholding-and-power-splitting-attack-economics, smartpool-decentralized-pooled-mining
- **specifications**: bip22-bip23-getblocktemplate, bip310-stratum-extensions
- **measurement**: measurement-bitcoin-networks-from-mining-pools

## Recent Changes

- 2026-09-21: Six papers ingested in research round 1. Two (Hardening Stratum, withholding economics) were independently surfaced by two agents and carry `credibility: high`.
