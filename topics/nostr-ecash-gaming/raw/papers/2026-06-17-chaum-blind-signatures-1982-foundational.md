---
title: "Chaum (1983) — Blind Signatures for Untraceable Payments — foundational primitive"
source: https://link.springer.com/chapter/10.1007/978-1-4757-0602-4_18
type: paper
tags: [chaum, blind-signature, foundational, cryptography, ecash, history]
fetched: 2026-06-17
confidence: high
credibility: high
quality_score: 5
relevance: indirect
direction: supports
summary: |
  Originating paper for blind signatures (CRYPTO '82, published 1983). Introduces the
  signer-blind authentication primitive (RSA-based original) with formal untraceability
  and unforgeability properties. Spawned the entire DigiCash → Cashu / Fedimint lineage.
  Every "blind-signed game token" claim downstream reduces to this primitive's properties.
---

# Chaum (1983) — Blind Signatures for Untraceable Payments

## Source

- Springer DOI: https://link.springer.com/chapter/10.1007/978-1-4757-0602-4_18
- (Open-access PDF mirrors searched but unavailable; Springer DOI is the authoritative
  citation.)
- Quality: 5 (foundational primitive paper)

## Findings

- Introduces the **blind signature** primitive (RSA-based original): signer signs a message
  hidden by a multiplicative blinding factor.
- Two formal properties:
  - **Untraceability** — signer cannot link the blinded signing event to the unblinded
    artifact
  - **Unforgeability** — under standard RSA verification
- Original framing: untraceable digital cash. But the abstraction is generic — any
  token-issuance protocol that needs issuer-blind authentication.
- Spawned: DigiCash → eCash → Cashu (BDHKE) / Fedimint (threshold blind sigs over guardians).
- Adjacent applications cited: anonymous voting, anonymous credentials, untraceable bearer
  instruments — all conceptually adjacent to in-game token ownership.

## Why this matters

Irreducible cryptographic root — every "blind-signed game token" claim ultimately reduces
to this primitive's untraceability + unforgeability properties. nutchain's threshold OPRF
over BDHKE is a direct descendant: it lifts the blind-sig from one signer to a threshold
group of game players.

## Quote

> "An ordinary digital signature can be verified by anyone using the corresponding public
> key. A blind signature, however, allows the message provider to prevent the signer from
> learning the content of the message being signed."
