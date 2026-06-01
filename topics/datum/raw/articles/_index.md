---
title: Articles
type: index
updated: 2026-06-01
---

# Articles (35)

## Contents

| File | Summary | Tags | Updated |
|------|---------|------|---------|
| [2026-05-28-datum-gateway-readme.md](2026-05-28-datum-gateway-readme.md) | DATUM Gateway README — DATUM Protocol shape, node config (Knots-recommended, blockmaxsize/weight), build matrix, Docker deployment, pool template/share rules. Public BETA. | datum, datum-protocol, gbt, stratum, bitcoin-knots, docker, ocean | 2026-05-28 |
| [2026-05-28-datum-gateway-usernames.md](2026-05-28-datum-gateway-usernames.md) | Stratum username semantics: address-as-username (Base58/Bech32/Bech32m), worker-name `.` separator, three pool-passthrough modes, `~modifier` per-share revenue sharing, ASIC length quirks. | datum, stratum, usernames, username-modifiers, asic | 2026-05-28 |
| [2026-05-28-ocean-docs-index.md](2026-05-28-ocean-docs-index.md) | OCEAN documentation landing page — directory of 10 entries (3 how-tos, 6 technical, 1 article). Entry point for the `ocean-docs` collection. | ocean, datum, mining-pool, documentation-index, collection | 2026-05-28 |
| [2026-05-28-ocean-alternate-templates.md](2026-05-28-ocean-alternate-templates.md) | Now-decommissioned (Dec 21 2025) menu of pre-DATUM block-template options served by OCEAN. Now positioned as a starting point for DATUM Gateway operators building their own templates. | ocean, datum, block-template, mining-pool, decommissioned | 2026-05-28 |
| [2026-05-28-ocean-datum-setup-guide.md](2026-05-28-ocean-datum-setup-guide.md) | OCEAN's official DATUM Gateway setup guide — Bitcoin Knots recommended over Core, five install steps, miner config (`stratum+tcp://your_datum_node_ip:23334`, address-as-username). | ocean, datum, datum-gateway, setup, bitcoin-knots, stratum-v1 | 2026-05-28 |
| [2026-05-28-ocean-lightning-payouts.md](2026-05-28-ocean-lightning-payouts.md) | OCEAN's BOLT12 Lightning payout opt-in flow, supported wallets, signing methods, 0.01048576 BTC on-chain fallback, March 2026 Alby Hub v1.21.2+ incompatibility advisory. | ocean, lightning, bolt12, payouts, bip-322, mining-pool | 2026-05-28 |
| [2026-05-28-ocean-core-antispam-policy.md](2026-05-28-ocean-core-antispam-policy.md) | Bitcoin Core v25.0 + antispam patch with `blockmaxweight=3985000` (vs default 3996000). Reserves template space for OCEAN's coinbase. | ocean, datum, bitcoin-core, antispam, node-policy, block-template | 2026-05-28 |
| [2026-05-28-ocean-core-policy.md](2026-05-28-ocean-core-policy.md) | Bitcoin Core v29.0 with single deviation: `blockmaxweight=3985000`. All other Core defaults preserved. | ocean, datum, bitcoin-core, node-policy, block-template | 2026-05-28 |
| [2026-05-28-ocean-data-free-policy.md](2026-05-28-ocean-data-free-policy.md) | Bitcoin Knots v28.1 with `datacarriersize=0`, `blockmaxsize=3985000`, `blockmaxweight=3985000`, `blockprioritysize=0`. Knots defaults preserved elsewhere. | ocean, datum, bitcoin-knots, data-carrier, node-policy, block-template | 2026-05-28 |
| [2026-05-28-ocean-node-policy.md](2026-05-28-ocean-node-policy.md) | OCEAN-recommended template: Bitcoin Knots v29.2 with `blockmaxsize/weight=3985000`, `blockprioritysize=0`. Defaults preserved for relay, data-carrier, RBF, parasitic-protocol rejection. | ocean, datum, bitcoin-knots, node-policy, block-template, parasitic-protocols | 2026-05-28 |
| [2026-05-28-ocean-tides-technical-documentation.md](2026-05-28-ocean-tides-technical-documentation.md) | TIDES (Transparent Index of Distinct Extended Shares) — non-custodial PPLNS-style payout. 8×network-difficulty share log window, generation-transaction payouts, 99.9665% reward probability. By Jason Hughes. | ocean, tides, payout, pplns, share-log, generation-transaction, non-custodial, jason-hughes | 2026-05-28 |
| [2026-05-28-ocean-origins-of-datum.md](2026-05-28-ocean-origins-of-datum.md) | Jason Hughes essay: DATUM = Decentralized Alternative Templates for Universal Mining. Pool-template-centralization thesis, two-component architecture, framed as first decentralized mining protocol since Eligius (2017). | ocean, datum, mining-decentralization, eligius, slush, jason-hughes, history | 2026-05-28 |
| [2026-05-28-ocean-intro-to-lightning.md](2026-05-28-ocean-intro-to-lightning.md) | OCEAN educational primer on the Lightning Network: payment channels, HTLCs, BOLT11 vs BOLT12, OCEAN's BOLT12 integration. Companion to /docs/lightning. | ocean, lightning, bolt11, bolt12, htlc, education, payment-channels | 2026-05-28 |

