---
title: "MuSig2 vs FROST/ROAST"
category: concept
sources: [raw/papers/2026-07-16-rfc-9591-frost.md, raw/papers/2026-07-16-roast-robust-asynchronous-schnorr-threshold.md, raw/articles/2026-07-16-bip-327-musig2-spec.md, raw/papers/2026-07-16-ros-attack-benhamouda-et-al.md, raw/articles/2026-07-16-kohen-musig2-nonce-reuse-attack.md]
created: 2026-07-16
updated: 2026-07-16
tags: [musig2, frost, roast, threshold-signatures, comparison, rounds, robustness, n-of-n, t-of-n, coordinator]
aliases: [MuSig2 vs FROST, FROST vs MuSig2, ROAST comparison, threshold vs multisig]
confidence: high
volatility: warm
verified: 2026-07-16
summary: "MuSig2, FROST, and ROAST are the three main interactive Schnorr signing ceremonies. MuSig2 is n-of-n, two online rounds, non-robust. FROST is t-of-n, two rounds with a precomputable commitment round, also non-robust. ROAST wraps FROST to add robustness/asynchrony via a coordinator pool — but requires a threshold, so it cannot make n-of-n MuSig2 robust. All three defend the same ROS/Wagner concurrent-forgery class differently."
---

# MuSig2 vs FROST/ROAST

> MuSig2, FROST, and ROAST are the three interactive Schnorr signing ceremonies a designer is most likely to choose between. They share a common ancestry and a common adversary (the ROS/Wagner concurrent-forgery attack) but differ on three axes that determine which one fits a given deployment: **threshold structure** (n-of-n vs t-of-n), **round structure** (whether the commitment round is separate, folded, or precomputable), and **robustness** (whether the ceremony can complete despite dropouts).

## Threshold structure

- **MuSig2**: strictly **n-of-n**. Every key-aggregation participant must sign. BIP-327: "not a t-of-n threshold-signature scheme." Naively bolting a threshold onto MuSig2 via replicated secret sharing is, per Kohen, "fraught" — replicated nonce components risk silent reuse.
- **FROST / ROAST**: genuine **t-of-n threshold** (`MIN ≤ NUM ≤ MAX`). Any subset of at least the threshold can produce a valid signature.

This is the first-order decision: if you need "any k of n can sign," you need FROST, not MuSig2.

## Round structure

- **MuSig2**: two **online** rounds (nonce exchange, then partial-sig exchange). Round 1 is message-independent and can be preprocessed. No separate commitment round — the [[nonce-commit-reveal-rounds|two-nonce trick]] ([two-nonce trick](nonce-commit-reveal-rounds.md)) provides the anti-adaptive binding.
- **FROST**: two rounds, but Round 1 is a **message-independent commitment/preprocessing phase** (each participant publishes a hiding-nonce and a binding-nonce commitment) that can be **batched in advance**. Operationally this leaves a single online signing round. The binding-nonce commitment plays the same anti-adaptive role as MuSig2's second nonce.
- **ROAST**: FROST's one-preprocessing + one-signing structure, run repeatedly by a coordinator.

Both schemes therefore reduce to roughly one online round in practice; they differ in whether the pre-round is a hash-bound extra nonce (MuSig2) or a precomputable commitment (FROST).

## Robustness and dropout handling

- **MuSig2 and plain FROST are both non-robust**: any single dropout or bad partial signature aborts the ceremony (see [[dropout-abort-and-robustness|Dropout, Abort, and Robustness]] ([Dropout, Abort, and Robustness](dropout-abort-and-robustness.md))). Both offer **identifiable abort** so the culprit can be attributed.
- **ROAST adds robustness** to FROST: a coordinator keeps a pool of willing signers, cyclically assigns groups of *t* to concurrent signing attempts, and — because a disruptive signer can stall only one attempt at a time — guarantees honest signers eventually complete one, even in a fully asynchronous network. Demonstrated: 67-of-100 with 33 malicious signers, completing within seconds.
- **ROAST cannot rescue MuSig2.** Its robustness depends on being able to complete with a *subset* of signers. MuSig2's n-of-n structure has no subset to fall back to, so ROAST — which requires a threshold scheme with one-preprocessing-round + identifiable-aborts + concurrent security (all FROST properties) — does not apply. An n-of-n MuSig2 deployment that needs robustness must instead move to a threshold scheme.

## Coordinator role

FROST and ROAST define an explicit **Coordinator** that routes messages and aggregates shares but is **not trusted with secrets** and works over authenticated (not necessarily confidential) channels. MuSig2 does not mandate a coordinator; deployments choose peer-to-peer (Lightning's two-party mesh) or coordinator-style (LND's session-collecting caller) framing themselves — see [[session-framing-and-state|Session Framing and State]] ([Session Framing and State](session-framing-and-state.md)).

## Common adversary

All three descend from the discovery that naive two-round Schnorr multisig is broken under concurrency by the **ROS/Wagner** attack (Benhamouda et al.). Each defends it differently: MuSig1 with an explicit commitment round, MuSig2 with two hash-bound nonces, FROST with a binding-nonce commitment. This shared threat is why none of them can safely use single-nonce interactive signing.

## Quick comparison

| Axis | MuSig2 | FROST | ROAST (FROST + wrapper) |
|------|--------|-------|-------------------------|
| Threshold | n-of-n | t-of-n | t-of-n |
| Standard | BIP-327 | RFC 9591 | eprint 2022/550 |
| Online rounds | 2 (round 1 preprocessable) | 2 (round 1 precomputable) | repeated 1+1 |
| Robust to dropouts | No | No | **Yes** |
| Identifiable abort | Yes | Yes | Yes (relied on) |
| Coordinator | Optional (deployment choice) | Yes (untrusted) | Yes (untrusted, pooling) |
| Async network tolerant | No | No | **Yes** |

## See Also

- [[musig2-protocol|The MuSig2 Protocol]] ([The MuSig2 Protocol](musig2-protocol.md)) — the n-of-n scheme in detail
- [[nonce-commit-reveal-rounds|Nonce Commit/Reveal Rounds]] ([Nonce Commit/Reveal Rounds](nonce-commit-reveal-rounds.md)) — the commitment-round question across schemes
- [[dropout-abort-and-robustness|Dropout, Abort, and Robustness]] ([Dropout, Abort, and Robustness](dropout-abort-and-robustness.md)) — robustness and ROAST's mechanism
- [[session-framing-and-state|Session Framing and State]] ([Session Framing and State](session-framing-and-state.md)) — coordinator vs peer topologies

## Sources

- [RFC 9591: The FROST Protocol](../../raw/papers/2026-07-16-rfc-9591-frost.md) — FROST's threshold structure, commitment round, coordinator, non-robustness
- [ROAST: Robust Asynchronous Schnorr Threshold Signatures](../../raw/papers/2026-07-16-roast-robust-asynchronous-schnorr-threshold.md) — the robustness wrapper and its requirements
- [BIP-327: MuSig2 Specification](../../raw/articles/2026-07-16-bip-327-musig2-spec.md) — MuSig2's n-of-n definition
- [On the (in)security of ROS](../../raw/papers/2026-07-16-ros-attack-benhamouda-et-al.md) — the shared concurrent-forgery adversary
- [Kohen: Limited MuSig2 Nonce Reuse Attack](../../raw/articles/2026-07-16-kohen-musig2-nonce-reuse-attack.md) — why naive MuSig2 thresholds are fraught
