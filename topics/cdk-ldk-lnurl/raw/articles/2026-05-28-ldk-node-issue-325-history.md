---
title: "ldk-node Issue #325 — `Bolt11Payment::receive*` should accept Bolt11InvoiceDescription"
type: article
source: https://github.com/lightningdevkit/ldk-node/issues/325
fetched: 2026-05-28
published: 2024-07
confidence: high
tags: [ldk-node, history, description-hash, fedimint, lnurl-motivation]
summary: The tracking issue (filed July 2024, closed Jan 2025 by PR #438) where Fedimint maintainers and tnull negotiated whether to expose Bolt11InvoiceDescription. Documents the maintainer's initial reluctance and the LNURL/nostr-zap motivation that won the day.
---

# Issue #325 — design history

## Filing

- **Filed**: 2024-07
- **Closed**: 2025-01-23 by PR #438
- **Body**: *"This is needed for Fedimint lightning gateway to support creating invoices with description hashes."*

## Maintainer initial position (tnull)

> "Unfortunately we can't do this (at least directly), as `Bolt11InvoiceDescription` wouldn't be exposable via our bindings. I'm also not the biggest fan of complicating the API too much here."

Counter-proposal floated: auto-hash descriptions when length exceeds 639 bytes (the BOLT11 `d` tag limit). This would NOT have satisfied LNURL-pay or nostr-zap requirements — those specs require the hash to be a SHA-256 of a SPECIFIC payload, not an arbitrary auto-derived hash.

## Pushback (benthecarman)

> "For lightning addresses it is needed... The lnurl pay spec and nostr zap spec requires that the description hash is a hash of some of the data... The hash and description are separate fields so you can't really just put the data from one in another."

This is the canonical explanation of why callers MUST be able to supply their own hash bytes — a parallel to the LUD-06 verification rule documented in [[../papers/2026-05-28-lnurl-lud-06-payrequest.md|LUD-06]].

## Resolution

PR #438 implemented the unified-enum approach: `description: &str` → `description: &Bolt11InvoiceDescription`. The bindings concern was resolved by exposing the enum through UniFFI (with hex-string hashes for binding consumers).

## Why this matters for the cdk-ldk-lnurl wiki

The thesis question — does ldk-node accept caller-supplied description_hash — boils down to: did PR #438 ship? Yes (LDK Node v0.5.0, 2025-05-05). cdk-ldk-node started life on ldk-node 0.6+ (CDK v0.12.0 Aug 2025) and has shipped on ldk-node 0.7+ since CDK v0.16 — well after PR #438 was in.

So the **upstream API is present**; the gap is purely on the CDK side: cdk-ldk-node currently calls `Bolt11InvoiceDescription::Direct(...)` only, and CDK's NUT-04 quote endpoint has no field for caller-supplied description_hash. Both gaps could be closed with small CDK PRs.

## See also

- [[2026-05-28-ldk-node-pr-438-description-hash.md|PR #438]]
- [[2026-05-28-ldk-node-bolt11-payment-source.md|bolt11.rs source]]
- [[../papers/2026-05-28-lnurl-lud-06-payrequest.md|LUD-06 (the LNURL spec that needs this)]]
