---
title: "Key Transparency Protocol (KeyTrans) — draft-ietf-keytrans-protocol-04"
source_url: https://datatracker.ietf.org/doc/draft-ietf-keytrans-protocol/
type: rfc-draft
ingested: 2026-06-01
quality: 5
confidence: high
tags: [keytrans, key-transparency, merkle-tree, vrf, append-only, ietf]
relevance: [single-slot-identity, signed-envelopes, audit-logs]
---

# KeyTrans Protocol (draft-04, April 2026)

Authors: Brendan McMillion, Felix Linker. Derives directly from WhatsApp's production Auditable Key Directory (AKD) deployment.

## Two-tree design

- **Prefix tree** maps `(label, version)` → commitment of the value
- **Log tree** (left-balanced binary) chronologically appends prefix-tree roots — each prefix-tree mutation produces a new entry with timestamp

## Label privacy

A VRF derives prefix-tree search keys from labels: "Each label-version pair corresponds to a unique search key in the prefix tree. This search key is the output of executing the VRF." Server cannot learn which labels are being looked up.

## Rotation as versioning

New label versions are added rather than overwriting; users monitor that all version transitions for their label are authorized. **This is the cleanest formalization of "single-slot fleet identity with rotation"**:

- The label = the device slot ID (immutable for device lifetime)
- Each version = one rotation of the device's signing key
- Append-only history binds prior versions; no rotation can erase history

## Consistency invariant

"If root hash B is shown after root hash A, then root hash B contains all the same log entries as A with any new log entries added to the rightmost edge." Timestamps must be monotonic.

## Cipher agility

Cipher-suite agnostic; HMAC commitments specified, signature algorithm pluggable. Defaults compatible with ed25519.

## Why it matters

Most rigorous current spec for long-lived identity keys with versioned rotation in an append-only log — direct analogue to "versioned signed identity envelopes with rotation." If you want to copy a pattern off the shelf, this is it.

## See also

- [[2026-06-01-seemless-paper]] — formal model behind KeyTrans
- [[2026-06-01-coniks-paper]] — original key-transparency design
- [[2026-06-01-scitt-architecture-draft-22]]
