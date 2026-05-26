---
title: "Regtest test harness design for sv2-p2pool"
type: topic
created: 2026-05-26
updated: 2026-05-26
confidence: high
status: draft
sources:
  - "[[raw/repos/2026-05-26-fedimint-devimint|Fedimint devimint]]"
  - "[[raw/repos/2026-05-26-bitcoind-corepc-node-crate|corepc-node crate]]"
  - "[[raw/repos/2026-05-26-bdk-testenv|bdk_testenv]]"
  - "[[raw/repos/2026-05-26-ldk-node-tests-common|ldk-node tests/common]]"
  - "[[raw/repos/2026-05-26-bitcoin-core-test-framework|Bitcoin Core test_framework]]"
  - "[[raw/repos/2026-05-26-sv2-apps-integration-tests|sv2-apps integration-tests]]"
  - "[[raw/repos/2026-05-26-p2poolv2-tests|p2poolv2_tests]]"
  - "[[raw/articles/2026-05-26-process-compose-orchestrator|process-compose]]"
---

# Regtest test harness design for sv2-p2pool

Synthesis of 5 parallel research paths (Fedimint devimint, LN/Bitcoin app harnesses, Bitcoin Core test_framework, Rust multi-service patterns, existing SV2/mining harnesses). Direct input to Phase 1.8 of [[../../output/plan-phase-1-wiring-2026-05-26|the Phase 1 wiring plan]].

## TL;DR

Build a workspace-internal crate **`crates/sv2-p2pool-testenv`** that:
1. **Wraps `corepc-node::Node`** for bitcoind regtest spawn (drop-in primitive — solves 90% of plumbing).
2. **Mirrors `bdk_testenv`'s `TestEnv` shape** (vocabulary like `mine_blocks`/`reorg`/`wait_until_*`).
3. **Composes services like `electrsd`** does on top of `bitcoind` — `P2poolV2D::new(&bitcoind)`, `Sv2P2poolD::new(&bitcoind, &p2poolv2)`, `JdClientD::new(&pool)`.
4. **Reuses sv2-apps's `integration-tests` plumbing** for sniffer / interceptor / mock-roles / minerd — vendored, already tested.
5. **Adds devimint-style two-phase process reaping** on a dedicated OS thread.
6. **Adds dump-on-fail logging** (the gap none of the surveyed harnesses fill).

Skip: testcontainers-rs (custom-image friction), pure-bash drivers (Lampo-style), porting Bitcoin Core's Python test_framework.

Use **`process-compose` separately** for the human-facing `just dev` loop — same binaries as `cargo test`, no double maintenance.

## Architecture

```
┌────────────────────────────────────────────────────────────────┐
│ crates/sv2-p2pool-testenv (workspace crate)                    │
│                                                                │
│  pub struct TestEnv {                                          │
│      bitcoind: corepc_node::Node,                              │
│      p2pool: P2poolV2D,                                        │
│      pool: Sv2P2poolD,                                         │
│      jdc: JdClientD,                                           │
│      sniffer: Option<Sniffer>,        // reused from sv2-apps  │
│      logs_dir: PathBuf,                                        │
│      _reaper: ProcessReaperGuard,     // devimint-style        │
│  }                                                             │
│                                                                │
│  impl TestEnv {                                                │
│      pub fn builder() -> TestEnvBuilder { ... }                │
│                                                                │
│      // bitcoind controls (mirrors bdk_testenv)                │
│      pub fn mine_blocks(&self, n: usize)                       │
│      pub fn mine_to(&self, addr: &Address, n: usize)           │
│      pub fn reorg(&self, depth: usize)                         │
│      pub fn invalidate_block(&self, hash: BlockHash)           │
│      pub fn split_network(&self, a: &[NodeId], b: &[NodeId])   │
│      pub fn join_network(&self)                                │
│                                                                │
│      // sv2-p2pool-specific waits                              │
│      pub async fn wait_until_pool_sees_share(&self, h: ...)    │
│      pub async fn wait_until_share_chain_tip(&self, h: ...)    │
│      pub async fn wait_until_jdc_token_allocated(&self, t: ...)│
│      pub async fn wait_until_block_credited_to(&self, s: ...)  │
│                                                                │
│      // logs                                                   │
│      pub fn dump_logs_on_fail(&self) {                         │
│          // flush per-service ring buffers to                  │
│          // target/test-logs/<test_name>/<service>.log         │
│      }                                                         │
│  }                                                             │
│                                                                │
│  impl Drop for TestEnv {                                       │
│      fn drop(&mut self) {                                      │
│          if std::thread::panicking() {                         │
│              self.dump_logs_on_fail();                         │
│          }                                                     │
│          // process_reaper handles SIGTERM→SIGKILL cleanup     │
│      }                                                         │
│  }                                                             │
└────────────────────────────────────────────────────────────────┘
```

