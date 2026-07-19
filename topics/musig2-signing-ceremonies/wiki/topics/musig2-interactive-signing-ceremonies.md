---
title: "MuSig2 Interactive Signing Ceremonies"
category: topic
sources: [raw/papers/2026-07-16-musig2-paper-nick-ruffing-seurin.md, raw/articles/2026-07-16-bip-327-musig2-spec.md, raw/articles/2026-07-16-bip-373-musig2-psbt-fields.md, raw/articles/2026-07-16-bolt2-interactive-tx-construction.md, raw/articles/2026-07-16-bolt-simple-taproot-channels-musig2.md, raw/repos/2026-07-16-lnd-musig2-signer-api.md, raw/repos/2026-07-16-libsecp256k1-musig-module.md, raw/articles/2026-07-16-kohen-musig2-nonce-reuse-attack.md, raw/articles/2026-07-16-jonas-nick-musig2-explainer.md, raw/papers/2026-07-16-musig-dn-deterministic-nonces.md, raw/papers/2026-07-16-roast-robust-asynchronous-schnorr-threshold.md, raw/papers/2026-07-16-rfc-9591-frost.md, raw/papers/2026-07-16-musig1-maxwell-poelstra-seurin-wuille.md, raw/papers/2026-07-16-ros-attack-benhamouda-et-al.md, raw/articles/2026-07-16-bitcoin-optech-musig-topic.md]
created: 2026-07-16
updated: 2026-07-16
tags: [musig2, signing-ceremony, wire-protocol, nonce-rounds, session-framing, dropout-handling, schnorr, bip-327]
aliases: [MuSig2 ceremony, MuSig2 signing over the wire, interactive MuSig2]
confidence: high
volatility: warm
verified: 2026-07-16
summary: "Umbrella article: running MuSig2 as an interactive signing ceremony over a wire protocol. Ties together the two-round protocol, the nonce commit/reveal question, session framing patterns (PSBT, Lightning TLV, LND RPC), the nonce-reuse catastrophe, and dropout/abort handling. Answers: how the rounds are carried, when a commitment pre-round is needed, and what happens when a signer drops out."
---

# MuSig2 Interactive Signing Ceremonies

> MuSig2 is a two-round Schnorr multi-signature scheme, but a *specification* of the cryptography is not a *deployment*. To actually run MuSig2, multiple parties must exchange messages over a network: a nonce round, then a partial-signature round, wrapped in some session framing, with a plan for what happens when a party misbehaves or vanishes. This article is the map of that territory — the ceremony as it runs on the wire, rather than the algebra on the page. It connects the protocol, the round structure, the framing patterns, and the failure handling that the concept articles cover in depth.

## The ceremony at a glance

An interactive MuSig2 ceremony among *n* signers proceeds:

1. **Setup (once).** Participants exchange public keys and compute the aggregate key via `KeyAgg` (canonically ordered by `KeySort`). Any Taproot/BIP32 tweaks are folded in. The aggregate key is what the world sees; the signature will verify against it as an ordinary BIP-340 Schnorr signature.
2. **Round 1 — nonce exchange.** Each signer runs `NonceGen`, keeping a secret nonce (`SecNonce`, 97 B) and broadcasting a public nonce (`PubNonce`, 66 B). All public nonces are combined (`NonceAgg`) into a single aggregate nonce. This round is message-independent and can be **preprocessed**.
3. **Round 2 — partial-signature exchange.** Given the aggregate nonce and the message, each signer runs `Sign` to produce a 32-byte partial signature and broadcasts it. `PartialSigAgg` combines them into the final signature.

The full protocol mechanics — the two-nonce trick `R_i = R_{i,1} + b·R_{i,2}`, the data structures, and the security assumptions — are in [[musig2-protocol|The MuSig2 Protocol]] ([The MuSig2 Protocol](../concepts/musig2-protocol.md)).

## The three questions this topic answers

### 1. Nonce commit/reveal — is a pre-round needed?

A recurring design question is whether to add a **commitment round** before revealing nonces, as MuSig1 did (broadcast `H(R_i)`, then reveal `R_i`, then sign — three rounds). The answer for canonical MuSig2 is **no**: the two-nonce construction, with the coefficient `b` hashing all nonces + aggregate key + message, provides the same protection against adaptive nonce choice that the commitment round gave MuSig1. Adding a commitment round to MuSig2 is redundant, not safer. FROST takes a middle path — it keeps a commitment round but makes it message-independent and precomputable. The full treatment, including the ROS/Wagner attack that motivates all of this, is in [[nonce-commit-reveal-rounds|Nonce Commit/Reveal Rounds]] ([Nonce Commit/Reveal Rounds](../concepts/nonce-commit-reveal-rounds.md)).

