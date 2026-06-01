---
title: "Concepts"
type: index
updated: 2026-06-01
---

# Concept Articles (8)

## Mobile (FFI + shipping)
- [[mobile-ffi-decision-tree]] — UniFFI vs swift-bridge vs hand-rolled
- [[ios-xcframework-aar-pipeline]] — packaging xcframework + AAR

## Desktop
- [[desktop-cross-compile-and-package]] — cross/zigbuild/xwin + cargo-dist + signing

## UI
- [[ui-framework-decision]] — Tauri / Dioxus / Slint / egui / Iced

## WASM
- [[wasm-browser-and-server]] — wasm-bindgen + Trunk + Yew/Leptos/Dioxus-web; Wasmtime + WASI 0.2/0.3

## Edge fleet operations (added 2026-06-01)
- [[single-slot-fleet-identity]] — Tailscale / K8s StatefulSet / Balena / Mender prior art; failure modes; recommendation
- [[signed-identity-envelopes]] — TOML/CBOR/Protobuf encoding choices; three-layer versioning; ed25519 rotation idioms
- [[append-only-audit-logs-edge-rpc]] — device-local Schneier-Kelsey + server-side CT/SCITT; witness frameworks
