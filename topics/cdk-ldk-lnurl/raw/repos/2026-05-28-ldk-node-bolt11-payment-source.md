---
title: "lightningdevkit/ldk-node — `src/payment/bolt11.rs` (current main)"
type: repo
source: https://github.com/lightningdevkit/ldk-node/blob/main/src/payment/bolt11.rs
fetched: 2026-05-28
confidence: high
tags: [ldk-node, bolt11-payment, description-hash, source-code]
summary: All eight Bolt11Payment receive variants take `description: &Bolt11InvoiceDescription` (an enum with Direct and Hash variants). The hash variant sets the BOLT11 `h` tag. Definitive primary source for the thesis.
---

# `Bolt11Payment` receive API — current main

## Method signatures (all take `&Bolt11InvoiceDescription`)

```rust
pub fn receive(
    &self,
    amount_msat: u64,
    description: &Bolt11InvoiceDescription,
    expiry_secs: u32,
) -> Result<Bolt11Invoice, Error>;

pub fn receive_for_hash(
    &self,
    amount_msat: u64,
    description: &Bolt11InvoiceDescription,
    expiry_secs: u32,
    payment_hash: PaymentHash,            // <-- HODL preimage, not description hash
) -> Result<Bolt11Invoice, Error>;

pub fn receive_variable_amount(
    &self,
    description: &Bolt11InvoiceDescription,
    expiry_secs: u32,
) -> Result<Bolt11Invoice, Error>;

pub fn receive_variable_amount_for_hash(...) -> ...;
pub fn receive_via_jit_channel(...) -> ...;
pub fn receive_via_jit_channel_for_hash(...) -> ...;
pub fn receive_variable_amount_via_jit_channel(...) -> ...;
pub fn receive_variable_amount_via_jit_channel_for_hash(...) -> ...;
```

## Crucial naming nuance

**The `_for_hash` suffix in ldk-node refers to a caller-supplied `PaymentHash` (HODL-style invoice with externally-held preimage), NOT to BOLT11's description hash (`h` tag).** Description hash is selected via the `description: &Bolt11InvoiceDescription` parameter on every variant, by passing the `Hash(Sha256(_))` variant of that enum.

This distinction is easy to conflate — the meta agent flagged it, the adjacent-embedder agent confirmed it.

## `Bolt11InvoiceDescription` (re-exported from `lightning_invoice`)

```rust
pub enum Bolt11InvoiceDescription {
    Direct(Description),    // sets BOLT11 `d` tag
    Hash(Sha256),           // sets BOLT11 `h` tag — 32-byte SHA-256
}
```

`Sha256` here is `lightning_invoice::Sha256(pub bitcoin_hashes::sha256::Hash)`.

## Internal flow (`receive_inner`)

```rust
let invoice_params = Bolt11InvoiceParameters {
    amount_msats: amount_msat,
    description: invoice_description.clone(),
    invoice_expiry_delta_secs: Some(expiry_secs),
    payment_hash: manual_claim_payment_hash,
    ..Default::default()
};
self.channel_manager.create_bolt11_invoice(invoice_params)
```

The description value is passed through verbatim to `ChannelManager::create_bolt11_invoice` (rust-lightning), which matches on the enum: `Hash(s)` → `.description_hash(s)` on `InvoiceBuilder`; `Direct(d)` → `.description(d)`.

## Caller usage

```rust
use ldk_node::lightning_invoice::{Bolt11InvoiceDescription, Sha256};
use ldk_node::bitcoin::hashes::{sha256, Hash};

let metadata_string: String = build_lud06_metadata();
let h: sha256::Hash = sha256::Hash::hash(metadata_string.as_bytes());
let description = Bolt11InvoiceDescription::Hash(Sha256(h));
let invoice = node.bolt11_payment().receive(amount_msat, &description, 3600)?;
// invoice.h_tag == h ✓ — wallet's sha256(metadata) == invoice.description_hash check passes
```

## Version note

This API shape is current as of `main` and was first shipped in **LDK Node v0.5.0 (2025-05-05)** via PR #438. Prior versions (v0.4.x and earlier) took `description: &str` only — the thesis is FALSE for those versions.

## See also

- [[2026-05-28-ldk-node-pr-438-description-hash.md|PR #438 — the merge]]
- [[2026-05-28-lightning-invoice-bolt11-description-enum.md|Bolt11InvoiceDescription enum]]
- [[2026-05-28-ldk-server-bolt11-description-hash-plumbing.md|ldk-server proto-adapter — Hash plumbing]]