### 2. Session framing — how are the rounds carried on the wire?

BIP-327 specifies the cryptography and explicitly leaves transport to the application. Three framing patterns are observed in practice:

- **PSBT as session container** (BIP-373): nonces and partial sigs ride inside a shared PSBT as per-input key types (`0x1a`/`0x1b`/`0x1c`); session identity is the `(participant pubkey, aggregate pubkey, tapleaf)` tuple. Used for hardware wallets and coordinator apps.
- **Message-piggybacking with TLVs** (Lightning simple taproot channels): nonces (`next_local_nonce`) and partial sigs (`partial_signature_with_nonce`) are attached as TLV fields to existing channel messages, adding **no new round trips**, keyed by `channel_id`.
- **RPC session keyed by `session_id`** (LND signrpc): `CreateSession` → `RegisterNonces` (Round 1, gated by `have_all_nonces`) → `Sign` (once per session) → `CombineSig`.

All three are dissected in [[session-framing-and-state|Session Framing and State]] ([Session Framing and State](../concepts/session-framing-and-state.md)), which builds on the general [[interactive-tx-wire-protocol|Interactive Transaction Wire Protocol]] ([Interactive Transaction Wire Protocol](../concepts/interactive-tx-wire-protocol.md)) as the framing exemplar.

### 3. Dropout / abort — what happens when a signer disappears?

