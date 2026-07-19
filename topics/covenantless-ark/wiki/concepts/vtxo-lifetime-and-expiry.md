---
title: "VTXO lifetime, expiry, and liquidity economics"
type: concept
created: 2026-07-17
updated: 2026-07-17
confidence: high
volatility: hot
verified: 2026-07-17
sources:
  - raw/articles/2026-07-17-second-docs-learn-lifetime.md
  - raw/articles/2026-07-17-second-docs-learn-liquidity.md
  - raw/articles/2026-07-17-second-docs-learn-fees.md
  - raw/articles/2026-07-17-second-docs-learn-vtxo.md
tags: [ark, clark, bark, vtxo-lifetime, expiry, sweep, refresh, liquidity, capital-lockup, cost-formula, fees]
aliases: [VTXO lifetime, VTXO expiry, liquidity cost, refresh cost, opportunity cost, sweep incentive]
summary: "Why VTXOs expire and what it costs. Bark VTXOs carry a lifetime (~28-30 days standard, ~3 days for Lightning-receive VTXOs); at expiry the server can sweep them via the timelock path. The server fronts all VTXO liquidity upfront and recovers it only after expiry, so refresh cost follows a formula amount x (expiry_delta / 365d) x opportunity_rate — fresh VTXOs cost more to refresh than near-expiry ones."
---

# VTXO lifetime, expiry, and liquidity economics

> Every [[vtxo-and-vtxo-tree|VTXO]] ([VTXO](../concepts/vtxo-and-vtxo-tree.md)) has a bounded **lifetime**. This is not an arbitrary limitation — it is what lets the [[clark-overview|Ark server]] ([Ark server](../concepts/clark-overview.md)) reclaim pooled capital and keep serving new users. The flip side is that the server must **front the full value of every VTXO from its own liquidity** and only recovers it once the old round's timelock expires, which is exactly why refreshing a VTXO costs money and why that cost depends on how much lifetime is left. This article pulls together bark's lifetime, sweep, and liquidity-cost model; the exact timelock constants live in the [[clark-glossary-and-timelocks|glossary + timelock reference]] ([timelock reference](../reference/clark-glossary-and-timelocks.md)).

## Lifetime and expiry

Board and refresh VTXOs expire after a set lifetime — bark states a standard round-VTXO lifetime of roughly **28-30 days**, while **Lightning-receive VTXOs** live only about **3 days** (see [[lightning-integration|Lightning integration]] ([Lightning integration](../concepts/lightning-integration.md))). At the expiry height "the server gains the ability to **sweep** any remaining bitcoin to its own wallet through the timelock spend paths" ([bark docs/lifetime](../../raw/articles/2026-07-17-second-docs-learn-lifetime.md)).

Key subtleties:

- Until expiry, the user keeps **concurrent** rights to spend or [[unilateral-exit-and-timeouts|emergency-exit]] ([emergency-exit](../concepts/unilateral-exit-and-timeouts.md)) the VTXO — unless they have forfeited it.
- **Spending does not reset the lifetime.** A received "old" VTXO inherits the original expiry, so a recipient of an aging VTXO must refresh sooner (this is why an [[out-of-round-payments|arkoor]] ([arkoor](../concepts/out-of-round-payments.md)) receiver cannot sit on funds indefinitely).
- **Refreshing** in a [[clark-round-lifecycle|round]] ([round](../concepts/clark-round-lifecycle.md)) issues a new refresh VTXO with a **fresh lifetime**.

### Keeping control (four options)

To avoid losing funds at expiry a user can: **spend** the VTXO (inherits original expiry), **refresh** it in a round (fresh lifetime), **cooperatively offboard** (see [[offboarding-and-onchain-payments|offboarding]] ([offboarding](../concepts/offboarding-and-onchain-payments.md))), or **emergency-broadcast** the exit chain. bark's framing is that a well-designed wallet auto-prioritizes older VTXOs and refreshes those near expiry, so "users shouldn't need to worry about VTXO lifetime as long as their wallet app comes online regularly."

### Why the server doesn't just steal expired VTXOs early

The sweep power only becomes valid **at** expiry. A server that tried to claim not-yet-forfeited, not-yet-expired bitcoin would be "quickly identifiable by users," triggering offboarding and loss of business — an **economic honesty incentive** rather than a cryptographic guarantee. This is the same liveness-vs-custody split described in [[clark-limitations-and-trust|limitations and trust]] ([limitations and trust](../topics/clark-limitations-and-trust.md)).

## Liquidity — the server fronts the capital

