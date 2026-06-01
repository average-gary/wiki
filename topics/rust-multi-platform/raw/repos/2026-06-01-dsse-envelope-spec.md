---
title: "DSSE — Dead Simple Signing Envelope"
source_urls:
  - https://github.com/secure-systems-lab/dsse/blob/master/envelope.md
  - https://github.com/secure-systems-lab/dsse/blob/master/protocol.md
type: spec
ingested: 2026-06-01
quality: 5
confidence: high
tags: [dsse, signed-envelope, json, pae, in-toto, sigstore]
relevance: [signed-envelopes]
---

# DSSE — Dead Simple Signing Envelope

The minimum viable signed envelope; demonstrates the "no envelope version, version lives in payloadType" pattern.

## Envelope schema (JSON)

```json
{
  "payload": "<base64 bytes>",
  "payloadType": "<URI or media type>",
  "signatures": [{"keyid": "...", "sig": "..."}]
}
```

## Versioning approach

**No envelope-level `version` field**. Versioning is delegated to the `payloadType` URI (e.g., `application/vnd.in-toto+json` plus the inner `_type`/`predicateType`). Two-axis versioning when paired with in-toto Statements.

## Multi-signature for rotation

`signatures` is an *array*; multiple `keyid`/`sig` pairs from different keys are explicitly allowed. **This is the rotation primitive**: dual-sign during transition, drop old kid after.

`keyid` is optional and treated as an opaque hint — verifiers must not trust it for key selection without independent binding.

## Pre-Authentication Encoding (PAE)

```
PAE(type, body) = "DSSEv1" + SP + LEN(type) + SP + type + SP + LEN(body) + SP + body
```

- `SP` = 0x20
- `LEN` = ASCII decimal length, no leading zeros
- Bytes signed: `Sign(PAE(UTF8(payloadType), serializedBody))`

## Why PAE matters

The literal string `"DSSEv1"` is the *protocol* version baked into every signature — **domain-separates DSSE signatures from any other ed25519 signature the key ever produces**.

Length-prefixing both fields removes any need for JSON canonicalization — explicitly why DSSE rejects canonical-JSON.

`payloadType` is cryptographically bound; you cannot relabel a payload without breaking the signature, so type confusion is structurally prevented.

## TOML question, answered

`serializedBody` is opaque to DSSE. **A TOML, CBOR, or protobuf body is fine as long as `payloadType` names the encoding.** This is the cleanest answer to "can I use TOML?" — yes, *inside* a DSSE-style envelope, but the envelope itself stays JSON.

## Why ingest

- PAE is the gold standard for "tag + length + bytes" pre-hash framing
- Directly applicable to a custom edge-device envelope spec to avoid canonicalization bugs
- Multi-sig array is a clean rotation pattern for offline / intermittent-connectivity edge fleets

## See also

- [[2026-06-01-rfc-9052-cose-structures]] — CBOR alternative
- [[2026-06-01-in-toto-attestation-statement]]
- [[2026-06-01-sigstore-bundle-protobuf]]
- [[2026-06-01-toml-no-canonical-form]] — why source format ≠ signed format
