---
title: "any-sync Protocol Overview"
source_url: "https://github.com/anyproto/any-sync"
type: article
path: case
date_ingested: 2026-05-27
date_published: unknown
tags: [case-study, decentralized, anytype, any-sync, crdt, e2e-encryption]
quality: 4
confidence: high
summary: "Anytype's any-sync protocol: CRDT-based, E2E encrypted, four-node-type architecture (sync/file/consensus/coordinator). One of the few production decentralized knowledge-app protocols with a real released client."
---

# any-sync Protocol Overview

## Key findings

Architecture: four node types — Sync nodes (store spaces/objects), File nodes (file storage), Consensus nodes (validate ACL changes), Coordinator nodes (network configuration).

Sync mechanism: data stored as encrypted DAGs. CRDT-based, "gas-less" — each device independently applies and cryptographically verifies updates without traditional consensus protocols.

Encryption: all channels E2E encrypted. "No external entity can view a channel's content" — including the relay providers themselves.

Design intent: providers are facilitators only. They "deliver sync and storage" but "cannot read user information, block users, or alter accounts." Users can switch providers without losing data — credible exit baked in.

## Notable quotes / specifics

- Spaces are "User-owned," "Permissionless," "End-to-end encrypted."
- Free hosted relays operated by Anytype today; users can self-host.
- Content stored in DAGs, signed by user keys — relay cannot tamper.
- The four-node-type split is heavier than Nostr's single relay role but lighter than running a full ATProto Relay.

## Source notes

Anytype is one of the few projects that ship a working decentralized E2E-encrypted knowledge app to real users. Worth studying the four-node split — it's a concrete answer to "how do you handle ACL/permissions in a CRDT world without a central server seeing plaintext." Note: most users in practice still hit Anytype's hosted relays rather than self-hosting (same pattern as Bluesky, Nostr).
