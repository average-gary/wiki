---
title: "Haber & Stornetta — How to Time-Stamp a Digital Document (1991)"
source_url: https://en.wikipedia.org/wiki/Linked_timestamping
type: paper
ingested: 2026-06-01
date_published: 1991
quality: 5
confidence: high
tags: [haber-stornetta, linked-timestamping, hash-chain, foundational, history]
relevance: [audit-logs]
note: "Original paper paywalled at Springer; Wikipedia entry summarizes lineage. Surety 1995 commercialization references confirm details."
---

# Haber & Stornetta — Linked Timestamping (1991)

Establishes the 35-year hash-chain lineage that every modern signed-envelope audit log (Rekor, SCITT, blockchain) descends from.

## Core scheme

First published linked-timestamping scheme:
- Each new document's hash incorporates the hash of the previous document's certificate
- Forms a linear hash chain
- No single timestamping server can rewrite history

## Distributed-trust extension

Link to *several* prior documents and rely on third-party witnesses → split-view-style attacks (avant la lettre) become detectable.

## Bayer/Haber/Stornetta (1992) — Merkle tree extension

Direct ancestor of Certificate Transparency's Merkle log. Tree-based linking instead of linear → log-scale proofs.

## Commercialization

Commercialized in **Jan 1995 as Surety** — first commercial linked-timestamping service.

## Lineage to 2026

| Year | Event |
|---|---|
| 1991 | Haber-Stornetta linear linking |
| 1992 | Bayer/Haber/Stornetta tree linking |
| 1994 | Benaloh/de Mare Merkle accumulator |
| 1995 | Surety commercialization |
| 1998 | Schneier-Kelsey on-device chains |
| 2008 | Bitcoin (Nakamoto cites Haber-Stornetta) |
| 2013 | RFC 6962 Certificate Transparency |
| 2017 | Trillian (generic CT engine) |
| 2021 | Sigstore Rekor |
| 2025 | SCITT generalizes for any artifact |

## See also

- [[2026-06-01-schneier-kelsey-1998]]
- [[2026-06-01-rfc-9162-ct-2-0]]
- [[2026-06-01-sigstore-paper]]
- [[2026-06-01-scitt-architecture-draft-22]]
