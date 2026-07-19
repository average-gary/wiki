---
title: "Nonce-Reuse Catastrophe"
category: concept
sources: [raw/articles/2026-07-16-kohen-musig2-nonce-reuse-attack.md, raw/articles/2026-07-16-jonas-nick-musig2-explainer.md, raw/papers/2026-07-16-musig-dn-deterministic-nonces.md, raw/articles/2026-07-16-bip-327-musig2-spec.md, raw/repos/2026-07-16-libsecp256k1-musig-module.md, raw/papers/2026-07-16-ros-attack-benhamouda-et-al.md]
created: 2026-07-16
updated: 2026-07-16
tags: [nonce-reuse, key-extraction, wagner-attack, deterministic-nonces, secnonce, security, concurrent-sessions]
aliases: [nonce reuse, secnonce reuse, nonce reuse attack]
confidence: high
volatility: cold
verified: 2026-07-16
summary: "Reusing a secret nonce is the single catastrophic failure of MuSig2 signing. In single-signer Schnorr, one reuse trivially leaks the key by solving two linear equations. In MuSig2 even a single reuse is exploitable via ~256 concurrent sessions plus Wagner's algorithm. This is why deterministic nonces are banned in multiparty, why the secnonce must never be copied/persisted, and why every retry must use fresh nonces."
---

# Nonce-Reuse Catastrophe

> If a signer ever runs `Sign` twice with the same secret nonce, an attacker can extract that signer's secret key. This is not a subtle degradation — it is total, immediate key compromise. It is the dominant safety concern in every MuSig2 deployment, and it shapes the API design, the state-machine rules, and the abort/retry semantics of the whole ceremony.

## The single-signer baseline

For plain Schnorr, two signatures that share a nonce `r` give `s₁ = r + c₁·x` and `s₂ = r + c₂·x`. Two equations, two unknowns, so the secret key falls out directly:

```
x = (s₁ − s₂) / (c₁ − c₂)
```

## Why MuSig2 is *not* safe just because it hides this

A common misconception is that MuSig2's two-nonce structure makes reuse harmless because the naive linear relation no longer holds. It does obscure the trivial equation — but Nadav Kohen's analysis shows a **single** reuse is still exploitable:

- The victim reuses a nonce pair only once. An attacker opens **~256 concurrent signing sessions**, obtaining the victim's paired nonces `(R₁^(k), R₂^(k))` in each, and responds twice per session to collect `s₁^(k), s₂^(k)`.
- The attacker forms weighted linear combinations of `s₂^(k) − s₁^(k)` that **cancel the second-nonce term**.
- It then applies **Wagner's algorithm** (~2³⁷ operations) to choose `R₂` values so that `Σ c^(k)` hits a target, yielding a full forgery `g^s = R · X̃^c`.

Kohen's conclusion: *"Although you don't trivially leak your private key after a single nonce reuse in MuSig2, it is still definitely insecure to reuse nonces in any capacity."* This is the same [[nonce-commit-reveal-rounds|ROS/Wagner attack family]] ([ROS/Wagner attack family](nonce-commit-reveal-rounds.md)) that governs why the ceremony needs anti-adaptive-nonce binding in the first place.

## Why deterministic nonces are banned in multiparty

For a single signer, deterministic nonce derivation (RFC 6979, or BIP-340's tagged-hash scheme) is *safe* — no adversary can vary the challenge for a fixed (key, message). In a **multi-signature**, this breaks: the MuSig-DN paper shows an active adversary can trick an honest signer into producing two partial signatures with the same nonce on *different challenges* (by varying the other cosigners' contributions), directly revealing the key. BIP-327 therefore mandates: *"the values k1 and k2 must not be derived deterministically from the session parameters because otherwise active adversaries can trick the victim into reusing a nonce."* MuSig2 requires fresh randomness per session; [[deterministic-vs-random-nonces|MuSig-DN]] ([MuSig-DN](deterministic-vs-random-nonces.md)) recovers safe determinism only by attaching a zero-knowledge proof of correct derivation.

## The canonical state-machine footgun: backup/restore

