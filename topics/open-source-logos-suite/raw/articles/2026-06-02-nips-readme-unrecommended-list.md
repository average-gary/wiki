---
title: "nostr-protocol/nips README — unrecommended NIPs list"
url: https://github.com/nostr-protocol/nips
retrieved: 2026-06-02
type: repo
---

The README of the canonical NIPs repository (`nostr-protocol/nips`) maintains a top-level index of every NIP and an explicit "unrecommended" section. As of 2026-06-02 the unrecommended list includes (at least): NIP-03, NIP-04, NIP-06, NIP-08, NIP-15, NIP-26, NIP-28, NIP-31, NIP-72, NIP-90, NIP-96, NIP-BE, and NIP-EE.

For the purposes of identity and key rotation, the two relevant flags are:

- NIP-06 — "prefer a single nsec"
- NIP-26 — "adds unnecessary burden for little gain"

The README does NOT list any merged NIP for key rotation, key migration, or compromise recovery. NIP-41 (a slot sometimes referenced in informal discussion as "key revocation") is not present in the index — fetching `41.md` returns 404. Identity-adjacent NIPs that ARE merged: NIP-05 (DNS identifiers), NIP-39 (external identities), NIP-42 (relay auth), NIP-46 (remote signing), NIP-49 (encrypted private keys), NIP-55 (Android signer), NIP-85 (trusted assertions). None of these provides a rotation primitive.
