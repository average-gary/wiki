---
title: NIP-44 Encrypted Payloads (Versioned)
source: https://raw.githubusercontent.com/nostr-protocol/nips/master/44.md
type: article
ingested: 2026-06-09
path: security
quality: 5
credibility: high
tags: [nostr, nip-44, nip-04, encryption, chacha20, hmac-sha256, cure53, audit, forward-secrecy, threat-model, foundation]
---

## Source overview

NIP-44 is the encryption primitive every CLINK transport mandates. It replaces NIP-04 (which is now `unrecommended` and "deprecated in favor of NIP-17"). NIP-44 v2 was audited by Cure53 in December 2023. Understanding NIP-44's *explicit non-properties* is essential to evaluating CLINK's security claims, because CLINK inherits every one of them.

## Key findings

- **NIP-44 v2 cryptographic stack**: secp256k1 ECDH → HKDF (salt `'nip44-v2'`) → ChaCha20 + HMAC-SHA256 + custom padding scheme + base64. Outer Schnorr signature on the Nostr event provides authentication of the encrypted payload (MAC-then-sign).
- **ChaCha20 chosen over AES** "because it's faster and has better security against multi-key attacks." HMAC-SHA256 chosen over Poly1305 "because polynomial MACs are much easier to forge."
- **Cure53 audited v2 in December 2023.** Audit report referenced as `audit-2023.12.pdf`. This is meaningful — it's the only Nostr cryptographic primitive that has a published professional audit, and it is the one CLINK uses for everything.
- **Six explicit non-properties of NIP-44.** These are inherited by CLINK:
  1. **No deniability** — events are signed; provenance is provable.
  2. **No forward secrecy** — past messages decryptable on key compromise.
  3. **No post-compromise security** — future messages decryptable on key compromise.
  4. **No post-quantum security**.
  5. **IP address leak** to relays.
  6. **`created_at` date leak** (it's part of the unencrypted NIP-01 event).
- **No replay protection at the NIP-44 layer.** Replay protection must be done at the application layer — exactly what CLINK Debits/Manage do via the 30s `created_at` delta and single-use `k1`.
- **Padding leaks message size approximately.** "Limited message size leak: padding only partially obscures true message length." Power-of-two padding with 32-byte minimum.
- **Nonce hygiene is the implementer's problem.** "Always use CSPRNG. Don't generate a nonce from message content. Don't re-use the same nonce between messages." Nonce reuse is catastrophic for ChaCha20.
- **Explicit threat-model caveat from the spec authors**: "When applying this NIP to any use case, it's important to keep in mind your users' threat model and this NIP's limitations. For high-risk situations, users should chat in specialized E2EE messaging software." NIP-44 is *not* claimed to be a Signal-grade primitive.

## Threat model components

| Asset | Threat | NIP-44 posture | CLINK consequence |
|---|---|---|---|
| Past payment requests | Attacker steals user's Nostr key | Decryptable forever (no FS) | Every prior CLINK request/response under that key is readable |
| Future payment requests | Same | Decryptable until key rotation (no PCS) | Every future CLINK exchange leaks until user rotates |
| Message timing | Relay/observer | `created_at` leaks | CLINK request timing is public to relays |
| Message size | Relay/observer | Approximate (padded) | Distinguishing offer-request from debit-request by size is approximately bounded |
| Quantum adversary | Future cryptanalytic capability | Vulnerable | All historical CLINK traffic eventually readable |
| Replay | Attacker re-sends an old encrypted event | NIP-44 doesn't address | CLINK Debits/Manage must enforce app-layer (and they do, via 30s delta + k1) |
| Confidentiality | Eavesdropper without key | Strong (Cure53-audited v2) | This is the win — the channel itself is solid |

## Direct quotes

1. "The v2 of the standard was audited by Cure53 in December 2023."
2. "No forward secrecy: when a key is compromised, it is possible to decrypt all previous conversations."
3. "No post-compromise security: when a key is compromised, it is possible to decrypt all future conversations."
4. "Always use CSPRNG. Don't generate a nonce from message content. Don't re-use the same nonce between messages."
5. "When applying this NIP to any use case, it's important to keep in mind your users' threat model and this NIP's limitations. For high-risk situations, users should chat in specialized E2EE messaging software."

## Open questions

- **Nostr keys are notoriously rotation-hostile** (no canonical key-rotation NIP). CLINK has no rotation primitive of its own. Combined with NIP-44's lack of forward secrecy and post-compromise security, a single key compromise is catastrophic in scope: every past and future CLINK exchange under that key falls.
- **Why does CLINK not use NIP-17 / gift-wrapped DMs as the transport?** NIP-17 (which is what NIP-04 was deprecated *in favor of*) layers NIP-44 inside NIP-59 gift wraps for sender-anonymity. CLINK Offers mentions NIP-59 as optional but does not require it. The same deniability/metadata-privacy gap applies.
- **The Cure53 audit covered NIP-44 v2 generically — has anyone audited CLINK's specific use of it?** No public evidence of a CLINK-specific cryptographic audit was found. Spec correctness is one thing; correct implementation by ShockNet's apps and any third-party CLINK clients is another.
- **`created_at` leak interacts with CLINK's replay window.** A relay can correlate request timing with payment timing (Lightning htlc settlements) to deanonymize ephemeral payer keys.

## Why this matters

NIP-44 is the cryptographic foundation under everything CLINK does. Its strengths (Cure53-audited, modern stack, MAC-then-sign with Schnorr) are genuine. Its non-properties (no FS, no PCS, no rotation story, metadata leakage of timing/size) are inherited wholesale by CLINK and are not separately mitigated by the CLINK specs themselves. Any honest threat model of CLINK begins with "NIP-44's six explicit non-properties apply, plus whatever CLINK adds on top."
