---
title: "Rust Multi-Platform"
type: topic
created: 2026-05-21
updated: 2026-05-21
status: active
---

# Rust Multi-Platform

## Driving Case

Survey the four practical surfaces where Rust ships beyond the native Linux/x86 default:

1. **Mobile FFI** — Swift (iOS) and Kotlin (Android) bindings via UniFFI, swift-bridge, jni-rs. Direct application: closing the iOS gap in [[gtx-1060-headless-ai-server]] (iroh-ffi was archived mid-2025; native Swift+Rust app is the v2 path).
2. **Desktop cross-compilation** — Linux/macOS/Windows, x86_64/aarch64. `cross`, `cargo-zigbuild`, GitHub Actions matrix builds, `cargo-dist` packaging.
3. **Cross-platform UI frameworks** — Tauri, Dioxus, Slint, egui, Iced. When each wins; mobile/web compatibility.
4. **WASM** — browser (`wasm32-unknown-unknown` + `wasm-bindgen`) and server-side WASI (Wasmtime, WASI Preview 2, Spin).

## Sub-questions (research paths)

For each of 4 scopes, 2 agents (deep mode):
- Mobile FFI: (a) UniFFI canonical patterns + tooling state, (b) shipping-to-app-store playbook (signing, MSL, build pipelines)
- Desktop cross-compile: (a) `cross` / `zigbuild` / GitHub Actions matrix, (b) packaging + distribution (`cargo-dist`, dmg/msi/AppImage/snap/flatpak)
- UI frameworks: (a) framework comparison + tradeoffs, (b) mobile + web target state of each
- WASM: (a) browser + `wasm-bindgen` + interop, (b) WASI Preview 2 + server-side WASM runtimes

## Theses

(none yet)

## Topic Articles (synthesis)

- [rust-multi-platform-synthesis](wiki/topics/rust-multi-platform-synthesis.md) — single-page summary across all 4 scopes

## Concept Articles

- [mobile-ffi-decision-tree](wiki/concepts/mobile-ffi-decision-tree.md) — UniFFI vs swift-bridge vs hand-rolled
- [ios-xcframework-aar-pipeline](wiki/concepts/ios-xcframework-aar-pipeline.md) — packaging xcframework + AAR
- [desktop-cross-compile-and-package](wiki/concepts/desktop-cross-compile-and-package.md) — cross/zigbuild/xwin + cargo-dist + signing
- [ui-framework-decision](wiki/concepts/ui-framework-decision.md) — Tauri / Dioxus / Slint / egui / Iced
- [wasm-browser-and-server](wiki/concepts/wasm-browser-and-server.md) — browser frontend + WASI Preview 2/3

## Sources

- [raw/_index.md](raw/_index.md) — 29 sources

## Output

- [output/_index.md](output/_index.md) — (no playbook generated this round; topic-mode survey)

## Stats

- Articles: 6 (1 topic synthesis + 5 concept)
- Sources ingested: 29 (16 articles, 12 repos, 1 guide)
- Research dates: 2026-05-21 (Round 1, 8-agent --deep, topic mode, 4 scope quadrants)

## Logs

- [log.md](log.md)
