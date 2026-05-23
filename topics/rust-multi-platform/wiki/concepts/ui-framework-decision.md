---
title: "Rust UI framework decision (2026) — Tauri vs Dioxus vs Slint vs egui"
type: concept
created: 2026-05-21
updated: 2026-05-21
verified: 2026-05-21
volatility: hot
confidence: high
sources:
  - raw/articles/2026-05-21-tauri-2-release.md
  - raw/articles/2026-05-21-dioxus-0-6-release.md
  - raw/articles/2026-05-21-slint-mobile-license.md
  - raw/articles/2026-05-21-boring-cactus-2025-rust-gui-survey.md
  - raw/articles/2026-05-21-tauri-open-ios-issues.md
  - raw/articles/2026-05-21-dioxus-mobile-webview-reality.md
---

# Rust UI framework decision (May 2026)

## TL;DR

Three architectural families. Pick by mobile/web requirements + binary-size budget + accessibility needs.

| Framework | Architecture | Mobile | Web | Bundle | a11y |
|-----------|--------------|--------|-----|--------|------|
| **Tauri 2** | Webview + Rust backend | iOS+Android (with caveats) | n/a (it IS web) | <600KB | ✓ (browser) |
| **Dioxus 0.7** | Webview (mobile=desktop re-export) + signals | iOS+Android (alpha) | yes | <50KB web | ✓ |
| **Slint 1.12** | Native renderer (Skia/WGPU) + DSL | Android stable, iOS tech-preview | yes (canvas) | <300 KiB RAM runtime | ✓ excellent |
| **egui** | Immediate-mode pure Rust | Android, no iOS | yes | ~5-8 MB | partial (Win/Mac) |
| **Iced** | Elm-architecture, retained-mode | **NO** | partial | ~10 MB | ✗ broken |

(Sources: [Tauri 2.0 release](../../raw/articles/2026-05-21-tauri-2-release.md), [Dioxus 0.6](../../raw/articles/2026-05-21-dioxus-0-6-release.md), [Slint license + mobile](../../raw/articles/2026-05-21-slint-mobile-license.md), [Boring Cactus 2025 survey](../../raw/articles/2026-05-21-boring-cactus-2025-rust-gui-survey.md))

## When each wins

### Tauri 2 — JS-frontend ergonomics, smallest binary

You have a JS/TS frontend team or already-existing web app. Need iOS+Android+desktop from one codebase. Don't need native-renderer performance.

**Real desktop apps**: Spacedrive, GitButler, RustDesk, Cap, Musicat, Screenpipe.

**Caveats**: [Open iOS issues](../../raw/articles/2026-05-21-tauri-open-ios-issues.md) — Xcode 26 link errors, HMR breakage with Next.js App Router, WKWebView layout regressions on rotation, no flagship shipped iOS app named in Tauri's official 2.0 announcement.

### Dioxus 0.7 — full-stack Rust with React patterns

Single codebase web → desktop → mobile → server. Pure Rust, no JS toolchain. Best web bundle size in the comparison (<50KB claimed).

**Production users (per Dioxus marketing)**: Airbus, ESA, Cognition, Y Combinator.

**Reality check**: [`dioxus-mobile` is a re-export of `dioxus-desktop`](../../raw/articles/2026-05-21-dioxus-mobile-webview-reality.md) — same wry/WebView stack as Tauri, just different packaging. v0.7.0-**alpha**.2 (mid-2025); Android "still quite experimental." Java/Kotlin interop weak.

### Slint 1.12 — native renderer + best a11y

Embedded UI (automotive/industrial/IoT) is the primary niche, but desktop+mobile work. Native renderer (Skia/WGPU) — NOT webview. Excellent accessibility per Boring Cactus.

**License footgun**: [3-tier license](../../raw/articles/2026-05-21-slint-mobile-license.md). GPLv3 free; Royalty-Free paid (no embedded); Enterprise paid (embedded requires per-device royalty $1+/unit). Tier eligibility gated by company size.

iOS support is **tech-preview** as of 1.12 (June 2025); only Rust can target iOS in Slint (no C++/JS/Python on iOS yet). Android stable since 1.5 (March 2024).

Web/WASM rendering is to canvas — Slint themselves recommend against it for general web apps because a11y and text rendering are weaker than native HTML.

### egui — tools, dashboards, dev UIs

Anywhere you'd reach for Dear ImGui in C++. Pure-Rust immediate-mode. Best for dev tools, debug overlays, in-game UIs, data viz dashboards.

**Real apps**: Rerun Viewer (multimodal data viz startup) sponsors development.

**Limitations**: [iOS native target still open issue #3117 from 2023](../../raw/articles/2026-05-21-tauri-open-ios-issues.md) — egui is Android-only on mobile. Default font lacks CJK; basic Android-WASM IME bug declined as "not planned."

### Iced — avoid for now

[Boring Cactus](../../raw/articles/2026-05-21-boring-cactus-2025-rust-gui-survey.md): "IME won't activate at all. No screen reader accessibility." [Iced's mobile issue #302](https://github.com/iced-rs/iced/issues/302) is labeled **out-of-scope** by maintainers. System76 betting on it for COSMIC shell — long-term maybe, today no.

### Floem / Makepad / Xilem — niche / experimental

- **Floem**: Lapce-shaped apps only; a11y absent
- **Makepad**: creative coding / VR-curious; a11y absent; DSL undocumented
- **Xilem**: long-term Linebender bet; experimental; no numbered release in ~1 year

## Decision matrix by use case

| You're building | Pick |
|-----------------|------|
| Internal B2B desktop tool with web frontend | **Tauri 2** |
| Single-codebase web+desktop+mobile in pure Rust | **Dioxus** |
| Embedded/automotive UI | **Slint** (paid Enterprise tier for embedded) |
| Cross-platform OSS desktop app, no a11y compromise | **Slint** (GPLv3) |
| Dev tool / debug UI / dashboard | **egui** |
| AAA Rust desktop app with mobile parity 2026 | **None production-grade**; ship native iOS+Android with [UniFFI core](mobile-ffi-decision-tree.md) instead |

## Cross-cutting findings

- **Mobile a11y is unsupported across the Rust ecosystem in 2026** — VoiceOver/TalkBack don't work well in any of these. Compliance-sensitive shipping = native iOS/Android with shared Rust core via [UniFFI](mobile-ffi-decision-tree.md), NOT a Rust UI framework.
- **Web/WASM via canvas (egui, Slint, Iced)** is fine for demos, weak for general web apps (no native text selection, no screen-reader access, no spell-check).
- **Tauri does NOT target web** — it's webview-on-desktop/mobile. If you want a real Rust web app: Yew/Leptos/Dioxus-web, see [[browser-wasm-frontend-frameworks]].
- **CI/CD for mobile is weak**: Tauri's `tauri-action` mobile is "in progress." Plan for hand-rolled CI.

## Cross-references

- [[mobile-ffi-decision-tree]] — native mobile alternative when UI frameworks fall short
- [[browser-wasm-frontend-frameworks]] — for actual web apps
- [[Boring Cactus 2025 Rust GUI survey]]
