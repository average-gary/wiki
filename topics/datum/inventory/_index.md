---
title: Inventory Index
type: index
updated: 2026-06-01
---

# Inventory Index

> Durable tracking records for items, candidates, entities, corpora, and watch items.

Last updated: 2026-06-01

## Statistics

- Total records: 6
- Items: 0
- Candidates: 6
- Entities: 0
- Corpora: 0
- Active: 4
- Blocked: 2

## Quick Navigation

- [Candidates](candidates/_index.md)

## Contents

| File | Kind | Status | Priority | Next Action | Updated |
|------|------|--------|----------|-------------|---------|
| [candidates/ocean-production-protocol-version.md](candidates/ocean-production-protocol-version.md) | question | active | p0 | Run handshake_probe against datum-beta1.mine.ocean.xyz:28915 with "v0.4.1-beta" once datum-protocol crate compiles in Phase 2. | 2026-06-01 |
| [candidates/datum-header-bitfield-byte-ordering.md](candidates/datum-header-bitfield-byte-ordering.md) | question | active | p1 | Capture a real C-emitted PING; commit as test fixture; pin frame::pack/unpack against it. | 2026-06-01 |
| [candidates/sri-master-watch.md](candidates/sri-master-watch.md) | watch | active | p2 | Monitor stratum-mining/stratum master for breaking changes during Phase 3 SV2 work. | 2026-06-01 |
| [candidates/datum-gateway-upstream-watch.md](candidates/datum-gateway-upstream-watch.md) | watch | active | p2 | Watch OCEAN-xyz/datum_gateway for protocol-version, wire-format, OCEAN pubkey, or coinbaser blob changes. | 2026-06-01 |
| [candidates/datum-rs-phase-2-distribution-polish.md](candidates/datum-rs-phase-2-distribution-polish.md) | task | blocked | p2 | After v0.1.0 ships: build CI matrix, cargo-deb, multi-arch Docker, StartOS swap, reproducible builds. | 2026-06-01 |
| [candidates/datum-rs-phase-3-observability-extras.md](candidates/datum-rs-phase-3-observability-extras.md) | task | blocked | p3 | After Phase 2: Prometheus /metrics, structured JSON logs, --migrate-config, --pid-file, systemd notify. | 2026-06-01 |
