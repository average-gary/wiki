---
title: "SEEMless: Secure End-to-End Encrypted Messaging with less Trust"
source_url: https://eprint.iacr.org/2018/607.pdf
type: paper
ingested: 2026-06-01
quality: 5
confidence: high
venue: "ACM CCS 2019"
tags: [seemless, vkd, append-only, zero-knowledge, key-transparency]
relevance: [single-slot-identity, audit-logs]
note: "PDF fetch 403; details from prior reads + citing literature"
---

# SEEMless (ACM CCS 2019)

Defines the **Verifiable Key Directory (VKD)** primitive — formal abstraction later adopted by KeyTrans/AKD.

## Key contributions

- **append-only Zero-Knowledge Set (aZKS)** — sparse Merkle prefix tree with commitments
- Privacy-preserving lookup, monitoring, audit at server-friendly cost
- Monitoring cost **independent of total user count** — fixes the CONIKS limitation
- Server publishes periodic epoch root commitments
- Auditors verify epoch-to-epoch append-only consistency

## Why it matters

The formal grounding behind the Meta/WhatsApp AKD library and IETF KeyTrans. If you want to understand *why* KeyTrans's two-tree design exists, this is the paper that proves the security properties.

For edge-fleet single-slot identity: SEEMless gives you the primitive "label has at most one current value, with append-only history" — which is **exactly** the abstraction.

## Lineage

Haber-Stornetta linking → CONIKS → SEEMless (formal model + scaling fix) → KeyTrans (IETF productization) → WhatsApp AKD (production deployment, 2 billion users).

## See also

- [[2026-06-01-coniks-paper]]
- [[2026-06-01-keytrans-protocol-draft]]
