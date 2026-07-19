---
title: "Bitcoin Optech Topic: MuSig"
source: "https://bitcoinops.org/en/topics/musig/"
type: articles
ingested: 2026-07-16
tags: [musig, musig2, bitcoin-optech, standardization-timeline, interactive-ceremony, round-count, adoption]
summary: "Bitcoin Optech's curated MuSig topic page. Explains MuSig key/signature aggregation (output indistinguishable from single-signer), the round-count evolution (MuSig1 three rounds → MuSig2 two rounds → MuSig-DN removes repeated-session risk), the standardization timeline (BIP327 in 2023; BIPs 328/390/373 in 2024; libsecp256k1 completion + Lightning Loop MuSig2 default in 2025), and the interactive-ceremony framing requiring a secure comms channel."
---

# Bitcoin Optech Topic: MuSig

Curated ecosystem context (not normative).

## Key points

- MuSig aggregates Schnorr keys and signatures so the combined key + signature are **indistinguishable from a single-signer output** — a privacy win and an on-chain space saving vs. script multisig.
- **Round-count evolution**: MuSig1 = three communication rounds; MuSig2 folds a round into key/nonce exchange for a two-round flow ("one extra round beyond single-sig"); but MuSig2 "demands storing extra data and being very careful about ensuring your signing software or hardware can't be tricked into unknowingly repeating part of the signing session." MuSig-DN eliminates repeated-session risk at higher complexity.
- **Standardization timeline**: BIP-327 became the official MuSig2 spec in 2023; BIPs 328 (key derivation), 390 (descriptors), 373 (PSBT) added in 2024; libsecp256k1 completed its MuSig2 implementation and Lightning Loop defaulted to MuSig2 in 2025.
- Emphasizes MuSig is fundamentally an **interactive ceremony** requiring a secure communication channel for nonce exchange and partial-sig coordination — the "wire protocol" framing.

## What this source contributes

The ecosystem framing, standardization timeline, and the interactive/wire-protocol context that the normative sources omit — useful for a references/timeline article and for orienting a reader who is new to MuSig.
