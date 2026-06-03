---
title: dmonad/crdt-benchmarks — Yjs vs ywasm vs Loro vs Automerge
url: https://github.com/dmonad/crdt-benchmarks
retrieved: 2026-06-02
type: repo
---

Kevin Jahns's `crdt-benchmarks` repository defines four reference workloads:
B1 (no conflicts), B2 (two-user conflicts), B3 (many concurrent actions
scaling √N), and B4 (a real-world LaTeX editing trace, **259,778
operations**). Headline numbers at N=6000 in the published table: gzipped
bundle sizes — **Yjs 20KB, ywasm 214KB, Loro 399KB, Automerge 604KB**;
B1.1 time — Yjs 188ms, ywasm 154ms, Loro 120ms, Automerge 365ms; B4 time —
Yjs 5,714ms, **ywasm 28,675ms (an outlier — slower than Yjs in JS)**, Loro
3,089ms, Automerge 14,326ms. Loro wins the realistic editing trace, ywasm
loses to plain JS Yjs on it. Caveats: the suite is JS-side and authored by
the Yjs maintainer; numbers above are the Node 20.5.0 / desktop run, no
2025-2026 update visible, no native Rust mobile build measurements.
