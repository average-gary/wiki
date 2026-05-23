---
title: "Tauri open iOS issues — the production-reality view"
source: https://github.com/tauri-apps/tauri/issues?q=is%3Aissue+is%3Aopen+label%3A%22platform%3A+ios%22
type: article
tags: [tauri, ios, production-reality, issues]
date: 2026-05-21
quality: 5
confidence: high
agent: 6
summary: "Recent open iOS issues paint a 'works for hello-world, breaks under sustained production' picture. Toolchain churn (Xcode 26 link errors), HMR breakage with Next.js App Router, WKWebView layout regressions on rotation/background, plugin event crash. Many tagged 'needs triage' = bandwidth pressure on mobile."
---

# Tauri 2 — production reality from the issue tracker

## Concrete recent open issues

1. **Dev Proxy HMR breaks** — "iOS/Android dev proxy breaks Next.js App Router HMR (blank screen with Next 16)"
2. **WKWebView layout bug** — "WKWebView shrinks to ~half screen width after returning from background; rotation restores it"
3. **Unicode/asset bug** — "iOS local app assets render Japanese text as '?'"
4. **Toolchain breakage** — "iOS build fails with Xcode 26 — linker error: library not found for -lswiftCompatibility56" (high priority)
5. **Plugin event crash** — Plugin event unregistration failing on iOS (crash priority)
6. Debug builds fail on physical iPhone (separate from simulator)
7. Provisioning profile env-variable handling generates malformed Xcode projects

## Pattern

Most are tagged "needs triage" → maintainer bandwidth pressure on mobile. Tauri 2 mobile **works for hello-world, but a sustained production app crosses many of these landmines**, and toolchain churn (Xcode bumps, plugin auth, HMR) hits fast.

## Implication for plan-making

If you're scoping Tauri 2 mobile on a 2026 timeline:
- Budget for maintenance against Xcode releases (not just one-time integration)
- Don't trust HMR for daily DX — fall back to full reload
- Test rotation + foreground/background return paths early
- Don't rely on the i18n bundling pipeline for non-Latin scripts without verification

## Cross-references

- [[Tauri 2.0 release]]
- [[Boring Cactus 2025 Rust GUI survey]]
