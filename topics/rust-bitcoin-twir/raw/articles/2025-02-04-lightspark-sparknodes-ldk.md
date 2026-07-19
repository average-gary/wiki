---
title: "How we built our Sparknodes using LDK (Lightspark Engineering)"
source: https://lightningdevkit.org/blog/how-we-built-our-sparknodes-using-ldk
type: case-study
tags: [ldk, lightspark, coinbase, remote-signing, scaling]
ingested: 2026-06-22
date: 2025-02-04
verified: 2026-06-22
volatility: cold
credibility: high
twir-fit: maybe-back-fill
twir-section: Project/Tooling Updates
agent: applied
---

# How we built our Sparknodes using LDK

Lightspark Engineering blog post (LDK blog mirror), 2025-02-04. Production-scale architecture.

## Key findings
- Single observer process to bitcoind shared across nodes.
- **Remote signing** where keys never leave customer infrastructure.
- LDK's flexibility advantage over alternatives explicitly cited as the reason for selection.
- No code samples — architectural narrative.

## TWiR fit
- **Section**: Project/Tooling Updates as case-study format.
- Aged but provides production-scale counterpoint to Lexe's enclave model — pair as twin "LDK in production" entries for an Observations piece.
