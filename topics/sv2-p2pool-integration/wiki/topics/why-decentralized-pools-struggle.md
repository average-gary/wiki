---
title: Why decentralized pools struggle
type: topic
created: 2026-05-22
updated: 2026-05-22
verified: 2026-05-22
volatility: warm
confidence: high
sources:
  - "[[raw/articles/2026-05-22-delvingbitcoin-deterministic-tx-selection|Delving Bitcoin: deterministic tx selection]]"
  - "[[raw/articles/2026-05-22-bitcoinmag-braidpool-second-competitor|Bitcoin Mag on Braidpool]]"
  - "[[raw/papers/2026-05-22-fiberpool-arxiv|FiberPool arxiv]]"
  - "[[raw/articles/2026-05-22-stacker-news-braidpool-mercenaries|Stacker News thread]]"
  - "[[raw/data/2026-05-22-pool-concentration-snapshot|Pool concentration snapshot]]"
---

# Why decentralized pools struggle

The contrarian thread that any sv2-p2pool integration plan must address. SV2 + p2poolv2 are necessary protocol-layer work, but the constraints below are not solved by protocol alone.

## 1. Variance economics dominate ideology

Per [[../concepts/p2pool-history|p2pool's hashrate trajectory]], the original P2Pool went from ~1-2% of network to ~0.00015% over a decade. The reason wasn't bug-shaped — it was variance economics. Centralized FPPS pools smooth payouts; decentralized share-chains don't. Stacker News thread captures it:

> Miners are blue collar mercenaries who just plug the machines in and make money.

Ideological decentralization arguments are an "uphill battle" against centralized-pool UX/payout-smoothing. Confidence: **high**.

Even Braidpool's ~600× variance reduction vs solo is *insufficient* for individual modern ASICs (Braidpool's own admission). The pool sub-pool escape hatch reintroduces variance-smoothing trust at one level of indirection.

## 2. Share-chain capacity ceiling

Per [[../raw/papers/2026-05-22-fiberpool-arxiv|FiberPool arxiv]]:

> P2Pool faces two main issues. The first is scalability: as a blockchain, the share chain has limited capacity for generating shares.

Single-share-chain protocols (longest-chain, DAG, braid) inherit this. As difficulty climbs, small miners get pushed off because their share rate falls below useful thresholds. Confidence: **high** (academic source explicitly identifies this).

## 3. Bandwidth ceiling at scale

Per [[../raw/articles/2026-05-22-delvingbitcoin-deterministic-tx-selection|Delving Bitcoin]] thread, ajtowns argues that at pool scale, beads every ~6s with full tx data per bead is bandwidth/validation prohibitive. Hybrid 95/5 schemes are proposed but reintroduce trust assumptions that "pure decentralized" claims are supposed to eliminate. Confidence: **medium-high**.

## 4. Policy alignment as covert centralization

Same thread: if a Braidpool/p2poolv2 deployment exceeds ~30% hashrate, Bitcoin Core relay policy must align to avoid expected/actual block divergence. This is a centralization vector even though no single entity is in charge. Confidence: **medium**.

## 5. No "pool company" to subsidize bootstrap

Per [[../raw/articles/2026-05-22-bitcoinmag-braidpool-second-competitor|Bitcoin Magazine]]:

> Any actual Braidpool must quickly grow to a sizable enough portion of the network to smooth out volatility... or those miners stay with a pool not achieving that growth will simply wind up losing themselves money.

Centralized pools subsidize early variance with operator capital. Decentralized pools have no such buffer. Same problem applies to p2poolv2. Confidence: **high**.

## 6. Demand-side ceiling: Ocean's stagnation

Per [[../raw/data/2026-05-22-pool-concentration-snapshot|2026-05-22 data]]:

- Foundry: 31.2%
- AntPool: 16.7%
- F2Pool: 11.5%
- SpiderPool: 10.4%
- ViaBTC: 8.1%
- Top 5 = 77.7% of blocks
- **Nakamoto coefficient (block production) = 3**
- OCEAN: 1.7-2.9% — **not growing** despite first-mover credibility, mainstream press, and DATUM differentiation
- Even OCEAN's intra-pool concentration is high: top miner = 22.97% of OCEAN's hash

If Ocean (well-funded, well-marketed, production-stable) can't grow past ~2%, p2poolv2's path to meaningful adoption is unclear. Confidence: **medium-high**.

## 7. UX burden

Every decentralized-pool miner must run a full node. Operational barrier vs plug-and-play centralized pools. p2poolv2 inherits this; SV2 doesn't fix it.

## 8. No consensus-enforcement of decentralized tx selection

Per Fi3 (SRI dev) in the Delving Bitcoin thread: deterministic tx selection has no Bitcoin-consensus enforcement. Governments can mandate jurisdictionally-compliant pools regardless of the protocol layer. SV2's JDP gives miners *the option* to select; it doesn't enforce that they do.

## What this means for the integration project

A clear-eyed sv2-p2pool integration plan should:
- **Not over-promise on adoption** — protocol elegance ≠ market share
- **Match SV2 + p2poolv2 to the real demand** — small miners and ideologically-motivated medium miners, not Foundry-scale operations
- **Treat variance smoothing as a first-class problem** — atomic-swap routing, pool-of-pools, derivative markets
- **Anticipate hybrid critique** — be explicit about what gets centralized in practice (relay policy, token-allocation authority, threshold signers if any)

## See also

- [[integration-paths]]
- [[../concepts/p2pool-history]]
- [[../concepts/ocean-datum]]
- [[../concepts/braidpool]]
