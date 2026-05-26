---
title: "p2poolv2_tests — what p2poolv2 itself ships"
source_url: https://github.com/p2poolv2/p2poolv2/tree/main/p2poolv2_tests
type: repo
ingested: 2026-05-26
quality: 3
confidence: medium
tags: [test-harness, p2poolv2, mockall, libp2p-swarm, baseline]
---

# `p2poolv2_tests` — what p2poolv2 itself ships

p2poolv2's own test crate. Functional but narrower scope than sv2-apps. Useful as the **baseline that sv2-p2pool's harness must exceed.**

## Layout

- `src/node_swarm_test.rs` (18KB) — multi-node libp2p swarm
- `src/stratum_server_test.rs` (5.6KB) — V1 stratum server
- `src/test_api_server_health_check.rs` (17KB) — HTTP API
- `src/common/mod.rs` — `default_test_config()` helper
- `test_data/` — fixtures (e.g., `test_data/gbt/signet/gbt-no-transactions.json` GBT fixture)

## Orchestration

Pure Rust, `tokio-test`, `mockall`, `test-log`. Run with `just test`. No docker / bash.

## Bitcoin handling: mocked, not spawned

- Most tests use `mockall` to stub `BitcoindRpcClient`.
- `setup_mock_bitcoin_rpc()` returns canned `getblocktemplate` JSON.
- **Does NOT spin a real bitcoind in `cargo test`.**
- Real bitcoind is via `docker/docker-compose.yml` + `docker/bitcoin-signet.conf` for **manual** e2e — not CI-integrated.

## Multi-node coverage (interesting bit)

`node_swarm_test.rs::test_three_nodes_share_sync`:
- Spins up 3 in-process `NodeHandle::new()` instances on different ports
- Pre-seeds node 1 with 5 share-blocks from a fixture
- Dials nodes 2/3 in
- Polls until headers + share blocks sync via libp2p
- Confirms identical chains
- **No reorg test.**

## Share submission coverage

`stratum_server_test.rs` only tests subscribe handshake — **not full share lifecycle.**

## Load tests

Separate `load-tests/jmeter-testing/` (JMeter) and `load-tests/diagnosis/` — perf, not CI integration.

## Implications for sv2-p2pool harness

- p2poolv2's own tests don't exercise real bitcoind in CI — sv2-p2pool's harness will be the first to do this end-to-end.
- The libp2p-swarm-with-3-nodes pattern is reusable for testing share-chain gossip with real BTC.
- The `mockall::BitcoindLike` pattern (now landed via #6 PR) is what makes p2poolv2's mocked tests possible — sv2-p2pool can mock at the same layer for unit tests, and switch to real `corepc-node::Node` for integration tests.

## Bottom line

p2poolv2's harness is fine for unit-level coverage but does NOT validate the integration surface that sv2-p2pool actually cares about (bitcoind ↔ p2poolv2 ↔ sv2 ↔ jd-client). sv2-p2pool's harness fills that gap.
