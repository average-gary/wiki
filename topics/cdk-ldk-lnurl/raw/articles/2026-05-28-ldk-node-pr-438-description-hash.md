---
title: "ldk-node PR #438 — Extend API to allow invoice creation with a description hash"
type: article
source: https://github.com/lightningdevkit/ldk-node/pull/438
fetched: 2026-05-28
published: 2025-01-23
confidence: high
tags: [ldk-node, pr-438, description-hash, history, fedimint]
summary: The merged PR (Joost Jager, +167/-50) that switched all Bolt11Payment receive* signatures from `&str` to `&Bolt11InvoiceDescription`. Shipped in v0.5.0 (2025-05-05). Motivated by Fedimint Lightning Gateway needing description-hash invoices.
---

# PR #438 — the merge that made the thesis true

## Metadata

- **Author**: Joost Jager
- **Merged**: 2025-01-23
- **Merge commit**: `92ee62fbc8aa3372d079679599f5a2f21a878e33`
- **Diff**: +167 / -50
- **Body**: "Fixes https://github.com/lightningdevkit/ldk-node/issues/325"
- **First release**: LDK Node v0.5.0 (2025-05-05). Release notes: *"The ability to set a description hash when creating a BOLT11 invoice has been added (#438)."*

## What it changed

All eight `Bolt11Payment` receive variants switched their description parameter:

```diff
- description: &str
+ description: &Bolt11InvoiceDescription
```

`Bolt11InvoiceDescription` is re-exported from `lightning_invoice` and has variants `Direct(Description)` and `Hash(Sha256)`. Callers wanting a description-hash invoice now pass `&Bolt11InvoiceDescription::Hash(Sha256(...))`.

## Motivating use case

Issue #325 body: *"This is needed for Fedimint lightning gateway to support creating invoices with description hashes."*

The Fedimint Gateway embeds LDK Node and needs to issue invoices binding to LNURL-pay metadata or nostr-zap event hashes — both standard use cases that mandate the `h` tag.

The same use case applies to:
- LNURL-pay bridges (e.g., npubcash-server) issuing invoices that satisfy `sha256(metadata) == invoice.h`
- Nostr-zap services binding zaps to event hashes
- Any LN service exposing pay endpoints where description content exceeds 639 bytes (BOLT11 `d` tag limit)

## Maintainer reluctance (historical context)

Issue #325 reveals the API addition was initially resisted by maintainer `tnull`:

> "Unfortunately we can't do this (at least directly), as `Bolt11InvoiceDescription` wouldn't be exposable via our bindings. I'm also not the biggest fan of complicating the API too much here."
> — tnull, 2024-07

Initial counter-proposal: auto-hash descriptions exceeding 639 bytes silently, never expose caller-supplied hash. Pushed back by `benthecarman`:

> "For lightning addresses it is needed... The lnurl pay spec and nostr zap spec requires that the description hash is a hash of some of the data... The hash and description are separate fields so you can't really just put the data from one in another."

Issue #361 ("Allow to use description hash") was filed Sept 2024, closed as duplicate, with explicit blocker:

> "Slipping, as we can't do this currently without pulling in *a lot* of code from upstream LDK. Blocked on https://github.com/lightningdevkit/rust-lightning/pull/3371"

The unblock came when rust-lightning consolidated invoice creation into `ChannelManager::create_bolt11_invoice` accepting a `Bolt11InvoiceParameters` struct (whose `description` is `Bolt11InvoiceDescription`). PR #438 then propagated that one-liner through ldk-node.

## Implication for the thesis

The thesis is **true for v0.5.0+** (May 2025 onward). Anyone reading older docs or pinned to v0.4.x would correctly conclude the thesis was false at that time.

cdk-ldk-node was added to CDK in v0.12.0 (Aug 2025), three months after ldk-node v0.5.0 — so cdk-ldk-node has had description_hash support since day one.

## See also

- [[2026-05-28-ldk-node-bolt11-payment-source.md|bolt11.rs source]]
- [[2026-05-28-lightning-invoice-bolt11-description-enum.md|Bolt11InvoiceDescription enum]]
- [[2026-05-28-ldk-server-bolt11-description-hash-plumbing.md|ldk-server uses it in production]]
