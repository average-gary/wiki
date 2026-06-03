---
title: Candidates
type: index
updated: 2026-06-01
---

# Candidates (6)

| File | Kind | Status | Priority | Next Action | Updated |
|------|------|--------|----------|-------------|---------|
| [ocean-production-protocol-version.md](ocean-production-protocol-version.md) | question | active | p0 | Run handshake_probe against datum-beta1.mine.ocean.xyz:28915 with "v0.4.1-beta" once datum-protocol crate compiles in Phase 2. | 2026-06-01 |
| [datum-header-bitfield-byte-ordering.md](datum-header-bitfield-byte-ordering.md) | question | active | p1 | Capture a real C-emitted PING; commit as test fixture; pin frame::pack/unpack against it. | 2026-06-01 |
| [sri-master-watch.md](sri-master-watch.md) | watch | active | p2 | Monitor stratum-mining/stratum master for breaking changes during Phase 3 SV2 work. Pin Cargo.toml; bump deliberately. | 2026-06-01 |
| [datum-gateway-upstream-watch.md](datum-gateway-upstream-watch.md) | watch | active | p2 | Watch OCEAN-xyz/datum_gateway for protocol-version, wire-format, OCEAN pubkey, or coinbaser blob changes. | 2026-06-01 |
| [datum-rs-phase-2-distribution-polish.md](datum-rs-phase-2-distribution-polish.md) | task | blocked | p2 | After v0.1.0 ships: build CI matrix, cargo-deb, multi-arch Docker, StartOS swap, reproducible builds. | 2026-06-01 |
| [datum-rs-phase-3-observability-extras.md](datum-rs-phase-3-observability-extras.md) | task | blocked | p3 | After Phase 2: Prometheus /metrics, structured JSON logs, --migrate-config, --pid-file, systemd notify. | 2026-06-01 |
