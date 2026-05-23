---
title: "Boring Cactus 2025 Survey of Rust GUI Libraries — accessibility-focused comparison"
source: https://www.boringcactus.com/2025/04/13/2025-survey-of-rust-gui-libraries.html
type: article
tags: [rust-gui, comparison, accessibility, ime, survey, boring-cactus]
date: 2026-05-21
quality: 5
confidence: high
agent: 5
summary: "Most authoritative single comparison. April 2025. Hands-on a11y/IME testing across 8 frameworks. Brutal verdicts: Iced=screen-reader broken; Floem=a11y completely absent; Makepad=a11y completely absent; egui+Slint+Tauri=working a11y. Recommends avoid Iced for now."
---

# Boring Cactus 2025 Rust GUI Survey

## Methodology highlight

Hands-on accessibility testing with **Windows Narrator** + IME testing across all 8 frameworks. This single methodological choice makes it the most actionable Rust GUI comparison.

## Verdicts (verbatim where shown)

### Tauri

- > "Splits application into separate frontend and host processes communicating via IPC. Frontend runs in system WebView (WebView2 on Windows, WebKit on macOS, WebKitGTK on Linux)."
- Cons: > "IPC boundary lacks type safety on frontend side despite claims otherwise"; "Stringly-typed communication causes runtime errors instead of compile-time checking."

### Dioxus

- > "Rust-focused throughout stack (unlike Tauri's split architecture)... Excellent choice if you want full-stack Rust with web-like UI patterns without the Tauri architectural split."

### Slint

- Pro: > "Excellent accessibility support with 'Windows Narrator working perfectly'... Two-way data binding with `<=>` operator... Professional tooling with C++, JS, Python bindings."
- Con: Learning new DSL; smaller ecosystem.

### egui

- Limitation (verbatim from README, not survey): > "If you are not using Rust, egui is not for you. If you want a GUI that looks native, egui is not for you."
- Survey notes: "Default font lacks CJK coverage"; "IME Tab press gets consumed."
- Real apps: Rerun Viewer (multimodal data viz startup) sponsors development.

### Iced

- > "IME won't activate at all. No screen reader accessibility ('Windows Narrator can't see into this window')"
- Recommendation: > "Avoid for now unless IME support isn't critical."
- System76 betting on it for COSMIC shell — long-term maybe.

### Floem (Lapce-derived)

- > "Complete lack of accessibility ('Windows Narrator can't see any of this text')"
- > "Tuple layout limited to 16 widgets maximum"
- > "Not ready for serious use outside Lapce."

### Makepad

- > "Accessibility completely absent (can't even see window chrome). Macro DSL lacks documentation ('no documentation I can find'). Project appears optimized for Makepad team's own use."

### Xilem (Linebender)

- > "Screen reader positioning incorrect (sees content but wrong location)... Some IME provisional states show tofu characters temporarily."
- > "No numbered release in ~1 year; Git dependency required."

## Architecture taxonomy

Three families:
1. **Webview-based**: Tauri, Dioxus desktop. UI is HTML/CSS in OS webview + Rust backend.
2. **Immediate-mode**: egui, Makepad. Widgets rebuilt every frame, no persistent widget state.
3. **Retained-mode/reactive**: Iced (Elm), Slint (DSL), Floem (signals), Xilem (view tree), Dioxus (vDOM).

## Production-readiness summary

| Framework | a11y | IME | Production? |
|-----------|------|-----|-------------|
| **Tauri** | yes (browser) | yes | YES |
| **egui** | yes (Win/Mac via AccessKit) | partial CJK | YES (tools/dashboards) |
| **Slint** | YES (excellent) | yes | YES |
| **Dioxus** | yes | yes | YES (with caveats) |
| **Iced** | NO | NO | NO (today) |
| **Floem** | NO | partial | NO (Lapce-only) |
| **Makepad** | NO | unknown | NO |
| **Xilem** | partial | partial | NO (experimental) |

## Cross-references

- [[Tauri 2.0 release]]
- [[Dioxus 0.6 release]]
- [[Slint 1.12 mobile + license]]
- [[Tauri open iOS issues]]
