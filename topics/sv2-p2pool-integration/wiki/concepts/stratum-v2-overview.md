---
title: Stratum V2 overview
type: concept
created: 2026-05-22
updated: 2026-05-22
verified: 2026-05-22
volatility: warm
confidence: high
sources:
  - "[[raw/papers/2026-05-22-sv2-spec-job-declaration-protocol|SV2 spec: JDP]]"
  - "[[raw/repos/2026-05-22-sv2-apps-repo|sv2-apps repo]]"
  - "[[raw/articles/2026-05-22-bitcoinwiki-stratum-v2|Bitcoin Wiki: Stratum v2]]"
---

# Stratum V2 overview

Stratum V2 is the successor to Stratum V1 designed by Braiins (Pavel Moravec, Jan Čapek) starting 2018. The reference implementation lives at `github.com/stratum-mining/stratum` (protocol crates) and `github.com/stratum-mining/sv2-apps` (application stack). Specs at `github.com/stratum-mining/sv2-spec`.

## Key innovations vs SV1

- **Noise-encrypted transport** — confidentiality + authenticity for miner↔pool comms
- **Binary framing** instead of JSON — bandwidth + parsing wins
- **Miner-side template construction** via Job Declaration Protocol (JDP) — addresses pool centralization of tx selection
- **Multiple channel types** — Standard, Extended, Group — supporting different miner topologies (single ASIC vs farm proxy)

## Spec structure

| Doc | Topic |
|-----|-------|
| 03 | Framing + Noise |
| 04 | Secp256k1 / Noise security |
| 05 | Mining Protocol — channels, share submission |
| 06 | Job Declaration Protocol (JDP) |
| 07 | Template Distribution Protocol (TDP) — `NewTemplate`, `SetNewPrevHash`, solution submission |
| 09 | Extensions framework |

## Roles in JDP (relevant for [[p2poolv2]])

- **JDC (Job Declarator Client)** — miner-side. Negotiates a custom mining job (template) with a JDS.
- **JDS (Job Declarator Server)** — pool-side. Validates declared jobs, returns a job token, routes shares.

Two declaration modes:
- **Coinbase-only** — pool sees only coinbase fee revenue (preserves miner mempool privacy)
- **Full-Template** — pool validates full wtxid list

## sv2-apps stack

| Crate | Purpose |
|---|---|
| `pool-apps/pool` | `PoolSv2` server |
| `pool-apps/jd-server` | JDS, with pluggable `JobValidationEngine` |
| `miner-apps/jd-client` | JDC |
| `miner-apps/translator` | SV1↔SV2 bridge for legacy miners |
| `bitcoin-core-sv2` | Bitcoin Core IPC → TDP |
| `stratum-apps` | shared utilities |

See [[sv2-integration-surface]] for plug-points.

## Key quote (scope)

From the JDP spec:

> Pools that opt into this protocol are only responsible for accounting shares and distributing rewards.

This is the *exact* scope p2poolv2 wants to decentralize. SV2 stops at "shares + rewards"; p2poolv2 says "let's do those P2P too."

## Honesty incentive

If a pool rejects valid shares for an acknowledged job, the JDC can transparently switch pools or mine solo — making SV2 pools defectable on-the-fly. This is a miner-side gain that p2poolv2 inherits but doesn't depend on (since p2poolv2's pool *is* the network).

## Critique

See [[../topics/why-decentralized-pools-struggle|why decentralized pools struggle]] for the contrarian thread:
- harding: deterministic tx selection may *worsen* censorship vs status quo
- ajtowns: bandwidth ceiling at 6s beads
- Fi3: no consensus enforcement of decentralized selection
- Bitcoin Mag: Ocean's stagnation is the demand-side ceiling signal

## See also

- [[sv2-integration-surface]]
- [[p2poolv2]]
- [[braidpool]]
- [[../topics/integration-paths|Integration paths]]
