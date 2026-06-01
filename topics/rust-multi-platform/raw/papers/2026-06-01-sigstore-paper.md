---
title: "Sigstore: Software Signing for Everybody (CCS '22)"
source_url: https://research.google/pubs/pub51999/
type: paper
ingested: 2026-06-01
quality: 5
confidence: high
tags: [sigstore, rekor, fulcio, ephemeral-keys, transparency-log, ccs-2022]
relevance: [signed-envelopes, audit-logs, single-slot-identity]
note: "PDF behind 403 paywall on ACM; abstract claims via indexed citations"
---

# Sigstore: Software Signing for Everybody (ACM CCS 2022)

The reference paper for the **opposite design model** to "long-lived ed25519 with rotation."

## Core insight

Decouple "who signed" from "which key signed":

- Long-lived identity = OIDC subject (e.g., GitHub identity, email)
- Signing key = ephemeral, generated in memory, valid ~10 minutes
- Fulcio CA binds the ephemeral pubkey to the OIDC identity in a short-lived X.509 cert
- Rekor (transparency log) records every signature event, providing non-repudiation through inclusion proofs

The long-lived key problem **vanishes**: there's no long-lived key to rotate, leak, or revoke. Compromise window = ~10 min.

## Building blocks

- **Rekor** — Trillian-backed Merkle log for arbitrary signed artifacts
- **Fulcio** — short-lived cert issuer
- **Cosign** — client tooling

## Why it matters as a counter-pattern

The wiki's topic frames the question as "long-lived ed25519 with rotation," but Sigstore explicitly rejects that frame. Edge fleet plans should reason about which model fits:

| Aspect | Long-lived ed25519 + rotation | Sigstore-style ephemeral |
|---|---|---|
| Connectivity | works offline | requires OIDC + Fulcio + Rekor at sign time |
| Rotation pain | high (key history, dual-sign windows) | none |
| Revocation | hard (CRL, JWKS update) | not needed |
| Audit log | external, optional | mandatory, integrated |
| Fits edge devices | yes (intermittent connectivity OK) | no (requires online sign) |
| Fits CI/CD/cloud | overkill | excellent |

## Adoption signals (per News/Trends agent)

- Maven Central (Jan 2025)
- NVIDIA NGC model signing (Jul 2025)
- PyPI Sigstore signing (Nov 2024)
- Homebrew in-toto attestations (May 2024)
- npm, GitHub Actions, Kubernetes upstream

Cited by USENIX Security 2026 work ("Why Johnny Adopts Identity-Based Software Signing").

## See also

- [[2026-06-01-rekor-v2-ga]]
- [[2026-06-01-cosign-keyless-overview]]
- [[2026-06-01-scitt-architecture-draft-22]] — generalizes Sigstore from software to "any artifact"
