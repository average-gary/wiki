---
title: "rust-dlc v0.8.0 release preparation"
source: https://github.com/p2pderivatives/rust-dlc
type: release-prep
tags: [rust-dlc, dlc, p2pderivatives, discreet-log-contracts]
ingested: 2026-06-22
date: 2025-12-13
verified: 2026-06-22
volatility: warm
credibility: medium
twir-fit: maybe-watch
twir-section: Project/Tooling Updates / Crate of the Week (when shipped)
agent: adjacent
---

# rust-dlc v0.8.0 Release Preparation

Discreet Log Contracts library in Rust. v0.8.0 release-prep PR merged 2025-12-13.

## Stats
- 160 stars, 42 forks.
- No published GitHub releases — track via tags / crates.io.
- Project still self-describes as **early-stage and not mainnet-recommended**.

## Workspace crates
- `dlc`, `dlc-manager`, `dlc-messages`, `dlc-trie`, `bitcoin-rpc-provider`, `p2pd-oracle-client`, `dlc-sled-storage-provider`.

## Recent changes
- bitcoin::Amount adoption.
- CI fixes.
- Infinite-loop fix on invalid args (Jan 2025).
- Benchmark fixes (Mar 2025).

## TWiR fit
- **Section**: Project/Tooling Updates once v0.8.0 actually ships and tags.
- Could be a "Crate of the Week" candidate (`dlc-manager`) when stabilized.
- DLCs are a high-signal Bitcoin Rust topic that rarely makes TWiR.

## Action item
- Watch for v0.8.0 cut → submit promptly when released.
