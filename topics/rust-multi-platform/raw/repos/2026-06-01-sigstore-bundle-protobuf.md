---
title: "Sigstore Bundle protobuf schema"
source_url: https://github.com/sigstore/protobuf-specs/blob/main/protos/sigstore_bundle.proto
type: spec
ingested: 2026-06-01
quality: 4
confidence: high
tags: [sigstore, protobuf, signed-envelope, media-type-versioning]
relevance: [signed-envelopes]
---

# Sigstore Bundle — protobuf signed-envelope format

Demonstrates **protobuf + media-type versioning** for signed envelopes, and the "short-lived cert vs long-lived key" trade-off.

## Encoding

Protobuf with a JSON projection. Versioning carried in `media_type`:
```
application/vnd.dev.sigstore.bundle.v0.3+json
```

The version is **in the MIME type string**, not a numeric protobuf field — un-spoofable since it's outside the parsed structure.

## Content

`oneof`:
- raw `MessageSignature`
- `io.intoto.Envelope dsse_envelope` (DSSE)

Bundles thus *wrap* DSSE rather than replace it.

## Constraint

"DSSE envelopes in a bundle MUST have exactly one signature" — **Sigstore explicitly forbids the multi-signature rotation model** and instead handles rotation via short-lived Fulcio certs in `verification_material`.

## Verification material

`verification_material` carries one of:
- opaque public-key hint
- X.509 chain
- single leaf cert

**v0.3 keyless bundles must use only the leaf cert** (chain rebuilt from trust root).

## Two philosophies of rotation

| Approach | Mechanism | Fits edge? |
|---|---|---|
| TUF / DSSE multi-sig | dual-sign chain across overlapping keys | yes (works offline) |
| Sigstore | short-lived (~10 min) cert under long-lived root | no (requires online sign) |

## Why it matters

If you choose protobuf for the wire format, this is the prior art for how to do it. If you need offline signing, this is the design to **not** copy.

## See also

- [[2026-06-01-sigstore-paper]]
- [[2026-06-01-rekor-v2-ga]]
- [[2026-06-01-dsse-envelope-spec]]
