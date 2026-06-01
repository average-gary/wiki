---
title: "NIP-46 — Nostr Remote Signing"
source_url: https://github.com/nostr-protocol/nips/blob/master/46.md
type: spec
ingested: 2026-06-01
quality: 5
confidence: high
tags: [nostr, nip-46, remote-signer, hot-cold-key-split, ephemeral-key]
relevance: [single-slot-identity, signed-envelopes]
---

# NIP-46 — Nostr Remote Signing

Closest off-the-shelf design for "long-lived cold key + scoped, ephemeral hot signers talking over an untrusted broker" — exactly the edge-fleet enrollment + signed-envelope shape.

## Three-keypair separation

| Keypair | Lifetime | Where it lives |
|---|---|---|
| **user-keypair** | long-lived | signer daemon only — never touches clients |
| **remote-signer-keypair** | long-lived | transport identity (may differ from user key) |
| **client-keypair** | ephemeral | per-session; deleted on logout |

## Transport

Encrypted JSON-RPC over `kind:24133` events (NIP-44 encryption). **Independent of any TLS/PKI assumption** — the relay is an untrusted broker.

## Pairing URIs

```
bunker://<pubkey>?relay=<url>&secret=<token>
nostrconnect://...
```

Secret prevents spoofing during connect.

## Permission grammar

`method[:params]` — e.g., `sign_event:4` = "may sign only kind-4 events". Passed at connect-time and enforced by the signer.

## Transport migration

Signer can call `switch_relays` to migrate transport without re-pairing — clean separation of identity from transport endpoint.

## Where it breaks for edge fleet

- **No key rotation or revocation guidance** — entirely implementation-specific
- Edge fleets need to add this layer themselves

The ephemeral client key model maps cleanly to per-device session keys backed by a fleet-level cold key.

## See also

- [[2026-06-01-nip-26-delegation]]
- [[2026-06-01-uptane-standard]] — solves the rotation gap NIP-46 doesn't
