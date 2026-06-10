---
title: CLINK Offers Specification (clink-offers.md)
source: https://github.com/shocknet/clink/blob/main/specs/clink-offers.md
type: repo
ingested: 2026-06-09
path: comparison
quality: 5
credibility: high
tags: [clink, lnurl, lud-06, lud-16, nip-57, zaps, offers, noffer, kind-21001, comparison]
---

## Source overview

The official CLINK Offers spec in the `shocknet/clink` GitHub repo. This is the canonical document positioning CLINK Offers explicitly as a replacement for LNURL-Pay (LUD-06) and the LNURL-callback portion of NIP-57 zaps. Defines event kind `21001`, the bech32 `noffer1...` static payment code format, the request/response flow over Nostr, and the integration story with NIP-57.

Quality 5 because it is the official protocol spec and contains explicit, on-the-record comparisons rather than marketing.

## Key findings (comparison axes)

### 1. Identity / addressing
- **LNURL-pay (LUD-06)**: bech32-encoded HTTPS URL. Identity is a domain name controlled by whoever holds the TLS certificate.
- **LUD-16 Lightning Address**: `user@domain` mapped to `https://domain/.well-known/lnurlp/user`. Identity is again domain-rooted.
- **CLINK Offers**: `noffer1...` bech32 string carrying `(service_pubkey, relay, offer_id, [pricing])`. Identity is a Nostr secp256k1 pubkey — no DNS, no CA chain.

### 2. Transport
- **LNURL-pay**: HTTPS GET to a callback URL; service must run a TLS web server (or rely on a custodian who does).
- **CLINK Offers**: encrypted Nostr events (NIP-44) on relays. Service only needs an outbound relay subscription; no inbound web server.

### 3. Custody pressure
The spec states the structural problem with LNURL-pay leads users into custody:
> "Current Lightning payment flows either require maintaining HTTP endpoints, leading to unnecessary complexity and centralization risks in self-hosted scenarios, or depend on slow and unreliable P2P transport mechanisms"

This frames LNURL's web-infra requirement as the *cause* of LN-Address centralization on a few custodial providers (Wallet of Satoshi, Alby, Coinos, etc.).

### 4. Privacy from the relay/host
- LNURL-pay leaks the recipient domain to anyone observing DNS/TLS SNI; the LNURL server sees the full request and IP.
- CLINK Offers requests are NIP-44 encrypted to the service pubkey; relays see only ciphertext + recipient pubkey.

### 5. Atomicity of payment + Nostr metadata
The spec explicitly integrates with NIP-57 zaps by allowing zap payloads to be embedded directly in the kind `21001` request, removing the LNURL-server intermediary that NIP-57 currently relies on (the trust hop noted in NIP-57 itself: "the zap receipt is not a proof of payment, all it proves is that some nostr user fetched an invoice").

### 6. Trust anchors
- **LNURL/LN-Address**: Web PKI + DNS + the operator of the `.well-known/lnurlp/` endpoint.
- **CLINK Offers**: Nostr keypair + relay availability. No CA, no DNS.

## Comparison matrix data

| Axis | LNURL-pay (LUD-06) | LN-Address (LUD-16) | NIP-57 zaps | CLINK Offers (kind 21001) |
|---|---|---|---|---|
| Identifier | bech32 `lnurl1...` | `user@domain` | LNURL on profile | `noffer1...` |
| Identity root | TLS cert / DNS | DNS | DNS (via LNURL) | Nostr pubkey |
| Transport | HTTPS GET | HTTPS GET (.well-known) | HTTPS GET + Nostr events | Nostr ephemeral events |
| Encryption | TLS (server-terminated) | TLS | TLS | NIP-44 (end-to-end) |
| Server requirement | Web server + TLS | Web server + TLS | LNURL server | Relay subscription only |
| Encryption to recipient | No (TLS terminates at server) | No | No | Yes (NIP-44 to service pubkey) |
| Receipt mechanism | Out of band | Out of band | kind 9735 (trusted) | Optional kind 21001 response |
| BOLT11 invoice carried? | Yes | Yes | Yes | Yes |

## Direct quotes

> "This specification defines **CLINK Offers**, a format for static payment codes in Nostr (`noffer1...`). It serves as a Nostr-native successor to LNURL-Pay."

> "Current Lightning payment flows either require maintaining HTTP endpoints, leading to unnecessary complexity and centralization risks in self-hosted scenarios, or depend on slow and unreliable P2P transport mechanisms"

> "By leveraging Nostr's native capabilities…CLINK Offers provides a more direct and robust alternative."

> "LNURL-pay callback step" dependencies are eliminated through the Nostr-native approach, providing "a more direct and robust alternative that eliminates these dependencies"

(The "slow and unreliable P2P transport mechanisms" line is a clear swipe at BOLT12's onion-message dependence, even though BOLT12 isn't named.)

## Open questions surfaced

- How does CLINK Offers handle the LUD-12 comments / LUD-18 payerData feature surface? Is parity intended or is the spec intentionally narrower?
- LNURL-pay's `metadata` array (text/plain, image/png) is part of the BOLT11 description-hash chain. How does CLINK Offers preserve description-hash semantics if metadata is supplied via Nostr instead of HTTP?
- Receipt path uses an *optional* kind 21001 response; does that imply the same "receipt is not proof of payment" caveat that NIP-57 carries, or is there a stronger guarantee?
- How are `noffer1...` codes revoked or rotated? LNURL-pay revocation = take down the URL; what's the CLINK equivalent?

## Why this matters for understanding CLINK's positioning

This is the load-bearing comparison document. Three claims are central to CLINK's identity and they all live here:

1. **CLINK Offers is positioned as a direct successor — not a complement — to LNURL-Pay**, with explicit framing that web-infra requirements are the *cause* of LN-Address centralization.
2. **CLINK swipes at both LNURL (HTTP) and BOLT12 (onion)** without naming BOLT12, classing both as failures of the "either centralized web or slow P2P" dichotomy that Nostr supposedly resolves.
3. **The integration with NIP-57 is offensive, not defensive**: by carrying zap payloads in-band on kind 21001, CLINK removes the LNURL-server trust hop that NIP-57 explicitly admits to (see the "not a proof of payment" caveat).

If the rest of the wiki needs one anchor article on "what CLINK is differentiating against," this is it.