## Key design choices

### 1. `corepc-node` as the bitcoind primitive

Confirmed by **4 of 5 research agents** as the foundation. Three-tier discovery (auto-download, `BITCOIND_EXE` env var, system PATH); OS-assigned free ports with retry; Drop = SIGKILL + tempdir cleanup; RAM-disk tmpdirs; `bitcoincore_rpc::Client` typed RPC. See [[../concepts/corepc-node-pattern]] (TBD — write if needed) or the raw note at [[raw/repos/2026-05-26-bitcoind-corepc-node-crate]].

### 2. Composition pattern from `electrsd`

```rust
let bitcoind = Node::from_downloaded()?;
let p2pool = P2poolV2D::new(p2pool_path, &bitcoind)?;
let pool = Sv2P2poolD::new(pool_path, &bitcoind, &p2pool)?;
let jdc = JdClientD::new(jdc_path, &pool)?;
```

Each daemon takes `&` references to its dependencies. Type system ensures correct startup order. Drop reverse-orders teardown automatically.

### 3. `bdk_testenv`-style vocabulary layer

Tests should read like specifications:

```rust
let env = TestEnv::builder().build().await?;
env.mine_blocks(101);  // mature coinbase
env.fund_miner_address(&miner_script, sats(1_000_000)).await?;
env.start_minerd(&miner_script).await?;
env.wait_until_pool_sees_share().await?;

// Now force a reorg
let tip_before = env.bitcoind.client.get_best_block_hash()?;
env.invalidate_block(tip_before)?;
env.mine_blocks(2);
env.wait_until_share_chain_tip(/* new tip */).await?;
```

Reorg primitives are the **gap none of the existing SV2 harnesses fill** (per the [[raw/repos/2026-05-26-sv2-apps-integration-tests|sv2-apps integration-tests review]]).

### 4. Reuse, don't duplicate

`vendor/sv2-apps/integration-tests/lib/` already has battle-tested:
- `Sniffer` / `Interceptor` / `MessagesAggregator` (MITM proxy, decrypts noise, asserts SV2 frames)
- `MockDownstream` / `MockUpstream`
- `start_minerd` (CPU miner subprocess)
- `prometheus_metrics_assertions`
- `UNIQUE_PORTS` allocator
- `shutdown_all!` macro
- `DifficultyLevel` enum + `high_diff_chain` fixture

Import these via path-dep on the vendored sv2-apps integration-tests crate. No re-implementation.

### 5. Devimint two-phase process reaping