Because MuSig2 is **n-of-n**, a single dropped or misbehaving signer aborts the whole ceremony — it is **non-robust**. Recovery means restarting, and every restart **must use fresh nonces** (reusing the aborted round's nonces is the nonce-reuse catastrophe). `PartialSigVerify` gives **identifiable abort** so the culprit can be attributed. True robustness (completing despite dropouts) requires a *threshold* scheme wrapped by ROAST — it cannot be retrofitted onto n-of-n MuSig2. See [[dropout-abort-and-robustness|Dropout, Abort, and Robustness]] ([Dropout, Abort, and Robustness](../concepts/dropout-abort-and-robustness.md)).

## The safety spine: nonce discipline

Nearly every operational rule in a MuSig2 ceremony traces back to one fact: **reusing a secret nonce leaks the secret key**, and in MuSig2 even a single reuse is exploitable via concurrent sessions + Wagner's algorithm. This is why:

- deterministic nonces are **banned** in multiparty ([[deterministic-vs-random-nonces|Deterministic vs Random Nonces]] ([Deterministic vs Random Nonces](../concepts/deterministic-vs-random-nonces.md)));
- the `SecNonce` must never be copied, serialized, or persisted, and is zeroized after signing;
- reference implementations enforce sign-once structurally (libsecp256k1 zeroize-on-sign; rust `SecretNonce` is non-`Copy`; LND one-sign-per-`session_id`);
- an abort is a **fresh session**, never a resume of persisted state.

The full attack algebra and mitigations are in [[nonce-reuse-catastrophe|Nonce-Reuse Catastrophe]] ([Nonce-Reuse Catastrophe](../concepts/nonce-reuse-catastrophe.md)).

## Choosing MuSig2 vs a threshold scheme

If the deployment needs "any *k* of *n* can sign" or must tolerate dropouts, MuSig2 is the wrong tool — use FROST (t-of-n, RFC 9591) and, for robustness, ROAST. If the deployment is genuinely all-parties-must-sign (2-of-2 Lightning channels, n-of-n vaults), MuSig2's smaller footprint and lack of a distributed-key-generation requirement make it the natural fit. The full decision matrix is in [[musig2-vs-frost-roast|MuSig2 vs FROST/ROAST]] ([MuSig2 vs FROST/ROAST](../concepts/musig2-vs-frost-roast.md)).

## Implementation & standardization status

MuSig2 was standardized as BIP-327 in 2023 (status "Deployed", v1.0.3 in Jan 2026), with companion BIPs 328 (key derivation), 390 (descriptors), and 373 (PSBT) in 2024. The reference implementation lives in libsecp256k1 / secp256k1-zkp (still gated behind `--enable-experimental`). In Rust, MuSig2 is exposed by `secp256k1-zkp` / `rust-secp256k1-zkp` (the Blockstream fork binding), **not** the mainline `rust-secp256k1` crate — a common point of confusion. LND ships a MuSig2 Signer API (experimental), and Lightning Loop defaulted to MuSig2 in 2025. See the [[implementations-and-specs|Implementations & Specs reference]] ([Implementations & Specs reference](../references/implementations-and-specs.md)) for the full source list.

## See Also

- [[musig2-protocol|The MuSig2 Protocol]] ([The MuSig2 Protocol](../concepts/musig2-protocol.md)) — the two-round scheme and its cryptography
- [[nonce-commit-reveal-rounds|Nonce Commit/Reveal Rounds]] ([Nonce Commit/Reveal Rounds](../concepts/nonce-commit-reveal-rounds.md)) — the commitment-round question
- [[session-framing-and-state|Session Framing and State]] ([Session Framing and State](../concepts/session-framing-and-state.md)) — the three wire-framing patterns
- [[interactive-tx-wire-protocol|Interactive Transaction Wire Protocol]] ([Interactive Transaction Wire Protocol](../concepts/interactive-tx-wire-protocol.md)) — the Lightning framing exemplar
- [[nonce-reuse-catastrophe|Nonce-Reuse Catastrophe]] ([Nonce-Reuse Catastrophe](../concepts/nonce-reuse-catastrophe.md)) — the dominant failure mode
- [[deterministic-vs-random-nonces|Deterministic vs Random Nonces]] ([Deterministic vs Random Nonces](../concepts/deterministic-vs-random-nonces.md)) — the nonce-generation rules
- [[dropout-abort-and-robustness|Dropout, Abort, and Robustness]] ([Dropout, Abort, and Robustness](../concepts/dropout-abort-and-robustness.md)) — non-robustness and retry semantics
- [[musig2-vs-frost-roast|MuSig2 vs FROST/ROAST]] ([MuSig2 vs FROST/ROAST](../concepts/musig2-vs-frost-roast.md)) — comparison with threshold schemes
- [[implementations-and-specs|Implementations & Specs]] ([Implementations & Specs](../references/implementations-and-specs.md)) — the spec and code landscape

## Sources

- [MuSig2: Simple Two-Round Schnorr Multi-Signatures](../../raw/papers/2026-07-16-musig2-paper-nick-ruffing-seurin.md) — the protocol
- [BIP-327: MuSig2 Specification](../../raw/articles/2026-07-16-bip-327-musig2-spec.md) — normative rounds, algorithms, session context, identifiable abort
- [BIP-373: MuSig2 PSBT Fields](../../raw/articles/2026-07-16-bip-373-musig2-psbt-fields.md) — PSBT session framing
- [BOLT #2: Interactive Tx Construction](../../raw/articles/2026-07-16-bolt2-interactive-tx-construction.md) — the wire-framing exemplar
- [BOLT: Simple Taproot Channels (MuSig2)](../../raw/articles/2026-07-16-bolt-simple-taproot-channels-musig2.md) — TLV piggybacking, stateless nonce regeneration
- [LND MuSig2 Signer API](../../raw/repos/2026-07-16-lnd-musig2-signer-api.md) — RPC session framing
- [libsecp256k1 / secp256k1-zkp MuSig module](../../raw/repos/2026-07-16-libsecp256k1-musig-module.md) — reference API and reuse guards
- [Kohen: Limited MuSig2 Nonce Reuse Attack](../../raw/articles/2026-07-16-kohen-musig2-nonce-reuse-attack.md) — the reuse attack
- [Jonas Nick: MuSig2 Explainer](../../raw/articles/2026-07-16-jonas-nick-musig2-explainer.md) — two-nonce rationale, backup/restore footgun
- [MuSig-DN: Verifiably Deterministic Nonces](../../raw/papers/2026-07-16-musig-dn-deterministic-nonces.md) — deterministic-nonce danger
- [ROAST: Robust Asynchronous Schnorr Threshold Signatures](../../raw/papers/2026-07-16-roast-robust-asynchronous-schnorr-threshold.md) — robustness
- [RFC 9591: The FROST Protocol](../../raw/papers/2026-07-16-rfc-9591-frost.md) — threshold comparison
- [Simple Schnorr Multi-Signatures (MuSig1)](../../raw/papers/2026-07-16-musig1-maxwell-poelstra-seurin-wuille.md) — the three-round predecessor
- [On the (in)security of ROS](../../raw/papers/2026-07-16-ros-attack-benhamouda-et-al.md) — the concurrent-forgery adversary
- [Bitcoin Optech: MuSig Topic](../../raw/articles/2026-07-16-bitcoin-optech-musig-topic.md) — standardization timeline
