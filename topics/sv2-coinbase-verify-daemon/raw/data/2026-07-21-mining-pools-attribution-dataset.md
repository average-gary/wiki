---
title: "Mining-pool attribution datasets (bitcoin-data/mining-pools, mempool/mining-pools)"
source_url: https://github.com/bitcoin-data/mining-pools
source_url_2: https://github.com/mempool/mining-pools
type: data
retrieved: 2026-07-21
credibility: high
corroboration: "gap-3 + gap-4 agents"
tags: [bitcoin, mining-pools, coinbase-tag, payout-address, attribution, dataset, address-book]
summary: "The community pool-attribution datasets: pools identified by (1) coinbase scriptSig tags (regex-matched) and (2) known coinbase payout addresses (first output). The practical backing store for a daemon's expected-address book + expected-tag alerts. Tags/addresses legitimately drift → the projects re-index."
---

# Mining-pool attribution datasets

## Structure

Pools are identified by **two mechanisms**:
1. **Coinbase tags** — ASCII markers in the coinbase scriptSig, matched as **regexes**
   against the block's coinbase (`/Foundry USA Pool/`, `/AntPool/`, `/SpiderPool/`).
2. **Payout addresses** — known coinbase **first-output** addresses.

- `bitcoin-data/mining-pools` (0xB10C / mempool upstream): per-pool
  `{ id, name, addresses: [...], tags: [...], link }`.
- `mempool/mining-pools` `pools-v2.json`: top-level `coinbase_tags` + `payout_addresses`
  objects; entries carry `name`, `link`, and (tags) `regexes` arrays. "Each coinbase tag
  will be used as a regex to match blocks"; payout = "the first output address of the
  coinbase transaction."

## Legitimate drift

When a pool changes its tag or addresses, blocks are **re-indexed / reassigned**
(`AUTOMATIC_BLOCK_REINDEXING`). Concrete example (0xB10C): Binance Pool switched template
providers 2024-08-23 → coinbase tag changed "SpiderPool/" → "binance/". So a tag/address
change is *not per se* suspicious — it can be a legitimate pool-config change.

## Relevance

This is the concrete **"configured address book"** for the daemon: seed expected
`scriptPubKey`s and expected scriptSig-tag substrings from this dataset, and alert on a
coinbase whose payout SPK or tag deviates from the configured expectation. The drift/
reindex behavior warns against treating any tag/address change as automatic fraud.
