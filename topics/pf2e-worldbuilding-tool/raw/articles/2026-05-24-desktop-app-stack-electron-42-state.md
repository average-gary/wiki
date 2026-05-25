---
title: "Electron 42 — bundled stack, ASAR integrity, Wayland default (May 2026)"
source: "https://www.electronjs.org/blog"
type: article
date_fetched: 2026-05-24
date_published: "2026-05"
tags: [desktop-app, electron, packaging, security, chromium]
quality: 5
credibility: high
path: desktop-app-stack
summary: "Electron 42 (May 2026) bundles Chromium 148 + V8 14.8 + Node 24.15. ASAR Integrity now stable — runtime hash validation against build-time digests. Wayland is now the default Linux display protocol. MSIX auto-updater added. Bundle size remains ~80-150 MB minimum (Chromium-shaped) — the perennial Tauri trade-off."
---

# Electron 42 (May 2026)

## Versioning

- **Electron 42** stable, May 2026
  - Chromium 148.0.7778.96
  - V8 14.8
  - Node v24.15.0
- **Electron 41** (Mar 2026): ASAR Integrity stabilized; Wayland Linux improvements

## Notable 2026 features

- **ASAR Integrity** (stable): "validates your packaged `app.asar` at runtime against a build-time hash to detect any tampering." Closes a long-standing supply-chain hole — Electron apps were trivially modifiable post-install.
- **Wayland default on Linux**: frameless windows now have drop shadows + extended resize boundaries.
- **MSIX auto-updater support** for Windows.
- **CSS `-electron-corner-smoothing`**: macOS-style squircle corners.

## Trade-offs vs Tauri 2 (synthesis with cross-ref topic)

| | Electron 42 | Tauri 2 |
|---|---|---|
| Min binary | ~80-150 MB | <600 KB (~10-30 MB realistic) |
| Memory | Chromium-tier (~200+ MB resident) | OS-webview (~50-100 MB) |
| Render consistency | Bundled Chromium → identical everywhere | Native webview → WKWebView quirks differ from WebView2 |
| Mobile | None (desktop only) | iOS+Android (rough) |
| Plugin/extension | Ad-hoc; Obsidian-style require() | Capability-gated IPC + Rust crate convention |
| Maturity | 10+ yrs, VS Code/Slack/Obsidian | 1.5 yr stable; Spacedrive/GitButler |

## Relevance for PF2e worldbuilding tool

**Pro-Electron**: render consistency matters for LLM-streaming UI + custom-rendered PF2e stat blocks; if you're already JS/TS, Obsidian's plugin model is well-trodden ground (see `2026-05-24-desktop-app-stack-obsidian-plugin-model.md`). **Anti**: bundle size, no mobile co-target, no built-in capability system. Tauri's capability model is genuinely safer for a plugin-loading worldbuilding app.
