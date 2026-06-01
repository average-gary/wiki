---
title: "TOML has no canonical form, unfit for signing (ALF #397)"
source_url: https://github.com/alamparelli/alf/issues/397
type: critique
ingested: 2026-06-01
quality: 4
confidence: high
tags: [toml, canonicalization, signed-envelope, jcs, contrarian]
relevance: [signed-envelopes]
---

# TOML Has No Canonical Form — Unfit for Signing

Concrete, named "do not sign your config file" guidance that contradicts the comfortable assumption that "we have envelope.toml so we can sign it."

## The problem

TOML has multiple representations of identical logical data:
- `{a = {b=1}}` (inline table)
- `[a]\nb=1` (regular table)

Both parse to the same tree but produce **different bytes** → different signatures over the same "manifest."

## Lenient parsers diverge on

- Whitespace
- Trailing commas
- Comment preservation
- Inline-vs-nested table choice

**No parser is canonical.**

## The right fix

NOT to canonicalize TOML. Instead:

1. Parse TOML
2. Project to JSON with sorted keys
3. Sign with **RFC 8785 JCS** (JSON Canonicalization Scheme) — or use deterministic CBOR (RFC 8949 §4.2)

**TOML on the wire is fine. JSON for the signing transform.**

Any system that tries to sign raw TOML (or raw YAML, same problem) is **broken by construction**. The signing format must be JCS-canonical JSON or deterministic CBOR — the source format is irrelevant.

## Det-CBOR pitfalls too

Deterministic-CBOR has its own pitfalls:
- RFC 8949 §4.2 vs old §3.9 differ
- Map-ordering rules differ across implementations

Pick one normative spec and pin it.

## Direct contradiction of topic phrasing

The topic frames "TOML/CBOR/Protobuf for long-lived ed25519." This source argues:

| Encoding | Signing-suitable? |
|---|---|
| TOML | **No** — no canonical form |
| YAML | **No** — same problem |
| Raw JSON | **No** — needs JCS canonicalization |
| Canonical JSON (JCS) | Yes |
| Deterministic CBOR (pin spec version) | Yes |
| Protobuf | Yes (deterministic field ordering by tag number) |

**Recommendation for the project**: keep TOML for human-edited source if needed, but the *signed bytes* must come from a deterministic transform — JCS JSON, det-CBOR, or protobuf wire format. Do not sign raw TOML.

## See also

- [[2026-06-01-rfc-9052-cose-structures]] — CBOR sign-the-bytes pattern
- [[2026-06-01-dsse-envelope-spec]] — PAE pattern (length-prefix to avoid canonicalization)
- [[2026-06-01-tuf-spec]] — uses canonical JSON
