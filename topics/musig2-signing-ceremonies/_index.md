---
title: "musig2-signing-ceremonies"
type: topic-wiki
created: 2026-07-16
updated: 2026-07-16
---

# musig2-signing-ceremonies

> MuSig2 interactive signing ceremonies run over a wire protocol: the two communication rounds (nonce exchange + partial-signature exchange), optional nonce commit/reveal pre-round, session framing and state machines, and dropout/abort/failure handling in real multi-party deployments.

## Statistics

- Sources: 15 raw documents (6 papers, 7 articles, 2 repos)
- Articles: 9 compiled wiki articles (7 concepts, 1 topic, 1 reference)
- Last compiled: 2026-07-16
- Last lint: —

## Quick Navigation

- [All Sources](raw/_index.md)
- [Concepts](wiki/concepts/_index.md)
- [Topics](wiki/topics/_index.md)
- [References](wiki/references/_index.md)
- [Theses](wiki/theses/_index.md)
- [Outputs](output/_index.md)

## Start here

- [MuSig2 Interactive Signing Ceremonies](wiki/topics/musig2-interactive-signing-ceremonies.md) — the umbrella synthesis answering the three core questions (rounds, framing, dropout).

## Recent Changes

- 2026-07-16: Topic wiki initialized and first research round completed. Ingested 15 sources (MuSig2 paper, ROS attack, MuSig1, MuSig-DN, ROAST, RFC 9591 FROST, BIP-327, BIP-373, BOLT #2, Simple Taproot Channels BOLT, Kohen nonce-reuse attack, Jonas Nick explainer, Bitcoin Optech, libsecp256k1 MuSig module, LND Signer API). Compiled 9 articles covering the protocol, nonce commit/reveal rounds, nonce-reuse catastrophe, session framing, dropout/abort/robustness, deterministic-vs-random nonces, the interactive-tx wire protocol, MuSig2-vs-FROST/ROAST, and an implementations/specs reference.
