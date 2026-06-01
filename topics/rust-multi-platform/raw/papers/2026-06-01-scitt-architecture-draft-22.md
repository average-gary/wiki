---
title: "An Architecture for Trustworthy and Transparent Digital Supply Chains (SCITT)"
source_url: https://datatracker.ietf.org/doc/draft-ietf-scitt-architecture/
type: rfc-draft
ingested: 2026-06-01
quality: 5
confidence: high
tags: [scitt, transparency-log, signed-envelope, cose, append-only, ietf]
relevance: [signed-envelopes, audit-logs, single-slot-identity]
---

# SCITT Architecture (draft-ietf-scitt-architecture-22)

IETF SCITT WG; revision 22 published 2025-10-10. Currently in RFC Editor queue (per Historical agent).

## Three primitives

- **Signed Statement** — a `COSE_Sign1` message binding an issuer identity to artifact metadata
- **Receipt** — a COSE-signed inclusion proof against a transparency-service Merkle tree
- **Transparent Statement** — the signed statement carried alongside its receipt (typically receipt embedded in COSE unprotected header)

## Identity & rotation

Issuers MAY rotate signing keys per artifact: "Issuers MAY use different signing keys (identified by `kid` in the protected header) for different Artifacts or sign all Signed Statements under the same key." Key compromise/revocation strategies are explicitly **out of scope** — pushed to deployment.

## Append-only invariant

The verifiable data structure must be append-only: "the Statement Sequence cannot be modified, deleted, or reordered." References `draft-ietf-cose-merkle-tree-proofs` for the underlying log structure rather than mandating one.

## Why it matters for edge fleets

This is the canonical IETF architectural framing of (signed envelope) + (receipt) + (append-only registry) — which exactly mirrors the topic's three pillars. Forward-looking design target for any signed-envelope + audit-log fleet system shipping 2026+.

## Working group context

- WG chairs: Jon Geater, Nicole Bates
- Coordinates with OpenSSF, W3C, ISO, TCG
- 1,268 commits on main, 7 releases as of mid-2025
- Companion drafts: SCRAPI (REST API), Use Cases / Threat Model, Information/Interaction Model, Countersigning Format
- Not yet RFC; production use rare in 2026 — track but don't bet on

## See also

- [[2026-06-01-scrapi-draft]] — concrete REST API for SCITT
- [[2026-06-01-rfc-9162-ct-2-0]] — Merkle log primitives SCITT inherits
- [[2026-06-01-rfc-9052-cose-structures]] — envelope format SCITT uses
