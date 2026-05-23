---
title: "Wasmtime, Spin/SpinKube (Akamai), Wasmer — three server-side WASM camps"
source: https://docs.wasmtime.dev/stability-tiers.html
type: article
tags: [wasmtime, spin, spinkube, wasmer, akamai, fermyon, edge-compute, cncf]
date: 2026-05-21
quality: 5
confidence: high
agent: 8
summary: "Wasmtime: BA Core Project (Apr 2025), v45 May 2026, 2-year LTS. Spin/Fermyon ACQUIRED BY AKAMAI (fermyon.com→akamai.com); SpinKube CNCF Sandbox (Jan 2025). Wasmer 7 (Jan 2026): WASIX dynamic linking enables numpy/pydantic; deliberately diverging from BA Component Model path."
---

# Wasmtime / Spin / Wasmer — server-side WASM camps

## Wasmtime — the de-facto runtime

- **First officially designated Bytecode Alliance Core Project** (April 2025)
- **2-year LTS** for security fixes
- Current: v45.0.0 (May 21, 2026); v44.0.0 (Apr 2026); v43.x
- Recent features: copying GC collector (handles cycles, improves DRC), gdbstub/LLDB debugging via `-g`, async component invocation, `map<K,V>` types, `wasi:tls`
- Tier 1 platforms: x86_64 macOS/Windows/Linux GNU
- Tier 2: aarch64 Linux/macOS, s390x
- Tier 3: Android, FreeBSD, iOS, RISC-V
- Production users: Fastly Compute, Microsoft (multiple internal services), Shopify Functions, Fermyon Spin, Cosmonic, InfinyOn
- Security: multiple critical sandbox-escape advisories shipped in 2026 patch releases (24.0.9, 36.0.9, 43.0.2, 44.0.1) — security maturity is real but ongoing

## Fermyon Spin & Akamai acquisition

**Big political shock since 2025**: **Fermyon was acquired by Akamai**.

- `fermyon.com/blog` 301-redirects to `akamai.com/blog/developers`
- Akamai's edge platform previously had no native WASM story; Spin pulls them in
- InfoQ has 2025-11 archive piece on the deal (access blocked from this run)

### Spin's programming model

- Spin app = TOML manifest mapping **HTTP routes to WASM components**
- Each request invokes a **fresh component instance**
- Sub-millisecond cold starts (instantiation = module + linear memory setup, not container/process boot)
- Language interop via Component Model (Rust component can import a JS component, etc.)

### SpinKube

- **CNCF Sandbox project as of January 21, 2025**
- containerd shim + Kubernetes integration
- `containerd-shim-spin` v0.24.0 (April 2026), 18 versioned releases
- Schedules Spin apps as if they were pods via a `RuntimeClass`
- runtime-class-manager automates installation across nodes

## Wasmer — the parallel ecosystem

- **Wasmer 7** released January 2026
- Wasmer 7 features: experimental async API across singlepass/cranelift/llvm backends; full **WebAssembly exception handling in Cranelift**; **RISC-V** in singlepass + LLVM; **dynamic linking in WASIX** (enables numpy/pydantic to run as native Python modules in WASM!)
- WASIX strategy: position as long-term stabilization of WASI Preview 1 + extensions (sockets, threads, fork, signals, TTY, pipes, futexes)
- Wasmer 7 announcement explicitly **does not mention** WASI 0.2, WASI 0.3, or the Component Model — Wasmer is **deliberately diverging** from the Bytecode Alliance path

## The architectural fork

- **Bytecode Alliance** bets on Component Model + WASI worlds (0.2, 0.3+)
- **Wasmer** bets on stabilized POSIX-flavored ABI plus dynamic linking
- These are NOT compatible long-term — pick one ecosystem

## Edge platform comparison

| Platform | Runtime | Programming model | Status |
|----------|---------|-------------------|--------|
| **Fastly Compute** | Wasmtime (replaced Lucet ~2022) | Per-request WASM, wasi-http | GA, mature; likely largest WASM deployment by request volume |
| **Cloudflare Workers** | V8 isolates (NOT WASM-first) | JS/TS primary; WASM as guest INSIDE V8 | Different path entirely |
| **Akamai (ex-Fermyon Cloud)** | Wasmtime via Spin | Spin manifest, HTTP component handlers | In transition post-acquisition; SpinKube available for self-host |
| **Cosmonic / wasmCloud** | Wasmtime | Actor model + WASI capability providers | Production for select customers; CNCF wasmCloud incubating |

**Cloudflare Workers being V8-isolate-based, not WASM-based**, is a frequently misunderstood point. WASM runs *inside* a Worker as a guest, but the isolation boundary is V8, not Wasmtime.

## Containers vs WASM-on-K8s sweet spot

- **Cold start**: WASM **sub-millisecond to ~5ms**; containers hundreds-of-ms-to-seconds
- **When containers still win**: full Linux ABI, rich filesystem, GPU passthrough, mature observability, native deps (Postgres clients, OpenCV)
- WASM sweet spot: per-request HTTP handlers, AI inference plugins, untrusted user code (Shopify Functions, Adobe extensibility), feature-flag rule engines

## Production deployments confirmed

- **Fastly Compute** — Wasmtime at CDN scale
- **Shopify Functions** — custom WASM platform for merchant-injected business logic; sub-5ms execution; production since 2022
- **Microsoft** — internal services using Wasmtime (Hyperlight, Azure plugin systems)

## 2026 recommendation

For a Rust developer choosing server-side WASM:
1. **Deploy on `wasi-http`** with `wasm32-wasip2` + Wasmtime LTS or Spin — only Tier 1 combo
2. **Stay on `wasm32-wasip1`** if your dep tree isn't component-ready
3. **Don't yet bet production on**: wasi-keyvalue, wasi-blobstore, wasi-tls (still draft), generic threads
4. **Pick Spin/SpinKube** if K8s-native and want smallest cold-start delta
5. **Pick plain Wasmtime embedding** if building a plugin system inside an existing Rust service
6. **Pick Fastly Compute** if your workload is HTTP edge logic
7. **Avoid Wasmer** unless you specifically need WASIX (dynamic linking, full POSIX-flavored sockets/fork)

## Cross-references

- [[WASI Preview 2/3 status]]
- [[WebAssembly 3.0 GC threads memory64]]
