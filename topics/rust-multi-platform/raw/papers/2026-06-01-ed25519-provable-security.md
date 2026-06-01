---
title: "The Provable Security of Ed25519: Theory and Practice"
source_url: https://eprint.iacr.org/2020/823.pdf
type: paper
ingested: 2026-06-01
quality: 5
confidence: high
venue: "IEEE S&P 2021"
authors: "Brendel, Cremers, Jackson, Zhao (CISPA / ETH Zurich)"
tags: [ed25519, formal-security, euf-cma, suf-cma, key-substitution]
relevance: [single-slot-identity, signed-envelopes]
---

# The Provable Security of Ed25519 (IEEE S&P 2021)

Authoritative security justification for choosing **RFC 8032 Ed25519** specifically when long-lived per-device keys are deployed in a multi-key fleet directory.

## The gap it fills

"No detailed proofs have ever been given for these security properties for EdDSA, and in particular its Ed25519 instantiations." Original 2011 paper had **no formal security proof until 2020**.

## Three variants distinguished

| Variant | EUF-CMA | SUF-CMA | M-S-UEO |
|---|---|---|---|
| Ed25519-Original (Bernstein et al.) | yes | **no** (malleable) | partial |
| Ed25519-IETF / RFC 8032 | yes | yes | yes |
| Ed25519-LibS (libsodium) | yes | yes | yes |

## Why this matters for fleet identity

- **EUF-CMA** = existential unforgeability under chosen-message attack (basic forgery resistance)
- **SUF-CMA** = strong unforgeability — needed to prevent malleability. Matters anywhere a signature is used as an idempotency key
- **M-S-UEO** = resistance to key-substitution attacks. **Critical when many keys exist in a fleet directory** — without it, an attacker could create a different `(key', sig')` pair valid for the same message

## Practical implication

Specify **RFC 8032 Ed25519** explicitly in the envelope spec. Don't just say "ed25519." The original variant is malleable; libsodium variant is fine but not all libraries match it.

## Caveat — see contrarian-1

Even with formal proofs, library-divergent verification is real (Cendyne 2022). Pin one verifier impl across server and edge.

## See also

- [[2026-06-01-cendyne-ed25519-deep-dive]]
- [[2026-06-01-rfc-9052-cose-structures]]
