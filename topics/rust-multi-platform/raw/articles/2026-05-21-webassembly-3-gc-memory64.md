---
title: "WebAssembly 3.0 — GC, memory64, exception handling shipped September 2025"
source: https://en.wikipedia.org/wiki/WebAssembly
type: article
tags: [webassembly, wasm-3, garbage-collection, memory64, exception-handling, threads]
date: 2026-05-21
quality: 4
confidence: medium
agent: 8
summary: "WebAssembly 3.0 released September 2025. Includes GC, 64-bit address space (memory64), exception handling. WasmGC does NOT satisfy .NET runtime needs; .NET continues shipping its own GC inside linear memory. Java/Kotlin/Dart benefit; .NET does not."
---

# WebAssembly 3.0 (September 2025)

## What landed

- **GC** (garbage collection) — `wasm-gc` proposal stabilized
- **memory64** — 64-bit address space (>4GB linear memory)
- **Exception handling** — try/catch in WASM

## WasmGC limitation

- **Does not satisfy .NET runtime needs**
- .NET continues to ship its **own GC inside linear memory** (Blazor approach)
- Java/Kotlin/Dart benefit from native WasmGC
- C++ / Rust unaffected (no GC needed)

## Threads proposal

- **Phase 4 (Standardize)** in proposals repo
- Tier 2 in Wasmtime
- Browser threads still need COOP/COEP cross-origin isolation
- WASI 0.3 will add cooperative threading; preemptive later

## JS Promise Integration (JSPI)

- Phase 4
- Mostly browser-relevant; unlocks better embedder integration
- Helps async-Rust→WASM-in-browser story

## Component Model

- Tier 1 in Wasmtime
- Implementer-led rather than W3C standards-track in the traditional sense
- **Not yet in browsers** — wasm-bindgen describes itself as "half polyfill" until browsers natively support component-style typed interfaces

## Practical takeaway

For Rust:
- WasmGC: irrelevant (Rust manages own memory)
- memory64: useful for >4GB heaps in scientific/data workloads
- Exception handling: matters for C++ interop (via cxx, etc.), less for pure Rust
- Threads: COOP/COEP gating still painful in browsers; WASI 0.3 will help server-side

## Cross-references

- [[WASI Preview 2/3 status]]
- [[Wasmtime / Spin / Wasmer — server-side WASM camps]]
- [[rustwasm/wasm-bindgen]]
