---
title: "Delving Bitcoin — Deterministic tx selection for censorship resistance"
source_url: https://delvingbitcoin.org/t/deterministic-tx-selection-for-censorship-resistance/842
type: forum-thread
ingested: 2026-05-22
quality: 5
confidence: high
tags: [contrarian, sv2, braidpool, censorship-resistance, ajtowns, harding, fi3]
---

# Delving Bitcoin — Deterministic tx selection for censorship resistance

Strongest technical pushback from named SRI/Bitcoin contributors against the central thesis of decentralized tx selection (a thesis shared by SV2 JDP, Braidpool, and p2poolv2).

## Key participants
- **harding** (David A. Harding)
- **Fi3** (Filippo Merli, SRI dev)
- **ajtowns** (Anthony Towns, Bitcoin Core)

## Critiques

### Status quo may be better than deterministic
**harding**: Forcing pool miners onto previously-selected txs may *worsen* censorship vs. status quo where ~1 block/day has independent selection. Creates perverse incentive: "whoever can include a tx in a share first gets to decide tx selection for every other miner."

### No consensus enforcement
**Fi3**: Deterministic selection has no Bitcoin-consensus enforcement — governments can still mandate jurisdictionally-compliant pools. SV2 JDP gives miners *the option* to select; it doesn't enforce that they do.

### Bandwidth ceiling at pool scale
**ajtowns**: At pool scale, beads every ~6s means full tx data per bead is bandwidth/validation prohibitive. Proposes 95/5 hybrid — undermining the "pure" decentralized claim. p2poolv2's chain-with-uncles likely hits the same wall.

### Policy divergence as centralization vector
If a Braidpool/p2poolv2 deployment exceeds ~30% hashrate, Bitcoin Core relay policy must align to avoid expected/actual block divergence — a centralization vector in disguise.

## Implication for p2poolv2 + SV2
JDP makes mining-job declaration efficient, but the variance math + bandwidth ceiling + policy alignment argue that decentralized share-chain pools can't simultaneously be (a) pure (b) at scale (c) enforcement-free.
