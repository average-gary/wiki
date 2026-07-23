---
title: "stratum.work (live coinbase decoder) + DATUM (miner-built coinbase) prior art"
source_url: https://stratum.work/
source_url_2: https://github.com/OCEAN-xyz/datum_gateway
source_url_3: https://ocean.xyz/docs/datum
type: article
retrieved: 2026-07-21
credibility: medium
corroboration: "prior-art agent"
tags: [stratum.work, DATUM, OCEAN, coinbase-decoder, mining.notify, block-template, miner-built-coinbase, stratum-v1]
summary: "Two prior-art points: stratum.work decodes live Stratum V1 coinbase outputs from mining.notify (external observer, does not assert against an expectation); DATUM (OCEAN) lets the miner BUILD its own coinbase locally from getblocktemplate (verification by construction, not audit)."
---

# stratum.work + DATUM — prior art

## stratum.work (live V1 coinbase visualizer)

- Connects to many pools as a **Stratum V1 client**, captures live `mining.notify`
  jobs, decodes/displays them in real time.
- Shows: **coinbase transaction** (scriptSig ASCII), **coinbase outputs and values**
  (the pool's payout outputs), **merkle branches** (up to 12), block height, first-tx
  fee rate, pool name/identification, `ntime`.
- Views: table, timing chart, Sankey, infra metrics — oriented to comparing pool
  behavior across pools.
- Operates as an **external observer** on public stratum endpoints; does not mine.
- Demonstrates the core primitive: **extract the coinbase output set from a V1 job
  (coinb1 + extranonce + coinb2) and read payout address/value** — but it does not
  assert them against a per-miner expected value, and it's V1.

## DATUM Gateway (OCEAN) — miner-built coinbase

- DATUM ("Decentralized Alternative Templates for Universal Mining") lets the **miner
  build the block template locally** from their own node's GBT; "the real miner is
  whoever runs the node."
- Architecture: local Bitcoin node (GBT) → DATUM Gateway (distributes work via Stratum
  V1, talks to pool, submits solved blocks directly to network) → mining hardware.
- **Coinbase split of control:** miner controls template policy, tx selection, and the
  **primary coinbase tag**; the **pool controls the generation-transaction payout
  splits** (reward distribution), a secondary tag, and a unique-identifier requirement.
  "Coinbase payouts go directly to miners, non-custodially."
- The "downstream miner that constructs & implicitly trusts its own coinbase" model —
  verification is **by construction**, not external audit.

## Relevance

stratum.work proves live coinbase-output decoding is feasible off the wire; DATUM is
the miner-builds-it alternative to a verify-only daemon and clarifies which coinbase
fields a pool legitimately sets (payout split + secondary tag).
