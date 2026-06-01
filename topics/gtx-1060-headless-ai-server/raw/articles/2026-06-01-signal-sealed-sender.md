---
title: "Signal Sealed Sender — short-lived certs + profile-key rotation as revocation"
source: https://signal.org/blog/sealed-sender/
type: article
tags: [signal, sealed-sender, short-lived-cert, profile-key, revocation-pattern]
date: 2026-06-01
publication_date: 2018
quality: 4
confidence: high
agent: adjacent
summary: "Server accepts messages without authenticating the sender by relying on (a) a short-lived sender certificate (phone number, identity key, expiry — signed by Signal's CA) and (b) a 96-bit delivery token derived from the recipient's profile key. Revocation is implicit via short certificate lifetimes plus profile-key rotation when a contact is blocked. Abuse rate-limiting is preserved by gating sealed sends on contact-graph or opt-in."
---

# Signal Sealed Sender — revocation by rotating the derivation key

Direct precedent for "rotate the underlying secret = invalidate all derived tokens."

## Two-part construction

### Short-lived sender cert

```
SenderCert = sign(SignalCA, {
    phone_number,
    identity_key,
    expiry,   // short — hours/days
})
```

→ Signal's CA signs a short-lived statement of identity. Compromise → wait for expiry → reissue.

### Recipient-keyed delivery token

```
delivery_token = HKDF(recipient_profile_key, ephemeral_data)[..96 bits]
```

→ 96-bit token derived from the **recipient's** profile key. Server uses this to route without knowing sender identity.

## Revocation

**Implicit via two mechanisms**:

1. **Short cert lifetime** — leaked cert expires in hours
2. **Profile-key rotation when blocked** — recipient blocks sender → rotates profile key → all delivery tokens derived from old profile key now invalidate

## The pattern

> "Rotate the derivation key, all derived tokens silently expire. No revocation list, no checking."

This is **identical** to the Wesh-style seed-rotation pattern for the iroh app token:

```
// Signal:                              // Iroh app:
profile_key                             seed
HKDF(profile_key, ephemeral)            blake3::keyed_hash(seed, bucket)
delivery_token = ...[..96 bits]         rendezvous_tag = ...[..32 bytes]

// Block contact:                       // Revoke leaked QR:
rotate profile_key                      rotate seed
```

## Abuse rate-limiting note (the honest part)

> "Abuse rate-limiting is preserved by gating sealed sends on contact-graph or opt-in."

Anonymous bearer-token systems still need an out-of-band signal to prevent abuse. For Signal: contact-graph or opt-in. For iroh app token: the EndpointID allowlist is the rate-limiting anchor.

→ The iroh app token wrapper provides **two layers of defense**:

1. **Identity layer** (allowlist): EndpointID is in `/etc/farm-ai/allowed/` → can connect at all
2. **Capability layer** (token): which ALPNs / operations the connection can use

Removing an EndpointID from the allowlist = full revocation; rotating the seed = invalidate outstanding QRs (for as-yet-unpaired devices).

## See also

- [[2026-06-01-rfc-6819-oauth-threats]] — family-revocation
- [[2026-06-01-langley-no-revcheck]]
- [[2026-06-01-tor-onion-v3-client-auth]] — file-based allowlist
