---
title: "Tauri 2.0 release — mobile support GA, but DX gaps acknowledged"
source: https://tauri.app/blog/tauri-20/
type: article
tags: [tauri, ui-framework, mobile, ios, android, webview]
date: 2026-05-21
quality: 5
confidence: high
agent: 5
summary: "Tauri 2 GA'd Oct 2024 with iOS+Android support. Architecture: WKWebView (iOS) / WebView (Android) + Rust backend via Swift/Kotlin plugin bindings. Official says 'not completely happy about DX, actively improving.' tauri-action mobile CI 'in progress'. Zero specific shipped apps named in announcement."
---

# Tauri 2.0 — mobile arrives, with caveats

## Architecture (verbatim)

> "The previous version of Tauri allowed to have a single UI code base for desktop operating systems but now this extends to iOS and Android."

- iOS: WKWebView via wry, Swift plugin subclasses
- Android: System WebView via wry, Kotlin `@Command` annotations
- Backend: Rust, communicating via JS bridge

## Binary size claim (verbatim from v2 docs)

> "A minimal Tauri app can be less than 600KB in size"

(uses system webview, no bundled Chromium)

## Acknowledged gaps

1. **Plugin support incomplete** — "not all official plugins support mobile; some aren't designed for mobile, others lack implementation"
2. **DX not yet there** — "We are not completely happy about the developer experience at the moment but are actively improving" toward desktop parity
3. **CI/CD gap** — `tauri-action` mobile support is "in progress"
4. **Zero shipped apps named** in the official announcement

## Plugin model change

- Allowlist replaced with permissions/scopes/capabilities model (more granular)
- 30+ official plugins (filesystem, HTTP, clipboard, notifications)

## Frontend choice

Any JS framework. Docs name: "Leptos, Next.js, Nuxt, Qwik, SvelteKit, Trunk, and Vite."

## License

MIT/Apache 2.0

## Real desktop apps

Spacedrive, GitButler, RustDesk, Cap, Musicat, Screenpipe.

## When Tauri wins

- You want Electron-class web UI flexibility with much smaller binaries
- You have an existing JS frontend team
- You need iOS+Android+desktop from one codebase
- You don't need native-renderer performance characteristics

## When NOT

- You need first-class native iOS/Android UX (today, mid-2026)
- You can't live with WKWebView/WebView quirks (see [[Tauri open iOS issues]])

## Cross-references

- [[Tauri open iOS issues]] — production-reality production gaps
- [[dioxus-mobile crate webview reality]] — Dioxus mobile uses the same wry stack
- [[Boring Cactus 2025 Rust GUI survey]]
