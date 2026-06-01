---
title: "Split-View Attack on Transparency Logs (Parker et al. + A-SIT)"
source_urls:
  - https://www.cs.ox.ac.uk/people/david.parker/papers/spc20.pdf
  - https://technology.a-sit.at/en/split-view-attack-protection-for-transparency-systems/
type: critique
ingested: 2026-06-01
quality: 4
confidence: high
tags: [transparency-log, split-view, gossip, witness, contrarian]
relevance: [audit-logs]
---

# Split-View Attack on Append-Only Logs

Forces honesty about what an "append-only audit log" actually guarantees. Without witnesses or sufficient gossip, it's audit theater.

## The fundamental break

A malicious log operator shows victim-A one view and victim-B another. Both views are:
- Internally consistent
- Signed by the operator
- Append-only on their own

Neither contradicting the other unless they gossip.

**Append-only is a property of the data structure, not the system.** Without external verification it's just "log + signature" and the operator can fork at will.

## Detection requires either

| Mechanism | Works for | Cost |
|---|---|---|
| **Client gossip** | Large user populations | Free, but needs threshold of clients |
| **Witness co-signing** | Any size | Witnesses are new SPOF |

## Why client gossip doesn't fit small edge fleets

- Pure client gossip needs a non-trivial fraction of clients to participate
- Small/edge fleets (10s-100s of devices) rarely cross threshold
- A 50-device fleet doesn't statistically detect a fork

## Why witnesses are non-trivial

Running additional infrastructure with its own:
- Identity
- Key management
- Availability requirements

Witnesses become a new trust dependency.

## The 2025-2026 industry response

Apple Private Cloud Compute (PCC) and Sigstore both adopted **witness frameworks** rather than relying on append-only-log signatures alone. Strong signal that single-signer logs are insufficient.

Rekor v2 GA (Oct 2025) — witness cosigning forthcoming.

## Recommendation for edge-fleet plans

Be explicit in the threat model:

| Choice | Threat coverage |
|---|---|
| Server signs log; no witnesses | Trusts server. Audit theater. |
| Server signs log; clients gossip | Catches forks IF fleet ≥ ~100 active devices |
| Server signs log; 1-2 witnesses co-sign STH | Catches forks at any fleet size; witnesses are new SPOF |
| Server signs log + Sigstore Rekor mirror | Witnesses-as-a-service via Rekor's witness pool |

For small fleets, **mirror the audit log into a public transparency service** (Rekor) — outsource witness infrastructure.

## See also

- [[2026-06-01-rfc-9162-ct-2-0]]
- [[2026-06-01-rekor-v2-ga]]
- [[2026-06-01-coniks-paper]]
