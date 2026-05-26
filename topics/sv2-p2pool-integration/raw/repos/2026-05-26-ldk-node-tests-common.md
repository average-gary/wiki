---
title: "ldk-node tests/common — hybrid Rust + docker-compose harness"
source_url: https://github.com/lightningdevkit/ldk-node/tree/main/tests
type: repo
ingested: 2026-05-26
quality: 5
confidence: high
tags: [test-harness, regtest, ldk-node, hybrid, docker-compose]
---

# ldk-node `tests/common/` — hybrid Rust + docker-compose harness

The closest analog to sv2-p2pool's situation: multiple long-running services (bitcoind, electrs, ldk-node, plus 3 different LN impls) needing end-to-end coordination.

## Pattern

**Hybrid: Rust spawns the manageable services; docker-compose handles the fussy ones.**

- `tests/common/` (Rust) spawns `bitcoind` + `electrs` via `electrsd` crate.
- Per-LN-impl modules: `cln.rs`, `eclair.rs`, `lnd.rs`, `external_node.rs`.
- `tests/docker/`: `docker-compose-{cln,eclair,lnd}.yml`, `Dockerfile.eclair`. Run independently of `cargo test`; tests connect to the docker-compose-managed services via env-configured RPC.
- `external_node.rs` — **attach mode**: connect to an already-running service via env vars, without spawning. Useful for debugging.

## Test isolation

- `static NEXT_PORT: AtomicU16 = AtomicU16::new(20000)` for deterministic port allocation.
- Random temp datadirs.

## Cross-service synchronization

- `generate_blocks_and_wait(bitcoind, electrs, n)` — mines AND waits for electrs to see the new tip. Avoids the "wrote a block but the next service hasn't seen it yet" race.
- `premine_and_distribute_funds()` — funding bootstrap.
- `expect_event!` / `expect_channel_pending_event!` macros — assert LDK-side state after a chain action.

## Logging

- `MockLogFacadeLogger` captures into in-memory `Vec` per-node.
- `MultiNodeLogger` prints to stdout for multi-node runs.
- **Does NOT dump-on-fail automatically** — gap that sv2-p2pool can fill.

## Lessons for sv2-p2pool

1. **Three modes is the right number**: spawn-mode (Rust), docker-mode (compose), attach-mode (env vars).
2. **Per-LN-impl** modules → for sv2-p2pool, **per-role** modules (`p2poolv2.rs`, `sv2_pool.rs`, `jdc.rs`, `bitcoind.rs`).
3. **`generate_blocks_and_wait` cross-service sync** is essential — never assert on chain state without waiting for downstream services to catch up.
4. **Custom `expect_*` macros** make tests readable.
5. **Fix what they didn't**: dump-on-fail logging via a `TestGuard` `Drop` impl that flushes ring buffers to `target/test-logs/<test_name>/<service>.log`. This is the differentiator for a 4-process stack.