The most vivid real-world reuse scenario (Jonas Nick): start a signing session, save its state, back up the drive, finish the session — then **restore the backup and finish again**. The restored state carries the same secret nonce, so the second completion produces a second signature under that nonce, "which can be used to steal our secret key." VM snapshots, rollbacks, database restores, and process crashes that replay persisted session state are all instances of this hazard. See [[session-framing-and-state|Session Framing and State]] ([Session Framing and State](session-framing-and-state.md)) for how real protocols avoid persisting secret nonces at all.

## API-level guardrails

Reference implementations enforce non-reuse structurally rather than trusting the caller:

- **libsecp256k1 / secp256k1-zkp**: the `secp256k1_musig_secnonce` struct is documented "MUST NOT be copied or read or written to directly" because "copying this data structure can result in nonce reuse which will leak the secret signing key." `musig_partial_sign` overwrites the secnonce with zeros and aborts if handed an all-zero secnonce — a best-effort sign-once guard. Each `nonce_gen` demands unique session randomness.
- **rust-secp256k1-zkp**: the `SecretNonce` type deliberately does not implement `Copy` or `Clone`, and `partial_sign` takes ownership of it, so the type system prevents a second use.
- **LND**: `MuSig2Sign` may be called only once per `session_id`.
- **BIP-327**: "The Sign algorithm must not be executed twice with the same secnonce."

## Mitigations (summary)

1. Never derive nonces deterministically in multiparty — use a high-quality RNG, optionally bound to `sk`/`aggpk`/`m`/`extra_in` for defense-in-depth.
2. Never copy, serialize, or persist a secret nonce; zeroize it immediately after signing.
3. On any [[dropout-abort-and-robustness|abort or retry]] ([abort or retry](dropout-abort-and-robustness.md)), generate a **fresh** nonce — reusing the aborted round's nonce is exactly this catastrophe.
4. Prefer stateless nonce regeneration keyed so each use is distinct (e.g. the Lightning shachain scheme) over persisting the secret nonce.

## See Also

- [[nonce-commit-reveal-rounds|Nonce Commit/Reveal Rounds]] ([Nonce Commit/Reveal Rounds](nonce-commit-reveal-rounds.md)) — the related adaptive-nonce (ROS/Wagner) attack line
- [[deterministic-vs-random-nonces|Deterministic vs Random Nonces]] ([Deterministic vs Random Nonces](deterministic-vs-random-nonces.md)) — why MuSig2 forbids determinism and how MuSig-DN restores it
- [[session-framing-and-state|Session Framing and State]] ([Session Framing and State](session-framing-and-state.md)) — persisting session state without persisting the secret nonce
- [[dropout-abort-and-robustness|Dropout, Abort, and Robustness]] ([Dropout, Abort, and Robustness](dropout-abort-and-robustness.md)) — the fresh-nonce-on-retry rule
- [[musig2-protocol|The MuSig2 Protocol]] ([The MuSig2 Protocol](musig2-protocol.md)) — the secnonce's role in the protocol

## Sources

- [Kohen: Limited MuSig2 Nonce Reuse Attack](../../raw/articles/2026-07-16-kohen-musig2-nonce-reuse-attack.md) — the concrete multiparty amplification via concurrent sessions + Wagner
- [Jonas Nick: MuSig2 Explainer](../../raw/articles/2026-07-16-jonas-nick-musig2-explainer.md) — the backup/restore state-machine footgun
- [MuSig-DN: Verifiably Deterministic Nonces](../../raw/papers/2026-07-16-musig-dn-deterministic-nonces.md) — why deterministic nonces are unsafe in multiparty
- [BIP-327: MuSig2 Specification](../../raw/articles/2026-07-16-bip-327-musig2-spec.md) — the normative sign-once rule and RNG mandate
- [libsecp256k1 / secp256k1-zkp MuSig module](../../raw/repos/2026-07-16-libsecp256k1-musig-module.md) — the API/struct-level reuse guards
- [On the (in)security of ROS](../../raw/papers/2026-07-16-ros-attack-benhamouda-et-al.md) — the Wagner/ROS foundation of the attack
