---
title: "datum-rs Phase 2: distribution polish — StartOS, .deb, Docker, static-musl"
kind: task
status: blocked
priority: p2
created: 2026-06-01
updated: 2026-06-01
last_checked: 2026-06-01
next_action: "After datum-rs v0.1.0 ships in Phase 1: build CI/CD matrix for {amd64,aarch64}-unknown-linux-{gnu,musl}; cargo-deb with Replaces:/Conflicts:; docker buildx multi-arch push to ghcr.io; fork OCEAN-xyz/datum-gateway-startos and swap submodule; reproducible builds (SOURCE_DATE_EPOCH, --remap-path-prefix)."
sources:
  - output/plan-bootstrap-datum-rs-2026-06-01.md
  - wiki/concepts/drop-in-distribution.md
tags: [datum-rs, phase-2, distribution, packaging, deferred]
confidence: high
summary: "Distribution polish explicitly deferred from datum-rs Phase 1 per user brief. Bundles 5 sub-tasks: static-musl artifacts on GitHub Releases, .deb via cargo-deb, multi-arch Docker push, StartOS submodule swap, reproducible builds. Blocked on Phase 1 v0.1.0 ship."
---

# datum-rs Phase 2: distribution polish

## Why Track This

The Phase 1 plan ([plan-bootstrap-datum-rs-2026-06-01.md](../../output/plan-bootstrap-datum-rs-2026-06-01.md)) ships build+test-only CI per the user brief. Full distribution mechanics — outlined in [drop-in-distribution](../../wiki/concepts/drop-in-distribution.md) — are deferred. This is a single tracked work item to revisit when v0.1.0 lands.

Bundled (not split into 5 records) because these tasks share infrastructure (GitHub Actions matrix, signing keys, release pipeline) and are sequenced together as Phase 2.

## Current State

Blocked on Phase 1 v0.1.0. Phase 1 plan does keep `Cargo.lock` committed and `dryoc 0.8` musl-clean from day one, so the foundation for static-musl is in place.

## Sub-tasks (when unblocked)

1. **Static-musl release matrix**: `{amd64,aarch64}-unknown-linux-{gnu,musl}` × release profile → 4 binaries → SHA256SUMS → GitHub Release attachment.
2. **`.deb` packaging via cargo-deb** (amd64 + arm64): `provides = "datum-gateway"`, `replaces = "datum-gateway"`, `conflicts = "datum-gateway"`. Either fork the OCEAN PPA namespace or ship `datum-gateway-rust` competing alongside.
3. **Multi-arch Docker push**: `docker buildx build --platform linux/amd64,linux/arm64` → `ghcr.io/<author>/datum-gateway:{tag, latest}`. With dryoc, final image can be `FROM scratch` or `FROM alpine` (~10 MB vs upstream's ~100 MB Debian).
4. **StartOS submodule swap**: fork `OCEAN-xyz/datum-gateway-startos`, replace C submodule pin with datum-rs, swap `cmake . && make` for `cargo build --release --locked`, drop runtime libs (libsodium23, libjansson4, libmicrohttpd12). Note: StartOS uses port 23335 for stratum, not 23334.
5. **Reproducible builds**: `cargo build --locked`, `SOURCE_DATE_EPOCH` from git, `--remap-path-prefix` in `RUSTFLAGS`, signed SHA256SUMS.

## Notes

- StartOS package is high-leverage (manifest update reaches thousands of self-hosted Bitcoin nodes) but conditional on v0.1.0 feature parity.
- Coordination: matches Q5 of the [playbook](../../output/playbook-drop-in-rust-datum-gateway-2026-06-01.md) step 11.
