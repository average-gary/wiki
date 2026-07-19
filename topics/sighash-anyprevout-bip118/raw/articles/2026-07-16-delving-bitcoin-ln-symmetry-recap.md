---
title: "LN-Symmetry Project recap (Delving Bitcoin, Instagibbs)"
source: "https://delvingbitcoin.org/t/ln-symmetry-project-recap/359"
type: articles
ingested: 2026-07-16
tags: [ln-symmetry, eltoo, anyprevout, instagibbs, ajtowns, rusty-russell, pinning, ephemeral-anchors, truc, signet, implementation-status]
summary: "Implementation status recap for eltoo/LN-Symmetry led by Greg Sanders (instagibbs), with AJ Towns and Rusty Russell. A working APO-based channel PoC (ephemeral anchors + v3/TRUC anti-pinning, opens/payments, fast-forward forwards, unilateral closes). Headline: 'Pinning is super hard to avoid — at least 1/3 of the work was designing for pinning robustness.' Jan 2026 rebase runs on bitcoin-inquisition 29.x on signet."
---

# LN-Symmetry Project recap

Delving Bitcoin, implementation recap (Jan 2024, with Jan 2026 rebase update).

## Team & scope

- Led by **Instagibbs (Greg Sanders)**, with **AJ Towns (ajtowns)** and **Rusty
  Russell**. A working eltoo-style channel PoC using APO.
- Implemented: ephemeral anchors + **v3 (TRUC) transactions** for anti-pinning,
  channel opens/payments, "fast-forward" (0.5-RTT) forwards, unilateral closes,
  reconnection.
- Omitted initially: cooperative closes, persistence, gossip compat.
- Timeline: recap Jan 2024; a **Jan 2026 rebase runs on bitcoin-inquisition 29.x on
  signet**, adding restarts, cooperative closes, and automated anchor bumping.

## Headline findings

- **"Pinning is super hard to avoid. At least 1/3 of the work was designing the system
  to be robust against pinning."**
- eltoo needs longer-than-expected HTLC expiry deltas (extra timelock rounds).
- Instagibbs argues symmetry/eltoo's incentive story (driving cheating success
  probability to ~zero) can beat penalties for encouraging cooperative closes.
