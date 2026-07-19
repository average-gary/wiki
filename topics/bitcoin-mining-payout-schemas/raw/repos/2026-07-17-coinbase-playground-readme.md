---
title: "coinbase-playground README — CTV+CSFS non-custodial coinbase payouts"
source: "https://github.com/vnprc/coinbase-playground/blob/0ac7ed25a21806a0c9ba96fe50c34b9ce2c2cce6/readme.md"
type: repo
ingested: 2026-07-17
quality: 4
credibility: medium
confidence: high
tags: [collection, coinbase-playground, ctv, csfs, coinbase, non-custodial-pool, ocean, p2pool, bitmain, truc, payout-tree, musig]
summary: "README for the CTV+CSFS coinbase playground. Argues CTV coinbase payout trees enable non-custodial mining pools by committing a large payout structure in a small footprint, defeating Bitmain's firmware coinbase-size limit. Documents a flat payout tree (~319-output TRUC ceiling, 330-sat anchor, 1 sat/vB) and a layered binary tree, with a MuSig-tree + P2Pool-reboot endgame."
collection: "coinbase-playground"
adapter: git
upstream_id: "readme.md"
upstream_type: git-file
revision: "0ac7ed25a21806a0c9ba96fe50c34b9ce2c2cce6"
sha: "730794475de02edd658556c4e7804fe46019b6cc"
canonical_url: "https://github.com/vnprc/coinbase-playground/blob/0ac7ed25a21806a0c9ba96fe50c34b9ce2c2cce6/readme.md"
content_format: markdown
license: "unknown"
authors: [vnprc]
outlinks: ["https://github.com/bitcoin/bips/blob/master/bip-0119.mediawiki", "https://github.com/bitcoin/bips/blob/master/bip-0348.md", "https://github.com/average-gary/bitcoin-garrys-mod", "https://github.com/stutxo/simple_ctv", "https://ocean.xyz", "https://blog.opdup.com/2025/02/26/trading-shares-for-bitcoin-user-story.html"]
fetched: 2026-07-17
---

# coinbase-playground README

Part of the [[2026-07-17-collection-coinbase-playground-manifest.md|coinbase-playground collection]]. Author advocacy + working regtest demo (medium credibility).

## Purpose
Regtest environment for experimenting with **OP_CHECKTEMPLATEVERIFY** (BIP-119) + **OP_CHECKSIGFROMSTACK** (BIP-348), using: `bitcoin-garrys-mod` (CTV+CSFS-enabled Core fork), electrs+esplora indexer/UI, and Rust scripts to generate a CTV coinbase and spend from it. `just` recipes wrap common actions. Credits stutxo's `simple_ctv` for inspiration.

## `just` recipes
- `mine-and-send` — mine initial coins, send 1 BTC to a new address
- `mine-ctv-coinbase [outputs]` — mine + spend a flat CTV coinbase (default 50 outputs)
- `mine-layered-ctv-coinbase` — mine + spend a 2-level CTV tree with fixed fees
- `parse-witness <txid> [index]` — parse input witness scripts (see the CTV/`OP_NOP4`)
- `build-esplora`, `reset-chain`

## The argument: CTV enables non-custodial pools
- "CTV enables noncustodial mining pools." Every pool except **OCEAN** is custodial — the "trust me bro" payout model where the pool takes possession of mined bitcoin.
- Pools *could* pay their largest miners directly in the **coinbase** (block's first tx, where new bitcoin originates). OCEAN does, but is "severely limited in the amount of outputs they can put in the coinbase."
- Two obstacles: (1) a larger coinbase eats into fee revenue; (2) the bigger problem — **miner firmware restrictions**.
- "**Bitmain**, the largest ASIC manufacturer by far, limits the size of the coinbase transaction in their miner firmware." Claimed as deliberate to "stifle competition from decentralized alternatives" — and "**P2Pool died a slow death**, in large part due to Antminer firmware restrictions."
- OCEAN works around it: "fingerprint the hardware in use by their miners and keep track of multiple work templates," plus loose validation of miner-submitted blocks (cites Jason Hughes talk, timestamp 3:03:00). "A really tough and completely unnecessary engineering problem."
- **CTV coinbase transactions eliminate this**: construct a large transaction tree with many outputs and "commit to the entire payout structure in a very small transaction footprint."

## Three wins / two downsides
Wins (in stated order of importance): 1. "Break Bitmain's stranglehold on the coinbase." 2. Enable non-custodial pools at any scale. 3. Maximize per-block fee revenue.
Downsides: 1. Users must get additional transactions mined to claim rewards. 2. Someone must make the **unroll transaction data** available.

## Flat payout tree
- Intended to be broadcast to the mempool **immediately** at **1 sat/vB** taken from the coinbase reward.
- Includes a **330-sat anchor** output anyone can spend to fee-bump; users could crowdsource the fee tx via `SIGHASH_ANYONECANPAY`.
- Solves data-availability by avoiding nested CTV txs and broadcasting the CTV spend right after the block is mined; it sits in the mempool up to **100 blocks** (coinbase maturity) and gets mined when fees are low; users can bump if impatient.
- **Tested upper limit ≈ 319 payout outputs** before hitting **TRUC** transaction-size policy limits.
- `parse-witness` reveals the tapleaf script: `PushBytes(<32-byte ctv hash>)` then `Op(OP_CTV)`.

## Layered payout tree
- Simple binary tree, 2 layers / 4 leaves; **fixed 500-sat fee per tx** (root + 2 children).
- Author notes it's "strictly worse than the flat structure" for pool payouts but a stepping stone. Planned next steps: replace fixed fee with 0-value anchors; make leaf count, depth, and **radix** (children per node) configurable.
- Esplora shows `OP_NOP4` in the scriptPubKey — CTV by its pre-activation NOP name; esplora isn't aware of the node's CTV activation code.

## Endgame
- "create a tree with an **n of n musig locking script at each node**." Leaf owners spend the 100 blocks after confirmation trading outputs to consolidate the tree into fewer nodes — e.g. swap off-chain funds for a sibling's signature(s) to collapse a subtree one level and get a larger on-chain payout with fewer txs.
- Explicitly ties to the **P2Pool reboot** (cites Kulpreet's opdup blog "trading shares for bitcoin"). (Cross-ref: this MuSig-tree + off-chain-consolidation pattern echoes Ark's shared-output tree; cf. hub topic covenantless-ark.)

## Cross-references
- Node dependency: [[../../../garrys-mod/_index.md|garrys-mod]] (local wiki) — the CTV/CSFS Core fork this runs on. (May be unavailable if not registered; see wikis.json local_wikis.)
- Adjacent: [[../../datum/_index.md|datum]] (OCEAN non-custodial coinbase templates), and hub topic covenantless-ark (MuSig payout trees, unroll/data-availability).
