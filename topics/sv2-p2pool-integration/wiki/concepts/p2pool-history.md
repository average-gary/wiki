---
title: P2Pool lineage
type: concept
created: 2026-05-22
updated: 2026-05-22
verified: 2026-05-22
volatility: cold
confidence: high
sources:
  - "[[raw/articles/2026-05-22-bitcointalk-p2pool-original|bitcointalk: original P2Pool announcement]]"
  - "[[raw/articles/2026-05-22-bitcoinwiki-p2pool|Bitcoin Wiki: P2Pool]]"
  - "[[raw/repos/2026-05-22-monero-p2pool-schernykh|Monero P2Pool (SChernykh)]]"
  - "[[raw/repos/2026-05-22-braidpool-repo|Braidpool repo]]"
  - "[[raw/repos/2026-05-22-p2poolv2-repo|p2poolv2 repo]]"
---

# P2Pool lineage

Timeline of the decentralized-pool design lineage and its convergence with [[stratum-v2-overview|Stratum V2]].

## Timeline

| Year | Event |
|------|-------|
| 2011-06-17 | **Forrest Voight** announces P2Pool on bitcointalk; first decentralized Bitcoin mining pool. Python, share-chain w/ 30s difficulty. |
| 2012 | **Marek Palatinus ("slush")** + Pavel Moravec at SlushPool develop **Stratum V1** protocol — the centralized-pool standard P2Pool was a reaction against. |
| 2013-2015 | P2Pool peaks at ~1-2% of network hashrate (anecdotal). Forks emerge: P2Pool-Bitcoin, p2pool-fpga, Litecoin scrypt support. |
| 2016-2018 | P2Pool declines as Stratum V1 + ASIC pools dominate. Concerns mount about pool centralization (job assignment monopoly). |
| 2018 | **Braiins (Slush Pool)** publishes **Stratum V2** draft with Pavel Moravec, Jan Čapek. Key innovation: Job Negotiation (later JDP) lets miners construct their own block templates — addressing the centralization that motivated P2Pool. |
| 2021-09-08 | **SChernykh** launches Monero P2Pool (v1.0) — C++, sharechain-with-uncles, 1-second blocks. Most successful P2Pool descendant. |
| 2022-03 | Stratum V2 reference implementation (SRI) goes public; backed by Spiral, Braiins. |
| 2022-2023 | **Braidpool** emerges (Bob McElrath et al.) — DAG/braid share chain designed to integrate SV2's Job Declaration. |
| 2024-2025 | **p2poolv2** development begins as Rust modernization with declared SV2-integration intent. The convergence point. |
| 2025-2026 | Active development: stratum-mining/stratum (SRI), sv2-apps, p2poolv2, braidpool. SV2's JDP becomes the standard interface for decentralized pool participation. |
| 2026-05 | p2poolv2 v0.10.16 — production-hardening V1 stratum surface; SV2 integration not yet started in code. |

## Convergence thesis

P2Pool (2011) solved decentralization but lacked a clean miner-side protocol. Stratum V2 (2018+) standardized miner-side block construction. p2poolv2 / Braidpool (2024+) marry the two — using SV2's JDP as the on-the-wire protocol while keeping P2Pool's sharechain (linear w/ uncles in p2poolv2; DAG/braid in Braidpool) as the consensus layer.

## Hashrate trajectory of original P2Pool

- 2011-06: 110 GH/s at launch
- 2012-01: 120-150 GH/s
- ~2013-2014: peaked at ~1-2% of network (anecdotal)
- Today: ~1.5 PH/s vs ~970 EH/s network = **~0.00015%** — effectively zero

The original died not because the protocol broke but because variance economics + ASIC concentration made centralized FPPS pools dominant. See [[../topics/why-decentralized-pools-struggle|why decentralized pools struggle]].

## Provenance details

- Forrest Voight's original bitcointalk thread: https://bitcointalk.org/index.php?topic=18313.0
- Original repo (Python, archived development): `github.com/p2pool/p2pool` — 1730 commits, GPL-3.0
- Monero P2Pool (active, C++): `github.com/SChernykh/p2pool`
- p2poolv2 (Rust, active): `github.com/p2poolv2/p2poolv2`
- Braidpool (Rust + Python sim): `github.com/braidpool/braidpool`

## See also

- [[p2poolv2]] — current Rust implementation
- [[braidpool]] — DAG alternative
- [[../topics/why-decentralized-pools-struggle|Why decentralized pools struggle]]
