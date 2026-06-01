---
title: "SV2 Spec — Discussion (10): Deployment scenarios and the missing v2→v1 proxy"
url: https://github.com/stratum-mining/sv2-spec/blob/main/10-Discussion.md
type: paper
source: stratum-mining/sv2-spec
captured: 2026-05-28
quality: 10
path: 3
tags: [deployment, translator, reverse-translator, sri, scenarios, sv1-upstream, spec-gap]
---

# SV2 Spec — Discussion (10)

## Why this matters for the reverse translator

This is the spec's own deployment-scenarios section. It enumerates four supported topologies — and **explicitly leaves "Proxy (v2 → v1)" undefined (section 10.4.5 is just `...`)**. The reverse translator is a topology the SV2 designers acknowledged but chose not to specify. That's not an oversight; it's a signal.

## Documented deployment scenarios (Section 10.4)

1. **End Device (v2 ST)** — standard channel, header-only mining, receives Merkle root from upstream
2. **Transparent Proxy (v2→v2)** — connection aggregation, no difficulty modification
3. **Difficulty Aggregating Proxy (v2→v2 EX)** — merges multiple standard channels into extended channels with aggregated difficulty
4. **Legacy Translation Proxy (v1→v2)** — converts legacy v1 clients to v2 upstream; spec marked incomplete ("Accept Opens...")

## Section 10.4.5 — Proxy (v2 → v1)

Spec body: `...`

That's it. The reverse direction — SV2 client to SV1 upstream — has *no* normative spec text. Anyone building one is on their own.

## Implications

- **No reference design**: SRI's `roles/translator` ships v1→v2 only
- **No conformance test**: nothing to validate against
- **No standardized failure modes**: every reverse-translator implementation will solve the lossy-mapping problem differently
- **No protocol identity binding**: see [[2026-05-28-path3-sv2-spec-protocol-security-noise.md]] — the egress plaintext segment has no spec-defined attestation flow

## Role-compatibility summary from spec

- End devices connect directly to upstream
- Proxies aggregate multiple downstream
- Multiple proxy layers are permitted
- Cross-version translation occurs **primarily downward** (v1→v2)

## Feature-survival verdict (reverse translator)

| Feature | Status | Why |
|---|---|---|
| Spec-conformant reverse-translator topology | **lost** | Spec doesn't define it |
| Reference implementation | **lost** | SRI ships v1→v2 only |
| Standardized lossy-mapping rules | **lost** | Implementer's burden |
| Protocol-level identity binding across SV1 egress | **lost-but-replaceable** | Implementer can layer TLS+pinning, but it's bespoke |

## Ingest justification

This is the smoking gun: **the SV2 spec authors deliberately left the reverse direction undefined.** Anyone building a reverse-translator is operating outside spec, with no conformance target, no reference, and no standard failure modes. Critical context for the migration-economics argument.
