---
title: "RFC 9052 — CBOR Object Signing and Encryption (COSE): Structures and Process"
source_url: https://datatracker.ietf.org/doc/html/rfc9052
type: rfc
ingested: 2026-06-01
quality: 5
confidence: high
tags: [cose, cbor, signed-envelope, ed25519, rfc, ietf]
relevance: [signed-envelopes]
---

# RFC 9052 — COSE Structures and Process

The canonical reference for any CBOR-based device identity envelope.

## COSE_Sign1 structure

Fixed 4-element CBOR array:
```
[ protected, unprotected, payload, signature ]
```
Optionally tagged with CBOR tag 18.

## Critical canonicalization rule

The `protected` bucket is a CBOR-encoded **byte string** — its bytes are signed verbatim, **no canonicalization re-encode hazard**. The `unprotected` map is mutable and excluded from the signature.

## Sig_structure

Signature is computed over a `Sig_structure` containing:
- the literal context string `"Signature1"`
- the encoded protected headers
- external AAD
- the payload

Re-encoded as CBOR before passing to Ed25519/ECDSA. **Canonicalization story**: CBOR-of-the-bytes, not "canonical CBOR of the parsed object." Sidesteps the parser-canonicalization bug class.

## Key identification (`kid`, label 4)

Spec explicitly warns: "applications MUST NOT assume `kid` values are unique." This **directly enables overlapping rotation windows** where two keys share a `kid`.

## Versioning slot

`content type` (label 3) is the natural slot for envelope version / payload schema URI; placing it in `protected` binds it to the signature.

## Detached payload

Payload may be `nil` (detached) — useful for edge devices that ship the identity blob separately from the signed manifest.

## Why CBOR won for IoT signing (per Historical agent)

- ~2 KB parser footprint on Cortex-M
- Binary-native, no base64 step (~33% smaller than JOSE/JWS)
- Deterministic encoding (RFC 8949 §4.2)
- COSE_Sign1 is now the universal envelope in CWT (RFC 8392), EAT (RFC 9711), C2PA, FIDO CTAP2, EU Digital COVID Cert, SCITT

## See also

- [[2026-06-01-rfc-8152-historical]] — predecessor
- [[2026-06-01-scitt-architecture-draft-22]] — uses COSE_Sign1
- [[2026-06-01-dsse-envelope-spec]] — JSON alternative
