---
title: "draft-ietf-moq-transport-18 — Media over QUIC Transport"
source: https://datatracker.ietf.org/doc/draft-ietf-moq-transport/
type: paper
tags: [moq, ietf, draft, pubsub, quic]
date: 2026-06-01
publication_date: 2026-05-12
quality: 5
confidence: high
agent: 1
summary: "IETF MoQ WG draft, rev -18 (2026-05-12). Four-level data model — Track → Group → Subgroup → Object. Subgroups map to QUIC streams for prioritization. Relays cache and forward but cannot combine/split/modify payloads; must forward unknown properties unchanged. WG plans IESG submission for Pub/Sub Protocol in Dec 2026."
---

# draft-ietf-moq-transport-18

Authoritative IETF draft for the MoQ pub/sub transport.

## Data model

- **Track** = (namespace, name) tuple — the unit subscribers request
- **Group** = temporal join point; ideally no cross-group dependencies (so subscribers can join at any group boundary)
- **Subgroup** = sequential objects inside a group, mapped 1:1 to a QUIC stream for stream-level prioritization
- **Object** = addressable byte sequence; metadata always visible to relays, payload optionally encrypted

Subgroup IDs are publisher-assigned and scoped to one group.

## Relay role

Relays are simultaneously publishers and subscribers but never the origin or terminal. Forwarding rules:

- MUST preserve object integrity — cannot combine, split, or modify payloads
- MUST forward unknown properties unchanged (forward-compatibility)
- Handle multi-publisher and graceful switchover

## WG status (mid-2026)

- 18 progressive revisions from -00; -18 dated 2026-05-12
- WG charter approved 2025-04-09
- Targeted IESG publication: **Dec 2026** for Pub/Sub Protocol; Mar 2027 for WARP/LOC/Privacy Pass
- Adjacent WG drafts: moq-msf (streaming format), moq-loc (low-overhead container), moq-cmsf (CMAF), moq-privacy-pass-auth, moq-secure-objects (E2E encryption)

## Key takeaway

Any "MoQ on Iroh" stack that wants WG-aligned semantics must implement the four-level model. moq-lite (a separate individual-submission draft) intentionally collapses this — see [[draft-lcurley-moq-lite-04]].
