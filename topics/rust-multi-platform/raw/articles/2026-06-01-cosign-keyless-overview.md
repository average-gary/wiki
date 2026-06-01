---
title: "Sigstore Cosign — Keyless Signing & Rekor Transparency Log"
source_urls:
  - https://docs.sigstore.dev/cosign/signing/overview/
  - https://docs.sigstore.dev/logging/overview/
type: docs
ingested: 2026-06-01
quality: 5
confidence: high
tags: [sigstore, cosign, rekor, keyless, ephemeral-key, oidc]
relevance: [signed-envelopes, audit-logs, single-slot-identity]
---

# Sigstore Cosign — Keyless Signing Overview

Demonstrates the canonical modern pattern — short-lived identity certs + append-only transparency log — and shows exactly which parts assume connectivity (informing what edge has to redesign).

## The flip

Replaces long-lived signing keys entirely:
1. Ephemeral keypair generated in-memory
2. OIDC token presented to **Fulcio**
3. Fulcio issues short-lived (~10-min) cert binding OIDC identity to ephemeral pubkey
4. Signing happens
5. **Private key is destroyed**

## Audit anchor

The signing artifact (cert + signature + artifact hash) is appended to **Rekor** — Merkle-tree transparency log built on Trillian (now Tessera, see [[2026-06-01-rekor-v2-ga]]). Provides inclusion proofs and consistency proofs.

Verification uses cert + Rekor entry timestamp: "this identity signed this artifact at time T, and Rekor witnessed it." **No long-lived key to revoke.**

## Audit tooling

- Rekor Monitor — detects log forks/omissions
- Omniwitness — third-party witness
- Same threat model as Certificate Transparency

## Where it breaks for edge fleet

Depends on a reachable OIDC IdP and a reachable Fulcio/Rekor at sign-time. Edge devices in disconnected/intermittent environments **can't do keyless-OIDC every signature**.

But the **transparency-log-as-audit-spine** pattern is directly applicable to fleet audit logs, even if the signing identity remains long-lived ed25519.

## See also

- [[2026-06-01-sigstore-paper]]
- [[2026-06-01-rekor-v2-ga]]
- [[2026-06-01-cosign-v3]]
- [[2026-06-01-rfc-9162-ct-2-0]]
