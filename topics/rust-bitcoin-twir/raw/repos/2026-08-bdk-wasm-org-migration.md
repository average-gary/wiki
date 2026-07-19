---
title: "bdk-wasm migration to bitcoindevkit org (Aug 2025)"
source: https://github.com/bitcoindevkit/bdk-wasm
type: org-migration
tags: [bdk, bdk-wasm, metamask, wasm, wasm-bindgen]
ingested: 2026-06-22
date: 2025-08-21
verified: 2026-06-22
volatility: cold
credibility: high
twir-fit: maybe-back-fill
twir-section: Project/Tooling Updates
agent: adjacent
---

# bdk-wasm Migration to BitcoinDevKit Org

MetaMask's bdk-wasm fork archived 2025-08-21 with the notice: "This repository has moved to the official Bitcoindevkit organization and will no longer be maintained."

## Active repo
- Now at `bitcoindevkit/bdk-wasm`, ~62.8% Rust / 35.7% TypeScript.
- Dual-licensed MIT/Apache-2.0.
- Ships two npm packages: `@bitcoindevkit/bdk-wallet-web`, `@bitcoindevkit/bdk-wallet-node`.
- Targets `wasm32-unknown-unknown` via wasm-bindgen.

## WASM constraints documented
- No filesystem (must call `wallet.take_staged()` and persist manually).
- Only HTTP(S) — Esplora only.
- RPC and Electrum require sockets and won't work in browsers.

## TWiR fit
- **Section**: Project/Tooling Updates (back-fill — likely missed window).
- Useful walkthrough fodder: "Compiling rust-bitcoin to WASM and the Esplora-only constraint."
