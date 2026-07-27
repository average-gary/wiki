---
title: "Fedimint devimint — regtest test harness reference"
source: https://github.com/fedimint/fedimint/tree/master/devimint
type: repos
ingested: 2026-05-26
quality: 5
confidence: high
tags: [test-harness, regtest, fedimint, devimint, bitcoin, multi-process]
---

# Fedimint `devimint` — regtest test harness reference

A published Rust crate (crates.io v0.11.1, MIT, 55 versions) that orchestrates `bitcoind` + lightning daemons + `fedimintd` for end-to-end testing. The closest architectural analog for what sv2-p2pool needs.

## Architectural shape

**Library + thin CLI binary** (`devimint/src/main.rs` is a clap shim; everything lives in `lib.rs` and friends).

Module layout:
- `cli` — clap subcommands
- `devfed` — full-stack composer
- `external` — wrappers around bitcoind, LND, etc.
- `federation` — fedimint-specific
- `gatewayd` — lightning gateway
- `process_reaper` — two-phase shutdown
- `util` — `ProcessManager`, `ProcessHandle`, `spawn_daemon`
- `vars` — `declare_vars!` macro for env-file output

CLI subcommands:
- `external-daemons` — just bitcoind + esplora
- `dev-fed` — full stack (bitcoind, LND, LDK gateway, faucet, esplora, federation)
- `rpc wait` — poll readiness file
- `rpc env` — export env vars

## Test interface: file-based, not RPC

Devimint does NOT expose an RPC server to tests. Instead it writes:
- `$FM_TEST_DIR/env` — env vars for tests to source
- `$FM_TEST_DIR/ready` — `READY` or `ERROR`
- `$FM_TEST_DIR/invite-code` — federation-specific handoff

Tests `source` the env file, then drive scenarios via per-service CLI binaries (`FM_MINT_CLIENT`, `FM_GWCLI_LND`, `bitcoin-cli`, `lncli`). Shell-friendly, language-agnostic.

For Rust callers: top-level `run_devfed_test()` is a `#[bon::builder]` async function:
```rust
run_devfed_test()
    .build()
    .run(async |dev_fed| {
        // test scenario here
    })
    .await
```

## Two-phase process reaping

`process_reaper.rs` is the trickiest part. SIGTERM → 250ms grace → SIGKILL → `waitpid`, all on a **dedicated OS thread** (not a tokio task) so:
- `Drop` impls stay synchronous
- tokio runtime isn't polluted during teardown
- avoids debug assertions in QUIC-using deps from unflushed close frames

`spawn_daemon()` opens `{logs_dir}/{name}.log` and dups stdout+stderr into it; `kill_on_drop(false)` so the reaper owns lifecycle.

## Bitcoind wrapper specifics

`devimint/src/external.rs` `Bitcoind { client, wallet_client: JitTryAnyhow, _process }`:
- Writes `bitcoin.conf` with port-allocator-assigned ports
- Spawns via `ProcessManager::spawn_daemon()`
- Probes RPC with 45s timeout (slow CI tolerated)
- `mine_blocks(n)` chunks at 32 to dodge stdout pipe-buffer overflow (real-world bug)
- 101-block coinbase-maturity bootstrap
- Wallet client lazily initialized via `JitTryAnyhow`

LND wrapper polls for TLS cert + macaroon files before constructing the tonic gRPC client (file-existence as readiness probe).

## Port allocation

`fedimint-portalloc` is its own published crate. Some daemons get fixed offsets when `gateway_base_port` is set (deterministic for debugging); most use dynamic allocation.

## Directory layout

`$FM_TEST_DIR/`:
- `logs/` — per-process log files
- `bitcoin/` `lnd/` `ldk/` `esplora/` — per-service datadirs
- `clients/default-0/` — per-client state
- `fedimintd-{name}-{id}/`

## JIT-lazy stack

`DevJitFed` uses `JitTry`/`JitTryAnyhow` lazy futures:
```rust
DevJitFed { bitcoind: JitTry<Bitcoind>, lnd: JitTry<Lnd>, ... }
```
`bitcoind` only spawns when `.get_try().await` is called. Tests that only need bitcoind don't pay the LND/fedimintd startup cost. `finalize()` forces full materialization; `to_dev_fed()` collapses to eager `DevFed`.

## Lessons for sv2-p2pool

1. **Build as a published crates.io library + thin clap binary.** Don't make it private to one repo.
2. **File-based test handoff** (`env`, `ready`) keeps it language-agnostic.
3. **Two-phase reaper on a dedicated OS thread** — don't try to do this in tokio.
4. **Port allocator as a separate published crate** if you might want to share it.
5. **JIT-lazy stack** so tests pay only for what they use.
6. **`declare_vars!` macro** is worth porting for env-file generation.
7. **Per-process log files in `$LOG_DIR`**, not real-time multiplexing — simpler and robust.
8. **Skip Iroh/QUIC complexity** — devimint deals with it because of fedimint internals; sv2-p2pool doesn't need it.
