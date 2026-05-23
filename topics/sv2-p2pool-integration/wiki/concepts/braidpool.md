---
title: Braidpool
type: concept
created: 2026-05-22
updated: 2026-05-22
verified: 2026-05-22
volatility: warm
confidence: high
sources:
  - "[[raw/papers/2026-05-22-braidpool-spec|Braidpool spec]]"
  - "[[raw/repos/2026-05-22-braidpool-repo|braidpool repo]]"
  - "[[raw/articles/2026-05-22-bitcoinmag-braidpool-second-competitor|Bitcoin Magazine on Braidpool]]"
---

# Braidpool

Braidpool is the closest design-space alternative to [[p2poolv2]]. Same problem (decentralized SV2-aligned pool), different consensus shape.

## Core differences vs p2poolv2

| Dimension | p2poolv2 | Braidpool |
|---|---|---|
| Share-chain shape | Linear chain + uncles | DAG ("braid") of "beads" |
| Consensus rule | Longest-share-chain | SSDW (Simple Sum of Descendant Work) |
| Payout | Direct coinbase to top-N miners; atomic swaps for the long tail | Threshold-signed (FROST) coinbase output |
| PPLNS window | Implicit via top-N + atomic swap | N=2016 (one Bitcoin difficulty epoch) |
| SV2 integration | Future / aspirational; V1-only today | Designed in from day 1 (uses SV2 Template Provider) |
| Tx-set bandwidth optimization | Compact-block / share commitment | "Committed mempool" — each share commits to 2-5 txs |
| Maturity | Active dev, no production deploys | Earlier stage; sim + CPUNet |

## Design goals (Braidpool's framing)

1. Lower variance for small miners
2. **Block sovereignty** — miners build their own blocks (same as P2Pool)
3. **Scalable payouts** — constant blockspace regardless of miner count
4. Support hashrate derivatives / futures market

## Variance reality check

Per Braidpool's own general-considerations doc:

- Targets ~1-second consensus → ~600× variance reduction vs solo
- Admits this is *still insufficient* for individual modern ASICs
- Proposes sub-pools as escape hatch

Same variance reality applies to p2poolv2.

## Threshold-signed payouts: the unsolved problem

Braidpool's largest unsolved problem is **threshold-signature coinbase payout authorization** (FROST-style). Brings significant cryptographic-protocol complexity:
- All signers must remain online
- Restart on any failure
- Scalability of signer set

p2poolv2 sidesteps this entirely via direct-coinbase payouts to top-N miners + atomic swaps for the long tail — simpler crypto but with its own coordination cost.

## Provenance

Bob McElrath et al. Cites P2Pool as design precedent for block sovereignty. 138 GitHub stars at time of ingest, active dev.

## SV2 alignment

Braidpool **explicitly builds on the SV2 Template Provider**: it factorizes transaction selection (delegated to SV2 TP / miner) from pool consensus (the braid). This contrasts with p2poolv2, which today has no SV2 dependencies.

The strategic implication: if p2poolv2 wants to be the SV2-aligned successor to P2Pool, it must close this gap; Braidpool is already there architecturally.

## See also

- [[p2poolv2]] — the comparator
- [[ocean-datum|OCEAN DATUM]] — V1-based competitor
- [[../topics/integration-paths|Integration paths]]
