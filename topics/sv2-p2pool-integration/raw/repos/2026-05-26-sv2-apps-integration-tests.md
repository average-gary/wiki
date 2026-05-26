---
title: "sv2-apps integration-tests — THE existing SV2 reference harness"
source_url: https://github.com/stratum-mining/sv2-apps/tree/main/integration-tests
type: repo
ingested: 2026-05-26
quality: 5
confidence: high
tags: [test-harness, regtest, sv2-apps, sniffer, integration-tests, reuse]
---

# sv2-apps `integration-tests/` — THE existing SV2 reference harness

Local path: `/Users/garykrause/repos/sv2-apps/integration-tests/`. Single Rust crate `integration_tests_sv2`. The most directly reusable code for sv2-p2pool's harness — already a vendored submodule.

## Layout

- `lib/` — shared helpers (sniffer, interceptor, mock_roles, sv1_minerd, prometheus_metrics_assertions, template_provider)
- `tests/*.rs` — flat per-scenario files:
  - `pool_integration.rs`
  - `jd_integration.rs` (43KB)
  - `translator_integration.rs` (89KB)
  - `jdc_block_propagation.rs`
  - `jdc_fallback_to_solo.rs`
  - `jdc_provide_missing_transaction.rs`
  - `monitoring_integration.rs`
  - many more

## Orchestration model

Pure Rust, `#[tokio::test]`. **No bash, no docker.** Roles spun up in-process via library calls:

- `start_pool()`, `start_jdc()`, `start_sv2_translator()`
- `start_template_provider()` — switches between standalone `sv2-tp` binary and Bitcoin Core IPC
- `start_minerd()` — real CPU miner subprocess
- `start_bitcoin_core()` — Bitcoin Core via `corepc-node`
- `start_sniffer()` — MITM proxy

`shutdown_all!` macro joins all handles in parallel.

## Port allocation

`UNIQUE_PORTS: OnceCell<Mutex<HashSet<u16>>>` allows parallel test execution without collisions.

## Bitcoin / TP modes

Two `TemplateProviderType` modes:
- **Standalone `sv2-tp` binary** — Bitcoin Core fork at v1.1.0, downloaded from GitHub release on first run, cached under `template-provider/`.
- **Bitcoin Core v31.0 native IPC** — via `corepc-node` crate with feature `28_0`.

`DifficultyLevel::{Low,Mid,High}` switches between regtest, fresh signet, and pre-mined high-diff signet (the 13MB `resources/high_diff_chain.tar.gz` fixture).

`-maxtipage` set to 100 years to prevent IBD freeze on static fixtures.

## Sniffer / Interceptor pattern (the killer feature)

`lib/sniffer.rs` (17KB), `lib/interceptor.rs`, `lib/sv1_sniffer.rs`:
- MITM proxy between any two roles
- Decrypts the noise handshake (with hardcoded test keypair)
- Records every Sv2 frame in a `MessagesAggregator`
- `wait_for_message_type(direction, msg_type)` — assert protocol behavior
- `IgnoreMessage` interceptor drops specific messages mid-stream — used to force fallback paths (e.g., `jdc_propagates_block_with_bitcoin_core_ipc` blocks `PushSolution` to ensure IPC path)

## Mock roles

`lib/mock_roles.rs`: `MockDownstream` / `MockUpstream` send arbitrary `AnyMessage` and assert protocol behavior without spinning a real role. Used for unit-style protocol tests.

## End-to-end share submission

`start_minerd` (lib/sv1_minerd/process.rs, 22KB) is a real CPU miner subprocess wrapper. Path: minerd → translator → pool → TP → bitcoind. Hash assertions via `prometheus_metrics_assertions.rs` (15KB) on Prometheus counters (`shares_accepted_total`, etc.).

## What's reusable directly

1. `corepc-node` + `sv2-tp` binary-download pattern (`lib/template_provider.rs`)
2. `UNIQUE_PORTS` allocator (`lib/utils.rs`)
3. `Sniffer` + `Interceptor` + `MessagesAggregator` (entire MITM stack)
4. `MockDownstream` / `MockUpstream` for unit-style protocol assertions
5. `start_minerd` + `sv1_minerd::MinerdProcess` for real share submission
6. `shutdown_all!` macro
7. `prometheus_metrics_assertions.rs` pattern for share-counter deltas
8. `DifficultyLevel` enum + `high_diff_chain` fixture

## What's MISSING (sv2-p2pool gap-fill)

1. **No reorg testing.** No tests force reorgs and assert share/block re-organization.
2. **No mempool manipulation.** No conflict-tx seeding, fee-rate spike tests.
3. **No multi-pool-node + shared-bitcoind tests.** Single pool, single TP only.
4. **No "fork the share-chain" / consensus-divergence tests.** Required for a P2P pool.
5. **No share-accounting end-to-end assertions across PPLNS payout.**
6. **No docker-compose harness for human demo.**

## Recommendation

sv2-p2pool's harness should depend on `sv2-integration-tests` (the published version of this crate) for the bitcoind + sv2-tp + sniffer plumbing, then add (a) p2pool node spawner, (b) reorg helpers (per `bdk_testenv`), (c) multi-node swarm with real bitcoind, (d) PPLNS payout assertions on top.

This is **NOT** "build from scratch." Most of the work is composing existing crates and filling six identified gaps.
