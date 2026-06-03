---
title: "anyproto/any-sync — Anytype's E2EE CRDT sync protocol"
url: https://github.com/anyproto/any-sync
retrieved: 2026-06-02
type: repo
---

Anytype's any-sync is a deployed (millions of users) MIT-licensed E2EE CRDT sync stack. Architecture splits roles across sync nodes (store spaces/objects), file nodes (file storage), consensus nodes (monitor ACL changes), and coordinator nodes (network config). Data structures are encrypted DAGs; "every change is cryptographically signed" through the CRDT, so devices verify updates without a central consensus protocol. Identity is DID-based with Curve25519 keypairs. Each "space" is the multi-participant unit; permissions and membership are enforced cryptographically. License: MIT. Comparison anchor for Keyhive: any-sync is *production-grade* and *deployed* but its group-membership model is bespoke + tied to Anytype's data model, while Keyhive aims to be a *generic* substrate that any local-first app (Automerge, Yjs adapters TBD) can adopt.
