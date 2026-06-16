---
title: "Bevy platform support"
type: concept
created: 2026-06-15
updated: 2026-06-15
confidence: high
tags: [bevy, platforms, mobile, console, wasm, webgpu, ios, android, switch]
---

# Bevy platform support

| Platform | Status (2026-06-15) | Notes |
|----------|---------------------|-------|
| **Linux x86_64** | **Tier 1** | Primary dev target; full GPU-driven rendering |
| **Windows x86_64** | First-class | Requires MSVC build tools |
| **macOS** | First-class | Requires `xcode-select --install` |
| **WASM/Web** (WebGL2) | Works | No multithreading; 256-light cap on 3D scenes |
| **WASM/Web** (WebGPU) | Works | Lifts WebGL2 limits, narrower browser support |
| **iOS** | Possible, hard | Apps shipped; weak ergonomics; no streamlined export |
| **Android** | Possible, hard | Emulator known-bad; real-hardware required |
| **Nintendo Switch** | Not viable | Rust toolchain not far enough along |
| **PlayStation** | Unknown / NDA | Some community work; not publicly shippable |
| **Xbox** | Unknown / NDA | Same as PlayStation |

Sources: [[bevy-cargo-features.md|Cargo features]] (`wayland`, `x11`, `web`, `webgl2`, `webgpu`, `android-game-activity`, `android-native-activity`), [[bevy-cheatbook-platforms.md|Bevy Cheat Book platforms]], [[bevy-discussion-20998.md|Discussion #20998 mobile export]].

## Why mobile is hard

[[bevy-discussion-20998.md|Bevy maintainer NthTensor]]:

> "It is possible to ship games to iOS and Android, but not easy... We don't have enough devs using bevy on these platforms who are able to debug issues and improve ergonomics."

Pixel-level interaction with game objects requires workarounds; multi-touch has "constraints and implementation difficulties"; no streamlined export workflow.

## Why console is blocked

[[bevy-discussion-20998.md|Maintainer viridia]]: the deeper blocker is **platform-vendor cooperation and Rust language support from Apple / Google / Nintendo / Sony**. NDAs prevent open-source Rust toolchains from shipping for these platforms, and the platform vendors haven't invested in changing that.

This is not a Bevy-specific problem — it gates every Rust game engine. Until that changes, console support remains structurally impossible for OSS Rust engines.

## WASM specifics

- **Multithreading is not supported** — WASM main-thread / SharedArrayBuffer limits restrict Bevy's parallel scheduler. "Limited performance and possible audio glitches."
- **WebGL2** caps 3D scenes at 256 lights and lacks the multi-draw-indirect / bindless features Bevy 0.16's GPU-driven rendering needs (so WASM gets the partial-tier rendering)
- **WebGPU** lifts these limits but breaks browser compatibility (still rolling out across Chrome/Firefox/Safari)

The 560 itch.io games tagged `bevy` ([[bevy-itchio-tag.md|itch.io tag]]) — many of which are browser-playable — confirm WASM works for indie-scale projects.

## Tier-1 platform

The repo's `README` cites `x86_64-unknown-linux-gnu` as the tier-1 platform ([[docs-rs-bevy.md|docs.rs landing]]). Other platforms work but receive less attention from CI and from maintainers' own dev environments.

## See also

- [[bevy-overview.md|Bevy overview]]
- [[bevy-criticisms.md|Criticisms]]
- [[bevy-rendering.md|Rendering]]
