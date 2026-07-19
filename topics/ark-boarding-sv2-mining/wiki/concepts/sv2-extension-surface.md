---
title: "The SV2 extension surface for a cosigning ceremony"
type: concept
created: 2026-07-17
updated: 2026-07-17
confidence: high
volatility: warm
verified: 2026-07-17
tags: [stratum-v2, extension, request-extensions, new-block-found, job-declaration, coinbase-output, verification-vs-custody]
sources:
  - raw/repos/2026-07-17-sv2-spec-extensions.md
  - raw/repos/2026-07-17-demand-share-accounting-ext.md
  - raw/articles/2026-07-17-sv2-job-negotiation-proxy.md
  - raw/articles/2026-07-17-hashpool.md
summary: "SV2 has a formal, negotiated, backward-compatible extension mechanism; a per-block trigger already exists (this repo's NewBlockFound, 0x03, EXTENSION_TYPE=32); Job Declaration lets a miner insert an arbitrary coinbase output (e.g. an n-of-n Ark batch address). Nothing forbids the extension — but it is net-new: the spec has zero notion of n-of-n/batch/custody. Critical caveat: the existing share-accounting extension is payout VERIFICATION, not an Ark custody layer — do not conflate."
---

# The SV2 extension surface for a cosigning ceremony

The "deliverable as an SV2 extension" sub-claim is **plausible but net-new**.

## The mechanism exists and is backward-compatible

SV2 defines a formal extension system: each extension gets an `extension_type`
identifier (core messages use `0x0000`); after `SetupConnection` a client sends
`RequestExtensions`, and servers that don't support it simply ignore the message —
so extensions are optional and non-breaking
([[../../raw/repos/2026-07-17-sv2-spec-extensions.md|sv2-spec 09-Extensions]]). The
registry already contains `0x0001` (negotiation) and `0x0002` (worker-specific
hashrate tracking) — precedent that accounting-adjacent extensions are in scope.

## A per-block trigger already ships

This repo's share-accounting extension uses `EXTENSION_TYPE = 32` and defines a
**`NewBlockFound` (0x03)** message the pool sends "when a miner found a valid block"
([[../../raw/repos/2026-07-17-demand-share-accounting-ext.md|demand-share-accounting-ext]]).
That is precisely the **post-block-found trigger** the thesis needs: the message
that would kick off the cosigning ceremony already exists on the wire.

## Job Declaration permits a miner-chosen coinbase output

SV2 Job Declaration lets the miner (JDC) build its own coinbase and add outputs —
the pool reserves a payout output, but the JDC "may add outputs … allocating
template revenue to addresses other than the pool payout"
([[../../raw/articles/2026-07-17-sv2-job-negotiation-proxy.md|SV2 job negotiation]]).
So inserting an **n-of-n Ark batch address** as a coinbase output is not forbidden.
Note the online party doing this is the **proxy/JDC**, not the ASIC — see
[[pure-receiver-and-liveness.md|liveness]].

## Two honest caveats

1. **Net-new.** The spec has "no discussion of n-of-n multisig outputs or batch
   commitments in coinbase transactions." This would be a brand-new extension, not
   a supported feature — nothing forbids it, but nobody has specified it.
2. **Verification ≠ custody.** The existing share-accounting extension (and
   hashpool's `ehash`) is a **payout accounting / verification** layer — hashpool is
   explicitly a *custodial Cashu mint*, with "no mention of Ark"
   ([[../../raw/articles/2026-07-17-hashpool.md|hashpool]]). Treating the current
   extension as though it already did Ark custody would be a category error. The
   thesis proposes a *new* custody/boarding extension that would sit alongside the
   accounting one.

## See Also

- [[post-block-found-signing.md|Post-block-found signing]]
- [[covenantless-batch-output-mechanics.md|Batch output mechanics]] — the ceremony the extension carries
- [[../topics/thesis-analysis-viability.md|Viability analysis (verdict)]]
