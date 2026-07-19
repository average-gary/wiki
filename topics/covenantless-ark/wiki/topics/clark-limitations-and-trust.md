---
title: "clArk limitations and trust model"
type: topic
created: 2026-07-16
updated: 2026-07-17
confidence: high
volatility: warm
verified: 2026-07-17
sources:
  - raw/articles/2026-07-16-evolution-adios-expiry-delegation.md
  - raw/articles/2026-07-16-criticism-spark-ark-explained.md
  - raw/articles/2026-07-16-criticism-shinobi-ark-vs-lightning.md
  - raw/repos/2026-07-16-dropout-instagibbs-boats-exit-spec.md
  - raw/articles/2026-07-16-implementations-arkade-os-docs.md
  - raw/articles/2026-07-17-second-docs-learn-liquidity.md
  - raw/articles/2026-07-17-second-docs-learn-lifetime.md
  - raw/articles/2026-07-17-second-docs-learn-payments.md
tags: [ark, clark, limitations, trust, liveness, liquidity, mass-exit, censorship, criticism]
aliases: [clArk limitations, Ark trust model, Ark criticism]
summary: "The costs of the covenantless design — interactivity/liveness, receiver-DoS griefing, exit-data storage burden, ASP liquidity cost, unilateral-exit cost and mass-exit feedback loop, ASP liveness/censorship trust, OOR double-spend gap, and cross-ASP contagion — plus bark's own framing of the liquidity cost formula and the economic (rather than cryptographic) honesty incentive against early sweeps."
---

# clArk limitations and trust model

The covenantless design buys "works on Bitcoin today, no soft fork" at real cost. Many limitations are **acknowledged by the designers themselves**, which makes them well-grounded rather than adversarial FUD.

## 1. Interactivity / liveness (designer-acknowledged)

- Every round is a **synchronous n-of-n ceremony**; all participants must be online and cooperating. See [[../concepts/dropout-and-round-abort.md|dropout and round abort]].
- Users must **refresh before `T_exp`** or the operator sweeps the funds. Ark Labs concedes: for users used to "'set it and forget it' self-custody, this feels like a step backwards," and missing a renewal means users "lose the ability to enforce ownership claims onchain" ([[../../raw/articles/2026-07-16-evolution-adios-expiry-delegation.md|Adios, Expiry]]).
- Spark frames it bluntly: clArk "reintroduces the kind of online-requirement that Ark was designed to eliminate" ([[../../raw/articles/2026-07-16-criticism-spark-ark-explained.md|Spark]]).

## 2. Griefing / receiver-DoS

A pure receiver has nothing at stake and can abort the round for free, so clArk cannot admit receivers into rounds. Interactivity and griefing are the **same mechanism**: "the bad actions of certain users will affect all other users." Mitigations: bans (300 s in arkd), [[../concepts/checkpoint-transactions.md|checkpoint txs]], and ultimately covenants. See [[../concepts/dropout-and-round-abort.md|dropout]].

## 3. Presigned-state storage burden

Because there is no covenant, users must **persist all data to reconstruct their exit chain** independently of the server — lose it and unilateral exit is impossible ([[../../raw/repos/2026-07-16-dropout-instagibbs-boats-exit-spec.md|instagibbs]]). This is a covenantless-specific risk; CTV variants remove it.

## 4. ASP capital / liquidity cost

- The ASP "must fund the entire value of all new vTXOs from its own capital," recovering it only at expiry or forfeit. Quantified: "An ASP serving 10,000 users with an average balance of 100,000 sats needs to maintain roughly 10 BTC in active liquidity" — passed to users as fees ([[../../raw/articles/2026-07-16-criticism-spark-ark-explained.md|Spark]]).
- Shinobi: "When the ASP gets to a point where it is running out of liquidity, its fees must necessarily start skyrocketing"; receiving still needs inbound liquidity like Lightning ([[../../raw/articles/2026-07-16-criticism-shinobi-ark-vs-lightning.md|Shinobi]]).
- bark quantifies the per-refresh cost as `amount × (expiry_delta ÷ 365 d) × opportunity_rate` (e.g. 100k sat, 5 d, 5% → 68 sats), so fresh VTXOs cost more to refresh than near-expiry ones. It frames its liquidity use as *more precise* than Lightning's — dynamic response rather than pre-funded channels — a designer counterpoint to the criticism above ([[../../raw/articles/2026-07-17-second-docs-learn-liquidity.md|bark liquidity]]). See [[../concepts/vtxo-lifetime-and-expiry.md|VTXO lifetime and expiry]].

