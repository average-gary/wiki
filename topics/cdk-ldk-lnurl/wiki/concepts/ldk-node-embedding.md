---
title: "LDK Node embedding inside cdk-mintd"
type: concept
created: 2026-05-28
updated: 2026-05-28
confidence: high
tags: [cdk-ldk-node, ldk-node, embedding, config]
---

# LDK Node embedding inside cdk-mintd

The `cdk-ldk-node` crate wraps `Arc<ldk_node::Node>` and implements `MintPayment`. When `cdk-mintd` is built with `--features ldk-node` and configured with `ln_backend = "ldknode"`, the resulting binary runs both the Cashu mint HTTP server **and** an LDK Node lightning node in one process.

## Why one process

- Single state-management story — no separate LN daemon to babysit
- Single set of credentials/config
- Native motivating use case: [[../../raw/articles/2026-05-28-hashpool-cashu-pow-mining.md|Hashpool]] (Cashu mint inside a mining pool)

## Why two processes (the K8s case)

The [[../../raw/repos/2026-05-28-asmogo-cashu-operator.md|asmogo/cashu-operator]] uses a sidecar pattern even when the LN backend is LDK — separate restart cycles, separate volume, isolation against panic. See [[ldk-node-footguns.md|LDK Node footguns]] for why.

## Configuration surface

Configured under `[ldk_node]` in cdk-mintd's TOML or `CDK_MINTD_LDK_NODE_*` env vars. The full schema is in [[../../raw/repos/2026-05-28-cashubtc-cdk-mintd-config.md|cdk-mintd config raw]]. Highlights:

| Key | Notes |
|---|---|
| `bitcoin_network` | mainnet / testnet / signet / regtest |
| `chain_source_type` | `esplora` or `bitcoinrpc` |
| `esplora_url` / `bitcoind_rpc_*` | source-specific |
| `gossip_source_type` | `p2p` or `rgs` |
| `rgs_url` | for RGS source |
| `storage_dir_path` | LDK Node persistence root — **never leave at default** (LDK's own default is `/tmp/ldk_node/`, see [[../../raw/repos/2026-05-28-ldk-node-builder-api.md|builder API raw]]) |
| `ldk_node_mnemonic` | BIP-39, required first run |
| `webserver_host` / `_port` | admin UI bind — **must be 127.0.0.1**, no auth |
| `fee_percent` | mint surcharge over LN routing fee (default 0.02) |

## Capabilities advertised

`CdkLdkNode::get_settings()` returns:
- BOLT11 — `mpp: false`, `amountless: true`, `invoice_description: true`
- BOLT12 — `amountless: true`
- Onchain — `None` (mints don't accept onchain via this backend; would need `cdk-bdk` separately)

## Persistence model

LDK Node v0.7 default: SQLite. Other options exposed by LDK Node Builder (filesystem KVStore, VSS) are **not** surfaced through cdk-mintd config — they require a custom build that calls the LDK Builder directly. This is a soft gap.

VSS persistence has an unexpected dependency: the default auth path uses LNURL-auth (LUD-04). Operators wanting cloud backup without that dependency need `build_with_vss_store_and_fixed_headers` or `build_with_vss_store_and_header_provider` — neither currently configurable from cdk-mintd TOML.

## What was added when

| CDK version | LDK Node-related change |
|---|---|
| v0.12.0 (2025-08-26) | Initial `cdk-ldk-node` crate; admin web UI; `MintPayment` lifecycle methods |
| v0.13.0 (2025-09-23) | Web UI improvements; `cdk-mintd-ldk-<ver>` release artifact added |
| v0.15.0 (2026-02-17) | BIP-39 mnemonic, configurable announcement addresses, configurable logging |
| v0.16.0 (2026-03-31) | Current stable; `cdk-mintd-ldk-0.16.0` artifact |
| v0.17.0-rc.0 (2026-05-22) | Pre-release |

LDK Node side: pinned to v0.7 since CDK v0.16 (PR #1399, 2025-12-14). v0.7 brought channel splicing, async payments, Bitcoin Core REST chain source, VSS encryption hardening. See [[../../raw/articles/2026-05-28-ldk-node-v0-7-0-release-notes.md|LDK Node v0.7 raw]].

## See also

- [[cdk-architecture-and-backends.md|CDK architecture]]
- [[ldk-node-footguns.md|LDK Node footguns]]
- [[lnurl-bridge-pattern.md|LNURL bridge pattern]]
