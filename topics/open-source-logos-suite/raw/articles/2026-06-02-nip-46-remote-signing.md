---
title: "NIP-46: Nostr Connect / Remote Signing"
url: https://github.com/nostr-protocol/nips/blob/master/46.md
retrieved: 2026-06-02
type: spec
---

NIP-46 ("Nostr Connect", commonly called "bunkers") specifies a two-way protocol between a Nostr client and a separate remote signer process. The client never holds the private key; it sends signing requests over a Nostr-encrypted channel and the remote signer (Amber on Android, nsec.app, hardware-backed keystores) returns signatures.

The spec's stated rationale: "Private keys should be exposed to as few systems — apps, operating systems, devices — as possible as each system adds to the attack surface." This is a *prevention* mechanism, not a rotation mechanism. A NIP-46 setup makes nsec leaks much less likely (the key never leaves the signer), but it does NOT solve the post-compromise problem: if the bunker itself is compromised, or the user backs up the key insecurely, the underlying secp256k1 nsec is still un-rotatable. NIP-46 is therefore the strongest mitigation Nostr offers in 2026, but it is not a substitute for a missing rotation primitive.
