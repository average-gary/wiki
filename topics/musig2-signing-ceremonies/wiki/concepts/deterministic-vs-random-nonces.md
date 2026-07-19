---
title: "Deterministic vs Random Nonces in Multi-Party Signing"
category: concept
sources: [raw/papers/2026-07-16-musig-dn-deterministic-nonces.md, raw/articles/2026-07-16-bip-327-musig2-spec.md, raw/articles/2026-07-16-bolt-simple-taproot-channels-musig2.md, raw/articles/2026-07-16-jonas-nick-musig2-explainer.md]
created: 2026-07-16
updated: 2026-07-16
tags: [deterministic-nonces, random-nonces, musig-dn, rfc-6979, bip-340, zero-knowledge-proof, stateless-signing, shachain]
aliases: [deterministic nonces, MuSig-DN, verifiably deterministic nonces, random nonces]
confidence: high
volatility: cold
verified: 2026-07-16
summary: "In single-signer Schnorr, deterministic nonce derivation (RFC 6979 / BIP-340) is safe and preferred. In multi-signatures it is dangerous: an adversary can vary other cosigners' inputs to force two signatures on the same nonce with different challenges, leaking the key. MuSig2 mandates fresh randomness. MuSig-DN recovers safe determinism with a ZK proof of correct derivation; Lightning uses a distinct-per-height shachain derivation."
---

# Deterministic vs Random Nonces in Multi-Party Signing

> Deterministic nonce generation is a security *best practice* for single-signer Schnorr — it removes reliance on a good RNG at signing time, the failure that has leaked keys in ECDSA deployments. In **multi-party** signing the same technique becomes a footgun. Understanding exactly why is essential to understanding MuSig2's design and its state-machine rules.

## Single-signer: determinism is safe

BIP-340 (and RFC 6979 for ECDSA) derive the nonce as a hash of the secret key and the message. For a lone signer this is safe: for a fixed (key, message) there is exactly one challenge, so there is no way to obtain two different signatures sharing a nonce. Determinism is actually *safer* than randomness here because it does not depend on entropy quality at signing time.

## Multi-party: determinism is dangerous

The MuSig-DN paper states the problem directly: standard derandomization "is NOT applicable to multi-signatures." In a multi-signature the challenge `e` depends on the *aggregate* nonce and *all* participants' public keys, so an **active adversary who controls or influences another cosigner's contribution can change `e` while the victim's deterministic nonce stays fixed**. The victim is thereby tricked into producing two partial signatures with the same nonce on different challenges — and, as the [[nonce-reuse-catastrophe|nonce-reuse catastrophe]] ([nonce-reuse catastrophe](nonce-reuse-catastrophe.md)) shows, that reveals the secret key. BIP-327 encodes the resulting rule: "the values k1 and k2 must not be derived deterministically from the session parameters."

## MuSig2's choice: fresh randomness + reuse discipline

MuSig2 requires a **freshly random** secret nonce per session, optionally bound to `sk`, `aggpk`, `m`, and `extra_in` as defense-in-depth (so even a repeated RNG value still yields distinct nonces if any other input differs). The cost is that the secret nonce is now **live state** that must be carried from Round 1 to Round 2 and never reused — pushing complexity into the [[session-framing-and-state|session state machine]] ([session state machine](session-framing-and-state.md)).

## MuSig-DN: verifiably deterministic nonces

MuSig-DN recovers the benefits of determinism *safely* by deriving the nonce as a **PRF of the message and all cosigners' public keys** — binding it to the collective session so no single cosigner can vary the challenge independently — and attaching a **non-interactive zero-knowledge proof** that the nonce was derived correctly. Cosigners verify the proof, gaining stateless signing with no reuse hazard (no live secret nonce to persist, back up, or replay). The trade-off is a comparatively expensive ZK proof (over an arithmetic circuit with Pedersen commitments) per signature.

## A middle path: distinct-per-use deterministic derivation

Lightning's simple taproot channels show a pragmatic third option. Nonces are derived deterministically from the per-channel revocation **shachain**, but keyed so that each commitment *height* produces a **distinct** nonce (`height N` → Nth shachain leaf → `rand'` input to `NonceGen`). This is not the banned kind of determinism: because every use derives a different nonce, there is never a reuse, and yet no secret nonce needs to be persisted across restarts. It sidesteps the backup/restore footgun without the cost of a ZK proof — at the price of a domain-specific derivation tied to the channel's existing key ladder.

## Summary

| Setting | Deterministic nonce | Why |
|---------|--------------------|-----|
| Single-signer Schnorr (BIP-340) | Safe, preferred | One challenge per (key, msg); no RNG dependence |
| Multi-signature, naive determinism | **Fatal** | Adversary varies others' inputs → same nonce, different challenge → key leak |
| MuSig2 | Random only (banned deterministic) | Fresh entropy per session + strict non-reuse |
| MuSig-DN | Safe deterministic + ZK proof | Bound to all cosigner keys; determinism proven |
| LN taproot channels | Safe distinct-per-height | Each height derives a unique nonce; no persistence |

## See Also

- [[nonce-reuse-catastrophe|Nonce-Reuse Catastrophe]] ([Nonce-Reuse Catastrophe](nonce-reuse-catastrophe.md)) — the attack that makes multiparty determinism fatal
- [[session-framing-and-state|Session Framing and State]] ([Session Framing and State](session-framing-and-state.md)) — the live-secret-nonce state MuSig2's randomness requirement creates
- [[musig2-protocol|The MuSig2 Protocol]] ([The MuSig2 Protocol](musig2-protocol.md)) — NonceGen and its binding inputs

## Sources

- [MuSig-DN: Verifiably Deterministic Nonces](../../raw/papers/2026-07-16-musig-dn-deterministic-nonces.md) — why determinism fails in multiparty and the ZK-proof fix
- [BIP-327: MuSig2 Specification](../../raw/articles/2026-07-16-bip-327-musig2-spec.md) — the ban on deterministic nonces and the binding inputs
- [BOLT: Simple Taproot Channels (MuSig2)](../../raw/articles/2026-07-16-bolt-simple-taproot-channels-musig2.md) — distinct-per-height shachain derivation
- [Jonas Nick: MuSig2 Explainer](../../raw/articles/2026-07-16-jonas-nick-musig2-explainer.md) — the MuSig-DN contrast
