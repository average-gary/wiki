---
title: "Fedimint Discussion #8218 — Are gold stable coins compatible? (Marc26z, dpc reply, 2026-01)"
type: raw
source_type: articles
source_url: https://github.com/fedimint/fedimint/discussions/8218
fetched: 2026-05-28
verified: 2026-05-28
volatility: warm
quality: 5
confidence: high
tags: [fedimint, multi-currency, stablecoin, fedi-app, dpc, maintainer-statement]
summary: User asks whether gold stablecoins (Tether Gold) work with Fedi Wallet's "stablecoin support". Maintainer dpc replies that Fedi's stable balance is a **synthetic** custom extension module, and that **native multi-currency in Fedimint is a longer-term goal "nowhere near to be implemented."**
---

# Discussion #8218 — Are gold stable coins compatible with the stablecoin integration in the Fedi Wallet?

- **Asked**: 2026-01-28 by Marc26z
- **Last activity**: 2026-02-05
- **State**: open (no chosen answer, but maintainer reply present)
- **URL**: https://github.com/fedimint/fedimint/discussions/8218

## Question (Marc26z, verbatim)

> I noticed Fedimint has stablecoin support. Does it also support stuff like Tether Gold?
>
> I know this requires trust a hashcash like Proof-Of-Work can't solve so don't get mad at me. It's just a question. 😀

## Maintainer answer (dpc, verbatim)

> Fedi app has a custom extension module that implements synthetic stable balances.
>
> In Fedimint we are working in the longer term goal on multi-currency support, which in principle would allow people to implement extension modules for any assets. But it is nowhere need to be implemented.

## Why this matters

This is the clearest single-sentence framing of where Fedimint actually stands on multi-currency, from a core developer:

1. **Fedi's "stablecoin" is synthetic** — implemented as a *custom extension module* (the Stability Pool — see [[2026-05-28-bitcoin-manual-fedimint-stability-pool|Stability Pool article]]). It is **not** a real stablecoin; there is no peg, no fiat backing, no oracle. It is a BTC-collateralized derivative that tracks USD value.
2. **Native multi-currency is a longer-term Fedimint goal**, not a shipped feature. dpc's "nowhere need [near] to be implemented" sets expectations bluntly — even though the core-layer infrastructure has since landed (PR #7734 was merged 2025-10-19, ~3 months before this discussion).
3. **The model would be modular**: "extension modules for any assets" — meaning any future non-BTC support would be implemented as a module, not baked into the core mint.

## Reconciling with shipped work

Note the timing:
- **PR #7734 (multi-currency core)** merged 2025-10-19
- **This discussion**: dpc replies in 2026-01/02
- **PR #8460 (mintv2 amount_unit)** merged 2026-04-08

So when dpc said "nowhere near," the rails (#7734) were already merged but no actual non-BTC asset module existed. Three months later, the per-module config field landed — still not an asset, just the label.

**Status as of 2026-05-28**: the protocol can carry multi-unit transactions and modules can declare units, but no production federation has spun up a non-BTC mint instance backed by anything real.

## See also

- [[2026-05-28-fedimint-pr-7734-multi-currency-support|PR #7734]] — the core-layer rails dpc was working toward
- [[2026-05-28-fedimint-pr-8460-mintv2-amount-unit-config|PR #8460]] — per-module unit config landed after this discussion
- [[2026-05-28-bitcoin-manual-fedimint-stability-pool|The Bitcoin Manual — Stability Pool]] — what "synthetic stable balances" actually means
