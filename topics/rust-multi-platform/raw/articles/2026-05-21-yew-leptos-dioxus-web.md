---
title: "Yew vs Leptos vs Dioxus-web — Rust frontend framework comparison"
source: https://github.com/yewstack/yew
type: article
tags: [yew, leptos, dioxus, frontend, rust-web, comparison]
date: 2026-05-21
quality: 5
confidence: high
agent: 7
summary: "Three viable Rust frontend frameworks in 2026, clear differentiation. Dioxus 0.7.9 (36.1k★): broadest scope (web+desktop+mobile+server). Leptos 0.8.18 (20.8k★): fine-grained signals, no vDOM, fastest-iterating. Yew 0.23.0 (32.6k★): most React-like, mature, slower release cadence."
---

# Yew vs Leptos vs Dioxus-web (May 2026)

## Side-by-side

| Framework | Latest | Stars | Mental model | Reactivity | Bundle |
|-----------|--------|-------|--------------|------------|--------|
| **Dioxus** | 0.7.9 (May 2026) | 36.1k | React-like + RSX | Signals | **<50KB** (claimed) |
| **Yew** | 0.23.0 (Mar 2026) | 32.6k | React-like + html! macro | Virtual DOM | ~100KB+ |
| **Leptos** | 0.8.18 (Apr 2026) | 20.8k | Solid-like fine-grained | Signals (no vDOM) | varies |
| Sycamore | (slow) | smaller | Older fine-grained reactive | Signals | varies |

## Dioxus

- **Broadest scope**: web + desktop + iOS + Android + fullstack with Axum from one codebase
- "Subsecond hot reload"
- Sub-50KB web bundles claimed; sub-5MB desktop/mobile
- shadcn-style component library
- Production users (per Dioxus marketing): Airbus, ESA, Cognition, Y Combinator, FutureWei
- Backed by FutureWei full-time team
- See [[dioxus-mobile crate webview reality]] for mobile architecture caveat

## Leptos

- **Fine-grained reactivity** (Solid.js-style) — no virtual DOM
- Server functions (RPC-like syntax for client-server)
- Islands architecture
- SSR / CSR / hydration modes
- APIs "basically settled" — mature for a 0.x project
- Fastest-iterating of the three (5,259 commits, 89 releases)

## Yew

- **Most React-like** with html! macro
- Mature SSR support
- Slower release cadence (0.23 in March 2026, ~yearly major versions)
- Community-maintained (no corporate backing)
- Best pick for "I want something rock-solid that's not going anywhere"

## Decision guide

| You want | Pick |
|----------|------|
| Single codebase across web+desktop+mobile | **Dioxus** |
| Best perf and React-y patterns aren't required | **Leptos** |
| Most stable / longest-running framework | **Yew** |
| Just embedded UI in a server app | wasm-bindgen direct (skip framework) |

## All three target

- `wasm32-unknown-unknown` via wasm-bindgen
- Build via Trunk (typical) or wasm-pack
- Standard COOP/COEP rules apply if using threads

## Cross-references

- [[rustwasm/wasm-bindgen]]
- [[wasm-pack vs Trunk]]
- [[Dioxus 0.6 release]]
- [[Boring Cactus 2025 Rust GUI survey]]
