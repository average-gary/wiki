---
title: "Off-mint payments-bridge pattern"
type: concept
created: 2026-05-28
updated: 2026-05-28
verified: 2026-05-28
volatility: warm
confidence: high
tags: [fedimint, fedi, mini-apps, bitsacco, chapsmart, m-pesa, payments-bridge, applied]
---

# Off-mint payments-bridge pattern

The dominant production answer to "how does a Fedimint user transact in non-BTC currency?" is **not** a multi-currency mint module. It's an **external Lightning-receiving service** that converts BTC → local fiat via existing mobile-money rails.

The federation's mint stays BTC-only. The fiat side never enters the federation. Trust is split between the federation guardians (for BTC custody) and the fiat-rails operator (for delivery).

## Documented examples

- **ChapSmart Mini App** ([[../../raw/articles/2026-05-28-chapsmart-fedi-mini-app|article]], 2026-05-18): Fedi user pays a Lightning invoice; ChapSmart settles to recipient's M-Pesa account in Tanzanian Shillings.
- **BitSacco** ([[../../raw/articles/2026-05-28-bitsacco-cracktheorange-interview|interview]]): 5+ guardian Kenyan federation. KES↔BTC handled via M-Pesa integration; chamas (savings groups) modeled as sub-accounts inside the federation; KES never touches the mint.

## Architectural shape

```
[ User wallet (BTC eCash) ]
            │
            │  Lightning (BTC)
            ▼
[ Bridge service (e.g. ChapSmart) ]
            │
            │  off-network conversion
            ▼
[ Mobile-money operator (M-Pesa) ]
            │
            │  KES / TZS / etc.
            ▼
[ Recipient ]
```

## Why this works without native multi-currency

- BTC custody model is well-understood (`Federation` of guardians, threshold sigs).
- Mobile-money operators (M-Pesa is the canonical example) already run regulated fiat infrastructure.
- The bridge is just a Lightning Service Provider that happens to settle in fiat.
- No peg, no oracle, no collateral pool, no proof-of-reserves problem for non-BTC value (the federation has none).

## Tradeoffs vs. native multi-currency

| Aspect | Off-mint bridge | Native multi-currency mint |
|---|---|---|
| Fiat custody risk | Bridge operator | Federation guardians |
| Regulatory exposure | Bridge operator | Federation guardians |
| Trust hops | 2 (federation + bridge) | 1 (federation) |
| Oracle requirement | None inside federation | Yes, per non-BTC unit |
| User experience | Per-app integration | Wallet-native |
| Deployment status | Production (BitSacco, ChapSmart) | Plumbing landed (PR #7734, PR #8460) but no production unit |

## Relation to multi-currency

This pattern is **why Fedimint has been able to ship into emerging markets without native multi-currency support**. It is also why the multi-currency core changes ([[amount-units-and-amounts|AmountUnits and Amounts]], [[mintv2-amount-unit-config|mintv2 amount_unit config]]) have shipped quietly as plumbing rather than as a flagship feature — there's no immediate production pressure, because the off-mint bridge pattern works.

It is the **alternative-with-strongest-mass-deployment** to the multi-currency-mint approach. Any multi-currency proposal needs to argue why it beats this baseline.

## See also

- [[../../raw/articles/2026-05-28-bitsacco-cracktheorange-interview|BitSacco]] — KES via M-Pesa
- [[../../raw/articles/2026-05-28-chapsmart-fedi-mini-app|ChapSmart]] — TZS via M-Pesa
- [[stability-pool|Stability Pool]] — synthetic alternative
- [[mintv2-amount-unit-config|mintv2 amount_unit config]] — native alternative (not yet in production)
- [[../topics/fedimint-multi-currency-status|Multi-currency status]] — three-path framing
