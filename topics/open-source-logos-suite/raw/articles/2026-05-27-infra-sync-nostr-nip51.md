---
title: "NIP-51: Lists (Nostr Personal Data Sync)"
source_url: "https://github.com/nostr-protocol/nips/blob/master/51.md"
type: article
path: infra-sync
date_ingested: 2026-05-27
date_published: 2024-06-01
tags: [decentralized, identity, sync, nostr, lists, encryption]
quality: 4
confidence: high
summary: "Nostr's NIP-51 defines replaceable list events (bookmarks, highlights, mute lists) with NIP-44-encrypted private content, synced across devices through user-chosen relays."
---

# NIP-51: Lists (Nostr Personal Data Sync)

## Key findings

- **Identity**: Single secp256k1 keypair (npub/nsec). No DID layer. Pubkey IS the identity. Loss of nsec = total loss.
- **Data model**: Replaceable events keyed by `(pubkey, kind)`. Kind 10003 = bookmarks, 10001 = pinned, 10000 = mute list, 30003 = curated bookmark sets. Public items in `tags`, private items as JSON encrypted into `.content`.
- **Sync**: User publishes signed events to N relays of their choice. Other devices subscribe to the same relays by pubkey. Latest-write-wins (replaceable events).
- **Encryption**: Private list items use NIP-44 (modern, ChaCha20+HMAC) — shared key derived from author's own pub+priv (self-encryption for private personal data). NIP-04 still supported with auto-detection.
- **Recovery**: Effectively none. nsec backup IS the recovery story. NIP-26 delegation and NIP-46 remote signers (Nsec Bunker, nostr-connect) emerging as UX mitigations.
- **Production apps**: Damus, Amethyst, Primal, Snort, Habla.news, Highlighter, Coracle. Several Bible-adjacent: Wavlake (audio), Olas, and reading-club use cases via 30003 bookmark sets.

## Notable quotes / specifics

- Private items "stringified and encrypted using the same scheme from NIP-44 (the shared key is computed using the author's public and private key)."
- "Clients can automatically discover if the encryption is NIP-04 or NIP-44 by searching for 'iv' in the ciphertext."

## Source notes

Solid for highlights/bookmarks/reading lists. Free public relays exist (degrade-gracefully default). Cheap to self-host nostr-rs-relay or strfry. Weak for large/structured docs (sermon drafts, big notes) — events are typically <64KB and replaceable semantics are coarse. Best paired with a CRDT layer for rich notes. Hardest problem: nsec key recovery for non-technical users — currently being addressed by NIP-46 bunkers but not solved.
