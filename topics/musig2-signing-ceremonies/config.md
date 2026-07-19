---
title: "musig2-signing-ceremonies"
description: "MuSig2 interactive signing ceremonies over a wire protocol — the two-round nonce/partial-signature exchange, nonce commit/reveal pre-rounds, session framing and state machines, and dropout/abort/failure handling."
created: 2026-07-16
freshness_threshold: 70
---

# Wiki Configuration

## Scope

Research on running MuSig2 (BIP-327 two-round Schnorr multi-signature) as an *interactive ceremony* between multiple signing parties communicating over a network/wire protocol. Covers:

- The MuSig2 protocol itself: key aggregation, the two communication rounds (Round 1 nonce exchange, Round 2 partial-signature exchange), nonce generation and the `SecNonce`/`PubNonce` model.
- **Nonce commit/reveal pre-rounds**: whether to add a commitment round before nonce reveal, when it matters, and why the canonical MuSig2 does *not* require it (contrast with MuSig1's three rounds).
- **Wire protocol / session framing**: message formats, session identifiers, coordinator vs. peer-to-peer topologies, round synchronization, timeouts, replay/ordering, and how existing protocols frame ceremonies (Lightning `interactivetxs`/dual-funding, LN splicing, FROST/ROAST framing for comparison, Nostr-based coordination, hardware-wallet transport).
- **Dropout / abort / failure handling**: what happens when a signer disappears mid-ceremony, nonce reuse catastrophe and its mitigations, identifiable/attributable aborts, restart/retry semantics, state persistence across rounds, and denial-of-service surfaces.
- Security pitfalls of interactive deployment: nonce reuse, Wagner/sub-exponential attacks on concurrent sessions, the `MuSig2*` variant, deterministic-nonce dangers, and the reasons BIP-327 mandates certain aggregation/tweaking steps.
- Implementations and reference code: `libsecp256k1-zkp` MuSig2 module, `secp256k1` (rust) `musig` module, LND/`btcd`, BDK/`rust-bitcoin`, and comparison points (FROST via `frost-secp256k1`, ZF FROST, ROAST).

Out of scope for this topic (covered elsewhere or only as comparison):

- Threshold e-cash custody and guardian consensus → see hub topic `fedimint`.
- General Lightning node internals → see hub topic `ldk-server` (only the interactive-tx / channel-establishment framing is in scope here as a wire-protocol exemplar).
- FROST as a standalone topic — referenced for contrast (t-of-n, one extra pre-processing round, robustness) but not the primary subject.

## Conventions

- **Hub-publishable.** This is a general cryptographic-protocol topic. Nothing employer-confidential or repo-specific belongs here; repo-specific application (e.g. wiring MuSig2 into a specific codebase) goes in that repo's local `.wiki/`.
- Prefer primary sources: BIP-327, the MuSig2 paper (Nick–Ruffing–Seurin), and reference-implementation code/docs over secondary blog explainers.
- Distinguish carefully between the *cryptographic protocol* (what BIP-327 specifies) and *ceremony/transport concerns* (session framing, dropout handling) which the BIP deliberately leaves to the application layer. Tag facts accordingly.
