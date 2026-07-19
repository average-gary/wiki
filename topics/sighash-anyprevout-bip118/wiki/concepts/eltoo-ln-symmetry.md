---
title: "eltoo / LN-Symmetry (APO's flagship motivation)"
category: concept
sources:
  - raw/papers/2026-07-16-eltoo-paper-decker-russell-osuntokun.md
  - raw/articles/2026-07-16-decker-eltoo-blockstream-blog.md
  - raw/articles/2026-07-16-optech-eltoo-topic.md
  - raw/articles/2026-07-16-delving-bitcoin-ln-symmetry-recap.md
  - raw/articles/2026-07-16-chaincode-podcast-anyprevout-instagibbs.md
created: 2026-07-16
updated: 2026-07-16
tags: [eltoo, ln-symmetry, lightning, anyprevout, apoas, channel-factories, pinning, toxic-information, decker, instagibbs]
aliases: [eltoo, LN-Symmetry, LN Symmetry, Decker-Russell-Osuntokun]
confidence: high
volatility: warm
verified: 2026-07-16
summary: "Eltoo (rebranded LN-Symmetry) is the primary reason BIP-118 exists. It replaces Lightning's LN-Penalty punishment model with a state-number-ordered update mechanism: any newer channel state can rebind onto and override any older one, so nodes store only the latest state and old states are harmless (cost only fees) instead of 'toxic.' The LN-Symmetry PoC (instagibbs/ajtowns/Rusty) uses APOAS and found pinning the dominant obstacle."
---

# eltoo / LN-Symmetry

> Eltoo — now usually called **LN-Symmetry** — is the flagship motivation for
> [[anyprevout-sighash-semantics|SIGHASH_ANYPREVOUT]] ([SIGHASH_ANYPREVOUT](anyprevout-sighash-semantics.md)).
> It is a channel-update mechanism (Decker, Russell, Osuntokun) that uses
> [[rebindable-signatures|rebindable signatures]] ([rebindable signatures](rebindable-signatures.md))
> to let each new channel state override any prior state, replacing Lightning's
> punishment-based LN-Penalty design.

## The problem it solves: "toxic information"

In Lightning's original **LN-Penalty** design, to punish a counterparty who broadcasts
a revoked (old) state, each participant must retain per-state revocation data for the
life of the channel. Christian Decker calls this **"toxic information"**: if it is
leaked or lost (e.g. after a backup restore), funds can be stolen or lost. The model
is asymmetric and punishment-based.

## The mechanism

- Each state = an **update transaction** (spends the prior contract output, creates a
  new one) + a **settlement transaction** (distributes funds).
- States carry incrementing **state numbers**. Using NOINPUT/APO, a signed update is a
  floating transaction that can **rebind onto any prior state's output**, so a
  higher-numbered update always overrides a lower one on-chain.
- **Short-circuiting**: the final update binds directly to the funding output — you
  never replay the intermediate updates. "Only the last settlement transaction can ever
  be confirmed."
- Decker's memorable framing: off-chain negotiation is like presenting cases to "a
  court that will decide the final state — the court being the blockchain." Highest
  state number wins.

## Why it reduces storage vs LN-Penalty

No revocation secrets per historical state. Nodes keep only the latest update, latest
settlement, and active HTLCs. Old states are **harmless** (cost only fees) rather than
toxic. This also simplifies **multi-party channels** (up to ~7 parties) and **channel
factories**, and lets storage-limited devices (hardware wallets) participate safely.

## Implementation status (LN-Symmetry PoC)

Led by **Greg Sanders (instagibbs)** with **AJ Towns** and **Rusty Russell**:

- Uses **APOAS** (the amount-agnostic variant), plus **ephemeral anchors** and **v3
  (TRUC) transactions** for anti-pinning; supports opens/payments, "fast-forward"
  (0.5-RTT) forwards, unilateral closes, reconnection.
- A **Jan 2026 rebase runs on bitcoin-inquisition 29.x on signet**, adding restarts,
  cooperative closes, and automated anchor bumping.
- **Headline finding**: "Pinning is super hard to avoid. At least 1/3 of the work was
  designing the system to be robust against pinning." Eltoo also needs
  longer-than-expected HTLC expiry deltas.

## Why this hasn't driven activation

Greg Sanders has for years **declined to champion APO activation** ("the community is
pretty split"), preferring to build tooling (package relay, ephemeral anchors) before a
consensus change. Lightning works today with LN-Penalty, so APO's flagship
justification lacks urgency — a key reason for the
[[anyprevout-status-and-activation|activation stalemate]] ([activation stalemate](../topics/anyprevout-status-and-activation.md)).

## See Also

- [[rebindable-signatures|Rebindable signatures]] ([Rebindable signatures](rebindable-signatures.md)) — the primitive eltoo relies on
- [[anyprevout-sighash-semantics|ANYPREVOUT sighash semantics]] ([ANYPREVOUT sighash semantics](anyprevout-sighash-semantics.md)) — why LN-Symmetry uses APOAS specifically
- [[anyprevout-status-and-activation|Status & activation]] ([Status & activation](../topics/anyprevout-status-and-activation.md)) — the stalled activation and CTV+CSFS competition

## Sources

- [eltoo paper (Decker/Russell/Osuntokun)](../../raw/papers/2026-07-16-eltoo-paper-decker-russell-osuntokun.md) — the primary mechanism
- [Decker — eltoo (Blockstream blog)](../../raw/articles/2026-07-16-decker-eltoo-blockstream-blog.md) — toxic-information framing, court analogy
- [Optech — eltoo](../../raw/articles/2026-07-16-optech-eltoo-topic.md) — benefits, LN-Symmetry rename, pinning
- [Delving Bitcoin — LN-Symmetry recap](../../raw/articles/2026-07-16-delving-bitcoin-ln-symmetry-recap.md) — PoC status, pinning finding
- [Chaincode Podcast — instagibbs](../../raw/articles/2026-07-16-chaincode-podcast-anyprevout-instagibbs.md) — APOAS usage, activation reluctance
