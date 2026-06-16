---
title: "Bevy on Different Platforms (Unofficial Bevy Cheat Book — platform support)"
source_url: https://bevy-cheatbook.github.io/platforms.html
source_date: 2024
ingested: 2026-06-15
type: article
author: Jasen Borisov / Unofficial Bevy Cheat Book
quality: 3
credibility: medium
research_path: contrarian
tags: [bevy, platforms, mobile, console, wasm, ios, android, switch]
---

# Bevy on Different Platforms (Cheat Book)

Canonical reference for the mobile/console/WASM gap. The Cheat Book is overall unmaintained as of 2026, but the structural platform blockers it documents (NDA, vendor Rust support, browser threading) haven't changed.

## Key findings

- **WASM/Web**: "Multithreading is not supported, so you will have limited performance and possible audio glitches." WebGL2 limits perf and caps 3D scenes to 256 lights; WebGPU lifts this but breaks browser compatibility.
- **Android**: "less mature than iOS"; emulator devices have known problems; real-hardware testing required.
- **iOS**: usable, apps shipped, but ergonomics weak.
- **Nintendo Switch**: Rust toolchain support "not progressed enough to be useful for Bevy yet."
- **PlayStation**: community work exists but status unknown; gated by NDA.
- Console support fundamentally blocked by NDA + lack of platform-vendor Rust support, not a problem Bevy can fix alone.
