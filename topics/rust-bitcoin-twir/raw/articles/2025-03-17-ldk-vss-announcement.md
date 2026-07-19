---
title: "Announcing Versioned Storage Service (VSS)"
source: https://lightningdevkit.org/blog/announcing-vss
type: announcement
tags: [ldk, ldk-node, vss, kvstore, uniffi, gursharan-singh]
ingested: 2026-06-22
date: 2025-03-17
author: Gursharan Singh
verified: 2026-06-22
volatility: cold
credibility: high
twir-fit: maybe
twir-section: Project/Tooling Updates
agent: applied / technical (corroborated)
---

# Announcing Versioned Storage Service (VSS)

LDK blog post by Gursharan Singh, 2025-03-17.

## Architecture
- VSS-rust-client integrates with LDK Node via `build_with_vss_store_and_fixed_headers()`.
- Client-side encryption with key obfuscation.
- PostgreSQL backend (swap-able with any `KeyValueStore`).
- Stateless server, JWT auth, horizontal scaling.
- **UniFFI bindings** for Swift/Kotlin/Python.

## Phasing
- Phase I (single-device recovery) shipped.
- Phase II (multi-device) deferred.

## TWiR fit
- **Section**: Project/Tooling Updates — has actual code, ships with a usable client crate.
- Aged; back-fill candidate at best.
