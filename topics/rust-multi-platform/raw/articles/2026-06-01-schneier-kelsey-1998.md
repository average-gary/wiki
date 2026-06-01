---
title: "Schneier & Kelsey — Cryptographic Support for Secure Logs on Untrusted Machines (1998)"
source_url: https://www.schneier.com/academic/paperfiles/paper-auditlogs.pdf
type: paper
ingested: 2026-06-01
date_published: 1998
venue: "USENIX Security Symposium"
quality: 5
confidence: high
tags: [schneier, secure-logs, hash-chain, forward-secure, foundational]
relevance: [audit-logs, single-slot-identity]
---

# Schneier & Kelsey — Secure Logs on Untrusted Machines (USENIX 1998)

Canonical citation for "tamper-evident log on an edge device you don't fully trust" — directly relevant to fleet audit envelopes.

## What it solves

First scheme to make a *local* log on a compromised host tamper-evident **even after the attacker captures the machine**.

## Hash-chain construction

```
A_i = H(A_{i-1} ‖ data_i ‖ type_i)
```

Altering any past record invalidates all subsequent links.

## Forward-secure key evolution

- A_i is MACed under a key K_i
- K_i = H(K_{i-1})
- Old keys are erased
- An attacker who steals the machine cannot forge or undetectably edit prior entries

## Threat-model contrast with CT

| | Schneier-Kelsey 1998 | RFC 6962 CT |
|---|---|---|
| Trust assumption | brief uncompromised init window only | log operator distrusted always |
| Audit | local log on edge device | global log with witnesses |
| Verification | future log entries chained from earlier | external gossip |

**Both models are needed for edge fleets**: device-local secure log (Schneier-Kelsey) when offline + transparency log (CT-style) for audit at scale.

## Predecessors

- Bellare-Yee forward-secure MACs (1997)
- Haber-Stornetta linking (1991)

## Successors

Every "append-only log on edge device" pattern uses this hash-chain + key-evolution combo:
- Linux audit secure logs
- AWS CloudTrail Lake
- sigstore-on-device
- Modern attested journals

## Why it matters for the topic

The "append-only audit logs over edge RPC" pillar has two halves:
1. **At-edge**: device must produce a tamper-evident local log even if compromised after-the-fact → Schneier-Kelsey forward-secure hash chain
2. **In-transit and at-server**: log must resist server tampering → CT-style Merkle log + witnesses

Modern systems combine both. The wiki's plan should treat them as complementary, not alternatives.

## See also

- [[2026-06-01-haber-stornetta-1991]]
- [[2026-06-01-rfc-9162-ct-2-0]]
- [[2026-06-01-rekor-v2-ga]]
