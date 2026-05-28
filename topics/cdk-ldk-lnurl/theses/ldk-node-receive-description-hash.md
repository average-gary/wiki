---
title: "Thesis: LDK Node bolt11_payment().receive accepts caller-supplied description_hash"
type: thesis
status: completed
created: 2026-05-28
updated: 2026-05-28
verdict: supported
confidence: high
core_claim: "LDK Node's `Bolt11Payment::receive` (or sibling on the bolt11_payment() handle) accepts a caller-supplied 32-byte description_hash for the BOLT11 `h` tag, not just a plaintext description string."
key_variables: [Bolt11Payment, description_hash, BOLT11-h-tag, Bolt11InvoiceDescription, ldk-node]
falsification: "All LDK Node BOLT11 invoice paths take only a description string and internally compute the hash; no public API accepts a raw Sha256 for the description_hash field."
---

# Thesis: LDK Node `bolt11_payment().receive` accepts caller-supplied description_hash

## Core Claim

LDK Node's `Bolt11Payment::receive` (and every sibling receive method on the same handle) accepts a caller-supplied 32-byte SHA-256 commitment for the BOLT11 `h` tag — not just a plaintext description string with auto-derived hash. The mechanism is the `Bolt11InvoiceDescription` enum (re-exported from `lightning_invoice`), which has a `Hash(Sha256)` variant. This is exactly what an LNURL bridge in front of cdk-mintd would need to issue invoices satisfying LUD-06's `sha256(metadata) == invoice.h` rule using a single LN node.

## Key Variables

- `ldk_node::payment::Bolt11Payment` (struct returned by `Node::bolt11_payment()`)
- `Bolt11InvoiceDescription` enum: `Direct(Description) | Hash(Sha256)`
- BOLT11 `h` tag (256-bit SHA-256, mutually exclusive with `d`)
- rust-lightning's `ChannelManager::create_bolt11_invoice` + `Bolt11InvoiceParameters`
- LDK Node version (capability landed in v0.5.0; not present in v0.4.x)

## Testable Prediction

A method on `Bolt11Payment` that accepts the description as `&Bolt11InvoiceDescription` exists in ldk-node v0.5.0+, and the `Hash(Sha256)` variant flows through unmodified to the BOLT11 `h` tag.

## Falsification Criteria

The thesis would be falsified if:
- All public methods on `Bolt11Payment` accept only a plaintext `description: String` / `&str`
- The description-hash variant is private to rust-lightning and not surfaced through ldk-node
- No issue/PR/commit references such an API

None of these are true.

## Evidence For

