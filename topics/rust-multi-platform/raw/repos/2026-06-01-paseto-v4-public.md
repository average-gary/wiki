---
title: "PASETO v4.public Specification (Ed25519)"
source_url: https://github.com/paseto-standard/paseto-spec/blob/master/docs/01-Protocol-Versions/Version4.md
type: spec
ingested: 2026-06-01
quality: 4
confidence: high
tags: [paseto, ed25519, version-as-prefix, footer-kid]
relevance: [signed-envelopes]
---

# PASETO v4.public — version-as-prefix signed token

Strong example of "version-as-prefix" (un-spoofable) and footer-as-key-hint patterns for long-lived public-key tokens; an alternative point in the design space to COSE/DSSE.

## Token format

```
v4.public.<base64url(message || signature)>[.<base64url(footer)>]
```

Version is a **literal ASCII prefix** on the token, not a header field. Cannot be silently swapped for `v4.local` etc.

## Signature placement

Signature is the rightmost 64 bytes of the decoded payload (Ed25519). Message is the leftmost remainder (typically a JSON claims blob, but PASETO doesn't mandate JSON).

## Canonicalization (PAE)

PASETO-flavored PAE (distinct from DSSE's): packs `(header, message, footer, implicit-assertion)` with **little-endian 64-bit length prefixes** before signing.

## Footer as `kid` slot

PASETO recommends putting `{"kid": "..."}` in the optional footer. Footer is signed but is *not* the payload, so verifiers can read `kid` before key lookup without parsing claims.

## Key rotation

Spec **deliberately omits** key-rotation guidance — leaves it to the application. Community pattern is JWKS-style: publish a list of active public keys and dispatch via footer `kid`.

## See also

- [[2026-06-01-rfc-7517-jwk]] — JWKS pattern
- [[2026-06-01-dsse-envelope-spec]]
- [[2026-06-01-rfc-9052-cose-structures]]