## 5. Unilateral exit cost and the mass-exit feedback loop

- Exit is **O(log t)** on-chain txs with CPFP fees; "the cost of unilateral exit could exceed the value of small vTXOs" (a dust-like constraint).
- The [[../concepts/unilateral-exit-and-timeouts.md|exit-window race]]: exits must finish before `T_exp` or the server sweeps; a simultaneous mass exit creates "a negative feedback loop similar to fee market dynamics during periods of high demand" ([[../../raw/articles/2026-07-16-criticism-spark-ark-explained.md|Spark]], [[../../raw/repos/2026-07-16-dropout-instagibbs-boats-exit-spec.md|instagibbs]]).

## 6. ASP trust surface (liveness / censorship)

The ASP can "refuse to include users in future rounds" and "go offline, halting new round creation." Funds remain recoverable via unilateral exit, but **no new activity** is possible while the operator is down ([[../../raw/articles/2026-07-16-criticism-spark-ark-explained.md|Spark]], [[../../raw/articles/2026-07-16-implementations-arkade-os-docs.md|Arkade]]). The ASP cannot *steal* funds (VTXOs have unilateral exit), but it is a **liveness and censorship** trust point.

## 7. OOR double-spend trust gap

Out-of-round payments require sender+operator co-signature; a receiver "must trust that the sender will not collude with the operator to double-spend" the chain until the VTXO is refreshed into a round ([[../concepts/out-of-round-payments.md|out-of-round payments]]).

## 8. Cross-ASP contagion

Payments across ASPs "interlink Arks across different ASPs, meaning non-cooperative closes would necessitate the closure of Arks operated by multiple entities" — a systemic risk "analogous to the channel jamming problem of Lightning" ([[../../raw/articles/2026-07-16-criticism-shinobi-ark-vs-lightning.md|Shinobi]]).

## Trust model summary

clArk is **trustless with respect to custody** (unilateral exit guarantees you can always leave, given stored exit data and timely action) but **trusted with respect to liveness and censorship** (the ASP can stall you, and expiry punishes your own offline time). The covenantless construction adds the synchronous-signing and exit-storage burdens on top of Ark's baseline liveness requirement.

One nuance the bark docs make explicit: the server's protection against *stealing* not-yet-expired, not-yet-forfeited VTXOs is partly **economic, not purely cryptographic** — an early sweep "would be quickly identifiable by users," causing offboarding and business loss ([[../../raw/articles/2026-07-17-second-docs-learn-lifetime.md|bark lifetime]]). Similarly, the OOR double-spend gap is deterred by detectability, reputation, the two-party collusion requirement, and fee-drain on competing exits ([[../../raw/articles/2026-07-17-second-docs-learn-payments.md|bark payments]]) — mitigations that are behavioral rather than trustless.

## See also

- [[clark-round-transaction-mechanics.md|Round transaction mechanics]]
- [[clark-vs-covenant-ark.md|clArk vs covenant-based Ark]]
- [[clark-evolution.md|Evolution — how these are being mitigated]]
- [[../concepts/vtxo-lifetime-and-expiry.md|VTXO lifetime and expiry]]
- [[../concepts/lightning-integration.md|Lightning integration]]

## Sources

- [Adios, Expiry — delegation](../../raw/articles/2026-07-16-evolution-adios-expiry-delegation.md) — "step backwards" from set-and-forget self-custody
- [Spark — Ark explained](../../raw/articles/2026-07-16-criticism-spark-ark-explained.md) — online-requirement, 10 BTC liquidity, mass-exit feedback loop, ASP trust surface
- [Shinobi — Ark vs Lightning](../../raw/articles/2026-07-16-criticism-shinobi-ark-vs-lightning.md) — liquidity skyrocketing, cross-ASP contagion
- [instagibbs / boats exit spec](../../raw/repos/2026-07-16-dropout-instagibbs-boats-exit-spec.md) — exit-data storage burden, exit-window race
- [Arkade docs](../../raw/articles/2026-07-16-implementations-arkade-os-docs.md) — operator-offline halting, sweep
- [Ark liquidity (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-liquidity.md) — cost formula, precision-vs-Lightning framing
- [VTXO lifetime (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-lifetime.md) — economic honesty incentive against early sweeps
- [Ark payments / arkoor (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-payments.md) — the four double-spend deterrents
