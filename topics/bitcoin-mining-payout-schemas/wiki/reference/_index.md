---
title: Reference
type: section-index
---

# Reference

Pools, projects, repos, specs, people.

## People

- [[people|People — eHash / hashpool / decentralized-pool contributors]]

## Pools (modern non-FPPS)

- **OCEAN** — TIDES + DATUM. ~3% network share. Operator: Luke Dashjr et al. https://ocean.xyz
- **DMND / Demand Pool** — SLICE / PPLNS-JD. Stratum V2 native. Operator: Guru Protocol Ltd. https://dmnd.work
- **hashpool** — eHash / Cashu mint. Testnet4 only (v0.1.1, March 2026). Author: vnprc. https://github.com/vnprc/hashpool
- **Hydrapool** — 256 Foundation pool, uses p2poolv2 lib. Author: Jungly. https://github.com/256foundation/hydrapool

## Pools (FPPS-class incumbents)

- Foundry, AntPool, F2Pool, ViaBTC, MARA Pool, Luxor, Braiins (Slush) — see [[../../raw/articles/2026-05-23-mempool-space-mining-dashboard|mempool.space]] for live shares.

## Specs

- **Stratum V2 (sv2-spec)** — https://github.com/stratum-mining/sv2-spec
- **Cashu NUTs** — https://github.com/cashubtc/nuts
- **p2poolv2 / ShareChain.tla** — https://github.com/p2poolv2/p2poolv2
- **delvingbitcoin/t/870** — https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870 (eHash origin proposal)

## Foundational papers

- Rosenfeld 2011 — Analysis of Bitcoin Pooled Mining Reward Systems
- Schrijvers et al. FC'16 — Incentive Compatibility of Pool Reward Functions
- Eyal IEEE S&P'15 — The Miner's Dilemma
- Chatzigiannis et al. 2022 — Diversification Across Mining Pools
- FiberPool 2025 — Sakurai & Shudo

See [[../../raw/papers/_index|raw/papers]] for full notes.

## Sister wikis (this hub)

- [[../../../sv2-p2pool-integration/_index|sv2-p2pool-integration]]
- [[../../../iroh-transport-stratum-v2/_index|iroh-transport-stratum-v2]] — relevant for EthnTuttle's SRI Iroh RFC
- [[../../../sv2-coinbase-identity/_index|sv2-coinbase-identity]] — SV2 coinbase construction, `JobFactory`, Pool-vs-JDC coinbase ownership

## Coinbase rotation

Rotation of the payout scriptPubKey (fresh address per block) is covered **inside this topic** rather than in a separate wiki:

- [[../../raw/repos/2026-07-29-sv2-apps-xpub-coinbase-rotation-code-read|sv2-apps xpub/wildcard-descriptor rotation @ e2930150]] — the SV2-native Rust implementation (`XpubDerivator`, miniscript `has_wildcard()` gate, rotation on `SubmitSolution`)
- `REPOS/para/.wiki/output/plan-coinbase-rotation-2026-06-24.md` + `pr-body-coinbase-rotation.md` — the shipped ckpool + BDK design (local wiki, not in this hub)

The former `coinbase-rotation-bitcoin` hub topic was an empty 0-file skeleton and was removed 2026-07-29.

## Coverage

- [[uncompiled-source-coverage.md|Uncompiled source coverage — bitcoin-mining-payout-schemas]] — Compilation backlog: raw sources in this topic that no wiki article yet cites in its sources.
