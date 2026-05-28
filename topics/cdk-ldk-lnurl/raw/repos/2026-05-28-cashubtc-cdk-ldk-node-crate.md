---
title: "cashubtc/cdk — `cdk-ldk-node` crate"
type: repo
source: https://github.com/cashubtc/cdk/tree/main/crates/cdk-ldk-node
fetched: 2026-05-28
confidence: high
tags: [cdk, ldk-node, lightning-backend, mint-payment-trait]
summary: The CDK lightning backend that embeds an LDK Node directly into cdk-mintd. First-class crate; ships its own admin web UI on port 8091 (no auth — localhost only). Implements the MintPayment trait.
---

# cashubtc/cdk — `cdk-ldk-node` crate

Ingested from `crates/cdk-ldk-node/` in [github.com/cashubtc/cdk](https://github.com/cashubtc/cdk).

## What this crate is

`cdk-ldk-node` is one of CDK's swappable lightning-backend crates (alongside `cdk-cln`, `cdk-lnd`, `cdk-lnbits`, `cdk-fake-wallet`, `cdk-payment-processor`). It implements the [`MintPayment`](2026-05-28-cashubtc-cdk-mint-payment-trait.md) trait by wrapping an `Arc<ldk_node::Node>` and translating CDK's mint/melt-quote calls into LDK Node BOLT11 / BOLT12 invoice creation, payment, and event polling.

It was added in CDK v0.12.0 (released 2025-08-26) via PR #904 by `thesimplekid` (+7351/-401). It is **not** a default feature of `cdk-mintd` — operators must build with `--features ldk-node` or install the separately published `cdk-mintd-ldk` binary.

## Public API surface

From `crates/cdk-ldk-node/src/lib.rs`:

- Types: `CdkLdkNode`, `CdkLdkNodeBuilder`, `BitcoinRpcConfig`
- `enum ChainSource { Esplora(String), BitcoinRpc(BitcoinRpcConfig) }`
- `enum GossipSource { P2P, RapidGossipSync(String) }`
- `CdkLdkNodeBuilder::new(network, chain_source, gossip_source, storage_dir_path, fee_reserve, listening_addresses)` plus
  - `.with_seed(Mnemonic)`
  - `.with_announcement_address(...)`
  - `.with_log_dir_path(...)`
  - `.build() -> Result<CdkLdkNode, Error>`
- `#[async_trait] impl MintPayment for CdkLdkNode { type Err = payment::Error; ... }`

`get_settings()` advertises:

- BOLT11 — `mpp: false`, `amountless: true`, `invoice_description: true`
- BOLT12 — `amountless: true`
- Onchain — `None`

`create_incoming_payment_request` calls `self.inner.bolt11_payment().receive(amount_msat, &description, expiry_secs)`. The event loop matches `ldk_node::Event::PaymentReceived { payment_id, payment_hash, amount_msat, .. }` and broadcasts on a `tokio::sync::broadcast` channel consumed by `wait_payment_event()`.

Internally uses `ldk_node::Builder` with `set_chain_source_esplora`, `set_chain_source_bitcoind_rpc`, `set_gossip_source_p2p`, `set_gossip_source_rgs`, `set_listening_addresses`, `set_filesystem_logger`, `set_custom_logger`.

## Embedded admin web UI

Default port 8091. **No authentication** — README mandates `127.0.0.1` binding. Configurable via `webserver_host`, `webserver_port`. Provides dashboard, channels, BOLT11/BOLT12 invoice/offer creation, payments, on-chain ops.

## Networks supported

mainnet · testnet · signet · regtest. Mutinynet (signet) is the documented test target with:

- esplora: `https://mutinynet.com/api`
- RGS: `https://rgs.mutinynet.com/snapshot/0`

## Notable known issues

- Issue [#1867 — receive amount includes fee](https://github.com/cashubtc/cdk/issues/1867): UI accounting drift in cdk-ldk dashboard. Direct evidence that the LN-backend's accounting drift translates to mint-reserve drift.
- The README explicitly positions LDK Node as **"Recommended for Testing"**; production guidance in surrounding cdk-mintd docs leans on CLN/LND.

## Why ingest

Authoritative source for the entire CDK + LDK Node integration surface. Settles open question: yes, CDK exposes a complete BOLT11/BOLT12 path through embedded LDK Node — what it does **not** ship is any LNURL surface.
