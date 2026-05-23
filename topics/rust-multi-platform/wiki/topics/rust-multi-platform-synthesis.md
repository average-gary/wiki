---
title: "Rust Multi-Platform — synthesis"
type: topic
created: 2026-05-21
updated: 2026-05-21
verified: 2026-05-21
volatility: warm
confidence: high
compiled-from: conversation
---

# Rust Multi-Platform — synthesis

Single-page summary tying the four scopes together.

## The four scopes at a glance

| Scope | Default pick | Key concept article |
|-------|--------------|---------------------|
| **Mobile FFI** | UniFFI + megazord | [[mobile-ffi-decision-tree]] |
| **Mobile shipping** | xcframework via SPM + AAR via Maven | [[ios-xcframework-aar-pipeline]] |
| **Desktop cross-compile** | 3-runner GitHub Actions matrix + cargo-dist | [[desktop-cross-compile-and-package]] |
| **UI framework** | Tauri 2 (web frontend) OR Slint (native renderer) | [[ui-framework-decision]] |
| **WASM browser** | Dioxus + Trunk OR Leptos + Trunk | [[wasm-browser-and-server]] |
| **WASM server** | Wasmtime + `wasi-http` + `wasm32-wasip2` | [[wasm-browser-and-server]] |

## Cross-cutting decisions

### "I need iOS + Android with native UX"

**Don't pick a Rust UI framework.** Mobile a11y is unsupported across the entire Rust UI ecosystem in 2026. Instead:

1. Write Rust **core only** (business logic, networking, crypto, parsing)
2. Wrap with [UniFFI](mobile-ffi-decision-tree.md) → Swift + Kotlin bindings
3. [Build native iOS app + native Android app](ios-xcframework-aar-pipeline.md) with platform-native UIs (SwiftUI / Jetpack Compose)
4. Apply megazord pattern if shipping multiple Rust components

This is what Mozilla, Bitwarden, and Element X (Matrix) do.

### "I need cross-platform desktop with web UI"

Pick **Tauri 2**. <600KB binary, system webview, mature. Risks: stringly-typed IPC, mobile is rougher than desktop.

If you want **all-Rust no-JS**: pick **Dioxus 0.7** (multi-platform from `main.rs`).

If you want **native-renderer**: pick **Slint** (read the [license tiers](../../raw/articles/2026-05-21-slint-mobile-license.md) carefully — embedded use has per-unit royalty).

### "I need browser frontend in Rust"

[Three frameworks](../../raw/articles/2026-05-21-yew-leptos-dioxus-web.md):
- **Dioxus** — broadest scope (web+desktop+mobile)
- **Leptos** — best perf (signals, no vDOM)
- **Yew** — most React-like, slowest cadence, most stable

Build with Trunk. Don't use Tauri for web — it's webview-on-desktop, not a browser target.

### "I need server-side WASM"

`wasi-http` is the only WASI 0.2 interface that's Tier 1 in Wasmtime. Deploy via:
- **Spin/SpinKube** — K8s-native, sub-ms cold starts, now Akamai-backed
- **Fastly Compute** — HTTP edge logic
- **Wasmtime embed** — plugin system inside an existing Rust service
- **Avoid Wasmer** unless you specifically need WASIX (POSIX-flavored ABI, dynamic linking)

[Component Model NOT in browsers yet](../../raw/articles/2026-05-21-wasi-preview-2-3-status.md). Server-only.

## The "single Rust core, multiple frontends" pattern

This is the highest-leverage architectural move when shipping the same logic across platforms:

```
                ┌─────────────────────────────┐
                │   Rust core (Cargo crate)   │
                │   business logic, network,  │
                │   crypto, parsing           │
                └────────────┬────────────────┘
                             │
       ┌─────────────────────┼─────────────────────┐
       │                     │                     │
   ┌───▼────┐         ┌──────▼──────┐         ┌────▼────┐
   │ UniFFI │         │ wasm-bindgen │         │ extern  │
   │ (mobile│         │ (browser)    │         │ "C" API │
   └───┬────┘         └──────┬──────┘         └────┬────┘
       │                     │                     │
   ┌───┴───────┐       ┌─────┴───────┐       ┌─────┴─────┐
   │ Swift app │       │ Yew/Leptos/ │       │ desktop UI │
   │ Kotlin app│       │ Dioxus-web  │       │ (Tauri/    │
   └───────────┘       └─────────────┘       │  Slint/...)│
                                              └────────────┘
```

Examples in the wild:
- **Mozilla**: Rust core ([application-services](../../raw/repos/2026-05-21-application-services.md)) → Firefox iOS (Swift), Firefox Android (Kotlin)
- **Matrix.org**: [matrix-rust-sdk](../../raw/repos/2026-05-21-matrix-rust-sdk.md) → Element X iOS, Element X Android, Element Web
- **Bitwarden**: [sdk-internal](https://github.com/bitwarden/sdk-internal) → Bitwarden iOS, Android, browser extension, desktop, CLI
- **Signal**: hand-rolled bridges (counter-example, [libsignal](../../raw/repos/2026-05-21-libsignal.md)) — same architectural pattern, different bridge tooling

## Connection to other wikis

This wiki provides the multi-platform craft layer for the **iOS gap** in [[gtx-1060-headless-ai-server]]:
- That plan deferred iOS-over-iroh to v2 because `iroh-ffi` was archived mid-2025
- The v2 path = native Swift app + custom Rust+UniFFI shim (4-6 weeks of dev)
- The patterns and tools in this wiki ([UniFFI](mobile-ffi-decision-tree.md), [xcframework pipeline](ios-xcframework-aar-pipeline.md), [Apple Developer Program](../../raw/guides/2026-05-21-macos-codesign-notarize.md)) cover the work directly

## Cross-references

- [[mobile-ffi-decision-tree]]
- [[ios-xcframework-aar-pipeline]]
- [[desktop-cross-compile-and-package]]
- [[ui-framework-decision]]
- [[wasm-browser-and-server]]
