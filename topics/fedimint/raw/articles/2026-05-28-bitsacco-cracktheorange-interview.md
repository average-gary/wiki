---
title: "Crack The Orange — BitSacco founder interview (Jodom)"
type: raw
source_type: articles
source_url: https://my.cracktheorange.com/adoption-africa/interview-bitsacco/
fetched: 2026-05-28
verified: 2026-05-28
volatility: warm
quality: 4
confidence: medium
tags: [bitsacco, fedimint, kenya, kes, m-pesa, chamas, hrf, emerging-markets, applied]
summary: Interview with BitSacco founder Jodom. KYC-compliant Fedimint deployment in Kenya providing chamas (savings groups) and KES↔BTC via mobile money. **KES is handled off-mint via M-Pesa integration; the federation stays BTC-only.**
---

# BitSacco founder interview (Crack The Orange, "Adoption: Africa")

## Subject

- **BitSacco** — Fedimint deployment in Kenya
- **Founder**: Jodom
- **Pilot**: launched at Africa Bitcoin Conference, KYC-compliant for Kenyan regulatory environment

## Architecture

- **5+ guardian multisig federation** — eCash issued under a primary federation
- **Chamas as sub-accounts** — community savings groups, each as a logical sub-account inside the federation
- **KES handled off-mint via M-Pesa** — fiat never enters the federation; the mint remains BTC-only
- **Open-source template** — designed to be replicable; targeting Uganda and Zimbabwe expansion
- Positioned as "entry-level" custody, with self-custody graduation as the long-term path

## Why this matters for multi-currency

BitSacco is **the marquee real-world emerging-markets Fedimint deployment** — featured in Fedimint's H1 2025 review, HRF-funded, and explicitly designed for users whose daily currency is not Bitcoin.

It is also **the canonical evidence that production Fedimint federations do not need native multi-currency support to serve non-BTC users.** The architecture choice is deliberate:

- Mint custody = BTC only (clean, well-understood threshold-trust model)
- Local-currency UX = mobile-money integration (M-Pesa) at the wallet/app layer
- Trust hop = the same BTC↔KES rails Kenya already uses for remittance

This is the **same off-mint payments-bridge pattern as ChapSmart** ([[2026-05-28-chapsmart-fedi-mini-app|ChapSmart]]) but generalized into a full community-banking product.

## Tradeoff vs. native multi-currency

The off-mint approach has one big advantage and one big disadvantage:

**Advantage**: no peg / oracle / collateral risk inside the federation. Guardians only secure BTC, which has a known custody model and no settlement-failure mode beyond BTC volatility.

**Disadvantage**: users must trust *both* the federation (for BTC custody) *and* the M-Pesa bridge (for fiat conversion + delivery). There is no Fedimint-cryptographic guarantee that the KES side settles — that's regulated mobile-money infrastructure.

Native multi-currency (post PR #7734 / #8460) could in principle let a future BitSacco-like federation issue KES-denominated eCash backed by guardian-held KES — but that introduces fiat custody, regulatory exposure, and an oracle problem the current architecture sidesteps entirely.

## See also

- [[2026-05-28-chapsmart-fedi-mini-app|ChapSmart]] — same off-mint pattern with TZS
- [[2026-05-28-fedimint-h1-2025-ecosystem-review|Fedimint H1 2025 review]] — BitSacco as featured deployment
- [[2026-05-28-spark-fedimint-research-overview|Spark research]] — discussion of regulatory exposure for federations
