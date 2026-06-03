---
title: DATUM — Wiki
type: wiki-root
created: 2026-05-28
updated: 2026-06-01
last-plan: output/plan-bootstrap-datum-rs-2026-06-01.md
renamed-from: datum-gateway
renamed-on: 2026-06-01
scope: hub-topic
---

# DATUM — Wiki

Topic wiki for OCEAN's **DATUM** (Decentralized Alternative Templates for Universal Mining) protocol and the engineering question of building a **DATUM-capable proxy with SV2 downstream**.

The original scope (2026-05-28) covered the standard [DATUM Gateway](https://github.com/OCEAN-xyz/datum_gateway): a miner-side template-construction client that bridges local bitcoind (`getblocktemplate`) ↔ SV1-to-ASIC mining hardware ↔ "DATUM Prime" pool over the encrypted custom DATUM Protocol. On 2026-06-01 the wiki was renamed and broadened to also cover the design of a proxy that exposes Stratum V2 downstream (replacing the SV1-to-ASIC leg) while still speaking DATUM upstream to OCEAN.

## Layout

- `wiki/concepts/` — atomic concept articles
- `wiki/topics/` — synthesizing topic articles
- `wiki/references/` — pointers to specs, repos, related projects
- `wiki/theses/` — testable claims
- `raw/` — ingested source material with provenance
- `output/` — generated artifacts

## Quick Navigation

- [All Sources](raw/_index.md)
- [Concepts](wiki/concepts/_index.md)
- [Topics](wiki/topics/_index.md)
- [References](wiki/references/_index.md)
- [Outputs](output/_index.md)

## Start here

### DATUM protocol & gateway (existing — pre-rename)

- [[wiki/topics/datum-gateway-overview|DATUM Gateway — overview]] — anchor article
- [[wiki/concepts/datum-protocol|DATUM Protocol]] — wire protocol surface and trust model
- [[wiki/concepts/gateway-data-flow|Gateway data flow]] — runtime path + SIGUSR1/NOTIFY
- [[wiki/concepts/stratum-usernames-and-modifiers|Stratum usernames and modifiers]] — share routing + revenue sharing
- [[wiki/concepts/deployment-and-node-config|Deployment and node config]] — operator playbook
- [[wiki/concepts/tides-payout|TIDES payout]] — OCEAN's payout layer
- [[wiki/concepts/lightning-payouts|Lightning payouts]]
- [[wiki/concepts/datum-history-and-motivation|DATUM history and motivation]]

### SV2-downstream DATUM proxy — sidecar pattern (2026-06-01 plan-mode session)

- [[wiki/topics/datum-sv2-proxy-playbook|DATUM SV2-downstream proxy — playbook]] — synthesis topic article (read this first for sidecar)
- [[wiki/concepts/sv2-downstream-architecture|SV2-downstream architecture]] — SRI codebase mapping; ~1500 LOC new + ~9600 LOC reuse
- [[wiki/concepts/gateway-internals-c-architecture|Gateway internals — C architecture, threading, queue seam]]
- [[wiki/concepts/ocean-sv2-stance-and-prior-art|OCEAN's SV2 stance and prior art]]
- [[wiki/concepts/operator-value-and-threat-model|Operator value and threat model]]

### Drop-in Rust replacement (2026-06-01 question-mode session — the project endgame)

- [[wiki/topics/drop-in-rust-datum-gateway|Drop-in Rust DATUM gateway — synthesis]] — read this first for drop-in
- [[output/playbook-drop-in-rust-datum-gateway-2026-06-01|Playbook artifact]] — sequenced action plan (10 steps, ~4,000-5,500 Rust LOC)
- [[output/plan-bootstrap-datum-rs-2026-06-01|Phase 1 plan: bootstrap datum-rs]] — 5-phase roadmap; full SV1+SV2 dual-protocol drop-in; distribution + observability deferred to Phase 2/3
- [[wiki/concepts/drop-in-surface-inventory|Drop-in surface inventory]] — 35-row operator-facing surface
- [[wiki/concepts/datum-protocol-rust-implementation|DATUM Protocol Rust implementation]] — `dryoc 0.8`, cipher correction
- [[wiki/concepts/drop-in-rust-port-architecture|Rust port architecture]] — 11-crate Cargo workspace, LOC budget
- [[wiki/concepts/dual-protocol-downstream|Dual-protocol downstream]] — SV1+SV2 in one binary
- [[wiki/concepts/drop-in-distribution|Drop-in distribution]] — packaging + binary swap
- [[wiki/concepts/switch-day-runbook|Switch-day runbook]] — F1-F8 failure catalog + MIGRATING.md skeleton

## Recent Changes

- 2026-06-01: plan — Phase 1 implementation plan for `~/repos/datum-rs/` ([output/plan-bootstrap-datum-rs-2026-06-01.md](output/plan-bootstrap-datum-rs-2026-06-01.md)). Full dual-protocol drop-in: SV1 + SV2 downstream + DATUM upstream + single source-of-truth coinbase array. 5 phases, 8 wiki articles consulted, 9 architecture decisions. Phase 2/3 deferral list per user brief: distribution polish (StartOS, .deb, Docker push), observability extras (Prometheus, structured logs, `--migrate-config`).
- 2026-06-01: rename `datum-gateway` → `datum`. Scope broadened to include SV2-downstream proxy design. New 5-path research session launched (DATUM protocol primary docs, gateway internals reread, SV2-downstream architecture, prior art, operator value & threat model).
- 2026-05-28: compile — 11 ocean-docs sources → 4 new articles (datum-history-and-motivation, tides-payout, lightning-payouts, node-policy-variants), 3 updated (datum-gateway-overview, gateway-data-flow, deployment-and-node-config).
- 2026-05-28: ingest `ocean-docs` — `https://ocean.xyz/docs` index + 10 sub-pages.
- 2026-05-28: collection ingest `datum-gateway` via git @ `a3da9e69` — 2 raw articles + 1 manifest.
- 2026-05-28: compile — 3 sources → 5 new articles (datum-gateway-overview + 4 concepts).

## Adjacent wikis

- [[../bitcoin-mining-payout-schemas/_index.md|bitcoin-mining-payout-schemas]] — DATUM concept article (template-construction vs TIDES payout layers)
- [[../sv2-p2pool-integration/_index.md|sv2-p2pool-integration]] — covers OCEAN/DATUM at a higher level vs SV2 alternatives
- [[../sv1-upstream-reverse-translator/_index.md|sv1-upstream-reverse-translator]] — generic SV2-downstream / SV1-upstream pattern (this wiki specializes that to DATUM/OCEAN)
- [[../stratum-sri/_index.md|stratum-sri]] — SRI codebase the proxy reuses (`channels-sv2`, `handlers-sv2`, `stratum-translation`)
- [[../sv2-coinbase-identity/_index.md|sv2-coinbase-identity]] — SV2 per-miner coinbase tagging; DATUM solves the same problem with a pool-supplied unique identifier
