---
title: "dioxus-mobile crate — definitively webview-based, not native"
source: https://lib.rs/crates/dioxus-mobile
type: article
tags: [dioxus, mobile, webview, wry, architecture]
date: 2026-05-21
quality: 5
confidence: high
agent: 6
summary: "dioxus-mobile is 'a re-export of dioxus-desktop with some minor tweaks and documentation changes.' Same wry/WebView engine as desktop, just different bundling. v0.7.0-alpha.2 (mid-2025). Android 'still quite experimental and requires a lot of configuration.'"
---

# dioxus-mobile — webview underneath

## The architectural reality (verbatim)

> "[dioxus-mobile is] a re-export of `dioxus-desktop` with some minor tweaks and documentation changes."

This is the crucial admission: **Dioxus mobile is NOT a separate native renderer.** It's the same wry/WebView-based desktop engine running inside an iOS/Android shell.

## Implication

Dioxus mobile and Tauri mobile share the same core architecture:
- WKWebView on iOS
- Android WebView on Android
- Rust-via-FFI for backend logic

Just with different bundling pipelines and developer ergonomics on top.

## Stability signals

- Version: 0.7.0-**alpha**.2 (mid-2025) — explicitly pre-release
- Repo concedes: **"Android support is still quite experimental and requires a lot of configuration"**
- Concedes: "getting set up with mobile can be quite challenging"
- Concedes: tooling "isn't great (yet)"
- Open contribution invitation: "improve the CLI tool to include bundling and mobile configuration"

## Reading

Dioxus's "first-class mobile" should be read as:
- **Same DX as web/desktop** ✓ (genuinely impressive — `main.rs` works everywhere)
- **Underlying renderer is webview** ← not native
- **Android specifically remains rough** as of mid-2025

## When Dioxus mobile is the right pick

- You're building an internal tool / B2B app where webview perf is acceptable
- You value single-codebase across web+desktop+mobile+server
- You're OK riding alpha releases until 0.7 / 1.0 stable

## When NOT

- You want native-feel iOS/Android UX (use Slint, or ship native and use UniFFI)
- You need rich native-API integration on Android (Java/Kotlin interop is weak)

## Cross-references

- [[Dioxus 0.6 release]]
- [[Tauri 2.0 release]] — same architecture
- [[Slint 1.12 mobile + license]] — actual native-renderer alternative
