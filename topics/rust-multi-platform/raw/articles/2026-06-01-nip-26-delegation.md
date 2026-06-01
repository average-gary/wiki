---
title: "NIP-26 — Nostr Delegated Event Signing"
source_url: https://github.com/nostr-protocol/nips/blob/master/26.md
type: spec
ingested: 2026-06-01
quality: 4
confidence: high
tags: [nostr, nip-26, delegation, bearer-token, scoped-credential]
relevance: [single-slot-identity, signed-envelopes]
---

# NIP-26 — Delegated Event Signing

Demonstrates a minimal, signature-only delegation primitive (no X.509, no JWT issuer endpoint) that edge fleets can adopt for offline-verifiable scoped credentials.

## Delegation token

Schnorr signature over:
```
nostr:delegation:<delegatee_pubkey>:<conditions_query_string>
```

A self-contained, **offline-verifiable bearer token**.

## Conditions grammar

- `kind=N` — restrict to specific event kinds
- `created_at>T`, `created_at<T` — time bounds
- Combined with `&`

**Time-bounded delegation is first-class** — directly applicable to "this device may emit signed events for the next 30 days under the fleet root key."

## Delegated event format

Delegatee includes a `delegation` tag carrying `(delegator_pubkey, conditions, token)` on every signed event; relays verify conditions match before accepting.

## Where it breaks for edge fleet

**Revocation is implicit only** — relays SHOULD let the delegator delete events; there's no explicit revocation list or epoch. **Unacceptable for compliance/audit.**

But the delegation-token-as-bearer-credential with embedded conditions is a directly portable pattern for short-lived per-device signing certificates without a CA roundtrip.

## See also

- [[2026-06-01-nip-46-remote-signing]]
- [[2026-06-01-paseto-v4-public]] — alternative bearer-token format
- [[2026-06-01-uptane-standard]] — explicit-revocation alternative
