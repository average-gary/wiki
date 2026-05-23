---
title: "WASI Preview 2 stable, Preview 3 in rollout — server-side WASM state"
source: https://wasi.dev/roadmap
type: article
tags: [wasi, preview-2, preview-3, component-model, wasmtime, server-side-wasm]
date: 2026-05-21
quality: 5
confidence: high
agent: 8
summary: "WASI 0.2 stable since Jan 25, 2024 (Component-Model-based). Tier 1 in Wasmtime: wasi-cli, wasi-http, wasi-clocks, wasi-filesystem, wasi-random, wasi-sockets, wasi-io. WASI 0.3 (~Feb 2026, in rollout): native async; Wasmtime 45 ships wasi:tls against 0.3-draft. wasi-keyvalue/blobstore/etc. still Tier 3."
---

# WASI Preview 2 / Preview 3 status (May 2026)

## WASI 0.2 — production-deployable

- **Released January 25, 2024**
- Complete redesign on top of Component Model (no longer a POSIX-shaped flat ABI)
- Stable WIT interfaces
- **Tier 1 in Wasmtime** (production-ready, continuously fuzzed):
  - `wasi-io`
  - `wasi-clocks`
  - `wasi-filesystem`
  - `wasi-random`
  - `wasi-sockets`
  - `wasi-cli`
  - `wasi-http`
- Release cadence: **point releases every 2 months on the first Thursday** (release-train model)
- "World" model: a component imports a curated bundle (e.g. `wasi:cli/command`, `wasi:http/proxy`) rather than ad-hoc syscalls

## WASI 0.3 — async + streams

- **Targeted ~February 2026** per official roadmap; rollout in progress
- Wasmtime 45.0.0 (May 21, 2026) ships `wasi:tls` against the **0.3.0-draft**
- Adds **native async to the Component Model**
- Refactors 0.2 interfaces to use async (futures, streams as first-class component types)
- Future 0.3.x: cancellation, stream optimization, caller-supplied buffers, **threading (cooperative first, preemptive later)**

## What's NOT yet production-ready

Despite the wasi-cloud vision, **only `wasi-http` is Tier 1** in Wasmtime.

| Interface | Wasmtime tier | Real-world readiness |
|-----------|---------------|----------------------|
| wasi-http | **Tier 1** | YES — most-deployed wasi-cloud interface |
| wasi-keyvalue | Tier 3 | "not production ready, may be disabled or removed if unmaintained" |
| wasi-config | Tier 3 | same |
| wasi-tls | Tier 3 (now 0.3-draft) | shipping but draft |
| wasi-nn | Tier 3 | same |
| wasi-threads | Tier 3 | same |
| wasi-blobstore | not in tier system | exploratory |
| wasi-sql | not in tier system | exploratory |
| wasi-crypto | not in tier system | exploratory |

**Real takeaway**: the "wasi-cloud" vision is mostly spec work + best-effort impls. Need keyvalue/blobstore today? Wrap a host-specific shim (Spin's `spin-key-value`, NATS via custom imports, etc.).

## Rust targets

- **`wasm32-wasip1`** — Tier 2 with host tools. Mature, stable Preview 1 ABI. **Default pick** for most server-side deployment today.
- **`wasm32-wasip2`** — Tier 2 without host tools. Component-Model-native; required to consume WASI 0.2 worlds directly without `wasi-libc` shim. Use when targeting Spin/Wasmtime hosts that expect components.
- **`wasm32-wasip1-threads`** — Tier 2 without host tools. Use only if you need pthreads in a Preview-1 world.
- Practical guidance: most existing Rust crates still build only on `wasip1`; ecosystem migration ongoing as 0.3 / async lands.

## Component Model

- **Tier 1 in Wasmtime** alongside core proposals (SIMD, multi-memory, tail-call, memory64)
- Toolchain support spans **C/C++, C#, Go, JavaScript, Python, Rust, MoonBit**, WAT
- Wasmtime 44 added experimental `map<K,V>` support
- Wasmtime 45 added async component-function invocation in C API + reflection on `Component` types

## Cross-references

- [[Wasmtime production runtime status]]
- [[Spin SpinKube CNCF Sandbox]]
- [[Wasmer divergence WASIX]]
