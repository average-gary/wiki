---
title: "SIGHASH_ANYPREVOUT, ephemeral anchors and LN symmetry (eltoo) — Chaincode Podcast (Greg Sanders)"
source: "https://btctranscripts.com/chaincode-podcast/sighash-anyprevout-ephemeral-anchors-and-ln-symmetry-eltoo"
type: articles
ingested: 2026-07-16
tags: [anyprevout, apoas, ln-symmetry, eltoo, instagibbs, activation-politics, ephemeral-anchors, package-relay, chaincode-podcast]
summary: "Transcript (2023-02-15) of Greg Sanders (instagibbs), a key APO/LN-Symmetry implementer. He explicitly declines to champion APO activation: 'the community is pretty split.' Rebrands eltoo as LN-Symmetry (vs LN-Penalty). Notes the two APO variants (ANYPREVOUT commits to amount, ANYPREVOUTANYSCRIPT any amount) and that the implementation uses APOAS. Emphasizes building tooling (package relay, ephemeral anchors) before pursuing consensus change."
---

# SIGHASH_ANYPREVOUT, ephemeral anchors and LN symmetry (eltoo)

Chaincode Podcast transcript, Greg Sanders (instagibbs), 2023-02-15.

## Key points

- Greg Sanders explicitly **declined to champion activation**: "with ANYPREVOUT, I
  don't want to champion it right now from an activation perspective... the community
  is pretty split."
- Rebrands eltoo as **"LN-Symmetry"** (vs. current "LN-Penalty"); APO enables
  symmetric channel states via **last-moment output rebinding** rather than
  pre-signing every possibility.
- Two variants: **ANYPREVOUT (commits to amount)** and **ANYPREVOUTANYSCRIPT (any
  amount)**; the LN-Symmetry implementation uses **APOAS**.
- Emphasizes building tooling (**package relay, ephemeral anchors**) *before* pursuing
  a consensus change — one reason APO activation has stalled.
