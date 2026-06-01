---
title: "Rust Multi-Platform"
type: topic
created: 2026-05-21
updated: 2026-06-01
status: active
---

# Rust Multi-Platform

## Driving Case

Survey the practical surfaces where Rust ships beyond the native Linux/x86 default, and the operational patterns Rust-based fleets adopt at the edge.

### Round 1 (2026-05-21) — deployment surfaces

1. **Mobile FFI** — Swift (iOS) and Kotlin (Android) bindings via UniFFI, swift-bridge, jni-rs. Direct application: closing the iOS gap in [[gtx-1060-headless-ai-server]] (iroh-ffi was archived mid-2025; native Swift+Rust app is the v2 path).
2. **Desktop cross-compilation** — Linux/macOS/Windows, x86_64/aarch64. `cross`, `cargo-zigbuild`, GitHub Actions matrix builds, `cargo-dist` packaging.
3. **Cross-platform UI frameworks** — Tauri, Dioxus, Slint, egui, Iced. When each wins; mobile/web compatibility.
4. **WASM** — browser (`wasm32-unknown-unknown` + `wasm-bindgen`) and server-side WASI (Wasmtime, WASI Preview 2, Spin).

### Round 2 (2026-06-01) — edge fleet operational patterns

5. **Single-slot fleet identity** — Tailscale tagged-authkey, Kubernetes StatefulSet, Balena, Mender prior art.
6. **Versioned signed identity envelopes** — TOML/CBOR/Protobuf encoding choices for long-lived ed25519 with rotation.
7. **Append-only audit logs over edge RPC** — device-local Schneier-Kelsey forward-secure chains + server-side CT/SCITT-style transparency logs.

## Sub-questions (research paths)

### Round 1 — 4 scopes × 2 agents (deep mode)

- Mobile FFI: (a) UniFFI canonical patterns + tooling state, (b) shipping-to-app-store playbook (signing, MSL, build pipelines)
- Desktop cross-compile: (a) `cross` / `zigbuild` / GitHub Actions matrix, (b) packaging + distribution (`cargo-dist`, dmg/msi/AppImage/snap/flatpak)
- UI frameworks: (a) framework comparison + tradeoffs, (b) mobile + web target state of each
- WASM: (a) browser + `wasm-bindgen` + interop, (b) WASI Preview 2 + server-side WASM runtimes

### Round 2 — 8-agent deep sweep (Academic, Technical, Applied, News/Trends, Contrarian, Historical, Adjacent, Data/Stats)

## Theses

(none yet — Round 2 surfaced one candidate: "for offline/intermittent edge fleets, dual-sign chain rotation beats Sigstore-style ephemeral identity, but the comfortable assumption that long-lived ed25519 with rotation is the default is partly load-bearing on a wrong claim — TOML cannot be the signed format")

## Topic Articles (synthesis)

- [rust-multi-platform-synthesis](wiki/topics/rust-multi-platform-synthesis.md) — Round 1 single-page summary across all 4 deployment scopes
- [edge-fleet-operational-patterns-2026](wiki/topics/edge-fleet-operational-patterns-2026.md) — Round 2 cross-pillar synthesis (identity / envelopes / audit logs)

## Concept Articles

### Round 1 — Rust deployment

- [mobile-ffi-decision-tree](wiki/concepts/mobile-ffi-decision-tree.md) — UniFFI vs swift-bridge vs hand-rolled
- [ios-xcframework-aar-pipeline](wiki/concepts/ios-xcframework-aar-pipeline.md) — packaging xcframework + AAR
- [desktop-cross-compile-and-package](wiki/concepts/desktop-cross-compile-and-package.md) — cross/zigbuild/xwin + cargo-dist + signing
- [ui-framework-decision](wiki/concepts/ui-framework-decision.md) — Tauri / Dioxus / Slint / egui / Iced
- [wasm-browser-and-server](wiki/concepts/wasm-browser-and-server.md) — browser frontend + WASI Preview 2/3

### Round 2 — Edge fleet operations

- [single-slot-fleet-identity](wiki/concepts/single-slot-fleet-identity.md) — Tailscale / K8s / Balena / Mender prior art + failure modes + recommendation
- [signed-identity-envelopes](wiki/concepts/signed-identity-envelopes.md) — encoding choice; three-layer versioning; ed25519 rotation idioms; hot/cold key split
- [append-only-audit-logs-edge-rpc](wiki/concepts/append-only-audit-logs-edge-rpc.md) — device-local + server-side; SCITT shape; witness frameworks; throughput

## Sources

- [raw/_index.md](raw/_index.md) — 72 sources (29 from Round 1 + 43 from Round 2)

## Output

- [output/_index.md](output/_index.md)

## Stats

- Articles: 10 (2 topic synthesis + 8 concept)
- Sources ingested: 72 (40 articles, 18 repos, 5 guides, 8 papers, 1 data)
- Research rounds:
  - 2026-05-21 — Round 1 (8-agent --deep, topic mode, 4 deployment scopes)
  - 2026-06-01 — Round 2 (8-agent --deep, topic mode, 3 fleet-ops pillars)

## Logs

- [log.md](log.md)
