---
title: "W3C Bitstring Status List v1.0 — what 'real' revocation infrastructure looks like"
source: https://www.w3.org/TR/vc-bitstring-status-list/
type: article
tags: [w3c, bitstring, vc, revocation, contrast, overkill]
date: 2026-06-01
publication_date: 2024
quality: 4
confidence: high
agent: adjacent
summary: "Each credential maps to one bit in a published bitstring; minimum list size 131,072 entries (~16KB) for herd anonymity. GZIP yields >90% compression on sparse revocations (a few hundred bytes for hundreds of revoked credentials in a 100k list). Privacy depends on issuer not creating per-credential lists. Verifiers SHOULD cache and use proxies to hide retrieval. Explicit tradeoff: bitstring vs short-lived credentials with periodic reissuance."
---

# W3C Bitstring Status List — the contrast

Useful **as a counter-example** in the wiki's design doc. Shows what "proper" revocation infrastructure costs, justifying the homelab's choice to skip it.

## Construction

```
bitstring = [bit_0, bit_1, ..., bit_N]   (N >= 131_072)
credential.status_index = i
revoked iff bitstring[i] == 1
```

Issuer publishes the bitstring at a stable URL. Verifiers fetch on each verification.

## Properties

- **Minimum size**: 131,072 entries (~16 KB) — for herd anonymity (you can't tell which credential I'm checking)
- **GZIP compression**: >90% on sparse revocations (a few hundred bytes for hundreds of revoked credentials in a 100k list)
- **Privacy depends on**: issuer not creating per-credential lists; verifier caching; proxies hiding retrieval

## Why this is overkill for a homelab

| Cost | Bitstring Status List | Homelab token wrapper |
|------|----------------------|----------------------|
| Infra | Stable URL, CDN, caching layer | None — file allowlist or DB |
| Min size | 16 KB always | Single byte (or row) per token |
| Verifier latency | HTTP GET per validation | Local lookup |
| Privacy | Herd anonymity needed | Don't care (single tenant) |
| Re-issuance | Optional | Token expires fast → reissue cheap |

## The explicit tradeoff in the spec

> "Bitstring lists trade infrastructure complexity for revocation flexibility against short-lived credentials with periodic reissuance."

→ For the homelab, **short-lived + reissuance wins**. See [[2026-06-01-langley-no-revcheck]] for the canonical argument.

## When this would matter

Bitstring lists are right when:

1. Credentials are long-lived (multi-year diplomas, government IDs)
2. Multiple unrelated verifiers (banks, employers, schools)
3. Privacy from the issuer matters (which schools are revoking degrees?)

None of these apply to a homelab AI server with a known friend group.

## See also

- [[2026-06-01-langley-no-revcheck]] — the short-lived alternative argument
- [[2026-06-01-rfc-6819-oauth-threats]] — family-revocation pattern
