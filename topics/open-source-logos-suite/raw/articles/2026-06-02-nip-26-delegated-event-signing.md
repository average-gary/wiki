---
title: "NIP-26: Delegated Event Signing (unrecommended)"
url: https://github.com/nostr-protocol/nips/blob/master/26.md
retrieved: 2026-06-02
type: spec
---

NIP-26 specifies a "delegation" tag that lets one keypair sign Nostr events on behalf of a root pubkey, with optional condition strings limiting authorization by event kind and timestamp range. The intended use case was holding a root key in cold storage while letting clients use ephemeral hot keys.

The canonical NIPs repository now flags NIP-26 with the warning: `"unrecommended": adds unnecessary burden for little gain`. The note appears at the top of the document and is mirrored in the repo README's "unrecommended" section. Wider community commentary (visible in PR discussions like #2114) reinforces that NIP-26 is treated as a cautionary precedent rather than a building block: it forces relays and clients to do extra delegation lookups every time they encounter a new pubkey, and it does not solve the underlying compromise-recovery problem. As of 2026-06-02 it remains in the spec only for historical and compatibility reasons.
