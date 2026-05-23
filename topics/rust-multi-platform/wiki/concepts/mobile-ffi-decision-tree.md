---
title: "Mobile FFI decision tree — UniFFI vs swift-bridge vs hand-rolled"
type: concept
created: 2026-05-21
updated: 2026-05-21
verified: 2026-05-21
volatility: warm
confidence: high
sources:
  - raw/repos/2026-05-21-uniffi-rs.md
  - raw/repos/2026-05-21-swift-bridge.md
  - raw/repos/2026-05-21-libsignal.md
  - raw/repos/2026-05-21-application-services.md
  - raw/repos/2026-05-21-matrix-rust-sdk.md
---

# Mobile FFI decision tree

Three viable approaches to ship a Rust core to iOS (Swift) and Android (Kotlin). Pick by surface size + maintenance budget.

## TL;DR

| Approach | When |
|----------|------|
| **UniFFI** ([repo](../../raw/repos/2026-05-21-uniffi-rs.md)) | Default — both iOS+Android, stable curated API surface |
| **swift-bridge** ([repo](../../raw/repos/2026-05-21-swift-bridge.md)) | iOS-only, perf-critical, want native Swift idioms (generics, ~Copyable) |
| **Hand-rolled FFI/JNI** ([libsignal pattern](../../raw/repos/2026-05-21-libsignal.md)) | Crypto / opaque handles / fast-evolving large surface where auto-gen ages poorly |

## The default: UniFFI

[Mozilla's UniFFI](../../raw/repos/2026-05-21-uniffi-rs.md) is "production but pre-1.0," validated by:
- Mozilla (Firefox iOS+Android, megazord pattern via [application-services](../../raw/repos/2026-05-21-application-services.md))
- Bitwarden ([sdk-internal](https://github.com/bitwarden/sdk-internal) uses UniFFI for Swift+Kotlin)
- Matrix.org ([matrix-rust-sdk](../../raw/repos/2026-05-21-matrix-rust-sdk.md) powers Element X iOS+Android)

Two parallel interface styles, both first-class:
- **proc-macros** (`#[uniffi::export]`) — modern default for greenfield
- **UDL files** (WebIDL-based `.udl`) — still supported, common in older codebases

### Async support

- Rust `async fn` → Swift `async`/`await`, Kotlin `suspend fun`, Python `asyncio`
- Foreign side supplies the executor (no Rust runtime forced)
- **No built-in cancellation** — DIY via flag + `cancel()` method
- Async trait methods need `async-trait`

### Known footguns

- **Pre-1.0** — API churn risk; pin a specific UniFFI version per release
- **Doesn't handle packaging** — xcframework / AAR is YOUR problem (see [[ios-xcframework-aar-pipeline]])
- **No native cancellation** for async
- **Lift/lower has serialization overhead** vs swift-bridge's zero-overhead claim
- **Megazord pattern essentially required** to avoid duplicating libstd across multiple components in one app — see [application-services /megazords](../../raw/repos/2026-05-21-application-services.md)

## The iOS-only fast path: swift-bridge

[swift-bridge](../../raw/repos/2026-05-21-swift-bridge.md) v0.1.59 (Jan 2026) wins when:
- iOS-only project (no Android needed)
- Perf is paramount (zero-overhead pitch: no serialization, no cloning, no synchronization)
- Want native Swift idioms — generics, `~Copyable` ownership for opaque Rust types

Bridge is defined inline via `#[swift_bridge::bridge]` macro module (no separate IDL).

## The hand-rolled route: when auto-gen ages poorly

[Signal's libsignal](../../raw/repos/2026-05-21-libsignal.md) hand-rolls per-platform bridges (`rust/bridge/jni/`, equivalent for Swift+Node). Custom Python codegen for Java declarations.

When to take this on:
- Crypto primitives, opaque handles, fine ABI control needed
- Large fast-evolving Rust surface where UniFFI bindings would constantly drift
- Cautionary tale: `iroh-ffi` was UniFFI-based and was archived in mid-2025; n0 now recommends "wrap iroh behind your own daemon and call that" — narrow hand-tuned bridges age better than auto-generated ones for unstable APIs

This is the most maintenance-heavy option; budget 3 bridges (JNI / Swift / Node-API) + custom codegen + independent error-mapping + manual coordination on every API change.

## Cross-references

- [[ios-xcframework-aar-pipeline]] — packaging that any of the three above needs
- [[gtx-1060-headless-ai-server/concepts/whisperx-known-broken-installs]] cross-wiki — iroh-ffi archive context
- [[Boring Cactus 2025 Rust GUI survey]]
