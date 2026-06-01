---
title: "LUD-04: LNURL-auth — deterministic per-domain HD derivation"
source: https://github.com/lnurl/luds/blob/luds/04.md
type: article
tags: [lnurl, lud-04, hd-derivation, per-domain, secp256k1, signing]
date: 2026-06-01
quality: 5
confidence: high
agent: applied
summary: "Per-domain identity via deterministic HD derivation. hashingKey = m/138'/0; per-service path is m/138'/<u32_1>/<u32_2>/<u32_3>/<u32_4> where the four u32s come from the first 16 bytes of HMAC-SHA256(hashingKey, FQDN). On-wire token = three GET params: k1 (32-byte server challenge, hex), sig (DER-encoded ECDSA secp256k1 signature over k1, hex), key (33-byte compressed secp256k1 pubkey, hex). No bearer secret leaves the wallet. Rotation: stateless — linking key is derived deterministically per-domain; each session is a fresh k1 challenge."
---

# LNURL-auth (LUD-04) — per-domain key derivation

Cleanest precedent for "per-app subkey deterministically derived from a master, signs a server challenge."

## Construction

```
hashingKey = m / 138' / 0    (BIP32 derivation from wallet master)

per-service path components:
  derivation_data = HMAC-SHA256(hashingKey, FQDN)
  u32_1 = derivation_data[0..4]   (big-endian)
  u32_2 = derivation_data[4..8]
  u32_3 = derivation_data[8..12]
  u32_4 = derivation_data[12..16]

per-service key = m / 138' / u32_1 / u32_2 / u32_3 / u32_4
```

→ Wallet stores **one master**; per-service keys are recomputed on demand.

## On-wire token

Three GET params:

| Param | Bytes | Encoding |
|-------|-------|----------|
| `k1`  | 32    | hex (server challenge) |
| `sig` | DER ECDSA secp256k1 signature over k1 | hex |
| `key` | 33 (compressed secp256k1 pubkey) | hex |

**No bearer secret leaves the wallet.** Server validates sig against key; correlates key to user; granted. Phishing-resistant by construction (signed challenge is bound to the FQDN).

## Rotation

**Stateless.** No rotation needed for the linking key:

- Per-domain derivation is deterministic
- Each session is a fresh `k1` server challenge
- Key compromise: switch wallet (master changes) → all per-domain keys change

## Direct application to the iroh app token

For an iroh app token where the user has a master keypair:

```rust
fn per_app_key(master: &[u8; 32], app_endpoint_id: &EndpointId) -> SigningKey {
    let derivation = blake3::keyed_hash(master, app_endpoint_id.as_bytes());
    SigningKey::from_bytes(derivation.as_bytes())
}

// Sign a challenge from the iroh server:
fn auth_response(master: &[u8; 32], app_id: &EndpointId, challenge: &[u8]) -> Signature {
    let key = per_app_key(master, app_id);
    key.sign(challenge)
}
```

→ Phone has one master key. Per-iroh-app derivation is deterministic. Server presents a challenge; phone signs with the per-app key. Server validates signature against the public part of the per-app key.

## Why this is structurally better than bearer tokens

| | Bearer token | LUD-04-style challenge-response |
|--|--------------|--------------------------------|
| Replay resistance | Needs jti + DB | Built-in (challenge is fresh per session) |
| Phishing resistance | None | Domain-bound by derivation |
| Revocation | Mark consumed | Rotate master (nukes all derivations) |
| Wire size | Token bytes (~150 chars) | sig + pubkey (~130 bytes hex) |
| Server state | Consumed-set | Per-user pubkey allow-list |

## Trade-off for the iroh app

LUD-04 fits the **interactive pairing UX** ("I scan QR, my phone signs back") but doesn't fit the **single-use printed-ticket UX** ("here's a QR for your guest, they scan and they're in").

→ The iroh app token wrapper should support **both**:

1. **AppTicket (bearer)** — for printed-ticket / sticker / one-shot pairing
2. **AppChallenge (LUD-04-style)** — for interactive pairing where the client has a wallet/master key

## See also

- [[2026-06-01-bolt-12-offer-encoding]] — sibling pattern with tweaked subkeys
- [[2026-06-01-tor-onion-v3-client-auth]] — service-side allowlist pattern
- [[2026-06-01-iroh-paycode-case-study]] — where this would fit Paycode's terminal pairing
