---
title: "Fedimint multi-currency support — status as of 2026-05-28"
type: topic
created: 2026-05-28
updated: 2026-05-28
verified: 2026-05-28
volatility: hot
confidence: high
tags: [fedimint, multi-currency, multi-asset, stablecoin, status, synthesis]
---

# Fedimint multi-currency support — status as of 2026-05-28

**One-line answer**: Fedimint's protocol layer can now carry multi-unit transactions and the v2 mint module can declare a unit per instance, but **no production federation currently issues non-BTC eCash backed by real non-BTC assets.** The dominant non-BTC patterns in production are **synthetic-USD via the Stability Pool** (BTC-collateralized derivative) and **off-mint payments bridges** (BitSacco, ChapSmart) where fiat never enters the federation.

## Three architectural paths

| Path | Approach | Status (2026-05-28) | Examples |
|---|---|---|---|
| **A. Native multi-currency mint** | Run multiple `mintv2` instances, each with `amount_unit` set to a different unit | Plumbing landed (PR #7734 Oct 2025, PR #8460 Apr 2026). **No production deployment of a non-BTC mint instance with real backing.** | none yet |
| **B. External custom module (FMCM)** | Module that holds non-BTC-shaped value alongside the BTC mint | Production-experimental | Fedi's [[../concepts/stability-pool\|Stability Pool]] (synthetic USD via BTC collateral) |
| **C. Off-mint payments bridge** | BTC stays in the mint; an external service converts BTC↔fiat via existing rails | Production today | [[../../raw/articles/2026-05-28-bitsacco-cracktheorange-interview\|BitSacco]] (KES via M-Pesa), [[../../raw/articles/2026-05-28-chapsmart-fedi-mini-app\|ChapSmart]] (TZS via M-Pesa) |

## Path A — what shipped, what's missing

**Shipped:**

- [[../concepts/amount-units-and-amounts|AmountUnits and Amounts]] in `fedimint-core` ([[../../raw/repos/2026-05-28-fedimint-pr-7734-multi-currency-support|PR #7734]], merged 2025-10-19, by dpc). Modules return `Amounts` (`unit -> amount` map) instead of a scalar `Amount`. Consensus iterates per unit and verifies each balances independently.
- [[../concepts/mintv2-amount-unit-config|mintv2 `amount_unit` config field]] ([[../../raw/repos/2026-05-28-fedimint-pr-8460-mintv2-amount-unit-config|PR #8460]], merged 2026-04-08, by joschisan; backported to `releases/v0.11`). Lets a federation operator declare which unit a given mintv2 instance issues. Combined with the `ModuleKind` / `ModuleInstanceId` decoupling that already existed in [[../concepts/fedimint-modules-and-instances|fedimint-core]], a single federation can spin up multiple mintv2 instances with different `amount_unit`s.
- Removal of the manual primary-module setting in favor of per-unit module priority (also part of #7734) — the wallet-side change needed to balance transactions across units.

**Missing:**

- **Any in-tree backing logic for non-BTC units.** `amount_unit` is a label. Whether a mintv2(`usd`) note is *redeemable* for any USD value is not specified — that's the responsibility of whatever process / module backs the unit. None ships in-tree.
- **Peg / oracle / collateral primitives.** No standard module for "this unit is pegged to that asset via this oracle with this attestation cadence."
- **Production deployment.** As of 2026-05-28, no public federation runs a non-BTC mintv2 instance with real backing.
- **dpc on the gap (Jan 2026)**: *"In Fedimint we are working in the longer term goal on multi-currency support, which in principle would allow people to implement extension modules for any assets. But it is nowhere need [near] to be implemented."* ([[../../raw/articles/2026-05-28-fedimint-discussion-8218-gold-stablecoins|Discussion #8218]]). Note this comment came **after** PR #7734 landed — meaning even with the rails in place, the maintainer characterized it as far from done.

## Path B — Stability Pool reality check

Fedi's **Stability Pool** ([[../concepts/stability-pool|concept]]) is the **closest live example** of "Fedimint holds non-BTC value." But the precise shape matters:

- The BTC mint still issues only BTC-denominated eCash.
- Stability Pool is a *separate* external custom module (FMCM) that holds locked BTC collateral and tracks USD-value positions via guardian-decided oracle prices.
- Settlement is in BTC. **There are no USD notes. There is no USD in the system.**
- A user "holds $X of stable balance" — redemption gives them BTC worth $X at the next epoch settlement, contingent on oracle and counterparty solvency.

This is **synthetic, not pegged**. dpc's verbatim framing: *"Fedi app has a custom extension module that implements synthetic stable balances."*

The FMCM ecosystem is also fragile. [[../../raw/articles/2026-05-28-fedimint-issue-8217-external-modules-broken|Issue #8217]] documents Fedi's Stability Pool breaking when porting to fedimint 0.10 because PR #8067 nuked module `GenParams` support — external modules track upstream API churn manually.

## Path C — why off-mint bridging dominates production

[[../concepts/off-mint-payments-bridge-pattern|Off-mint payments-bridge pattern]] handles non-BTC currency entirely outside the mint:

```
User wallet (BTC eCash) → Lightning (BTC) → Bridge (e.g. ChapSmart) → M-Pesa (KES/TZS) → Recipient
```

This is what BitSacco (Kenya) and ChapSmart (Tanzania) actually do. The mint stays BTC-only. The fiat side runs on existing regulated mobile-money infrastructure. **Fedimint federations have shipped to emerging markets without ever needing native multi-currency support.**

The H1 2025 official Fedimint blog ([[../../raw/articles/2026-05-28-fedimint-h1-2025-ecosystem-review|review]]) features BitSacco as the marquee deployment and **does not mention multi-asset support anywhere** — confirming the production path Fedimint is committed to today.

## Why this matters: the risk multiplier

[[../concepts/federation-trust-model|Fedimint's federation trust model]] already carries five named risks (custodial, debasement, regulatory, gateway censorship, availability). **Multi-currency multiplies most of them per-unit:**

- Debasement risk is per-unit. Each non-BTC mint instance has its own bank-run failure mode and its own proof-of-reserves gap (Fedimint has no trustless PoR even for BTC).
- Regulatory exposure depends on the asset. BTC-only federations sit in (often-known) Bitcoin custody regimes. Fiat-pegged or commodity-pegged units cross into securities, money-transmitter, stablecoin-issuer, or commodity-token regimes.
- Oracle dependency is created per non-BTC unit. BTC mints don't need oracles. USD-synth (Stability Pool) needs a BTC/USD oracle. Fiat-pegged units would need an off-chain peg + attestation.

This is the strongest steelman for why Fedimint has built the rails quietly and not rushed Path A into production.

## Comparison with Cashu

[[../reference/cashu-comparison|Cashu]] (single-operator Chaumian e-cash, the closest cousin) **already supports multi-unit per mint** via NUT-00/01/02. A keyset's `unit` field is cryptographically bound to its keyset ID via a `|unit:sat` prefix in the hash derivation. Wallets must support multiple keysets simultaneously.

Fedimint's path A is converging toward a similar shape — units as first-class labels, with multi-instance modules carrying them — though Fedimint adds the threshold-custody and consensus-verified-balance layers Cashu doesn't have.

## Where this points

If you care about Fedimint multi-currency support today:

- **Operator wanting to serve a non-BTC user base**: use Path C (off-mint payments bridge), unless you specifically need Fedimint-cryptographic guarantees on the non-BTC side.
- **Operator wanting "stable" UX**: Path B (Stability Pool) is the experimental option, but it is synthetic and the FMCM brittleness is real.
- **Builder wanting a real multi-currency federation**: the rails are in place (Path A), but you'd be building the backing-mechanism module itself plus solving the oracle / proof-of-reserves problems for whichever asset.
- **Researcher / skeptic**: the [[../concepts/federation-trust-model|trust-model risk multiplier]] is the most important critique — every multi-currency proposal needs to argue why it beats the off-mint baseline (Path C) given that multiplier.

## Open questions / theses for follow-up

- *Will Fedimint's first production non-BTC mintv2 deployment carry real backing or remain synthetic?* (Plausible follow-up: a guardian-held fiat-reserve model, but regulatory exposure is the gating constraint.)
- *Does the off-mint pattern (Path C) make Path A economically irrelevant for emerging-markets use cases?* (BitSacco's success suggests yes for the Kenya-shape; less clear for use cases requiring eCash-native settlement, e.g. micropayments for content.)
- *Cashu's NUT-02 multi-unit pattern is a clear template — will Fedimint's approach diverge significantly or converge?*

## See also

- Concepts: [[../concepts/amount-units-and-amounts|AmountUnits & Amounts]] · [[../concepts/mintv2-amount-unit-config|mintv2 amount_unit]] · [[../concepts/fedimint-modules-and-instances|Modules & instances]] · [[../concepts/stability-pool|Stability Pool]] · [[../concepts/off-mint-payments-bridge-pattern|Off-mint bridge pattern]] · [[../concepts/federation-trust-model|Federation trust model]]
- Primary sources: [[../../raw/repos/2026-05-28-fedimint-pr-7734-multi-currency-support|PR #7734]] · [[../../raw/repos/2026-05-28-fedimint-pr-8460-mintv2-amount-unit-config|PR #8460]] · [[../../raw/articles/2026-05-28-fedimint-discussion-8218-gold-stablecoins|Discussion #8218]] · [[../../raw/articles/2026-05-28-fedimint-issue-8217-external-modules-broken|Issue #8217]]
