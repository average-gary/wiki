---
title: "cdk-ehash plugin — code-state report (May 2026)"
publication: forge.anarch.diy/vnprc/cdk-ehash + github mirror
url: https://forge.anarch.diy/vnprc/cdk-ehash
url2: https://github.com/vnprc/cdk-ehash
type: article
ingested: 2026-05-24
quality: 5
credibility: high
confidence: high
tags: [cdk-ehash, hashpool, MintPayment, code-state, stub-vs-shipped]
---

# cdk-ehash — Code-State Report

The CDK MintPayment plugin that hashpool depends on. Wiki had inferred its README "has no accumulating-melt-quote or BlockFound code yet." Confirmed and quantified May 2026.

## Stats

- **Default branch**: `main`
- **5 commits total**, all from vnprc
- **Latest commit**: `33f16c3` "Update README: CDK 0.16.0 released, fix forge URLs" — **2026-05-19** (docs only)
- **Last functional code commit**: `d5d16cf` "feat: initial cdk-ehash standalone crate" — **2026-03-18**
- **Last meaningful code change** (dep bump): `e53938e` to `cdk-common 0.16.0` — 2026-04-13
- **Pinned by hashpool**: `cdk-ehash = { git = "https://forge.anarch.diy/vnprc/cdk-ehash.git", rev = "c1a11ba" }`
- **Total LOC**: ~899 (Rust 100%)

## File layout

| File | Lines | Role |
|---|---|---|
| `src/lib.rs` | 32 | crate root, re-exports |
| `src/error.rs` | 35 | `EhashError` enum (6 variants) |
| `src/payment.rs` | 534 | `EhashPaymentProcessor` + full `MintPayment` impl + 14 unit tests |
| `tests/integration.rs` | 298 | 4 `#[tokio::test]` integration tests |

## Public API (tiny)

Two public items:

- `EhashPaymentProcessor` struct
- `EhashError` enum: `WrongPaymentOptions`, `InvalidExtraJson`, `MissingHeaderHash`, `InvalidHeaderHash`, `NoReceiver`, `OutgoingNotSupported`

Public methods:
- `EhashPaymentProcessor::new(CurrencyUnit)`
- `EhashPaymentProcessor::pay_ehash_quote(&str, Amount<CurrencyUnit>) -> Result<(), EhashError>`

Everything else comes from the `MintPayment` trait impl.

## Mental model: 1:1 quote-per-share

The plugin is **fire-and-forget**. External code (hashpool) decides shares are good and calls `pay_ehash_quote(header_hash, amount)`; the plugin emits exactly one `Event::PaymentReceived` keyed by that single `header_hash`.

- No batching
- No aggregation across shares
- No melt path
- Outgoing payments explicitly return `EhashError::OutgoingNotSupported` from `get_payment_quote`, `make_payment`, `check_outgoing_payment`

## What is NOT in the crate

| Concept (from `SETTLEMENT_DESIGN.md`) | Status in cdk-ehash |
|---|---|
| Accumulating melt quote | **Not implemented, not stubbed, not referenced** |
| `BlockFound` SV2 message | **Zero occurrences**. Also not in `hashpool/roles/mint/` proper |
| Keyset rotation per epoch | **Not implemented**. `EhashPaymentProcessor::new()` takes a single `CurrencyUnit`; no epoch concept |
| Coinbase-tx vs accumulating-quote reconciliation | **Zero occurrences** of `coinbase`, `block`, `reward` |
| Share PoW validation | Out of scope — that's hashpool upstream |

**All of these are target-state items in `SETTLEMENT_DESIGN.md`, not shipped code.**

## Where the heavier protocol primitives live

In **`vnprc/hashpool` at `protocols/ehash/`** (a separate workspace crate, NOT in `cdk-ehash`):
- `keyset.rs`
- `locking_key.rs`
- `share.rs`
- `work.rs`
- `sv2.rs`

So `cdk-ehash` is a thin **trait adapter**; the protocol guts live in hashpool's `protocols/ehash/`.

## hashpool consumes it minimally

In `hashpool/roles/mint/src/lib/mint_manager/setup.rs`, the only contact point is one line:

```rust
Arc::new(EhashPaymentProcessor::new(hash_currency_unit.clone()))
```

inside `setup_mint()`. **No `pay_ehash_quote` call site appears in the mint-role mod tree** — the wiring from share-validator into `pay_ehash_quote` either lives in `mint_manager/mod.rs` (not fetched) or has not yet been implemented.

`hashpool/roles/mint/src/lib/message_types.rs` defines `MintMessageType` with only three variants:
- `MintQuoteRequest = 0x80`
- `MintQuoteResponse = 0x81`
- `MintQuoteError = 0x82`

**No `BlockFound` message type.**

## Test coverage

Surprisingly thorough for the narrow scope:

- **14 unit tests** in `src/payment.rs` cover hash validation (length 63/64/65, non-hex chars, uppercase), `extra_json` parsing edge cases, `wait_payment_event` single-consumer semantics
- **4 integration tests** in `tests/integration.rs` build a real `cdk::Mint` with `cdk-sqlite` in-memory store, register the processor, create custom quotes via `MintQuoteCustomRequest`, then verify `pay_ehash_quote` flips state to `QuoteState::Paid`. Notably `test_pay_unknown_hash_does_not_affect_existing_quotes` confirms unmatched hashes are silently ignored.

These tests **do not cover any share→PoW validation** — only the CDK-facing half: "given a header_hash and amount, the quote transitions correctly."

## Bottom line

`cdk-ehash` is a **~900-LOC adapter crate** that fits Hashpool's share-payment model into CDK 0.16's `MintPayment` trait. **Feature-complete for its scope** (single-quote-per-share, header_hash-keyed). But the SETTLEMENT_DESIGN.md machinery — `BlockFound`, accumulating melt quotes, keyset rotation, epochs, coinbase reconciliation, batching — is **entirely absent**. All target-state.

The plugin is in **maintenance mode** as of May 2026. Last functional code commit ~2 months prior. The 12-month tag cadence (v0.1 March 2025 → v0.1.1 March 2026) on hashpool itself + the dormant cdk-ehash plugin = **the gap between the design vision and the shipped code is large, and not actively closing**.

## Sources

- `https://forge.anarch.diy/vnprc/cdk-ehash` (canonical)
- `https://github.com/vnprc/cdk-ehash` (mirror)
- File inspection: `src/payment.rs`, `src/error.rs`, `src/lib.rs`, `tests/integration.rs`, `Cargo.toml`
- Cross-reference: `vnprc/hashpool/roles/mint/Cargo.toml`, `roles/mint/src/lib/mint_manager/setup.rs`, `roles/mint/src/lib/message_types.rs`

## See also

- [[2026-05-24-hashpool-architecture-deep|hashpool architecture deep-dive]] — describes the target-state SETTLEMENT_DESIGN
- [[2026-05-24-pioneerhash-org|PioneerHash org]] — parallel `cdk` fork at `ehash-dev` branch
- [[../../wiki/concepts/ehash|eHash concept]]
