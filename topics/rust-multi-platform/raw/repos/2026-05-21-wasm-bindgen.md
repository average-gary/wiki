---
title: "rustwasm/wasm-bindgen — Rust↔JS interop for browser WASM"
source: https://github.com/rustwasm/wasm-bindgen
type: repo
tags: [wasm, browser, wasm-bindgen, web-sys, js-sys, futures]
date: 2026-05-21
quality: 5
confidence: high
agent: 7
summary: "v0.2.121 (May 2026), 9k stars, 4,345 commits, 467 open issues, monthly releases. MSRV 1.77 (lib) / 1.86 (CLI). Includes web-sys (Web IDL bindings), js-sys (JS built-ins), wasm-bindgen-futures. Self-described as 'half polyfill for component model proposal' since browsers don't yet have native component model."
---

# wasm-bindgen

## Status (May 2026)

- Latest: **v0.2.121 (May 7, 2026)**
- 9k stars, 4,345 commits, 467 open issues, **monthly releases**
- 125 total releases
- MSRV split: **library 1.77, CLI 1.86**

## What's in the repo

- `wasm-bindgen` — the macro crate
- `web-sys` — auto-generated bindings to ~all Web IDL APIs (DOM, Fetch, WebGL/WebGPU, AudioContext, etc.)
- `js-sys` — bindings to JS built-ins (Promise, Array, Map, etc.)
- `wasm-bindgen-futures` — `Future` ↔ JS `Promise` glue

## Self-positioning

Generates JS shims for Rust↔JS interop covering closures, futures, TypeScript declarations.

> "sort of half polyfill for features like the component model proposal"

— it fills the gap until browsers natively support component-style typed interfaces.

## Practical pitfalls

1. **Async closures crossing JS↔Rust** require `wasm-bindgen-futures::spawn_local`; common gotcha — Rust `Future` doesn't auto-run, must be spawned
2. **`Closure` lifetime management** — `Closure::new` callbacks passed to JS must be `forget()`-ed or kept alive in Rust, otherwise dropped on free
3. **MSRV churn** — CLI now needs Rust 1.86; CI pipelines on older toolchains break
4. **`getrandom` js feature** — many ecosystem crates require `getrandom` with the `js` feature for browser builds; common build-failure on first compile
5. **Threads need COOP/COEP** — see [[browser-wasm-coop-coep-threading]]

## Cross-references

- [[wasm-pack vs trunk]] — different deployment targets
- [[Yew vs Leptos vs Dioxus-web]]
- [[Component Model not in browsers]]
