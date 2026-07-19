---
title: "Pathfinding with LDK"
source: https://lightningdevkit.org/blog/ldk-pathfinding
type: blog-deep-dive
tags: [ldk, pathfinding, dijkstra, probabilistic-scorer, matt-corallo]
ingested: 2026-06-22
date: 2025-02-10
author: Matt Corallo
verified: 2026-06-22
volatility: cold
credibility: high
twir-fit: yes-strong (likely already covered TWiR Feb 2025)
twir-section: Observations/Thoughts (would have been)
agent: technical
---

# Pathfinding with LDK

LDK blog post by Matt Corallo, 2025-02-10. Algorithmic deep-dive on liquidity learning in LDK 0.1.

## Key technical content
- Evolution from time-decay to histogram-based liquidity learning (8 → 32 variable-sized buckets).
- Adopted polynomial PDF: from `12·(x-0.5)²` to `128·(1/256 + 9·(x-0.5)⁸)` in LDK 0.1.
- Buckets concentrate resolution near channel edges (first bucket only updated when liquidity is in first 1/16384th).
- Real-network validation: ~67% success-prob for successful, 33% for failures, log2-loss -0.58.
- Built on Dijkstra plus combined fee + success-probability heuristics.

## TWiR fit
- Exemplary "wraps a release with explanation" content TWiR favors.
- **Section**: Observations/Thoughts or Rust Walkthroughs.
- **Status**: should grep TWiR archive for Feb 2025 issues to confirm whether this was already linked. (Initial archive grep found no `rust-lightning` mentions, but the URL itself may not have been keyword-matched.)

## Use as historical anchor
- Even if missed, it remains a teaching reference for "what good Rust-Bitcoin TWiR submissions look like" — first-principles algorithmic write-up by the maintainer with named author and clear narrative.
