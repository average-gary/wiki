---
title: "RFC 8152 — COSE (2017, obsoleted by RFC 9052/9053)"
source_url: https://datatracker.ietf.org/doc/html/rfc8152
type: rfc
ingested: 2026-06-01
date_published: 2017-07
quality: 5
confidence: high
tags: [cose, cbor, history, encoding-evolution, iot]
relevance: [signed-envelopes]
---

# RFC 8152 — COSE (2017) Historical Context

Defined the binary signed-envelope format that won the IoT/edge signing market over JOSE/JWS.

## Why CBOR over JOSE for IoT

- base64url is ~33% bloat over wire — forces JSON parsers onto constrained MCUs
- CBOR is binary-native, deterministic, smaller
- Parses with **<2 KB of code**

## The universal envelope

`COSE_Sign1` (single signer, headers and signature in same buckets) became the universal envelope in:
- CWT (RFC 8392)
- EAT — Entity Attestation Token (RFC 9711)
- C2PA (content provenance)
- FIDO CTAP2
- EU Digital COVID Cert
- SCITT

## Encoding evolution

| Era | Encoding | Driver |
|---|---|---|
| 1980s+ | ASN.1/DER (X.509) | telecom origin |
| 2015 | JOSE/JWS (RFC 7515) | web era |
| 2017 | COSE/CBOR (RFC 8152) | IoT era |
| 2022 | RFC 9052/9053 split | maintainability |

Each generation traded human readability for either tooling or wire efficiency.

## Why CBOR won for IoT signing

Hardware crypto on Cortex-M can produce a COSE_Sign1 in **~100 ms** with:
- No JSON parser
- No base64 step
- Stable byte ordering (deterministic CBOR / dCBOR)

The only viable choice for bandwidth-constrained, battery-powered fleets.

## See also

- [[2026-06-01-rfc-9052-cose-structures]] — current spec
- [[2026-06-01-fleet-ops-numerical-baseline]] — encoding size data
