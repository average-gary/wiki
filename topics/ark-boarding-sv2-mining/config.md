---
title: ark-boarding-sv2-mining — config
type: topic-config
created: 2026-07-17
---

# ark-boarding-sv2-mining — config

## Scope

**In scope**:
- **The thesis**: can an *online-while-mining, covenantless Ark boarding* mechanism be delivered as a **Stratum V2 extension**, where the n-of-n cosigning ceremony is triggered **post-block-found** (coinbase outpoint already known), on Bitcoin **today** (no `OP_CTV`/`OP_CSFS`/APO)?
- **Post-block-found signing timing**: signing over a *known* coinbase outpoint vs presigning over an *unknown* one; how deferring the ceremony sidesteps the unknown-txid wall.
- **n-of-n batch output + presigned VTXO tree + ephemeral-key deletion** as the covenant substitute (clArk mechanics) applied to a mining-payout context.
- **Online-while-mining liveness**: whether miners being continuously connected to the pool changes clArk's liveness/receiver-DoS calculus.
- **Coinbase constraints**: 100-block (~16.7 h) maturity, reorg risk, variable coinbase value, and how they interact with a batch-boarding ceremony.
- **SV2 extension surface**: message flow layered on the mining connection (à la demand-open-source/share-accounting-ext); activation, ceremony orchestration, dropout handling.
- **Unilateral exit** guarantees for a miner-VTXO holder.

**Out of scope**:
- General Ark UX and non-mining Ark deployments (cross-link `covenantless-ark`).
- PPLNS / payout-fairness math (cross-link `bitcoin-mining-payout-schemas`).
- CTV/APO-*based* mining payout designs (jamesob, Braidpool) except as the covenant baseline being *avoided*.
- Generic SV2 protocol internals unrelated to a cosigning ceremony.
- Covenant soft-fork activation politics beyond "is it needed here or not."

## Sensitivity

Public. Hub-publishable. Ark is an open protocol; clArk/bark/arkd and the
demand-open-source SV2 share-accounting extension are public OSS (MIT/Apache).

## Source preferences

- **Primary**: Ark protocol docs (arkdev.info / ark-protocol.org), Second `bark`/clArk repos, Ark Labs arkd/arkade, Stratum V2 spec (stratum-mining/sv2-spec), demand-open-source/demand-share-accounting-ext, BIP-327 (MuSig2), BIP-341/342 (Taproot).
- **Secondary**: Bitcoin Optech, delvingbitcoin / bitcoin-dev threads, Second & Ark Labs engineering blogs, SRI (Stratum Reference Implementation) docs.
- **Tertiary**: practitioner blog posts, conference talks, named-author social commentary.

## Adjacent topic wikis

- `covenantless-ark` — the clArk mechanics this thesis builds on (n-of-n batch output, VTXO tree, liveness/receiver-DoS).
- `sighash-anyprevout-bip118` — the coinbase-presigning wall this thesis routes around by signing post-block-found.
- `musig2-signing-ceremonies` — the interactive n-of-n ceremony (rounds, framing, dropout) that the SV2 extension would carry.
- `sv2-coinbase-identity`, `sv2-p2pool-integration`, `bitcoin-mining-payout-schemas`, `coinbase-rotation-bitcoin` — the mining/payout context.
