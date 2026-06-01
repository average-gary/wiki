---
title: "in-toto Attestation Statement v1"
source_url: https://github.com/in-toto/attestation/blob/main/spec/v1/statement.md
type: spec
ingested: 2026-06-01
quality: 4
confidence: high
tags: [in-toto, attestation, dsse, layered-versioning]
relevance: [signed-envelopes]
---

# in-toto Attestation Statement v1 — Layered Versioning

Canonical example of layered versioning (envelope vs. statement vs. predicate) — directly applicable to long-lived device identity that must outlive multiple schema revisions.

## Schema

```json
{
  "_type": "https://in-toto.io/Statement/v1",
  "subject": [{"name": "...", "digest": {"sha256": "..."}}],
  "predicateType": "<URI>",
  "predicate": { ... }
}
```

Wrapped in a DSSE envelope with `payloadType = "application/vnd.in-toto+json"`.

## Two-axis versioning

- `_type` URI versions the **outer schema** (`https://in-toto.io/Statement/v1`)
- `predicateType` URI versions the **inner predicate** independently

Either can evolve without breaking the other.

## URI-based versions

Self-describing and namespaced — no central registry needed, consumers branch on the URI.

## Subject matching = digest only

Subject matching is by digest, not by name. **Perfect analog for edge devices identified by hardware-rooted fingerprints rather than mutable hostnames.**

## Why this layering matters for fleet identity

Outer envelope handles signing+rotation.
Inner statement schema evolves on its own URI cadence.
Predicate (the actual device claim — "I am device X with these attrs") evolves independently of both.

The wiki's topic phrasing — "**versioned** signed identity envelopes" — should likely adopt this three-layer split:
- v1 envelope (DSSE/COSE) — stable across the fleet's lifetime
- v1 statement schema — evolves rarely (once per major fleet redesign)
- v1 predicate — evolves more often (new attrs, new attestation types)

## See also

- [[2026-06-01-dsse-envelope-spec]]
- [[2026-06-01-tuf-spec]]
