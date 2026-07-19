---
title: "A Practical Attack Against Limited MuSig2 Nonce Reuse (Nadav Kohen)"
source: "https://nkohen.github.io/blog/musig2-nonce-reuse/"
type: articles
ingested: 2026-07-16
tags: [musig2, nonce-reuse, key-extraction, wagner-attack, concurrent-sessions, forgery, threshold-caveat, security]
summary: "Nadav Kohen's writeup (2026) showing the concrete algebra of MuSig2 nonce reuse. In single-signer Schnorr, one reused nonce trivially leaks the key. In MuSig2, even a SINGLE reuse is exploitable: an attacker opens ~256 concurrent sessions, responds twice per session, forms linear combinations that cancel the second-nonce term, and uses Wagner's algorithm (~2^37 ops) to forge. Concludes it is 'definitely insecure to reuse nonces in any capacity.'"
---

# A Practical Attack Against Limited MuSig2 Nonce Reuse

**Author**: Dr. Nadav Kohen. Personal blog, 2026-03-19.

## Single-signer baseline

Two signatures sharing nonce `r`: `s₁ = r + c₁·x` and `s₂ = r + c₂·x`. Two equations, two unknowns → `x = (s₁ − s₂)/(c₁ − c₂)`. Instant secret-key recovery.

## The MuSig2 "limited reuse" attack

MuSig2 does *not* trivially leak the key after a single reuse (the two-nonce structure obscures the linear relation), but it is still exploitable:

- The victim reuses a nonce pair only *once*. An attacker opens **~256 concurrent sessions**, receiving the victim's paired nonces `(R₁^(k), R₂^(k))` in each, and responds twice per session to harvest `s₁^(k), s₂^(k)`.
- The attacker forms weighted linear combinations of `s₂^(k) − s₁^(k)` that **cancel the second-nonce term**.
- It then uses **Wagner's algorithm** (~2³⁷ operations) to find `R₂` values making `Σ c^(k)` hit a chosen target, producing a full forgery `g^s = R · X̃^c`.
- Direct warning: *"Although you don't trivially leak your private key after a single nonce reuse in MuSig2, it is still definitely insecure to reuse nonces in any capacity."*

## Threshold caveat

*"Naive approaches to turning MuSig2 into a threshold signature scheme using replicated secret sharing are fraught"* — replicated or deterministic nonce components across a quorum can silently cause reuse. (This is part of why dedicated threshold schemes like FROST exist rather than bolting a threshold onto MuSig2.)

## What this source contributes

The only source that shows the *concrete multiparty amplification*: why "just one reuse" is still fatal in MuSig2 and how Wagner + concurrent sessions turn a limited reuse into a practical forgery. Motivates the strict never-reuse / fresh-nonce-on-retry discipline that the reference implementations enforce.