| # | Source | Strength | Direction | One-line summary |
|---|---|---|---|---|
| 1 | [[../raw/repos/2026-05-28-ldk-node-bolt11-payment-source.md\|ldk-node `src/payment/bolt11.rs` (main)]] | **Strong** (primary source) | supports | All eight `receive*` methods take `description: &Bolt11InvoiceDescription`; passed verbatim to `ChannelManager::create_bolt11_invoice`. |
| 2 | [[../raw/repos/2026-05-28-lightning-invoice-bolt11-description-enum.md\|`lightning_invoice::Bolt11InvoiceDescription`]] | **Strong** (canonical type def) | supports | `enum { Direct(Description), Hash(Sha256) }` — `Hash(Sha256)` wraps a 32-byte hash; sets BOLT11 `h` tag. |
| 3 | [[../raw/articles/2026-05-28-ldk-node-pr-438-description-hash.md\|ldk-node PR #438]] | **Strong** (merged official PR) | supports | Joost Jager merged 2025-01-23, +167/-50, replacing `&str` with `&Bolt11InvoiceDescription` on every receive method. |
| 4 | LDK Node v0.5.0 release notes (2025-05-05) | **Strong** (official release notes) | supports | Verbatim: "The ability to set a description hash when creating a BOLT11 invoice has been added (#438)." |
| 5 | [[../raw/repos/2026-05-28-ldk-server-bolt11-description-hash-plumbing.md\|ldk-server proto-adapter]] | **Strong** (production embedder, same org) | supports | ldk-server gRPC proto exposes `Bolt11InvoiceDescription { oneof kind { string direct; string hash } }`; routes through to `bolt11_payment().receive(...)`. |
| 6 | Alby Hub `lnclient/ldk/ldk.go` | Moderate (production binding consumer) | supports | Go code via UniFFI passes `Bolt11InvoiceDescriptionHash{Hash: descriptionHash}` to `node.Bolt11Payment().Receive(...)` for NWC/LNURL flows. |
| 7 | [[../raw/articles/2026-05-28-ldk-node-issue-325-history.md\|Issue #325 design history]] | Moderate (maintainer thread) | supports | Original issue filed 2024-07 by Fedimint Gateway maintainers; closed 2025-01-23 by PR #438. The motivating use case is exactly LNURL-pay description binding. |
| 8 | rust-lightning `Bolt11InvoiceParameters.description: Bolt11InvoiceDescription` | **Strong** (rustdoc) | supports | The unified entry point `ChannelManager::create_bolt11_invoice` takes the same enum; `Hash(_)` → `.description_hash(_)` on `InvoiceBuilder`. |

## Evidence Against

| # | Source | Strength | Direction | One-line summary |
|---|---|---|---|---|
| 1 | ldk-node v0.4.x source `src/payment/bolt11.rs` | Strong (historical primary source) | nuances | Pre-v0.5.0 (Jan 2025), all receive methods took only `description: &str`. The thesis is FALSE for v0.4.x and earlier. |
| 2 | tnull comment on issue #325 | Moderate (maintainer statement) | nuances | "Unfortunately we can't do this... `Bolt11InvoiceDescription` wouldn't be exposable via our bindings. I'm also not the biggest fan of complicating the API too much here." Initial design resistance. Resolved by adopting the enum unchanged. |
| 3 | Issue #361 closed-as-blocked | Moderate (maintainer statement) | nuances | September 2024: "Slipping, as we can't do this currently without pulling in a lot of code from upstream LDK. Blocked on rust-lightning PR #3371." For ~6 months the feature was actively blocked upstream. |
| 4 | UniFFI binding shape | Weak (precision-only nuance) | nuances | Over UniFFI (Swift/Kotlin/Python), the Hash variant carries `String` (hex), not `[u8; 32]`. Hex parsed at runtime; invalid hex → `Error::InvoiceCreationFailed`. The thesis says "32-byte" — strictly true for pure-Rust; for binding consumers the shape is hex-string-validated-to-32-bytes. |

## Nuances & Caveats

1. **Mechanism is the enum, not a separate parameter.** The thesis paraphrases as "accepts caller-supplied description_hash"; literally, there is no `description_hash: [u8; 32]` parameter. Caller passes `&Bolt11InvoiceDescription::Hash(Sha256(_))` as the `description` argument. Functionally equivalent; clarify in any downstream documentation.

2. **`_for_hash` suffix is a name collision trap.** `receive_for_hash` and other `_for_hash`-suffixed methods take a caller-supplied **`PaymentHash`** (HODL-invoice / manual-claim flow) — orthogonal to BOLT11 description hash. The description hash is set via the `description` parameter on every variant, including the simple `receive`.

3. **Version-scoped.** True for ldk-node v0.5.0+ (May 2025). FALSE for v0.4.x and earlier. cdk-ldk-node started life on ldk-node 0.6+ (CDK v0.12.0, Aug 2025), so the cdk-mintd LDK backend has had the capability since day one.

4. **CDK side has not yet wired it through.** `cdk-ldk-node`'s `create_incoming_payment_request` currently calls `Bolt11InvoiceDescription::Direct(...)` only. The capability is reachable in one line of CDK code, but:
   - `MintPayment` trait's `create_incoming_payment_request` signature has no `description_hash` field
   - `cdk-mintd`'s NUT-04 quote endpoint accepts `description: Option<String>` only
   - A NUT extension or cdk-side feature would be needed to plumb hash bytes from an LNURL bridge through to the LDK Node call

5. **Implication for the cdk-ldk-lnurl wiki design tensions article**: the LDK-layer blocker that motivated the "two-LN-node" workaround in [[../wiki/concepts/lnurl-cdk-design-tensions.md|design tensions]] is **not real at the LDK layer**. The blocker is purely in CDK's intermediate trait/HTTP surface. A small upstream PR to CDK would unblock single-LN-node spec-compliant LNURL.

## Verdict

**Status**: **Supported**
**Confidence**: **High**

**Summary**: LDK Node v0.5.0+ accepts caller-supplied 32-byte description_hash via the `Bolt11InvoiceDescription::Hash(Sha256)` enum variant on all `Bolt11Payment::receive*` methods. The capability is documented (rustdoc), tested (PR #438), used in production by ldk-server and Alby Hub, and motivated by exactly the LNURL/Fedimint Gateway use cases this wiki cares about.

**Strongest supporting evidence**:
- ldk-node `src/payment/bolt11.rs` source — every receive method takes `&Bolt11InvoiceDescription`
- PR #438 (merged 2025-01-23) and v0.5.0 release notes ("ability to set a description hash when creating a BOLT11 invoice has been added")
- ldk-server (same org as ldk-node) ships description_hash on its gRPC `Bolt11InvoiceDescription`

**Strongest opposing evidence**:
- v0.4.x and earlier had `description: &str` only — thesis is version-scoped
- Maintainer initial resistance (issue #325 thread); resolved, but worth knowing this was non-obvious

**Key caveats**:
- Mechanism is `Bolt11InvoiceDescription::Hash(Sha256)` enum variant, not a separate `description_hash` parameter
- `_for_hash` method suffix means PaymentHash, not description hash — name-collision trap
- CDK side has not wired the capability through `cdk-ldk-node` or NUT-04 yet — that's where the actual remaining gap is

**What would change this verdict**:
- A regression in ldk-node removing the `Hash` variant (extremely unlikely)
- Discovery that the merged PR was reverted (verified not the case)
- Evidence that `ChannelManager::create_bolt11_invoice` does not honor the Hash variant (rustdoc + source contradict this)

**Suggested follow-up theses**:
1. "A 50-line PR to `cdk-ldk-node::create_incoming_payment_request` plus a `description_hash: Option<String>` field on NUT-04's mint-quote request would enable single-LN-node spec-compliant LNURL on cdk-mintd."
2. "BIP-353 / BOLT12 offers, which carry an issuer signature, are a strictly better long-term replacement for LNURL Lightning Address on a Cashu mint than patching LUD-06 description-hash plumbing."

## See also

- [[../raw/repos/2026-05-28-ldk-node-bolt11-payment-source.md|ldk-node bolt11.rs source]]
- [[../raw/repos/2026-05-28-lightning-invoice-bolt11-description-enum.md|Bolt11InvoiceDescription enum]]
- [[../raw/articles/2026-05-28-ldk-node-pr-438-description-hash.md|PR #438 — the merge]]
- [[../raw/repos/2026-05-28-ldk-server-bolt11-description-hash-plumbing.md|ldk-server uses it in production]]
- [[../raw/articles/2026-05-28-ldk-node-issue-325-history.md|Issue #325 design history]]
- [[../wiki/concepts/lnurl-cdk-design-tensions.md|Design tensions (this verdict resolves tension #1)]]
- [[../wiki/concepts/lnurl-bridge-pattern.md|LNURL bridge pattern]]
