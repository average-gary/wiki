---
title: "Cashu — multi-unit Chaumian e-cash (comparison reference)"
type: reference
created: 2026-05-28
updated: 2026-05-28
verified: 2026-05-28
volatility: cold
confidence: medium
tags: [cashu, comparison, nut-02, multi-unit, blind-signatures, single-operator]
---

# Cashu (comparison reference)

Cashu is the closest cousin to Fedimint: a Chaumian e-cash protocol with blind signatures, but with **a single operator (mint)** instead of a Fedimint-style threshold-signed federation. Cashu is interesting here because **it already has multi-unit support per mint** in its specification.

## Multi-unit pattern (NUT-00 / NUT-01 / NUT-02)

- A Cashu mint can publish multiple **keysets**, one per unit (e.g. `sat`, `usd`).
- The `unit` is cryptographically bound to the keyset ID via a `|unit:sat` (or analogous) prefix in the hash derivation. Distinct units → distinct keyset IDs.
- Wallets MUST support multiple keysets simultaneously.

This is the most plausible template for what Fedimint's [[../concepts/mintv2-amount-unit-config|mintv2 amount_unit]] approach is converging toward at the per-unit level.

## How Cashu and Fedimint differ on the multi-currency question

| Aspect | Cashu | Fedimint |
|---|---|---|
| Custody | Single operator | t-of-n threshold federation |
| Multi-unit support | NUT-02 native | mintv2 `amount_unit` config (PR #8460), no production unit |
| Backing of non-BTC units | Mint operator's responsibility (anyone can claim a unit) | Federation guardians' responsibility — same trust model as BTC custody |
| Custodial risk | Concentrated in one party | Distributed across guardians |
| Regulatory exposure for non-BTC units | Single legal entity | Multiple guardian entities (jurisdictional spread possible) |
| User exit | Single operator must process | Quorum must process |
| Production multi-unit deployments | Yes (e.g. testnet `tsat`, some experimental USD-claiming mints) | No |

## Why Cashu can ship multi-unit faster

- Single operator means the legal/custodial structure is one party's decision, not a guardian-coordination problem.
- No AlephBFT-style consensus — the operator just signs.
- Lower bar for "experimental USD mint" — anyone can spin one up; users self-select on trust.

The flip side: Cashu inherits all of single-operator custodial risk. Fedimint's slower pace on multi-currency is in part a consequence of taking the threshold-trust model seriously.

## Reading list

- Cashu spec / NUT-02: https://github.com/cashubtc/nuts/blob/main/02.md (canonical)
- Cashu protocol overview: https://docs.cashu.space
- Comparison framing: [[../topics/fedimint-multi-currency-status|Multi-currency status]] — Path A (Fedimint native multi-unit) is converging toward what Cashu does, but with threshold custody on top.

## See also

- [[../topics/fedimint-multi-currency-status|Multi-currency status]] — the synthesized comparison
- [[../concepts/mintv2-amount-unit-config|mintv2 amount_unit config]] — the Fedimint-side analog
- [[../concepts/federation-trust-model|Federation trust model]] — the part Fedimint adds that Cashu doesn't have
