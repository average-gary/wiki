---
title: "Uptane Standard 2.0.0 — Automotive OTA Update Security"
source_url: https://uptane.org/papers/uptane-standard.2.0.0.html
type: spec
ingested: 2026-06-01
quality: 5
confidence: high
tags: [uptane, automotive, ota, threshold-signing, role-separation, prior-art]
relevance: [signed-envelopes, single-slot-identity]
---

# Uptane Standard 2.0.0

Most mature production deployment of "long-lived hierarchical signing identity at fleet scale with offline cold keys, threshold trust, rollback protection, and regulator-grade audit trails" — the edge-fleet problem with a 10-year head start.

## Four-role key separation

| Role | Compromise blast radius |
|---|---|
| **Root** | Distributes/revokes the other three. Offline + threshold-signed. |
| **Targets** | Attests image authenticity |
| **Snapshot** | Pins which versions ship together |
| **Timestamp** | "This is the freshest metadata" |

## Offline cold key

Root key is offline + threshold-signed by multiple custodians — the canonical pattern for the cold key in a long-lived identity hierarchy.

## Threshold signing throughout

Critical metadata requires `t-of-n` signers. Single-key compromise doesn't forge updates.

## Rollback protection

Built-in via monotonic version counters in metadata — clients refuse any metadata older than what they've already trusted. **This is the missing piece NIP-26 lacks.**

## Primary/Secondary ECU split

A connected, capable Primary does full verification; resource-constrained Secondaries trust the Primary's distilled package. **Direct analog to edge-gateway + dumb-leaf-device topologies.**

## Auditable chain

Every update passes signed metadata at each hop, producing a documented evidence trail suitable for regulatory type-approval (UN R155/R156).

## Where it breaks for bidirectional edge fleets

Uptane assumes update consumers (vehicles) are mostly read-only — they don't sign data going *out*. Edge fleets are bidirectional. But the role-separation + offline-root + threshold + monotonic-version model is directly liftable.

## See also

- [[2026-06-01-tuf-spec]] — Uptane derives from TUF
- [[2026-06-01-mender-device-auth]]
- [[2026-06-01-keytrans-protocol-draft]]
