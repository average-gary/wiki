---
title: "Tauri 2 — current production state (May 2026)"
source: "https://tauri.app/start/ + https://v2.tauri.app/blog/ + https://v2.tauri.app/develop/plugins/"
type: guide
date_fetched: 2026-05-24
date_published: "2024-10-02"
tags: [desktop-app, tauri, plugin-architecture, mobile, security]
quality: 5
credibility: high
path: desktop-app-stack
summary: "Tauri 2.0 stable shipped Oct 2024 with iOS+Android support. Plugin model is Rust-crate + optional NPM package + Swift/Kotlin sub-packages, governed by JSON/TOML capability files. Latest active blog content is mid-2025 (Verso integration, board elections); no flagship 2.x dot-release news on the public blog through May 2026 — feature work is in GitHub releases, not blogposts."
---

# Tauri 2 production state (May 2026)

## Version & cadence

- **Tauri 2.0 stable**: released Oct 2, 2024 (announced by Tillmann Weidinger).
- Public blog channel quiet since June 2025 (board elections post). Active work moved to GitHub releases / Discord. No 2.x marketing pushes ≠ stagnation, but indicates project maturity not aggressive expansion.
- Experimental Verso (Servo-based browser) integration announced Mar 17, 2025 — a future alt to per-OS webview. Not production.

## Architecture

- Uses each OS's **native webview** (WKWebView macOS/iOS, WebView2 Win, WebKitGTK Linux, Android System WebView) instead of bundling Chromium.
- Min app size: **<600 KB** (claim from official docs). Real-world Spacedrive/GitButler ship ~10-30 MB total.
- Rust backend ↔ JS frontend over IPC commands.

## Plugin architecture (load-bearing for PF2e tool)

A plugin = `tauri-plugin-{name}` Rust crate + optional `@scope/plugin-{name}` npm package + optional Swift package + optional Kotlin/Android lib. Lifecycle hooks: `setup()`, `on_navigation()`, `on_webview_ready()`, `on_event()`, `on_drop()`.

**Permissions**: JSON/TOML files in `permissions/` directory. Each permission gates a command + can scope arguments. `build.rs` autogenerates `allow-<cmd>` / `deny-<cmd>` from a command list. **This is the pattern to copy** for a worldbuilding-tool plugin model — capability-scoped IPC with build-time codegen.

## Security model

- Capability-based — any window/webview gets only the commands granted by capability files at build time.
- CSP enforced by default.
- Security audits performed on major/minor releases (per official docs).

## Mobile state

- iOS+Android signing/bundling guides exist in official docs.
- Cross-references with `rust-multi-platform/wiki/concepts/ui-framework-decision.md`: open iOS issues — Xcode 26 link errors, HMR breakage with Next.js App Router, WKWebView rotation regressions, `tauri-action` mobile CI "in progress." **No flagship iOS app named in 2.0 announcement.**

## Relevance for PF2e worldbuilding tool

Tauri 2 plugin model + capability JSON + Rust backend is the closest off-the-shelf match for a "filesystem-canon + LLM streaming + plugin-extensible" desktop app architecture. iOS co-target is plausible but rough — treat as v2.
