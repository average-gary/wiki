---
title: "bdk_testenv — workspace-internal shared test-harness crate"
source_url: https://github.com/bitcoindevkit/bdk/tree/master/crates/testenv
type: repo
ingested: 2026-05-26
quality: 4
confidence: high
tags: [test-harness, regtest, bdk, shared-library, workspace-crate]
---

# `bdk_testenv` — workspace-internal shared test-harness crate

The architectural answer to "shared harness library vs. duplicated plumbing across crates." BDK ships a workspace-internal crate at `crates/testenv/` that every other BDK crate (`bitcoind_rpc`, `electrum`, `esplora`) depends on for tests.

## Shape

`TestEnv { bitcoind, electrs }` with a high-level vocabulary tailored to BDK's testing needs:

- `mine_blocks(n)` / `mine_empty_block()`
- `reorg(n)` / `reorg_empty_blocks(n)`
- `invalidate_blocks(n)`
- `send(addr, amount)`
- `wait_until_electrum_sees_block(hash)`
- `wait_until_electrum_sees_txid(txid)`
- `make_checkpoint_tip()`

Wraps `electrsd` underneath but exposes its own opinionated API.

## Why this is the right pattern

- **No duplication** across the 3+ test-needing crates in the BDK workspace.
- **Vocabulary layer** above the raw process spawner — tests read like specifications.
- **Reorg-aware** — directly supports the chain-reorg patterns BDK needs to test.

## Direct application to sv2-p2pool

Build a workspace crate `crates/sv2-p2pool-testenv/` that wraps `corepc-node::Node` + adds spawners for `p2poolv2`, `sv2-p2pool-pool`, `jd-client`. Expose sv2-specific `wait_until_*` helpers:

- `wait_until_pool_sees_share(share_hash)`
- `wait_until_share_chain_tip(hash)`
- `wait_until_jdc_token_allocated(token)`
- `wait_until_block_credited_to(miner_script)`

Every integration test in the workspace depends on `sv2-p2pool-testenv`. No per-test plumbing.

## Reorg primitives — the differentiator

BDK's `reorg(n)` and `invalidate_blocks(n)` are exactly what sv2-p2pool needs to validate `reorg_detector` + `notify_share_chain_reorg` paths end-to-end. The existing sv2-apps `integration-tests/` does NOT have reorg primitives (per parallel research). Building these into testenv fills a real gap in the SV2 ecosystem.
