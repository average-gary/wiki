---
title: "secsync — E2EE relay architecture for CRDTs (Yjs/Automerge)"
url: https://github.com/serenity-kit/secsync
retrieved: 2026-06-02
type: repo
---

Secsync is the closest existing alternative to Keyhive for projects already on Yjs: "an architecture to relay end-to-end encrypted CRDTs over a central service." Beta status, ~228 stars, NGI Assure-funded, AGPL-ish licensed. Model: documents have an active *snapshot* (encrypted CRDT state) plus a stream of *updates* (encrypted CRDT changes referencing the snapshot) plus *ephemeral* messages (presence, cursors). Cryptography: XChaCha20-Poly1305-IETF for symmetric encryption, Ed25519 signatures for authenticity. Relay can see metadata (who participates, change frequency) but "cannot inject any participants nor data into a document." Working examples for both Yjs and Automerge. Notably *does not* implement a Continuous Group Key Agreement primitive — group key rotation / forward secrecy is left to the application; this is precisely the gap Keyhive's BeeKEM fills.
