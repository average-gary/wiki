---
title: "lightningdevkit/ldk-node — Builder & Config API (v0.7.0)"
type: repo
source: https://docs.rs/ldk-node/0.7.0/ldk_node/struct.Builder.html
fetched: 2026-05-28
confidence: high
tags: [ldk-node, config, persistence, vss, lsp, gossip]
summary: Authoritative enumeration of LDK Node v0.7 Builder methods and Config defaults. Settles persistence (SQLite default, fs/VSS optional), chain sources (Esplora/Electrum/Bitcoin Core RPC+REST), gossip (P2P/RGS), and LSP (LSPS1/LSPS2 client and service) options.
---

# LDK Node Builder & Config — v0.7.0

`ldk_node::Builder` is the entry point. CDK's `cdk-ldk-node` configures a subset of these knobs from `[ldk_node]` TOML.

## Chain sources (4 variants)

| Method | Use |
|---|---|
| `set_chain_source_esplora(url, Option<EsploraSyncConfig>)` | Public/private Esplora HTTP endpoint |
| `set_chain_source_esplora_with_headers(url, headers, sync_config)` | + custom HTTP headers (auth) |
| `set_chain_source_electrum(url, Option<ElectrumSyncConfig>)` | Electrum protocol over TCP/SSL |
| `set_chain_source_bitcoind_rpc(host, port, user, password)` | Direct Bitcoin Core JSON-RPC |
| `set_chain_source_bitcoind_rest(rest_host, rest_port, rpc_host, rpc_port, user, password)` | REST for bulk sync, RPC for broadcast — fastest cold sync |

CDK's `cdk-ldk-node` exposes only Esplora and bitcoind RPC variants. Electrum and the REST+RPC pair are reachable only via custom `cdk-ldk-node` builds.

## Gossip

- `set_gossip_source_p2p()` — full network gossip (default if unset)
- `set_gossip_source_rgs(url)` — Rapid Gossip Sync from a snapshot server. Default URL on `rapidsync.lightningdevkit.org` (path differs by network — `/testnet/v2/snapshot` etc.)
- `set_pathfinding_scores_source(url)` — merge external routing scores into local scoring

## Liquidity / LSP

- `set_liquidity_source_lsps1(node_id, address, Option<token>)` — buy a static channel (bLIP-51)
- `set_liquidity_source_lsps2(node_id, address, Option<token>)` — JIT inbound channels (bLIP-52). Note: open issue [#913](https://github.com/lightningdevkit/ldk-node/issues/913) — first HTLC can fail on small JIT channels due to default 1000-sat reserve eating capacity.
- `set_liquidity_provider_lsps2(LSPS2ServiceConfig)` — node can also **act as an LSP** (alpha)

LSPS1/LSPS2 LSPs are auto-marked as trusted-for-0-conf.

## Persistence (build-variant selector)

- `build()` → SQLite (default in v0.7+)
- `build_with_fs_store()` → KVStore on filesystem
- `build_with_vss_store(vss_url, store_id, lnurl_auth_server_url, fixed_headers)` (alpha) — **uses LNURL-auth (LUD-04) for VSS authentication**. This is an unexpected coupling: LDK Node's recommended cloud-backup path depends on LNURL.
- `build_with_vss_store_and_fixed_headers(...)` — non-LNURL header-based auth
- `build_with_vss_store_and_header_provider(..., Arc<dyn VssHeaderProvider>)` — custom dynamic auth headers
- `build_with_store(Arc<DynStore>)` — fully custom backend

Persistence note: open issue [#381](https://github.com/lightningdevkit/ldk-node/issues/381) — panic-on-persistence-failure still has unaddressed paths blocked on rust-lightning. Crash mid-state-update can stale ChannelMonitors.

## Entropy

- `set_entropy_seed_path(path)` (default: `keys_seed` file in storage dir)
- `set_entropy_seed_bytes([u8; 64])`
- `set_entropy_bip39_mnemonic(Mnemonic, Option<passphrase>)`

v0.7.0 introduced `NodeEntropy` type passed to `build(node_entropy)` — breaking change. CDK's `cdk-ldk-node` v0.16+ accepts `[ldk_node].ldk_node_mnemonic` (BIP-39).

## Networking

- `set_listening_addresses(Vec<SocketAddress>)` — default `None` (no inbound channels possible without setting this)
- `set_announcement_addresses(...)` — defaults to `listening_addresses`
- `set_node_alias(String)` — max 32 UTF-8 bytes
- `set_async_payments_role(Option<AsyncPaymentsRole>)` — BOLT12 async payments

## Logging

- `set_filesystem_logger(Option<path>, Option<LogLevel>)`
- `set_log_facade_logger()`
- `set_custom_logger(Arc<dyn LogWriter>)`

## Config struct defaults (footguns)

- `storage_dir_path: String` — **default `/tmp/ldk_node/`** ⚠ override for production
- `network: Network` — default `Bitcoin` (mainnet)
- `listening_addresses: Option<Vec<SocketAddress>>` — `None` (no inbound channels)
- `anchor_channels_config` — `Some(..)` (anchors enabled by default)
- `probing_liquidity_limit_multiplier: u64` — `3`

## Tor / .onion

No dedicated `set_tor_*` methods. `SocketAddress` enum supports `OnionV3` variants. Outbound Tor proxy must be configured via OS / app layer. Open issue [#834](https://github.com/lightningdevkit/ldk-node/issues/834) — RGS, pathfinding scoring, and **LNURL-auth (used for VSS)** HTTP calls **bypass SOCKS5** even with `TorConfig` set.
