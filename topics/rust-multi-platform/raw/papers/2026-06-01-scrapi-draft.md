---
title: "SCITT Reference APIs (SCRAPI)"
source_url: https://datatracker.ietf.org/doc/draft-ietf-scitt-scrapi/
type: rfc-draft
ingested: 2026-06-01
quality: 4
confidence: high
tags: [scitt, rest-api, cose, audit-log, ietf]
relevance: [audit-logs, signed-envelopes]
---

# SCRAPI — SCITT Reference APIs

REST API spec for an interoperable SCITT Transparency Service.

## Three core endpoints

- `GET /.well-known/scitt-keys` — COSE Key Set discovery
- `POST /entries` — register a Signed Statement
- `GET /entries/{id}` — retrieve receipt

## Wire format

- Submission body is a `COSE_Sign1` object with protected/unprotected headers and signature
- Supports **detached payloads** for large artifacts (relevant for edge: payload stays on device, only digest hits the log)

## Sync vs async

- **Synchronous** — `201 Created` with receipt immediately
- **Asynchronous** — `303 See Other` redirect → poll → `302` (in progress) or `200 OK` (complete)
- Errors use **Concise Problem Details for CBOR (RFC 9290)**

## Key identification

Recommends **COSE Key Thumbprint (RFC 9679)** for `kid` assignment. This gives stable, content-addressed identity-from-pubkey mapping — the same trick TUF uses for keyids — eliminates kid spoofing across rotations.

## Why it matters

Concrete RPC-shape blueprint for "audit log over edge RPC." Identifies wire-level patterns (sync vs async receipt, kid as thumbprint, well-known key discovery) to reuse rather than invent.

## See also

- [[2026-06-01-scitt-architecture-draft-22]] — the architecture this API serves
- [[2026-06-01-rfc-9162-ct-2-0]]
