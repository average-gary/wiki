---
title: "PioneerHash GitHub org — eHash integration vehicle"
publication: github.com/PioneerHash
url: https://github.com/PioneerHash
type: article
ingested: 2026-05-24
quality: 5
credibility: high
confidence: high
tags: [PioneerHash, EthnTuttle, eHash, github-org, integration-vehicle]
---

# PioneerHash (GitHub org)

GitHub organization that aggregates the eHash technology stack as a coordinated set of forks + originals. **Created 2025-10-23.** Last updated 2026-03-24. 12 public repos. Public membership: **none surfaced** (privacy flag).

## Critical disambiguation

**`pioneerhash.com`** (the cloud-mining domain) is a flagged scam per scam-detector.com / Trustpilot / fraud-detector-ar.com (promoted Oct 2025+). The naming collision is unfortunate but the GitHub `PioneerHash` org's repos (Rust, SV2, CDK forks, eHash branches) are unmistakably FOSS protocol work and **unrelated to the cloud-mining-investment brand**.

## Likely owner: EthnTuttle

EthnTuttle is **near-certainly the owner/operator** of the org:
- His personal account already forks the same set of repos (`cdk`, `stratum`, `sv2-apps`, `mujina`, `coinbase-playground`).
- His bio: *"professional ehash shill / shill pioneer."*
- The org's branch naming (`ehash-dev`, `ehash-persistence`) maps to the design EthnTuttle proposed in [delvingbitcoin/t/870](https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870).

Not a public member due to GitHub membership-privacy flag — cannot prove ownership from listing alone, but the technical signature is decisive.

## Repository inventory

| Repo | Type | Lang | Default branch | Notes |
|---|---|---|---|---|
| **`ehash`** | Original | Rust | `ehash-persistence` | Core eHash project (no description) |
| `sv2-startos` | Original | TS | `master` | StartOS package for SV2 mining stack. **1 star, 21 issues — most active repo** |
| `hydrapool-startos` | Fork | TS | `update/040` | Hydrapool StartOS wrapper |
| `coinbase-playground` | Fork | — | `master` | "devenv to generate CTV coinbase txs and explore with mempool visualizer" |
| `mujina` | Fork | Rust | `main` | "Open Source Bitcoin Mining Firmware" (256 Foundation pillar) |
| `cdk` | Fork | Rust | **`ehash-dev`** | Cashu Development Kit, **eHash branch** |
| `bitcoin-core-testnet4-startos` | Fork | TS | `update/040-testnet4` | bitcoind StartOS wrapper |
| `sv2-tp` | Fork | C | `master` | Stratum V2 Template Provider (C++) |
| `sv2-apps` | Fork | Rust | **`ehash-dev`** | "Stratum V2 pool and miner applications" |
| `stratum` | Fork | Rust | **`ehash-dev`** | "Stratum V2 protocol libraries" |
| `webuyhash` | Original | JS | `master` | (no description; possibly a hashrate-marketplace UI) |
| **`e-sharp`** | Original | Rust | `master` | **The canonical eHash workspace.** 7 crates, 4 fork submodules, JDC-as-sub-pool architecture with formal SV2 extension protocol (5 new messages, type 0x0100), keyset-lifecycle state machine, dual-mode (solo + pool), real LDK+LND+CLN integration, full E2E tests, working `ehash` CLI. Materially more advanced than vnprc/hashpool. *See [[2026-05-25-pioneerhash-e-sharp-deepdive|e-sharp deep-dive]].* |

The branches `ehash-dev` / `ehash-persistence` across forks of `cashubtc/cdk`, `stratum-mining/stratum`, `stratum-mining/sv2-apps` confirm this org is **EthnTuttle's integration vehicle for the eHash design**.

## Relationship map

| Entity | Linkage to PioneerHash |
|---|---|
| **EthnTuttle** | Near-certain owner (technical signature + branch names + bio) |
| **vnprc** | Not a public member. No direct evidence; vnprc is the hashpool implementer using `forge.anarch.diy/vnprc/cdk-ehash` (separate code stream from PioneerHash's `cdk` fork at `ehash-dev`) |
| **256 Foundation** | Separate org. Hydrapool is theirs; PioneerHash forks `hydrapool` downstream. No upstream EthnTuttle PRs to 256foundation org. |
| **Virginia Freedom Tech LLC** | EthnTuttle owns `EthnTuttle/virginiafreedomtech`. No direct linkage to PioneerHash visible. |

## What this means for the wiki

**There are now TWO parallel eHash code streams, and PioneerHash/e-sharp has overtaken vnprc/hashpool on multiple dimensions** (confirmed 2026-05-25):

1. **vnprc/hashpool + forge.anarch.diy/vnprc/cdk-ehash** — the **original** implementation. testnet4-only, v0.1.1 (March 2026), ~12-month tag cadence, no LN integration (#56 Not Planned), `cdk-ehash` plugin dormant since March 2026.
2. **PioneerHash/e-sharp** — the **canonical** implementation as of May 2026. JDC-as-sub-pool architecture, dual-trigger payout lifecycle (block OR LN), real LDK+LND+CLN, P0 E2E tests, working `ehash` CLI, formal specs in `specs/`. Daily commits in May 2026.

The `forge.anarch.diy` self-hosted vnprc fork is a separate canonical line for vnprc's design. The PioneerHash org under EthnTuttle has effectively **superseded** it as the more-developed version. *See [[2026-05-25-pioneerhash-e-sharp-deepdive|e-sharp deep-dive]] for the full comparison.*

## Sources

- https://github.com/PioneerHash (org landing)
- https://github.com/PioneerHash?tab=repositories
- API: https://api.github.com/orgs/PioneerHash (created 2025-10-23, members public list empty)
- https://github.com/PioneerHash/ehash, /sv2-startos, /cdk (branch ehash-dev), /stratum (branch ehash-dev), /sv2-apps (branch ehash-dev)

## See also

- [[2026-05-24-ethntuttle-profile|EthnTuttle profile]]
- [[2026-05-24-vnprc-profile|vnprc profile]]
- [[2026-05-24-cashu-mining-application|Cashu mining application]]
- [[2026-05-24-cdk-ehash-code-state|cdk-ehash plugin code state]]
