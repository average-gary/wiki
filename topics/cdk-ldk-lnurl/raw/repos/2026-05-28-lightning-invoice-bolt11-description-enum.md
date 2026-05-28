---
title: "`lightning_invoice::Bolt11InvoiceDescription` — the enum (rustdoc)"
type: repo
source: https://docs.rs/lightning-invoice/latest/lightning_invoice/enum.Bolt11InvoiceDescription.html
fetched: 2026-05-28
confidence: high
tags: [rust-lightning, lightning-invoice, bolt11, description-hash]
summary: The enum LDK Node accepts on its receive methods. Has Direct(Description) and Hash(Sha256) variants. Hash variant maps to BOLT11 `h` tag.
---

# `Bolt11InvoiceDescription`

```rust
pub enum Bolt11InvoiceDescription {
    Direct(Description),
    Hash(Sha256),
}
```

- `Direct(Description)` — the BOLT11 `d` tag, plaintext description (max 639 bytes per spec)
- `Hash(Sha256)` — the BOLT11 `h` tag, exactly 32 bytes (SHA-256 commitment)

`lightning_invoice::Sha256` is `pub struct Sha256(pub bitcoin_hashes::sha256::Hash)` — a tuple wrapper around a 32-byte hash.

## Spec mapping (BOLT11 §11)

The BOLT11 spec mandates `h` xor `d` — invoices MUST include exactly one of:
- `d` field — a plaintext description (max 639 bytes)
- `h` field — a 256-bit SHA-256 of arbitrary content

`Bolt11InvoiceDescription` collapses both options into one type: callers pick the variant they want.

## Builder primitive

`lightning_invoice::InvoiceBuilder` provides type-state generic methods enforcing the spec exclusivity at compile time:

```rust
pub fn description(self, description: String) -> InvoiceBuilder<True, ...>
pub fn description_hash(self, description_hash: bitcoin_hashes::sha256::Hash) -> InvoiceBuilder<True, ...>
```

Once one is called, the other becomes uncallable in the type state.

## Why the thesis is true via this enum (not a separate param)

Modern rust-lightning consolidated the two old top-level helpers (`create_invoice_from_channelmanager` for plaintext + `create_invoice_from_channelmanager_with_description_hash` for hash) into one function `ChannelManager::create_bolt11_invoice` taking a `Bolt11InvoiceParameters` struct whose `description` field is `Bolt11InvoiceDescription`.

So:
- The capability did not regress — it was unified into one entry point
- Anywhere that used to call `_with_description_hash` now passes `Bolt11InvoiceDescription::Hash(_)` to the unified call
- ldk-node's `Bolt11Payment::receive(...)` uses this unified path

## See also

- [[2026-05-28-ldk-node-bolt11-payment-source.md|ldk-node bolt11.rs source]]
- [[2026-05-28-ldk-node-pr-438-description-hash.md|PR #438 — when ldk-node adopted the enum]]
