---
title: "PR #2114 — NIP D8 Key Rotation (closed in favor of #2137)"
url: https://github.com/nostr-protocol/nips/pull/2114
retrieved: 2026-06-02
type: pr
---

Earlier key-rotation proposal by staab, opened 2025-11-07, closed 2025-12-20 in favor of PR #2137. The design used a pre-configured "migration key" (held in cold storage) that could sign a single rotation event without a time delay. It was intended to fix the latency problem of earlier holding-window schemes.

The PR was rejected for two stated reasons. (1) fiatjaf argued it inherits the worst property of NIP-26 — a "decoupling between identities" that forces relays/clients to do extra delegation lookups every time they encounter a new pubkey, and makes reliable relays a hard requirement against Nostr's "relays may fail anytime" design philosophy. (2) vitorpamplona deemed it "too complex" with "too many edge cases" and preferred simpler revocation (PR #1056). Author staab agreed the critiques were valid, conceding that "any key rotation scheme on nostr is going to come with some hefty assumptions," and consolidated the work into PR #2137. Useful as a record of why the obvious cold-storage delegation design does not work on Nostr.
