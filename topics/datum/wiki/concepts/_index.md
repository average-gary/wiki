---
title: Concepts
type: index
updated: 2026-06-01
---

# Concepts (17)

## Contents

| File | Summary | Tags | Updated |
|------|---------|------|---------|
| [datum-protocol.md](datum-protocol.md) | OCEAN's custom encrypted protocol. Wire format: 32-bit packed header, libsodium **XSalsa20Poly1305** (corrected 2026-06-01; was previously misdocumented as ChaCha20-Poly1305), 8-job ring, 16-bit unique-identifier, hardcoded OCEAN pool pubkey, ephemeral gateway keypair. Confidence: high. | datum-protocol, ocean, encryption, libsodium | 2026-06-01 |
| [gateway-data-flow.md](gateway-data-flow.md) | Runtime path: GBT → Stratum v1 → ASIC → DATUM Prime. SIGUSR1/HTTP NOTIFY for stale-work invalidation. | gbt, blocknotify, sigusr1, share-validation | 2026-05-28 |
| [stratum-usernames-and-modifiers.md](stratum-usernames-and-modifiers.md) | Bitcoin-address-as-username, three pool-passthrough modes, `~modifier-name` per-share revenue split, ASIC length quirks. | stratum, usernames, username-modifiers, asic | 2026-05-28 |
| [deployment-and-node-config.md](deployment-and-node-config.md) | Operator playbook: Knots-vs-Core, blockmaxsize/weight=3985000, build deps, Docker topologies. | deployment, bitcoin-knots, docker, blocknotify | 2026-05-28 |
| [datum-history-and-motivation.md](datum-history-and-motivation.md) | Hughes' Origins-of-DATUM essay: Eligius lineage, censorship thesis, OCEAN's incentives. | datum, ocean, history, eligius | 2026-05-28 |
| [tides-payout.md](tides-payout.md) | TIDES as it intersects DATUM: 8×network-difficulty share log, generation-transaction payouts. | tides, payout, pplns, non-custodial | 2026-05-28 |
| [lightning-payouts.md](lightning-payouts.md) | OCEAN's optional BOLT12 Lightning payout rail. BIP-322 linking, Alby Hub v1.21.2+ incompatibility. | lightning, bolt12, payouts, bip-322 | 2026-05-28 |
| [gateway-internals-c-architecture.md](gateway-internals-c-architecture.md) | C gateway code-level reading: module map, threading model (epoll+pthread), the queue seam. | gateway, c-internals, threading, epoll | 2026-06-01 |
| [sv2-downstream-architecture.md](sv2-downstream-architecture.md) | SRI-based architecture for an SV2-downstream **sidecar proxy**: plain SV2 pool front (no JDS/JDC), separate Rust binary alongside C gateway, ~1500 LOC new vs ~9600 LOC SRI reuse (6:1). | sv2-proxy, sri, channels-sv2, sidecar | 2026-06-01 |
| [ocean-sv2-stance-and-prior-art.md](ocean-sv2-stance-and-prior-art.md) | OCEAN docs explicitly reject SV2; Luke Dashjr "GBT has worked for years" quote; issue #146 only public SV2-DATUM bridge proposal. | ocean, sv2, prior-art, luke-dashjr | 2026-06-01 |
| [operator-value-and-threat-model.md](operator-value-and-threat-model.md) | Honest read for the sidecar proxy: operator value real but narrow — connectivity bridge for SV2-fleet miners who want OCEAN's TIDES. | operator-value, threat-model, ocean, custody | 2026-06-01 |
| [drop-in-surface-inventory.md](drop-in-surface-inventory.md) | 35-row inventory of every operator-facing surface a Rust drop-in must match. **De-risking finding**: no on-disk state to migrate. 4 hard surfaces (log format, binary name + SIGUSR1, HTTP API URLs, default ports). | drop-in, compatibility, datum_gateway, operator-surface | 2026-06-01 |
| [datum-protocol-rust-implementation.md](datum-protocol-rust-implementation.md) | Rust reimplementation of the encrypted DATUM upstream. Crate pick: `dryoc 0.8` (pure Rust, libsodium-compatible, musl-static-clean). Critical correction: cipher is XSalsa20Poly1305, NOT ChaCha20-Poly1305. OCEAN pool pubkey is hardcoded in `datum_conf.c`. | datum-protocol, rust, libsodium, dryoc | 2026-06-01 |
| [drop-in-rust-port-architecture.md](drop-in-rust-port-architecture.md) | 11-crate Cargo workspace; module-by-module port plan; LOC budget ~5,300 C → ~4,000-5,500 Rust; `datum-api` is 40% of port budget; `bitcoincore-rpc` is archived 2025-11-25 → hand-rolled `reqwest + corepc-types` (~200 LOC). Free upgrade: native GBT long-poll. | rust, workspace, architecture, modules, loc-budget | 2026-06-01 |
| [dual-protocol-downstream.md](dual-protocol-downstream.md) | OCEAN miner base ~75-90% SV1; SV2-only would brick fleet. Recommended: dual-port (23334 SV1 default, 23335 SV2 opt-in). SRI's `stratum_translation` crate is the SV1↔SV2 adapter. | dual-protocol, sv1, sv2, drop-in, miner-firmware | 2026-06-01 |
| [drop-in-distribution.md](drop-in-distribution.md) | Distribution channels: source / Ubuntu PPA / StartOS / Docker (no upstream image — free win). `cargo-deb` with `Replaces:`/`Conflicts:`. Static-musl via `dryoc` enables `FROM scratch` Docker. | packaging, debian, ppa, docker, startos, musl | 2026-06-01 |
| [switch-day-runbook.md](switch-day-runbook.md) | 5-phase operator runbook + F1-F8 failure-mode catalog + MIGRATING.md skeleton. C gateway ships zero migration docs today; the Rust port shipping real ones is purely additive credibility. | migration, runbook, operator, failure-modes | 2026-06-01 |

## Categories

- **protocol**: datum-protocol.md, datum-protocol-rust-implementation.md
- **runtime**: gateway-data-flow.md
- **stratum**: stratum-usernames-and-modifiers.md, dual-protocol-downstream.md
- **operations**: deployment-and-node-config.md, gateway-internals-c-architecture.md, switch-day-runbook.md, drop-in-distribution.md
- **history**: datum-history-and-motivation.md
- **payout**: tides-payout.md, lightning-payouts.md
- **sv2-sidecar-proxy** (added 2026-06-01): sv2-downstream-architecture.md, ocean-sv2-stance-and-prior-art.md, operator-value-and-threat-model.md, gateway-internals-c-architecture.md
- **drop-in-rust-port** (added 2026-06-01 question session): drop-in-surface-inventory.md, datum-protocol-rust-implementation.md, drop-in-rust-port-architecture.md, dual-protocol-downstream.md, drop-in-distribution.md, switch-day-runbook.md
