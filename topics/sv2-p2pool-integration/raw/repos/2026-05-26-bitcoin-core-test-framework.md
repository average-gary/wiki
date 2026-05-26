---
title: "Bitcoin Core test_framework — canonical regtest test patterns"
source_url: https://github.com/bitcoin/bitcoin/tree/master/test/functional/test_framework
type: repo
ingested: 2026-05-26
quality: 5
confidence: high
tags: [test-harness, regtest, bitcoin-core, test-framework, reorg-primitives]
---

# Bitcoin Core `test_framework/` — canonical regtest test patterns

Python harness used by Bitcoin Core itself. Defines the de-facto vocabulary every Bitcoin testing harness mimics: `generate_blocks`, `connect_nodes`, `split_network`, `sync_blocks`, `mine_to_address`.

## Module layout

- `test_framework.py` — orchestrator
- `test_node.py` — per-process lifecycle
- `authproxy.py` — JSON-RPC binding
- `p2p.py`, `messages.py` — raw P2P protocol
- `blocktools.py` — block construction helpers
- `wallet.py` — minimal test wallet
- `mempool_util.py` — mempool inspection
- `script.py`, `psbt.py`, `key.py`, `address.py` — script + crypto helpers
- `coverage.py` — coverage harness
- `test_shell.py` — interactive REPL-style debugging

## Multi-node topology

Default: linear chain `node0 ← node1 ← node2 ← node3` via `add_nodes(num_nodes)` + `connect_nodes()`.

Two init strategies:
- **199-block cached chain** with deterministic premined coins, copied to each datadir (massive speedup)
- `_initialize_chain_clean()` — empty chain

## Reorg primitives (the high-leverage part)

- `split_network()` — disconnects nodes into two groups
- Mine divergent chains in each group
- `join_network()` — reconnects, observes consensus

This is exactly the primitive sv2-p2pool needs to test `reorg_detector` + `notify_share_chain_reorg` end-to-end. The Rust ecosystem mostly lacks this; `bdk_testenv` has `reorg(n)` and `invalidate_blocks(n)` which are simpler analogs.

## Port allocation

- `p2p_port(n)` / `rpc_port(n)` / `tor_port(n)` — deterministic per-node port assignment.
- Avoids races in CI parallel runs.

## Helper vocabulary (worth porting names + semantics)

- `dumb_sync_blocks()` — wait for blocks to propagate
- `sync_txindex()` — wait for txindex
- `mine_large_block()`
- `find_vout_for_address()`
- `create_lots_of_big_transactions()`
- Assertions: `assert_equal`, `assert_raises_rpc_error`

## Mock time

Injects controlled time via `setmocktime` RPC to keep blocks from drifting under regtest.

## Recommendation for sv2-p2pool

**Don't port to Rust.** Two reasons:
1. Wrong language for a Rust-native project.
2. `corepc-node` + `bdk_testenv` already have most of `test_framework`'s functionality at the right layer of abstraction.

**Do steal the vocabulary**: `connect_nodes`, `split_network`, `join_network`, `sync_blocks`, `mine_to_address` should be the names of the Rust helpers in `sv2-p2pool-testenv`.
