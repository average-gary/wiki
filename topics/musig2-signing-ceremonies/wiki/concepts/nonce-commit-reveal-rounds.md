---
title: "Nonce Commit/Reveal Rounds"
category: concept
sources: [raw/papers/2026-07-16-musig1-maxwell-poelstra-seurin-wuille.md, raw/papers/2026-07-16-ros-attack-benhamouda-et-al.md, raw/articles/2026-07-16-jonas-nick-musig2-explainer.md, raw/papers/2026-07-16-rfc-9591-frost.md, raw/articles/2026-07-16-bitcoin-optech-musig-topic.md]
created: 2026-07-16
updated: 2026-07-16
tags: [nonce-commitment, commit-reveal, musig1, three-round, two-round, concurrent-security, ros-attack, frost]
aliases: [nonce commitment round, commit-reveal, MuSig1 three rounds]
confidence: high
volatility: cold
verified: 2026-07-16
summary: "A nonce commit/reveal round is a pre-round in which each signer first broadcasts a hash commitment to its nonce, then reveals the nonce only after all commitments are in. MuSig1 needed it (three rounds total) to stop an adversary from choosing its nonce adaptively. MuSig2 eliminates it by using two nonces bound by a hash; FROST keeps an equivalent commitment round but makes it message-independent and precomputable."
---

# Nonce Commit/Reveal Rounds

> A nonce commit/reveal round is an extra interaction placed *before* nonce exchange: each signer first broadcasts a **commitment** (a hash `t_i = H(R_i)`) to the nonce it intends to use, and only once every signer's commitment has been received does anyone **reveal** the actual nonce `R_i`. The purpose is to prevent a malicious signer from waiting to see everyone else's nonce and then adaptively choosing its own — the manipulation that underlies the concurrent-session forgery. Whether a ceremony needs this round is the central design fork between MuSig1, MuSig2, and FROST.

## Why MuSig1 needed it

The original [[musig2-protocol|MuSig]] ([MuSig](musig2-protocol.md)) paper (Maxwell–Poelstra–Seurin–Wuille) originally proposed a two-round scheme, but its security proof was found to be flawed (the flaw is documented by Drijvers et al., ePrint 2018/417). The authors concluded that "the security of 2-round MuSig does not appear to be provable under standard assumptions," and the published version fell back to a **three-round** variant proven under the plain discrete-log assumption. The three rounds are:

1. **Commit** — each signer broadcasts `t_i = H(R_i)`.
2. **Reveal** — each signer broadcasts `R_i`; others check it against `t_i`.
3. **Sign** — each signer sends its partial signature.

The commitment round forces every signer to *fix* its nonce before seeing any other nonce, removing the adaptive freedom an attacker would otherwise exploit.

## The attack the commitment defends against

Without a commitment (or an equivalent binding), an attacker who can run **many concurrent sessions** can choose its nonce contributions adaptively across sessions and solve the **ROS** problem (Random inhomogeneities in an Overdetermined Solvable system), forging a signature on a message the honest signer never agreed to. Benhamouda et al. showed ROS is solvable in polynomial time above `log p` dimensions and sub-exponentially for any dimension via **Wagner's generalized-birthday attack**. This attack line broke concurrently-run Schnorr blind signatures, CoSI, the original FROST, and naive two-round MuSig — see [[nonce-reuse-catastrophe|Nonce-Reuse Catastrophe]] ([Nonce-Reuse Catastrophe](nonce-reuse-catastrophe.md)) for the closely related reuse attack.

## How MuSig2 removes the round

MuSig2 achieves the same adaptive-nonce protection *without* a commitment round by having each signer publish **two** nonces and combining them as `R_i = R_{i,1} + b·R_{i,2}`, with `b` a hash of all nonces, the aggregate key, and the message. Because `b` depends on everyone's nonces, no signer can steer the aggregate nonce to a chosen value after the fact — the hash binding substitutes for the commitment. This is the reduction from three rounds to two.

## How FROST handles it (contrast)

[[musig2-vs-frost-roast|FROST]] ([FROST](musig2-vs-frost-roast.md)) *keeps* a commitment round but restructures it: Round 1 is a **message-independent** commitment/preprocessing phase in which each participant publishes public nonce commitments (a hiding nonce and a binding nonce). Because it does not need the message, it can be **precomputed and batched in advance**, so operationally FROST also feels like a single online signing round. The binding-nonce construction plays the same anti-adaptive role that MuSig2's hash-bound second nonce does.

The recurring theme: every secure interactive Schnorr multisig must somehow stop adaptive nonce choice under concurrency. The schemes differ only in *how* — explicit commit/reveal (MuSig1), hash-bound extra nonce (MuSig2), or a precomputable binding commitment (FROST).

## See Also

- [[musig2-protocol|The MuSig2 Protocol]] ([The MuSig2 Protocol](musig2-protocol.md)) — the two-nonce mechanism that replaces the commitment round
- [[nonce-reuse-catastrophe|Nonce-Reuse Catastrophe]] ([Nonce-Reuse Catastrophe](nonce-reuse-catastrophe.md)) — the ROS/Wagner attack line in detail
- [[musig2-vs-frost-roast|MuSig2 vs FROST/ROAST]] ([MuSig2 vs FROST/ROAST](musig2-vs-frost-roast.md)) — FROST's precomputable commitment round
- [[musig2-interactive-signing-ceremonies|MuSig2 Interactive Signing Ceremonies]] ([MuSig2 Interactive Signing Ceremonies](../topics/musig2-interactive-signing-ceremonies.md)) — the umbrella topic

## Sources

- [Simple Schnorr Multi-Signatures (MuSig1)](../../raw/papers/2026-07-16-musig1-maxwell-poelstra-seurin-wuille.md) — the three-round variant and why the two-round proof failed
- [On the (in)security of ROS](../../raw/papers/2026-07-16-ros-attack-benhamouda-et-al.md) — the attack the commitment round defends against
- [Jonas Nick: MuSig2 Explainer](../../raw/articles/2026-07-16-jonas-nick-musig2-explainer.md) — how the two-nonce trick substitutes for a commitment
- [RFC 9591: The FROST Protocol](../../raw/papers/2026-07-16-rfc-9591-frost.md) — FROST's precomputable commitment round
- [Bitcoin Optech: MuSig Topic](../../raw/articles/2026-07-16-bitcoin-optech-musig-topic.md) — round-count evolution across MuSig1/MuSig2/MuSig-DN
