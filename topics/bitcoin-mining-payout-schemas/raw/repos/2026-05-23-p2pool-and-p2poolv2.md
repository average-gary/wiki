---
title: "p2pool (forrestv 2011) and p2poolv2 (2024+)"
publication: bitcoin wiki + github.com/p2poolv2/p2poolv2
url: https://en.bitcoin.it/wiki/P2Pool
url2: https://github.com/p2poolv2/p2poolv2
url3: https://bitcointalk.org/index.php?topic=18313.0
type: repo
ingested: 2026-05-23
quality: 4
credibility: high
confidence: high
tags: [p2pool, p2poolv2, share-chain, decentralized-pool, on-chain-PPLNS]
---

# p2pool (2011) and p2poolv2 (2024+)

The decentralized-pool branch. p2pool was the first peer-to-peer Bitcoin pool — June 17, 2011, by forrestv. p2poolv2 is the modern revival with formal TLA+ spec.

## p2pool (original) parameters

- Share-chain block time: **30 seconds**.
- Payout window N: `min(shares whose total work = 3× block-work, 8640)` — up to **72 hours of shares**.
- Each share-chain block is a "share"; coinbase pays previous N shares' contributors directly.
- **On-chain PPLNS without a custodian** — direct intellectual ancestor of TIDES, PPLNS-JD/SLICE, hashpool.
- Endorsed by gmaxwell (Jan 2012) as "critical for the health and welfare of the Bitcoin system."

## Why p2pool declined (2014-2017)

Documented failure modes:

- **Stale-share problem**: 30-sec share-chain is 20× faster than Bitcoin's 10-min block; DOA and orphan shares "common and expected" → direct hashrate loss vs. centralized pools.
- **Dust problem**: as miners join, individual coinbase outputs shrink below cost-to-spend → motivated "Lightning P2Pool" proposal.
- **Hardware incompatibilities**: Cointerra and certain Antminers lost 10-20% hashrate when mining on p2pool.
- **Operational complexity**: full node + correct FPS/intensity tuning required → UX disqualified casual miners.
- ASIC era rewarded **low-variance PPS/FPPS** model offered by centralized pools.

## p2poolv2 design (2024+)

Spec: `ShareChain.tla` (formal TLA+).

- Share chain with **uncle shares** for full work accounting (low-orphan PPLNS-on-chain analog).
- Coinbase payout to **top-N large miners** (non-custodial).
- Smaller miners paid via atomic-swap **"support transactions"** where market makers buy small shares for virgin coinbase coins → addresses the dust-output problem.
- Successor to forrestv's p2pool; addresses high-variance and small-miner UX problems via the market-maker layer.
- Hybrid model: top-N coinbase + atomic-swap PPLNS — absent from centralized-pool literature.

## Connection to Stratum V2

p2poolv2 + SV2 Job Declaration is one of the four 2024-2026 production decentralization paths:
- TIDES + DATUM (OCEAN)
- SLICE / PPLNS-JD (DMND)
- eHash / hashpool
- p2poolv2 share-chain

Each removes a different point of trust:
- TIDES + DATUM: removes pool's custody of payouts and template construction.
- SLICE: removes pool's choice of block content.
- eHash: removes pool's per-miner ledger.
- p2poolv2: removes the pool operator entirely.

## See also (in this hub)

[[../../sv2-p2pool-integration/_index|sv2-p2pool-integration]] (sister wiki: how p2poolv2 plugs into sv2-apps)
