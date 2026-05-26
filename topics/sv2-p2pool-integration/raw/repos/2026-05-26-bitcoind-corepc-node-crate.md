---
title: "bitcoind / corepc-node — Rust harness primitive for bitcoind regtest"
source_url: https://github.com/rust-bitcoin/corepc, https://docs.rs/bitcoind/, https://docs.rs/corepc-node/
type: repo
ingested: 2026-05-26
quality: 5
confidence: high
tags: [test-harness, regtest, bitcoind, rust, primitive]
---

# `bitcoind` / `corepc-node` — Rust harness primitive

The de-facto Rust pattern for spinning bitcoind in tests. Originally `bitcoind` (RCasatta), now under the rust-bitcoin org as `corepc-node`. Confirmed by 4 of 5 research agents as the foundation.

## API shape

```rust
use corepc_node::Node;
let bitcoind = Node::from_downloaded()?;        // or ::new(path)
let client: &bitcoincore_rpc::Client = &bitcoind.client;
let info = client.get_blockchain_info()?;
// Drop = SIGKILL + tmpdir cleanup
```

## Three-tier binary discovery

1. **Auto-download (feature-gated)**: `corepc-node = { version = "...", features = ["28_0"] }` — downloads + hash-verifies a Core binary keyed to the version.
2. **`BITCOIND_EXE` env override**: skips download, uses the path.
3. **System PATH**: fallback.

`ELECTRSD_SKIP_DOWNLOAD` env knob also recognized for Nix-like environments.

## What it gets right

- **OS-assigned free ports** with 3-attempt retry — solves parallel-CI port collisions out of the box.
- **`Drop` = SIGKILL + tempdir cleanup** — no leaks across panicking tests.
- **RAM-disk tmpdir support** — fast.
- **Typed RPC** via `bitcoincore_rpc::Client` (or `corepc-types` v17+ schemas).
- **`Conf` struct** for arg overrides.

## Runtime cost

- Cold start: 500ms-1.5s with `_initialize_chain_clean`; 2-3s with the 199-block premine cache.
- 4-8 parallel instances per GitHub Actions runner is routine.

## Composition pattern (key for sv2-p2pool)

`electrsd` builds on top by accepting a `&BitcoinD` reference:
```rust
let bitcoind = BitcoinD::new(...)?;
let electrsd = ElectrsD::new(electrs_path, &bitcoind)?;
```

Same pattern transfers directly to sv2-p2pool:
```rust
let bitcoind = BitcoinD::new(...)?;
let p2poolv2 = P2poolV2D::new(p2pool_path, &bitcoind)?;
let pool = Sv2P2poolD::new(pool_path, &bitcoind, &p2poolv2)?;
let jdc = JdClientD::new(jdc_path, &pool)?;
```

## Sister crates worth knowing

- `corepc-types` — typed JSON-RPC response schemas for Core v17+. Replaces hand-rolled types.
- `electrsd` — electrs spawner; same crate family.
- `bdk_testenv` — BDK's workspace-internal harness, wraps `electrsd`, adds `mine_blocks`/`reorg`/`invalidate_blocks`/`wait_until_*`.

## Why this is the right primitive

No mature **in-process** bitcoind embedding crate exists. bitcoind is C++ with global state; not designed to be a library. Process-spawn is the only viable path, and `corepc-node` already solves the 90% of plumbing (port alloc, drop cleanup, version pinning, typed RPC) that you'd otherwise reinvent.
