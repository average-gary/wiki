---
title: "chinedufn/swift-bridge — zero-overhead Rust↔Swift FFI"
source: https://github.com/chinedufn/swift-bridge
type: repo
tags: [swift-bridge, ffi, ios, swift, rust, alternative-to-uniffi]
date: 2026-05-21
quality: 4
confidence: high
agent: 1
summary: "iOS-only Rust↔Swift FFI generator. Pitches zero-overhead vs UniFFI's lift/lower serialization. v0.1.59 (Jan 2026), 42 releases. Swift 6.0+ minimum; plans ~Copyable for opaque Rust ownership."
---

# chinedufn/swift-bridge

## Status

- Latest: v0.1.59 released 2026-01-06
- Single-language focus: **Swift only** — not a UniFFI competitor for Android
- License: MIT/Apache-2.0

## Pitch (verbatim)

> "None of its generated FFI code uses object serialization, cloning, synchronization or any other form of unnecessary overhead"

Direct shot at UniFFI's lift/lower model. UniFFI serializes data across the FFI boundary; swift-bridge does not.

## Type support

- Primitives, `String`, `Option<T>`, `Result<T,E>`
- Custom structs / enums / classes
- `Vec<T>`, raw pointers
- Transparent + opaque types
- Async functions (both directions)
- Generics is an explicit goal

## Definition style

Bridge defined inline via `#[swift_bridge::bridge]` macro module — **no separate IDL file** (vs UniFFI's UDL).

## Roadmap

- Swift 6.0+ minimum
- Plans to use `~Copyable` for ownership of opaque Rust types

## When to pick this over UniFFI

- iOS-only project
- Perf-sensitive (every byte across the boundary counts)
- Want native Swift idioms — generics, `~Copyable` ownership

## When NOT to pick this

- You also need Kotlin/Android (UniFFI is the answer there)
- You want a stable 1.0 — both are pre-1.0; UniFFI has wider production validation
