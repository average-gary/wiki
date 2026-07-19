---
title: covenantless-ark — config
type: topic-config
created: 2026-07-16
---

# covenantless-ark — config

## Scope

**In scope**:
- **Covenantless Ark (clArk)** — the Ark protocol variant that runs on current Bitcoin without a covenant opcode (no `OP_CTV`/`OP_CHECKTEMPLATEVERIFY`), using n-of-n multisig presigning instead
- **Round / batch mechanics**: the ASP (Ark Service Provider) round, the n-of-n batch (pool) output, the presigned VTXO transaction tree, connector transactions/outputs, forfeit transactions
- **VTXOs** (Virtual UTXOs): creation, lifecycle, expiry, exit
- **Tree presigning**: how the shared-output spend tree is signed by all round participants (MuSig2 / n-of-n), the signing session, and what makes it "covenantless"
- **Dropout / offline dynamics**: what happens when a participant goes offline during a round, freeze conditions, and the timeout-driven **unilateral exit / refund** path
- **Exit / redemption**: cooperative redeem vs unilateral on-chain exit, exit windows, sweep/expiry reclaim by the ASP
- **Comparisons**: clArk vs covenant-based Ark (CTV), vs Lightning, vs statechains, vs coinpools/Timeout-Trees, vs Ark v2 / "Signet Ark"
- **Implementations**: Ark Labs (arkd / arkade), Second (bark / clArk Rust), ark-rs, related repos and specs

**Out of scope**:
- General Bitcoin scripting theory beyond what touches Ark round transactions
- Deep covenant-opcode soft-fork politics beyond how CTV would change Ark (cross-link only)
- Lightning internals unrelated to Ark boarding/liquidity
- Non-Ark L2s except as comparison points

## Sensitivity

Public. Hub-publishable. Ark is an open protocol; clArk/bark/arkd are public OSS.

## Source preferences

- **Primary**: arkdev.info / ark-protocol.org docs, github.com/ark-network, github.com/arkade-os, Second's `bark`/clArk repos, Burak Keçeli's original Ark writeups, whitepaper/specs
- **Secondary**: Bitcoin Optech coverage, delvingbitcoin / bitcoin-dev mailing-list threads, engineering blogs (Second, Ark Labs), conference talks
- **Tertiary**: practitioner blog posts, podcast transcripts, social-media commentary from named protocol authors

## Adjacent topic wikis

- `fedimint` — federated ecash; shared-custody / off-chain pattern
- `ldk-server`, `cdk-ldk-lnurl` — Lightning stacks (Ark boarding / unilateral exit liquidity)
