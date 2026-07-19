---
title: "The MuSig2 Protocol"
category: concept
sources: [raw/papers/2026-07-16-musig2-paper-nick-ruffing-seurin.md, raw/articles/2026-07-16-bip-327-musig2-spec.md, raw/articles/2026-07-16-jonas-nick-musig2-explainer.md, raw/papers/2026-07-16-musig1-maxwell-poelstra-seurin-wuille.md]
created: 2026-07-16
updated: 2026-07-16
tags: [musig2, schnorr, multisignature, two-round, key-aggregation, bip-327, secnonce, pubnonce]
aliases: [MuSig2, BIP-327, MuSig2 multisignature]
confidence: high
volatility: cold
verified: 2026-07-16
summary: "MuSig2 is a two-round n-of-n Schnorr multi-signature scheme (BIP-327) that produces a single BIP-340-compatible signature against an aggregated public key. Round 1 exchanges public nonces; Round 2 exchanges partial signatures. Its defining trick is that each signer contributes two nonces, which yields concurrent security without a separate commitment round."
---

# The MuSig2 Protocol

> MuSig2 (Nick–Ruffing–Seurin, CRYPTO 2021; standardized as BIP-327) is a Schnorr multi-signature scheme in which *n* signers jointly produce a single signature that verifies against a single aggregated public key, indistinguishable on-chain from an ordinary single-signer Schnorr signature. It reduces the signing interaction to **two communication rounds** while remaining secure even when many signing sessions run concurrently — a property that every prior practical two-round Schnorr multisig had failed to achieve.

## What MuSig2 is (and is not)

MuSig2 is **n-of-n**: every participant that took part in key aggregation must also take part in signing. BIP-327 states it plainly — MuSig2 is "not a t-of-n threshold-signature scheme." For threshold (t-of-n) signing, see [[musig2-vs-frost-roast|MuSig2 vs FROST/ROAST]] ([MuSig2 vs FROST/ROAST](musig2-vs-frost-roast.md)).

It inherits **key aggregation** from the original MuSig ([[nonce-commit-reveal-rounds|MuSig1]] ([MuSig1](nonce-commit-reveal-rounds.md))): keys and signatures are the same size as plain Schnorr, and the scheme works in the plain public-key model — signers publish only a public key, with no proof-of-knowledge required. Rogue-key attacks are neutralized by per-signer aggregation coefficients `a_i = H(L, X_i)`, where `L` is the multiset of all participant public keys.

## The two rounds

The ceremony is two rounds of message exchange (BIP-327 algorithm names in parentheses):

1. **Round 1 — nonce exchange.** Each signer generates a secret/public nonce pair (`NonceGen`) and broadcasts the **public nonce**. All public nonces are combined into a single aggregate nonce (`NonceAgg`).
2. **Round 2 — partial-signature exchange.** Each signer produces a 32-byte **partial signature** (`Sign`) using its secret nonce and secret key, and broadcasts it. The partial signatures are combined (`PartialSigAgg`) into the final BIP-340 Schnorr signature.

Because Round 1 does not depend on the message, it can be **preprocessed** — signers can exchange nonces in advance, so at signing time only Round 2 is truly "online." In effect MuSig2 is one extra round beyond single-signer Schnorr.

## The two-nonce trick

The heart of MuSig2 is that each signer sends **two** (more generally ν) public nonces in Round 1, `R_{i,1}` and `R_{i,2}`. Every signer then forms an effective per-signer nonce as the linear combination

```
R_i = R_{i,1} + b · R_{i,2}
```

where the coefficient `b` is a hash of *all* signers' nonces, the aggregate public key, and the message. If any signer changes any nonce, every other signer's combination changes unpredictably. This denies an attacker the controlled algebraic structure needed for the concurrent-session forgery, which is precisely why MuSig2 can drop the separate commitment round that MuSig1 required — see [[nonce-commit-reveal-rounds|Nonce Commit/Reveal Rounds]] ([Nonce Commit/Reveal Rounds](nonce-commit-reveal-rounds.md)). Typical parameters: ν=2 for the proof in the Algebraic Group Model (AGM), ν=4 for the Random-Oracle-Model-only proof.

