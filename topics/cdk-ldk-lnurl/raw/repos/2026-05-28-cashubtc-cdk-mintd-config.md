---
title: "cashubtc/cdk — `cdk-mintd` config + setup wiring"
type: repo
source: https://github.com/cashubtc/cdk/tree/main/crates/cdk-mintd
fetched: 2026-05-28
confidence: high
tags: [cdk-mintd, config, deployment, feature-flags]
summary: The cdk-mintd binary's TOML config schema, feature-flag matrix, and lightning-backend selection wiring. Operator-grade reference.
---

# `cdk-mintd` — operator config surface

Source files:
- `crates/cdk-mintd/example.config.toml`
- `crates/cdk-mintd/src/setup.rs`
- `crates/cdk-mintd/src/config.rs`
- `crates/cdk-mintd/Cargo.toml`

## Backend selection

```toml
[ln]
ln_backend = "ldknode"   # also accepts "ldk-node", "cln", "lnd", "lnbits", "fakewallet", "grpc-processor"
```

`LnBackend::LdkNode` is gated on `#[cfg(feature = "ldk-node")]`. Env var equivalent: `CDK_MINTD_LN_BACKEND="ldk-node"`.

## Feature matrix

`cdk-mintd` `Cargo.toml` defaults: `["management-rpc", "cln", "lnd", "lnbits", "fakewallet", "grpc-processor", "sqlite", "info-page", "bdk"]`.

`ldk-node` is **not default** — must build with `--features ldk-node` or `cargo install cdk-mintd --features ldk-node`. Official release artifacts include both `cdk-mintd-<ver>` (no LDK) and `cdk-mintd-ldk-<ver>` (with LDK), starting v0.13.0 / v0.15.0.

Other feature flags: `postgres`, `sqlcipher`, `redis`, `prometheus`, `info-page`. `bdk` pulls `cdk-bdk/bitcoin-rpc` and `cdk-bdk/esplora`.

## `[ldk_node]` config keys (config.rs::LdkNode)

| Key | Default | Notes |
|---|---|---|
| `bitcoin_network` | (required) | `mainnet`, `testnet`, `signet`, `regtest` |
| `chain_source_type` | (required) | `esplora` or `bitcoinrpc` |
| `esplora_url` | — | e.g. `https://mutinynet.com/api` |
| `bitcoind_rpc_host` / `_port` / `_user` / `_password` | — | for `bitcoinrpc` source |
| `gossip_source_type` | (required) | `p2p` or `rgs` |
| `rgs_url` | — | e.g. `https://rgs.mutinynet.com/snapshot/0` |
| `storage_dir_path` | (required) | LDK Node persistence root |
| `log_dir_path` | — | filesystem logger path |
| `webserver_host` | — | admin UI bind, **must be 127.0.0.1** |
| `webserver_port` | 8091 | admin UI |
| `ldk_node_host` | — | P2P listen host |
| `ldk_node_port` | — | P2P listen port |
| `ldk_node_announce_addresses` | — | comma list |
| `ldk_node_mnemonic` | — | BIP-39, Debug-redacted; required for new node, optional after first start |
| `fee_percent` | 0.02 | mint surcharge over LN routing fee |
| `reserve_fee_min` | — | minimum fee floor in msat |

Env-var equivalents: `CDK_MINTD_LDK_NODE_*` prefix.

## Adjacent surfaces

- `[mint_management_rpc]` — separate gRPC admin (default port 8086) provided by `cdk-mint-rpc` crate
- `[info]` page — public mint metadata (`info-page` feature)
- `[mint_management_rpc]`, `[grpc_processor]`, `[prometheus]` — opt-in features

## Setup wiring

`LnBackendSetup for config::LdkNode` in `setup.rs:337` maps TOML → `cdk_ldk_node::CdkLdkNodeBuilder`. Requires `ldk_node_mnemonic` for first run; subsequent runs reuse on-disk seed.

## Why ingest

Reference for any deployment writeup. Tells the operator exactly which knobs to set, which feature-flag combinations exist, and what the binary does on startup.
