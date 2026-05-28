---
title: "Thesis: A spec-compliant LUD-06 LNURL bridge can be deployed in front of cdk-mintd + cdk-ldk-node with a single LN node"
type: thesis
status: completed
created: 2026-05-28
updated: 2026-05-28
verdict: partially-supported
confidence: high
core_claim: "A single-LN-node CDK + LDK Node + LNURL deployment can be made strictly LUD-06 compliant by extending NUT-04 (or cdk-mintd's quote endpoint) to accept caller-supplied description_hash."
key_variables: [description_hash, NUT-04, LUD-06, cdk-mintd, cdk-ldk-node]
falsification: "If LDK Node BOLT11 invoice creation does not allow setting description_hash to an arbitrary value supplied by the caller, the thesis is false at the LDK level — bridge would have to generate its own invoices."
---

# Thesis: single-LN-node deployment feasibility

## Core Claim

A spec-compliant LUD-06 LNURL bridge can be deployed in front of cdk-mintd + cdk-ldk-node using only the cdk-ldk-node lightning node — without standing up a second LN node alongside the bridge — by extending NUT-04 (or cdk-mintd's quote endpoint) to accept a caller-supplied description_hash.

## Key Variables

- LUD-06 verification rule: `sha256(metadata) == invoice.description_hash`
- NUT-04 quote-request shape (currently accepts optional `description` text, not `description_hash`)
- LDK Node `Bolt11Payment::receive` API (does it accept `description_hash`?)
- Whether CDK maintainers would accept a NUT extension or cdk-mintd-only extension for this purpose

## Testable Prediction

If LDK Node's `bolt11_payment().receive(...)` (or a near sibling) accepts a 32-byte description_hash in lieu of a description string, then the entire pipeline is just a NUT-04 extension away from spec-compliant single-node LNURL.

## Falsification Criteria

The thesis is falsified if either:

- LDK Node's BOLT11 invoice generation cannot set `description_hash` directly (only `description` string, with hash auto-derived from the string)
- A NUT extension for description_hash is rejected upstream

## Evidence For

- [[ldk-node-receive-description-hash.md|companion thesis]] — verdict: **Supported (high confidence)**. LDK Node accepts caller-supplied description_hash via `Bolt11InvoiceDescription::Hash(Sha256)` on every `Bolt11Payment::receive*` method (since v0.5.0, May 2025). The mechanism is the enum's `Hash` variant — there is no separate `_with_description_hash` method needed because the description argument itself is polymorphic.
- ldk-server (same org as ldk-node) ships description_hash on its public gRPC API and routes it to `bolt11_payment().receive()` in production.

## Evidence Against

- The capability is **not yet wired through CDK**: `cdk-ldk-node::create_incoming_payment_request` calls `Bolt11InvoiceDescription::Direct(...)` only; `MintPayment::create_incoming_payment_request` has no description_hash parameter; cdk-mintd's NUT-04 quote endpoint accepts `description: Option<String>` only.
- So strictly, "single LN node deployment" today still requires the bridge-side-LN-node workaround (option A in [[../wiki/concepts/lnurl-cdk-design-tensions.md|design tensions]]) UNLESS the operator patches CDK locally.

## Verdict

**Status**: **Partially Supported** — at the LDK layer the thesis is true; at the CDK layer there's a small upstream gap (~50 lines + a NUT extension). The *path* exists; the path is *unfinished*. A small CDK PR would close it.

**What would change this verdict to fully Supported**:
- Merge a CDK PR adding `description_hash: Option<String>` to NUT-04 mint-quote requests
- Update `cdk-ldk-node::create_incoming_payment_request` to construct `Bolt11InvoiceDescription::Hash(Sha256(_))` when the field is set
- (Optional) formalize as a NUT extension upstream

## Suggested follow-up

Read the LDK Node `bolt11_payment` module source. If LDK doesn't support description_hash, try ldk-node issue tracker for prior discussion. If LDK supports it, file a NUT-04 extension proposal upstream.
