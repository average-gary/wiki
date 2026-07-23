---
title: "miningpool.observer + 0xB10C observations (template↔block observer; coinbase EXCLUDED)"
source_url: https://github.com/0xB10C/miningpool-observer
source_url_2: https://miningpool.observer/
source_url_3: https://b10c.me/observations/12-template-similarity/
type: repo
retrieved: 2026-07-21
credibility: high
corroboration: "prior-art agent"
tags: [miningpool-observer, 0xB10C, template-comparison, censorship, coinbase-tag, merkle-branch, transparency, rust]
summary: "The canonical template-vs-block observer (Rust, own Bitcoin Core node). Detects missing/extra/conflicting/sanctioned transactions — but EXPLICITLY excludes the coinbase from analysis. The exact gap a coinbase-verify daemon fills. 0xB10C's template-similarity method shows coinbase tags + merkle branches are strong pool-attribution signals."
---

# miningpool.observer + 0xB10C observations

## miningpool.observer

- Compares **block templates** (from its own Bitcoin Core via `getblocktemplate`)
  against **actually mined blocks** → finds **missing** (in template, not block),
  **extra** (in block, not template), **conflicting** (double-spend) transactions.
  Purpose: transparency into pool transaction selection / censorship.
- **Rust**, multi-crate (daemon + web + shared), PostgreSQL-backed; requires Bitcoin
  Core ≥ v22.0; runs continuously. Self-hostable; public instance at
  miningpool.observer.
- Flags **OFAC-sanctioned** txs omittable-but-omitted; records mempool arrival timing
  to distinguish censorship from propagation delay (pools refresh templates ~every 30s).
- Origin: Marathon's March 2021 "OFAC-compliant pool" announcement; a 25-day study
  found Marathon didn't actually filter sanctioned txs.
- **Coinbase handling: treats the coinbase as pool-specific data and EXCLUDES it from
  censorship analysis** — it does NOT verify the coinbase payout. **This is the gap a
  coinbase-checking daemon fills.**
- Runs as an **external observer** (own node), NOT as a downstream miner.

## 0xB10C observations (methodology substrate)

- **Template-similarity (Sept 2024):** detects proxy-pooling / shared templates by
  comparing **merkle-branch sequences** from stratum jobs (branches encode
  included-tx structure without full txs), weighted so later branches count more;
  **coinbase tags** used as corroborating evidence.
- Concrete: Binance Pool switched template providers 2024-08-23, visible as a
  merkle-branch shift AND a **coinbase-tag change "SpiderPool/" → "binance/"** — the
  coinbase scriptSig tag is a reliable pool-attribution signal.
- Related: OFAC-sanctioned txs missing from blocks (Nov 2023, Jan 2025); AntPool
  distributing invalid mining jobs during forks (Mar 2025) — real pool misbehavior
  detected externally.

## Relevance

Closest architectural cousin, but coinbase-blind. Confirms the daemon's niche is real
and largely unoccupied: external, per-miner coinbase payout verification.
