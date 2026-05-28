---
title: "CDK architecture and lightning backends"
type: concept
created: 2026-05-28
updated: 2026-05-28
confidence: high
tags: [cdk, architecture, mint-payment, ldk-node]
---

# CDK architecture and lightning backends

Cashu Dev Kit ([cashubtc/cdk](https://github.com/cashubtc/cdk)) is a Rust workspace. The pieces relevant to LNURL deployment:

## Workspace layout

| Crate | Purpose |
|---|---|
| `cdk` | Wallet — used by client apps and (importantly) implements LNURL/lightning-address **sender** support |
| `cdk-common` | Shared types; defines the `MintPayment` trait |
| `cdk-mintd` | The mint binary an operator runs |
| `cdk-cln` / `cdk-lnd` / `cdk-lnbits` / `cdk-fake-wallet` / `cdk-ldk-node` | `MintPayment` implementations — pick one at compile time |
| `cdk-payment-processor` | Newer gRPC abstraction over backends — used by the cashu-operator's sidecar pattern |
| `cdk-mint-rpc` | Optional gRPC admin surface (separate port) |
| `cdk-postgres` | Mint-side database backend |

## The `MintPayment` trait

Defined in `cdk-common/src/payment.rs`. Every backend implements:

- `start()` / `stop()` — lifecycle (added in v0.12 specifically for LDK Node)
- `get_settings()` — capability advertisement (BOLT11 mpp/amountless/description, BOLT12, onchain)
- `create_incoming_payment_request(...)` — generate invoice
- `get_payment_quote(...)` / `make_payment(...)` — outbound
- `wait_payment_event() → Stream<...>` — async settlement events
- `check_incoming_payment_status(...)` / `check_outgoing_payment(...)` — defensive polling

`type DynMintPayment = Arc<dyn MintPayment<Err = Error> + Send + Sync>` — every backend plugs in here.

See [[../../raw/repos/2026-05-28-cashubtc-cdk-mint-payment-trait.md|MintPayment trait raw]].

## How `cdk-mintd` selects a backend

```toml
[ln]
ln_backend = "ldknode"   # cln | lnd | lnbits | fakewallet | grpc-processor | ldknode
```

`LnBackend::LdkNode` is gated on `#[cfg(feature = "ldk-node")]`. **Default `cdk-mintd` builds do NOT include `ldk-node`** — operators install via `cargo install cdk-mintd --features ldk-node` or use the `cdk-mintd-ldk-<version>` artifact published alongside each release since v0.13.0.

See [[../../raw/repos/2026-05-28-cashubtc-cdk-mintd-config.md|cdk-mintd config raw]].

## Where LNURL fits (it doesn't, on the mint side)

CDK's wallet crate has `LightningAddress`, `LnurlPayResponse`, `melt_lightning_address_quote`, etc. — the **payer** side. cdk-mintd ships **no LNURL endpoints**: no `/.well-known/lnurlp/<u>`, no `lnurlw://` handler, no NIP-05.

Issue [#1286](https://github.com/cashubtc/cdk/issues/1286) ("add melt to lnurl like we have for bip353") was closed without merge, milestone 0.14. CDK's direction prioritizes BOLT12 + BIP-353 over LNURL helper integration.

Implication: deploying LNURL on a CDK mint requires an external bridge — see [[lnurl-bridge-pattern.md|the LNURL bridge pattern]].

## See also

- [[ldk-node-embedding.md|LDK Node embedding inside cdk-mintd]]
- [[lnurl-bridge-pattern.md|LNURL bridge pattern]]
- [[../../ldk-server/wiki/concepts/ldk-vs-ldk-node-vs-ldk-server.md|LDK vs LDK Node vs LDK Server]] (adjacent wiki)
