---
title: "RFC 9421 — HTTP Message Signatures"
source_url: https://datatracker.ietf.org/doc/html/rfc9421
type: rfc
ingested: 2026-06-01
quality: 5
confidence: high
tags: [http-signatures, selective-coverage, opaque-keyid, rfc]
relevance: [signed-envelopes, audit-logs]
---

# RFC 9421 — HTTP Message Signatures

Industry-standard answer to "how do you sign a structured message such that it survives non-malicious mutation" — direct reference for designing edge-fleet envelope coverage rules.

## Mechanism

Signs a canonicalized signature base built from explicitly-listed HTTP components plus signature parameters — **not the whole message**.

Components:
- `@method`, `@path`, `@authority`
- selected headers (chosen by signer)

Signature parameters:
- `created`
- `expires`
- `keyid`
- `alg`
- `nonce`
- `tag`

## Opaque keyid

`keyid` is opaque — the verifier resolves it to a key out-of-band, decoupling signing from any specific PKI.

## Survives intermediaries

Survives intermediary transformations (header reordering, value combination) that would break naive whole-message signatures.

## Foot-gun: replay protection

**Replay protection is NOT built in.** The spec defers to applications to enforce `created`/`expires` windows and nonce uniqueness — a known foot-gun.

## Detached signature

Lives in headers, not payload — useful when the same payload needs multiple signatures or when payload size matters.

## What the edge can borrow

The selective-coverage + named-component + opaque-keyid model is the right mental model for any signed-envelope format. For non-HTTP transports (MQTT, custom binary), the canonicalization rules don't directly apply, but the model does.

## See also

- [[2026-06-01-rfc-9052-cose-structures]]
- [[2026-06-01-dsse-envelope-spec]]