## 2026-06-01 research session — Path 1 (DATUM protocol primary docs)

- [2026-06-01-path1-issue-146-sv2-support.md](2026-06-01-path1-issue-146-sv2-support.md) — `OCEAN-xyz/datum_gateway#146` open SV2-support proposal
- [2026-06-01-path1-recent-prs-protocol-hardening.md](2026-06-01-path1-recent-prs-protocol-hardening.md) — protocol-evolution PRs/issues (PR #190, #202, #209)
- [2026-06-01-path1-ocean-org-survey.md](2026-06-01-path1-ocean-org-survey.md) — OCEAN-xyz org has only 2 public repos; DATUM Prime is closed-source

## 2026-06-01 — Path 2 (gateway internals)

- [2026-06-01-path2-datum-stratum-server-internals.md](2026-06-01-path2-datum-stratum-server-internals.md) — `datum_stratum.c`
- [2026-06-01-path2-datum-stratum-header-structs.md](2026-06-01-path2-datum-stratum-header-structs.md)
- [2026-06-01-path2-datum-sockets-epoll-threadpool.md](2026-06-01-path2-datum-sockets-epoll-threadpool.md)
- [2026-06-01-path2-datum-config-surface.md](2026-06-01-path2-datum-config-surface.md)
- [2026-06-01-path2-datum-stratum-dupes-share-validation.md](2026-06-01-path2-datum-stratum-dupes-share-validation.md)
- [2026-06-01-path2-datum-protocol-share-handoff.md](2026-06-01-path2-datum-protocol-share-handoff.md)
- [2026-06-01-path2-datum-api-operator-observability.md](2026-06-01-path2-datum-api-operator-observability.md)

## 2026-06-01 — Path 3 (SV2-downstream architecture)

- [2026-06-01-path3-pool-vs-jds-vs-jdc-roles.md](2026-06-01-path3-pool-vs-jds-vs-jdc-roles.md)

## 2026-06-01 — Path 4 (prior art / OCEAN SV2 stance)

- [2026-06-01-path4-bitcoin-core-rfc-31002-datum-mining-interface.md](2026-06-01-path4-bitcoin-core-rfc-31002-datum-mining-interface.md) — Luke Dashjr "GBT has worked for years"
- [2026-06-01-path4-ocean-docs-sv2-rejection.md](2026-06-01-path4-ocean-docs-sv2-rejection.md)
- [2026-06-01-path4-electricalgrade-sv2-c-library.md](2026-06-01-path4-electricalgrade-sv2-c-library.md) — only existing prior-art code, stalled
- [2026-06-01-path4-blockspace-media-datum-vs-sv2.md](2026-06-01-path4-blockspace-media-datum-vs-sv2.md)
- [2026-06-01-path4-atlas21-datum-launch-luke-dashjr-quotes.md](2026-06-01-path4-atlas21-datum-launch-luke-dashjr-quotes.md)
- [2026-06-01-path4-prior-art-enumeration-and-notable-absences.md](2026-06-01-path4-prior-art-enumeration-and-notable-absences.md)

## 2026-06-01 — Path 5 (operator value & threat model)

- [2026-06-01-path5-datum-gateway-readme.md](2026-06-01-path5-datum-gateway-readme.md)
- [2026-06-01-path5-mempool-pool-rankings.md](2026-06-01-path5-mempool-pool-rankings.md)
- [2026-06-01-path5-tides-payout-mechanics.md](2026-06-01-path5-tides-payout-mechanics.md)
- [2026-06-01-path5-hashpool-architecture.md](2026-06-01-path5-hashpool-architecture.md)
- [2026-06-01-path5-braiins-sv2-features.md](2026-06-01-path5-braiins-sv2-features.md)
- [2026-06-01-path5-template-similarity-bitmex.md](2026-06-01-path5-template-similarity-bitmex.md)

## Categories

- **datum-collection**: 2026-05-28-datum-gateway-readme.md, 2026-05-28-datum-gateway-usernames.md
- **ocean-docs collection**: 2026-05-28-ocean-docs-index.md, 2026-05-28-ocean-alternate-templates.md, 2026-05-28-ocean-datum-setup-guide.md, 2026-05-28-ocean-lightning-payouts.md, 2026-05-28-ocean-core-antispam-policy.md, 2026-05-28-ocean-core-policy.md, 2026-05-28-ocean-data-free-policy.md, 2026-05-28-ocean-node-policy.md, 2026-05-28-ocean-tides-technical-documentation.md, 2026-05-28-ocean-origins-of-datum.md, 2026-05-28-ocean-intro-to-lightning.md
- **2026-06-01 session**: see per-path sections above
