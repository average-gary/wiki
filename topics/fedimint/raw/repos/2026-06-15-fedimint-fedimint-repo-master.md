---
title: "fedimint/fedimint — Federated Chaumian E-Cash Mint (master @ c39f9c8, 2026-06-15)"
type: raw
source_type: repos
source_url: https://github.com/fedimint/fedimint
source: "https://github.com/fedimint/fedimint"
local_path: /Users/garykrause/repos/fedimint
ingested: 2026-06-15
fetched: 2026-06-15
verified: 2026-06-15
volatility: hot
quality: 5
confidence: high
revision: c39f9c83255fb88adb2381848ed3423c1e6d5c64
branch: master
latest_release_tag: v0.11.2-alpha.1
latest_release_date: 2026-06-02
workspace_version: 0.12.0-alpha
license: MIT
edition: "2024"
tags: [fedimint, repo, rust-workspace, consensus, alephbft, mint, lightning, wallet, gateway, multi-currency, mintv2, lnv2, walletv2]
summary: Top-level Fedimint monorepo at master c39f9c8 (2026-06-15) — workspace version 0.12.0-alpha, 103 member crates spanning fedimint-core, fedimint-server, fedimint-client, the gateway, devimint, and the v1+v2 mint/lightning/wallet/meta modules. 352 commits ahead of latest tag v0.11.2-alpha.1 (2026-06-02). MIT, Rust 2024 edition, Nix-based dev shell.
---

# fedimint/fedimint — repo snapshot

- **Upstream**: https://github.com/fedimint/fedimint
- **Local clone**: `/Users/garykrause/repos/fedimint`
- **Snapshot commit**: `c39f9c83255fb88adb2381848ed3423c1e6d5c64` (master, 2026-06-15)
  > `ci(review): surface codex review failures (#8705)`
- **Latest release tag at snapshot**: `v0.11.2-alpha.1` (2026-06-02), 352 commits behind master
- **Workspace version**: `0.12.0-alpha`
- **Edition**: Rust 2024
- **License**: MIT (`LICENSE` at repo root)
- **Authors (workspace)**: "The Fedimint Developers"
- **Build**: `just` + Nix flake (`nix develop`); `just build`, `just check`, `just test`, `just lint`, `just final-check`

## What this repo is

The Fedimint monorepo: a federated, byzantine-fault-tolerant Chaumian e-cash framework for Bitcoin custody and Lightning payments, plus the Lightning gateway and a development federation harness. The "core" implementation focuses on a federated Chaumian e-cash mint that is natively compatible with Bitcoin and the Lightning Network. Federations are run by guardians who threshold-custody Bitcoin and issue blinded e-cash notes; users transact privately, with Lightning gateways bridging the federation to the wider network.

