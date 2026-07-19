---
title: p2poolv2 ↔ 256 Foundation — the actual relationship
category: topic
created: 2026-05-24
confidence: high
tags: [p2poolv2, 256-foundation, Hydrapool, governance, framing-correction]
volatility: warm
updated: 2026-07-15
verified: 2026-07-15
sources:
  - "raw/articles/2026-05-24-256-foundation-overview.md"
  - "raw/articles/2026-05-24-hydrapool-256-foundation.md"
  - "raw/articles/2026-05-24-p2poolv2-lineage-and-history.md"
  - "raw/repos/2026-05-24-p2poolv2-accounting-modules.md"
---

# p2poolv2 ↔ 256 Foundation — the Actual Relationship

Synthesis article. The user's working framing — "p2poolv2 under the 256 Foundation" — is **incorrect as commonly stated**. This article documents the real structure.

## TL;DR

- **p2poolv2 is independent.** Maintained by `pool2win` (Jungly). Not a 256 Foundation pillar grantee. Funding source not publicly disclosed.
- **The 256 Foundation's pool-software pillar is Hydrapool**, not p2poolv2.
- **Hydrapool uses `p2poolv2_lib` as a library**. Latest pin: `p2poolv2 lib v0.10.14`.
- **Same lead engineer** for both: Jungly = pool2win.
- So the engineering relationship is real (same dev, library dependency); the funding relationship is not direct.

## The 256 Foundation

501(c)(3) public charity, EIN 99-1662333. Mission: dismantle Bitcoin mining centralization across hardware (~90% one Chinese vendor), pools (~90% top-4), reward custody (~40% one custodian).

- **Total raised**: 7.208 BTC
- **Allocated**: ~$584,000 USD
- **Admin cut**: 0%
- **Notable grant**: $100,000 from MARA Foundation, awarded April 29, 2026

### Four core pillar projects

| Project | Layer | What it is |
|---|---|---|
| **Ember One** | Hardware | Open hashboard |
| **Mujina** | Firmware | Open ASIC firmware |
| **Libre Board** | Hardware | Open control board |
| **Hydrapool** | Pool software | One-click open-source mining pool |

p2poolv2 is **NOT** one of the four pillars. There are 6 additional ecosystem grants but p2poolv2 is also not visibly listed there.

## p2poolv2 (the project)

- Repo: `github.com/p2poolv2/p2poolv2` (alias: `github.com/pool2win/p2pool-v2`)
- License: AGPL-3.0
- Lead: **pool2win** (GitHub username) = **Jungly** (real-world identity referenced on 256 Foundation site)
- Latest release: v0.10.16 (2026-05-19), 17 total releases, ~76 stars
- Default deployment: **signet** (not mainnet)
- Funding: not publicly disclosed in repo metadata; appears uncompensated or indirectly through Hydrapool overlap

### Sibling projects (same maintainer)

- **Braidpool** (also pool2win + Bob McElrath) — theoretical DAG pool requiring covenants/CTV
- **Frost-federation** (also pool2win) — FROST threshold-sig federation library

So pool2win is the engineering hub of three sibling decentralized-pool projects, with **p2poolv2 as the shipping pragmatic implementation**.

## Hydrapool (the 256 Foundation pool)

- Repo: `github.com/256foundation/hydrapool` (Rust, AGPL-3.0)
- Lead engineer: **Jungly** (= pool2win)
- Project manager: **econoalchemist**
- Latest version: v2.5.8 (~mid-May 2026)
- Live test: `pool.256foundation.org:3333` and `test.hydrapool.org`
- **Library dependency**: `p2poolv2 lib v0.10.14`

## The two distinct accounting systems

| Property | p2poolv2 (protocol) | Hydrapool (256 Foundation) |
|---|---|---|
| Operator model | None — P2P share-chain | Single operator |
| Share consensus | libp2p gossip + share-chain | Internal ledger using `p2poolv2_lib` |
| PPLNS variant | Work-bounded window (133k shares, ~2 weeks) | PPLNS-with-decay (small-state) |
| Custody | None (coinbase splits) | None (coinbase splits) |
| Audit | On-chain coinbase | On-chain coinbase + `/pplns_shares` API |
| User cap | 500+ via atomic swaps (target) | ~100 per coinbase, no atomic-swap edge |
| Deployment | Signet today, mainnet planned | Mainnet test instance live |

## Why this framing matters

If you say "256 Foundation's pool is p2poolv2," you'll mis-evaluate:

- **Decentralization**: Hydrapool is single-operator; p2poolv2 protocol is genuinely peer-to-peer.
- **Audit model**: Hydrapool publishes a share-log API; p2poolv2 publishes nothing because the share-chain *is* the audit log.
- **Risk**: Hydrapool's lead has a single bus-factor (Jungly); p2poolv2 has a tiny contributor base (also Jungly + a couple others).
- **Funding**: Hydrapool is a 256 Foundation grant; p2poolv2 has no visible funding.
- **Roadmap**: Hydrapool ships now via centralized one-click deploys; p2poolv2 protocol needs more development (atomic-swap timelocks unspecified, mainnet not default).

## Lineage context

p2poolv2 is the engineering branch of a 4-generation decentralized-pool lineage:

1. **forrestv p2pool** (2011-2017, Python, Bitcoin) — linear share chain, Python codebase
2. **SChernykh Monero p2pool** (2021+, C++, Monero) — added uncles + auto-window
3. **Braidpool spec** (Bob McElrath + pool2win, ongoing) — full DAG, requires CTV
4. **p2poolv2** (pool2win, 2024+) — pragmatic Bitcoin implementation: chain-with-uncles + atomic-swap edge

The 256 Foundation's role is **adjacent** to this lineage — funding Hydrapool which depends on p2poolv2_lib — not central to it.

## Inventory candidate

If the wiki tracks watch items:

- **Watch**: "256 Foundation 990 filing for board members and recipient list" (EIN 99-1662333). Currently no public board disclosure.
- **Watch**: "p2poolv2 funding source" — single-maintainer bus-factor risk; sustainability unclear.
- **Watch**: "Hydrapool mainnet launch + first miner cohort" — primary near-term proof point for the deployment model.

## Sources

- [[../../raw/articles/2026-05-24-256-foundation-overview|256 Foundation overview]]
- [[../../raw/articles/2026-05-24-hydrapool-256-foundation|Hydrapool article]]
- [[../../raw/articles/2026-05-24-p2poolv2-lineage-and-history|p2poolv2 lineage]]
- [[../../raw/repos/2026-05-24-p2poolv2-accounting-modules|p2poolv2 accounting source]]

## See also

- [[../concepts/p2poolv2-accounting|p2poolv2 accounting deep-dive]]
- [[../concepts/hydrapool|Hydrapool concept]]
- [[../concepts/p2pool-share-chain|p2pool / p2poolv2 share-chain]]
- [[../topics/payout-design-space|Payout Design Space]]
