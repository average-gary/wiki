---
title: "Transparency Dictionaries with Succinct Proofs of Correct Operation (Verdict)"
source_url: https://www.ndss-symposium.org/ndss-paper/auto-draft-252/
type: paper
ingested: 2026-06-01
quality: 4
confidence: medium
venue: "NDSS 2022"
tags: [transparency-dictionary, snark, verifiable-computation, append-only]
relevance: [single-slot-identity, audit-logs]
---

# Verdict — Transparency Dictionaries (NDSS 2022)

Bridges from "append-only log" to "current-state-with-history" — exactly the "single-slot identity with version history" abstraction the topic targets.

## Contribution

Extends transparency-log primitives from append-only sequences (CT-style) to **transparency dictionaries**:
- label → value maps
- server can prove "X is the *current* value for label L and was reached via a permitted transition"
- not just "X exists in the log"

## Mechanism

- Succinct cryptographic proofs (SNARK-style verifiable computation)
- Attest correct service operation across batches of updates
- Reduces per-client verification cost to O(1)-ish — relevant for resource-constrained edge fleets where the verifier is the device

## Trade-off

Higher prover cost (SNARK generation is expensive) for cheap client-side verification.

## Why it matters for edge fleets

Models exactly the abstraction needed: "fleet identity directory where each device has at most one currently-valid identity, with permitted rotation transitions." Maps `(device_id) → (current_pubkey)` with append-only history of past transitions.

## See also

- [[2026-06-01-keytrans-protocol-draft]]
- [[2026-06-01-seemless-paper]]
