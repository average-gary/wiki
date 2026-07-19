---
title: "coinbase-playground: mine_and_send.rs (regtest bootstrap)"
source: "https://github.com/vnprc/coinbase-playground/blob/0ac7ed25a21806a0c9ba96fe50c34b9ce2c2cce6/scripts/src/mine_and_send.rs"
type: repo
ingested: 2026-07-17
quality: 3
credibility: medium
confidence: high
tags: [collection, coinbase-playground, regtest, bootstrap, wallet, rust]
summary: "Minimal regtest bootstrap script: ensures a devwallet, mines 101 blocks if balance < 1 BTC to mature a coinbase, then sends 1 BTC to a fresh address and confirms it. Setup helper, not CTV-specific."
collection: "coinbase-playground"
adapter: git
upstream_id: "scripts/src/mine_and_send.rs"
upstream_type: git-file
revision: "0ac7ed25a21806a0c9ba96fe50c34b9ce2c2cce6"
sha: "fc719c9ca6eff5baf6ca0b0ccefc7f8ef07e11a4"
canonical_url: "https://github.com/vnprc/coinbase-playground/blob/0ac7ed25a21806a0c9ba96fe50c34b9ce2c2cce6/scripts/src/mine_and_send.rs"
content_format: text
license: "unknown"
authors: [vnprc]
fetched: 2026-07-17
---

# mine_and_send.rs — regtest bootstrap

Part of the [[2026-07-17-collection-coinbase-playground-manifest.md|coinbase-playground collection]]. Behind `just mine-and-send`. A setup helper, not CTV-specific.

- Ensures a `devwallet` regtest wallet (create/load, tolerating "already exists").
- If balance < 1 BTC: `generate_to_address(101, mining_addr)` to mature a coinbase.
- Sends **1 BTC** to a fresh `getnewaddress`, then mines 1 block to confirm; prints balance and txids.
- Lowest-signal of the four scripts; included for collection completeness/provenance.