Three default modules ship in-tree (mint, wallet, lightning) plus a meta module and a v2 line (`mintv2`, `lnv2`, `walletv2`, `recurringdv2`). External applications can write [custom modules](https://github.com/fedimint/fedimint-custom-modules-example) using the same framework.

## Workspace layout (103 members)

Top-level crates that aren't inside a sub-directory:

- **fedimint-core** — shared types, encoding, registries, time, db abstraction
- **fedimint-server** — guardian consensus (AlephBFT), epoch processing, networking
- **fedimint-server-core** — server-side module trait surface
- **fedimint-server-bitcoin-rpc** — bitcoind backend for the server
- **fedimint-server-tests** — server integration tests
- **fedimint-server-ui** — server-rendered Maud-based guardian dashboard
- **fedimint-client** — high-level client orchestrator
- **fedimint-client-module** — module-side client trait surface
- **fedimint-client-rpc** — RPC layer for client
- **fedimint-client-wasm** — WASM client bindings
- **fedimint-cli** — CLI wallet
- **fedimint-api-client** — HTTP client for federation API
- **fedimint-bitcoind** — bitcoind RPC adapter
- **fedimint-bip39** — BIP-39 seed handling
- **fedimint-build** — build-time helpers
- **fedimint-connectors** — pluggable transport connectors
- **fedimint-cursed-redb**, **fedimint-rocksdb**, **fedimint-db-locked** — DB backends + locking
- **fedimint-dbtool** — DB inspector
- **fedimint-derive** — proc-macros (`Encodable`, `Decodable`)
- **fedimint-eventlog** — event log infrastructure
- **fedimint-fountain** — onboarding/distribution helper
- **fedimint-lnurl** — LNURL endpoint surface
- **fedimint-load-test-tool** — load test driver
- **fedimint-logging** — tracing setup
- **fedimint-metrics** — Prometheus metrics
- **fedimint-recoverytool** — recovery tool
- **fedimint-recurringd**, **fedimint-recurringd-tests**, **fedimint-recurringdv2** — recurring-payment daemon (v1 + v2)
- **fedimint-testing**, **fedimint-testing-core** — test scaffolding
- **fedimint-ui-common** — shared UI primitives
- **fedimint-util-error** — error utilities
- **fedimint-wasm-tests** — WASM integration tests
- **fedimintd**, **fedimintd-envs** — guardian daemon binary + env config
- **fuzz** — fuzz harness
- **devimint** — multi-process dev federation runner
- **docs** — book-style and Cargo doc tree

Sub-directory groupings:

- **`crypto/`** — `aead`, `derive-secret`, `hkdf`, `tbs` (threshold blind signatures), `tpe` (threshold-PKE)
- **`modules/`** — module triplets (`-client`, `-common`, `-server`) + `-tests`:
  - `fedimint-dummy-*`, `fedimint-empty-*`, `fedimint-unknown-*`
  - `fedimint-mint-*` and `fedimint-mintv2-*`
  - `fedimint-ln-*` and `fedimint-lnv2-*`
  - `fedimint-wallet-*` and `fedimint-walletv2-*`
  - `fedimint-meta-*`
  - `fedimint-gw-client`, `fedimint-gwv2-client`
- **`gateway/`** — Lightning gateway:
  - `fedimint-gateway-server` (binary)
  - `fedimint-gateway-client`, `fedimint-gateway-common`
  - `fedimint-gateway-server-db`, `fedimint-gateway-ui`
  - `fedimint-lightning` (LN backend abstraction over CLN/LND/LDK)
  - `gateway/integration_tests`
- **`utils/`** — `portalloc`

## Entry points

- `fedimintd/src/bin/main.rs` — guardian daemon
- `fedimint-cli/src/main.rs` — CLI wallet
- `gateway/fedimint-gateway-server/src/bin/main.rs` — Lightning gateway

## In-tree docs (`docs/`)

`api.md`, `architecture.md` (+ `architecture.svg`), `backup_and_recovery.md`, `building-new-modules.md`, `database.md`, `debugging.md`, `deploying.md`, `dev-env.md`, `fuzzing.md`, `gateway.md`, `lifecycle.md`, `lightning_module_v1.md`, `lightning_module_v2.md`, `modular-architecture.md`, `networking.md`, `nix-ci.md`, `recoverable_e-cash.md`, `tutorial.md`, `expected_loss.ipynb`, plus `meta_fields/` and embedded images.

## Architecture highlights

- **Consensus**: AlephBFT-based BFT consensus among guardians. Epoch-based transaction processing with module-specific consensus contributions.
- **Module system**: `ServerModule` and `ClientModule` traits. Modules are pluggable and can be developed out-of-tree (see `fedimint-custom-modules-example`).
- **Encoding**: Custom `Encodable` / `Decodable` traits with module registries for canonical wire/storage formats.
- **Client API**: Operation-based — long-running operations tracked by `OperationId`, driven by async state machines.
- **Database**: Key-value store with module-specific namespacing; backends include rocksdb and redb. Migration tested against snapshot fixtures.
- **WASM**: First-class WASM compatibility via `fedimint-client-wasm` + `fedimint-wasm-tests`; `just check-wasm`.
- **Multi-currency rails**: `fedimint-core` carries `AmountUnits` and `Amounts` (unit→amount map); `mintv2` accepts an `amount_unit` config field per module instance. See [[2026-05-28-fedimint-pr-7734-multi-currency-support|PR #7734]] (core types, merged 2025-10-19) and [[2026-05-28-fedimint-pr-8460-mintv2-amount-unit-config|PR #8460]] (mintv2 config, merged 2026-04-08). The protocol-layer rails are merged; non-BTC unit deployments and peg/oracle/collateral mechanisms are not in this repo.

## Release/version state at snapshot

- Workspace declares `version = "0.12.0-alpha"` (next-cycle alpha line).
- Most recent published tag: `v0.11.2-alpha.1` at 2026-06-02 (the v0.11.x release stream).
- Master is **352 commits ahead** of `v0.11.2-alpha.1` as of `c39f9c8`.
- Recent master commit subjects (top-of-tree at snapshot):
  - `c39f9c8` — ci(review): surface codex review failures (#8705)
  - `1904297` — ci(review): surface codex review failures
  - `1986da8` — ci(agent): scope bot mentions to reviewers (#8703)
  - `f7bca18` — ci(agent): scope bot mentions to reviewers
  - `1ee68fd` — test(lnv2): bound LNURL balance waits (#8631)

## Operational provenance

- **Clone path**: `/Users/garykrause/repos/fedimint`
- **Pinned commit**: `c39f9c83255fb88adb2381848ed3423c1e6d5c64` (master, 2026-06-15 13:18:27 +0000)
- **Total commits at HEAD**: 12,880
- **Remote**: `origin → git@github.com:fedimint/fedimint`

This is a "warm/hot" source — the repo is actively developed; pin to the commit SHA above when citing specifics. For PR-level provenance, prefer the dedicated PR raw sources rather than this repo source.

## Why ingested

This is the canonical upstream of the Fedimint topic wiki. Two PR-level sources existed prior; this snapshot captures the repo as a whole — workspace layout, module roster, doc inventory, license/version state — so future research and compiled articles have a stable, dated reference for "what was actually in master on 2026-06-15."

## See also

- [[2026-05-28-fedimint-pr-7734-multi-currency-support|PR #7734 — chore: multi-currency support]] — core `AmountUnits` / `Amounts`
- [[2026-05-28-fedimint-pr-8460-mintv2-amount-unit-config|PR #8460 — feat(mintv2): amount_unit config]] — per-module unit config
- [[../../wiki/topics/fedimint-multi-currency-status|Multi-currency status]] — three-path framing of how Fedimint handles non-BTC value today