Liquidity management "shifts entirely to the server," which "deploys bitcoin upfront while waiting to sweep equivalent amounts from spent VTXOs after they expire" ([bark docs/liquidity](../../raw/articles/2026-07-17-second-docs-learn-liquidity.md)). Three operations consume this liquidity:

1. **Refreshes** — the most common;
2. **Offboarding**;
3. **[[lightning-integration|Lightning payments]]** ([Lightning payments](../concepts/lightning-integration.md)).

The server must **wait for the old round's timelock to expire** before reclaiming funds from forfeited VTXOs — a temporary capital requirement. At scale this is substantial: an ASP serving 10,000 users at 100,000 sats each needs roughly **10 BTC** in active liquidity (a figure echoed in [[clark-limitations-and-trust|the criticism sources]] ([limitations and trust](../topics/clark-limitations-and-trust.md))).

### The liquidity-cost formula

The cost of the liquidity a refresh consumes is:

```
liquidity_cost = amount x (expiry_delta / 365 days) x opportunity_rate
```

Worked example from the docs: a **100,000 sat** VTXO with **5 days** of lifetime remaining at a **5%** annual opportunity cost → **68 sats**.

The formula explains the age→price relationship: **fresh VTXOs cost more to refresh** because the server's capital is committed for longer (larger `expiry_delta`), while VTXOs **nearing the end of their lifetime cost significantly less**. bark frames this as more precise than Lightning's model, because the server responds to actual demand dynamically instead of pre-funding channels for predicted behavior.

## Fees — the categories

The liquidity cost above is one line in a broader fee picture. bark enumerates the categories (without amounts, which live on the operator's pricing page) ([bark docs/fees](../../raw/articles/2026-07-17-second-docs-learn-fees.md)):

- **liquidity costs** (the capital opportunity cost above, for refreshes / Lightning / on-chain);
- **on-chain Bitcoin fees**;
- **Lightning routing fees**;
- **development costs** and **server operating costs**.

"Any Ark server **must** charge fees (in some way or another) to cover their operational costs." There are two pricing philosophies — **direct cost-based** (each operation priced at its actual server cost) and **abstracted** (cross-subsidized for predictable pricing) — and Second uses a **hybrid**.

## See Also

- [[vtxo-and-vtxo-tree|VTXOs and the VTXO tree]] ([VTXOs and the VTXO tree](../concepts/vtxo-and-vtxo-tree.md)) — the object whose lifetime this article governs
- [[clark-round-lifecycle|Round lifecycle]] ([Round lifecycle](../concepts/clark-round-lifecycle.md)) — refreshing is what resets the lifetime and consumes liquidity
- [[lightning-integration|Lightning integration]] ([Lightning integration](../concepts/lightning-integration.md)) — the short ~3-day receive-VTXO lifetime
- [[offboarding-and-onchain-payments|Offboarding and on-chain payments]] ([Offboarding and on-chain payments](../concepts/offboarding-and-onchain-payments.md)) — the other liquidity-consuming exits
- [[out-of-round-payments|Out-of-round (arkoor) payments]] ([Out-of-round payments](../concepts/out-of-round-payments.md)) — spend VTXOs inherit the source expiry; refresh to harden
- [[unilateral-exit-and-timeouts|Unilateral exit and timeouts]] ([Unilateral exit and timeouts](../concepts/unilateral-exit-and-timeouts.md)) — the sweep is the operator side of the exit clock
- [[boarding|Boarding]] ([Boarding](../concepts/boarding.md)) — board VTXOs also carry a lifetime and sweep
- [[clark-overview|clArk overview]] ([clArk overview](../concepts/clark-overview.md)) — where lifetime/liquidity sits in the whole system
- [[clark-limitations-and-trust|clArk limitations and trust model]] ([limitations and trust](../topics/clark-limitations-and-trust.md)) — the ASP capital cost as a systemic constraint
- [[clark-round-transaction-mechanics|Round transaction mechanics]] ([Round transaction mechanics](../topics/clark-round-transaction-mechanics.md)) — the end-to-end synthesis
- [[clark-glossary-and-timelocks|Glossary + timelock reference]] ([timelock reference](../reference/clark-glossary-and-timelocks.md)) — exact expiry / exit-delay constants

## Sources

- [VTXO lifetime (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-lifetime.md) — expiry/sweep, spend-inherits-expiry, refresh-resets, server honesty incentive
- [Ark liquidity (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-liquidity.md) — upfront-capital model, the cost formula + worked example, age→price, capital lockup
- [Ark fees (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-fees.md) — fee categories, must-charge, direct vs abstracted pricing
- [Ark VTXOs (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-vtxo.md) — ~30-day lifetime, spending doesn't reset lifetime