## Data structures (BIP-327)

- **`SecNonce`** = 97 bytes: `k1 (32) || k2 (32) || pk (33)` — the two secret nonce scalars plus the signer's own public key. This is the sensitive per-session state that must survive from Round 1 to Round 2 and must never be reused — see [[nonce-reuse-catastrophe|Nonce-Reuse Catastrophe]] ([Nonce-Reuse Catastrophe](nonce-reuse-catastrophe.md)).
- **`PubNonce`** = 66 bytes: two 33-byte compressed points.
- **`SessionContext`** = `(aggnonce, u, pk_1..u, v, tweak_1..v, is_xonly_t_1..v, m)` — the aggregate nonce, the participant public keys, the tweaks (with per-tweak x-only flags), and the message. `GetSessionValues` derives `(Q, gacc, tacc, b, R, e)` from it.

The partial-signature equation each signer computes is `s = (k1 + b·k2 + e·a·d) mod n`, where `d` is the signer's secret key, `a` its aggregation coefficient, and `e` the BIP-340 challenge.

## Tweaking

Both plain/EC tweaks (`P + t·G`, BIP32-style key derivation) and x-only tweaks (`with_even_y(P) + t·G`, BIP341/Taproot) are applied inside the session via the tweak fields of the `SessionContext`, so a MuSig2 aggregate key can serve directly as a Taproot output key.

## Security assumptions

The paper gives two proofs: one under a weaker variant of the **one-more discrete log (OMDL / AOMDL)** assumption in the Random Oracle Model, and a more efficient one in the combined **ROM + Algebraic Group Model**. The scheme's concurrent-session security is what the [[nonce-reuse-catastrophe|ROS/Wagner attack line]] ([ROS/Wagner attack line](nonce-reuse-catastrophe.md)) had broken in earlier schemes.

## See Also

- [[nonce-commit-reveal-rounds|Nonce Commit/Reveal Rounds]] ([Nonce Commit/Reveal Rounds](nonce-commit-reveal-rounds.md)) — why MuSig1 needed a third round and how MuSig2 removes it
- [[nonce-reuse-catastrophe|Nonce-Reuse Catastrophe]] ([Nonce-Reuse Catastrophe](nonce-reuse-catastrophe.md)) — the fatal failure mode of the secret nonce
- [[session-framing-and-state|Session Framing and State]] ([Session Framing and State](session-framing-and-state.md)) — how the two rounds are carried on the wire
- [[dropout-abort-and-robustness|Dropout, Abort, and Robustness]] ([Dropout, Abort, and Robustness](dropout-abort-and-robustness.md)) — what happens when a signer disappears mid-ceremony
- [[musig2-vs-frost-roast|MuSig2 vs FROST/ROAST]] ([MuSig2 vs FROST/ROAST](musig2-vs-frost-roast.md)) — comparison with threshold Schnorr ceremonies
- [[musig2-interactive-signing-ceremonies|MuSig2 Interactive Signing Ceremonies]] ([MuSig2 Interactive Signing Ceremonies](../topics/musig2-interactive-signing-ceremonies.md)) — the umbrella topic

## Sources

- [MuSig2: Simple Two-Round Schnorr Multi-Signatures](../../raw/papers/2026-07-16-musig2-paper-nick-ruffing-seurin.md) — the two-round construction, key aggregation, security proofs, the multi-nonce mechanism
- [BIP-327: MuSig2 Specification](../../raw/articles/2026-07-16-bip-327-musig2-spec.md) — normative rounds, algorithms, data structures, and byte layouts
- [Jonas Nick: MuSig2 Explainer](../../raw/articles/2026-07-16-jonas-nick-musig2-explainer.md) — the two-nonce fix in plain language
- [Simple Schnorr Multi-Signatures (MuSig1)](../../raw/papers/2026-07-16-musig1-maxwell-poelstra-seurin-wuille.md) — key aggregation and the plain public-key model