The trickiest part of any multi-process harness. Steal the design from [[raw/repos/2026-05-26-fedimint-devimint|devimint's `process_reaper.rs`]]:

- SIGTERM → 250ms grace → SIGKILL → `waitpid()`
- Runs on a **dedicated OS thread** (not a tokio task)
- `Drop` impls stay synchronous, runtime not polluted during teardown
- `kill_on_drop(false)` on `tokio::process::Command` — reaper owns lifecycle, not Drop

License compatibility: devimint is MIT, we're AGPL. Can copy-with-attribution.

### 6. Dump-on-fail logging (the differentiator)

None of the surveyed harnesses do this well — flagged as a gap by 2 of 5 agents:

- Each service writes to `tempdir/{name}.log` (devimint pattern)
- Wrap in a `TestGuard` whose `Drop` impl checks `std::thread::panicking()` — if true, copy the log files to `target/test-logs/<test_name>/<service>.log`
- Aggregator prefixes lines by service name
- Most-recent-N-lines printed inline on failure for fast feedback

Without this, debugging a 4-process failure means tailing 4 log files manually. With it, the failure dump tells you exactly what happened.

### 7. Skip testcontainers-rs

Custom-image friction outweighs the benefit at our scale (4 services). p2poolv2 has no published Docker image; we'd need to maintain Dockerfiles for every dep. `corepc-node`-style native-process spawn doesn't have this problem.

### 8. `process-compose` for `just dev`

Separate from `cargo test`. Same binaries via env-var paths. YAML-driven; TUI for visual debugging; hot-reload friendly. See [[raw/articles/2026-05-26-process-compose-orchestrator]].

## File layout

```
crates/sv2-p2pool-testenv/
├── Cargo.toml
├── src/
│   ├── lib.rs                  # TestEnv, TestEnvBuilder, public API
│   ├── bitcoind.rs             # thin wrapper over corepc-node::Node
│   ├── p2poolv2d.rs            # spawns p2poolv2_node binary
│   ├── sv2_p2poold.rs          # spawns sv2-p2pool-pool binary
│   ├── jdcd.rs                 # spawns jd-client binary
│   ├── reaper.rs               # devimint-style two-phase reaper
│   ├── ports.rs                # port allocator (or use existing UNIQUE_PORTS)
│   ├── waits.rs                # async wait_until_* helpers
│   ├── reorg.rs                # split_network/join_network/invalidate_block
│   └── log_guard.rs            # dump-on-fail TestGuard
└── tests/                      # tests of the harness itself

integration-tests/
├── tests/
│   ├── e2e_regtest.rs          # the Phase 1.8 acceptance test
│   ├── reorg_invalidates_jobs.rs
│   ├── push_solution_race.rs
│   └── share_chain_gossip.rs
```

## What this resolves for the Phase 1 plan

[[../../output/plan-phase-1-wiring-2026-05-26|Phase 1 plan §1.8]] called for "regtest harness + E2E test" but didn't specify the harness pattern. This article fills that:

| Phase 1 plan §1.8 task | Harness design answer |
|---|---|
| Spawn bitcoind regtest | `corepc-node::Node::from_downloaded()` |
| Spawn p2poolv2 node | `P2poolV2D::new(path, &bitcoind)` |
| Spawn sv2-p2pool-pool | `Sv2P2poolD::new(path, &bitcoind, &p2poolv2)` |
| Spawn jd-client | `JdClientD::new(path, &pool)` |
| `bitcoin-cli generatetoaddress 101` | `env.mine_blocks(101)` |
| Force regtest reorg | `env.invalidate_block(tip)` + `env.mine_blocks(2)` |
| Verify share appears in p2pool accounting | `env.wait_until_pool_sees_share(h)` |
| Confirm cached `declared_jobs` invalidates | `env.wait_until_token_revoked(t)` |

## Effort estimate

Replaces Phase 1.8's "1-2 days" with a more honest:
- Initial `TestEnv` skeleton: 1 day
- Per-service spawners (4 services × 0.5 day): 2 days
- Reorg + multi-node helpers: 1 day
- Dump-on-fail + log aggregation: 0.5 day
- Acceptance test wiring: 0.5 day

Total: **~5 days**. Worth it because every subsequent integration test depends on this crate.

## See also

- [[../../output/plan-phase-1-wiring-2026-05-26|Phase 1 wiring plan]] — consumer of this design
- [[../../output/plan-sv2-p2pool-repo-2026-05-22|repo spec]] §6 — original testing strategy (signet smoke); user has since chosen regtest
- [[../decisions/open-questions]] — Phase 1.0 spike on whether p2poolv2 supports regtest as a network
