---
title: "WASM in 2026 — browser frontends + server-side WASI"
type: concept
created: 2026-05-21
updated: 2026-05-21
verified: 2026-05-21
volatility: hot
confidence: high
sources:
  - raw/repos/2026-05-21-wasm-bindgen.md
  - raw/articles/2026-05-21-wasm-pack-vs-trunk.md
  - raw/articles/2026-05-21-yew-leptos-dioxus-web.md
  - raw/articles/2026-05-21-wasi-preview-2-3-status.md
  - raw/articles/2026-05-21-webassembly-3-gc-memory64.md
  - raw/articles/2026-05-21-wasmtime-spin-wasmer.md
---

# WASM in 2026 — browser + server-side

Two distinct ecosystems with different toolchains.

## Browser: `wasm32-unknown-unknown` + wasm-bindgen

[wasm-bindgen v0.2.121](../../raw/repos/2026-05-21-wasm-bindgen.md) (May 2026) is the production-grade glue layer. Includes `web-sys` (Web IDL bindings) and `js-sys` (JS built-ins). Self-described as "half polyfill for component model proposal" — browsers don't yet have native Component Model.

### Build tools split: libraries vs apps

| Tool | Purpose |
|------|---------|
| [`wasm-pack`](../../raw/articles/2026-05-21-wasm-pack-vs-trunk.md) v0.15.0 | Builds Rust crate → npm-publishable package |
| [`Trunk`](../../raw/articles/2026-05-21-wasm-pack-vs-trunk.md) v0.21.14 | Builds Rust frontend app (HTML entrypoint, HMR, asset pipeline) |

Complementary, not competing.

### Frontend frameworks (May 2026)

[Three viable choices](../../raw/articles/2026-05-21-yew-leptos-dioxus-web.md):

| Framework | Stars | Reactivity | Bundle | Best for |
|-----------|-------|------------|--------|----------|
| **Dioxus 0.7.9** | 36.1k | Signals | <50KB | Multi-platform (web+desktop+mobile+server) |
| **Yew 0.23.0** | 32.6k | Virtual DOM | ~100KB+ | Most React-like, mature, slow cadence |
| **Leptos 0.8.18** | 20.8k | Fine-grained signals (no vDOM) | varies | Best perf, fastest-iterating |

### Pitfalls

1. **Async closures crossing JS↔Rust** require `wasm-bindgen-futures::spawn_local`
2. **`Closure` lifetime** — `Closure::new` callbacks must be `forget()`-ed or kept alive
3. **MSRV churn** — wasm-bindgen CLI now needs 1.86; CI on older toolchains breaks
4. **`getrandom` js feature** — many crates need it for browser builds
5. **Threads need COOP/COEP** cross-origin isolation (SharedArrayBuffer requirement) — real deployment friction since third-party iframes/scripts must opt in via CORP

### Binary size optimization (2026)

```toml
[profile.release]
lto = true
opt-level = "z"
panic = "abort"
strip = "symbols"
```
Then `wasm-opt -Oz` for ~15-20% extra. Avoid `format!`, prefer trait objects to dodge monomorphization bloat. Brotli/gzip beats raw transit by >50%.

### What's NOT in browsers

[Component Model is NOT yet in browsers](../../raw/articles/2026-05-21-wasi-preview-2-3-status.md). Browser WASM in 2026 still consumes core modules. The Component Model lives in server-side runtimes (Wasmtime, Jco). wasm-bindgen explicitly polyfills component-style typed interfaces.

[WebAssembly 3.0 (Sept 2025)](../../raw/articles/2026-05-21-webassembly-3-gc-memory64.md) shipped GC + memory64 + exception handling. Threads proposal is Phase 4.

## Server-side: WASI 0.2 (stable) + 0.3 (rolling out)

[WASI 0.2](../../raw/articles/2026-05-21-wasi-preview-2-3-status.md) stable since January 2024. Component-Model-based, NOT POSIX-shaped. Tier 1 in Wasmtime: `wasi-cli`, `wasi-http`, `wasi-clocks`, `wasi-filesystem`, `wasi-random`, `wasi-sockets`, `wasi-io`.

[WASI 0.3](../../raw/articles/2026-05-21-wasi-preview-2-3-status.md) targets ~Feb 2026; native async + streams. Wasmtime 45 ships `wasi:tls` against the 0.3-draft.

### Rust target choice

| Target | When |
|--------|------|
| `wasm32-wasip1` | Default; broadest crate compatibility |
| **`wasm32-wasip2`** | Component-Model native; targets Spin/Wasmtime expecting components |
| `wasm32-wasip1-threads` | If you need pthreads in a Preview-1 world |

### Runtime camps

[Three competing visions](../../raw/articles/2026-05-21-wasmtime-spin-wasmer.md):

| Camp | Bet |
|------|-----|
| **Bytecode Alliance** (Wasmtime, Spin, jco) | Component Model + WASI 0.2/0.3 |
| **Wasmer** | WASIX (POSIX-flavored ABI + dynamic linking) — DELIBERATELY diverging |
| **Cloudflare Workers** | V8 isolates (NOT WASM-first; WASM as guest inside V8) |

These are NOT compatible long-term. Pick one.

### Production deployments

- **Fastly Compute** — Wasmtime at CDN scale
- **Shopify Functions** — sub-5ms execution, since 2022
- **Microsoft** — Hyperlight, Azure plugin systems

### Big political shock since 2025

**Fermyon was acquired by Akamai.** `fermyon.com/blog` 301-redirects to `akamai.com/blog/developers`. Spin/SpinKube pulled into a major edge CDN. SpinKube became CNCF Sandbox project Jan 21, 2025.

### What's NOT yet production-ready

Despite "wasi-cloud" framing, **only `wasi-http` is Tier 1**. wasi-keyvalue/blobstore/config/tls/nn are Tier 3 ("not production ready, may be disabled"). For keyvalue/blobstore today, wrap host-specific shims (Spin's `spin-key-value`, NATS via custom imports).

### Cold-start advantage

WASM instantiation: **sub-millisecond to ~5ms**. Containers: hundreds-of-ms-to-seconds. Sweet spot for: per-request HTTP handlers, AI inference plugins, untrusted user code, feature-flag rule engines, scale-to-zero.

When containers still win: full Linux ABI, GPU passthrough, native deps (Postgres clients, OpenCV), mature observability.

## 2026 recommendations

**Browser frontend**:
1. Pick Dioxus (multi-platform parity) OR Leptos (best perf) OR Yew (rock-solid)
2. Build with Trunk
3. Optimize: `lto=true`, `opt-level="z"`, `wasm-opt -Oz`
4. Don't depend on native Component Model in browsers yet

**Server-side WASM**:
1. Deploy on `wasi-http` with `wasm32-wasip2` + Wasmtime LTS or Spin
2. Stay on `wasm32-wasip1` if your dep tree isn't component-ready
3. Don't bet production on wasi-keyvalue/blobstore/tls/threads
4. Pick Spin/SpinKube if K8s-native; plain Wasmtime for embedded plugins; Fastly Compute for HTTP edge
5. Avoid Wasmer unless you specifically need WASIX (numpy/pydantic via dynamic linking)

## Cross-references

- [[release-pipeline-canonical-2026]]
- [[ui-framework-decision]]
- [[mobile-ffi-decision-tree]] (UniFFI's "half polyfill for component model" parallels wasm-bindgen)
