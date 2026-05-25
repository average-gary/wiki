---
title: "p2poolv2 wiki: Uncle Blocks"
publication: github.com/p2poolv2/p2poolv2/wiki
url: https://github.com/p2poolv2/p2poolv2/wiki/Uncle-Blocks
type: article
ingested: 2026-05-24
quality: 5
credibility: high
confidence: high
tags: [p2poolv2, uncle, share-chain, DAG-lite]
---

# p2poolv2 Uncle Blocks

p2poolv2 share-chain is **chain-with-uncles** (DAG-lite), not full DAG (Braidpool). Each share may reference up to 3 uncles.

## Inclusion rules

- **Uncles in PPLNS at 90% weight** (`UNCLE_SCALED_WEIGHT = 9` of `DIFFICULTY_SCALE = 10`).
- **Nephew bonus**: implicit in the chain-work accounting via `NEPHEW_SCALED_BONUS = 1` per referenced uncle. The wiki says: *"entire weight of the uncle blocks while traversing the DAG."*
- A share may cite up to **3 uncles**.
- Uncles must be within **3 blocks of tip** (recent only).
- **No ancestor refs**.
- An uncle cited by share X **cannot be cited by direct descendants of X** (prevents double-counting).

## Reorg / chainwork

Chainwork for a share = `own work + Σ(referenced uncles' work)`. This is the value compared during reorgs to pick the heaviest tip — analogous to Bitcoin's longest-chain rule but with uncle work counted in.

## Coinbase spendability

- **Uncle coinbase outputs ARE spendable.**
- **Non-coinbase outputs in uncle blocks are NOT.**

This bounds the accounting surface to coinbase outputs only. Important for the atomic-swap design — share-chain transactions can only redeem from confirmed-share coinbases, not from uncles' tx pools.

## Why uncles vs. linear chain (forrestv 2011)

Original p2pool had no uncle mechanism. Latency-orphaned shares were lost work for the miner. p2poolv2's uncles fix that — propagation losers still get 90% credit if they can be referenced within 3 share-block depths.

## Why uncles vs. full DAG (Braidpool)

Braidpool's "beads in cohorts" is a strict generalization. p2poolv2's chain-with-up-to-3-uncles is a **shipping subset** — implementable on existing Bitcoin consensus, no soft fork. Braidpool's covenant-based UHPO requires CTV/TXHASH-class opcodes.

## See also

- [[../repos/2026-05-24-p2poolv2-accounting-modules|p2poolv2 accounting code]]
- [[../articles/2026-05-24-monero-p2pool-schernykh|SChernykh Monero p2pool]] — earlier uncle implementation
