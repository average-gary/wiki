---
title: "Fedimint H1 2025 Ecosystem Review (official, 2025-06-30)"
type: raw
source_type: articles
source_url: https://fedimint.org/blog/2025/06/30/fedimint-review-first-half
fetched: 2026-05-28
verified: 2026-05-28
volatility: warm
quality: 5
confidence: high
tags: [fedimint, roadmap, v0.6, v0.7, bitsacco, vipr, iroh, lnurl, bolt12]
summary: Official mid-2025 Fedimint blog post recapping v0.6 ("On-Chain for Everyone") and v0.7 (unified UI, LNURL recurring, Iroh networking beta, BOLT12 planned). Highlights BitSacco (Kenya, HRF-funded) and Vipr Wallet PWA. **No multi-asset / multi-currency mention.**
---

# Fedimint H1 2025 Ecosystem Review

Official Fedimint blog post, 2025-06-30.

## v0.6 — "On-Chain for Everyone"

- Simplified on-chain Bitcoin transactions
- Refined withdrawal fees
- Made deposits "notably more straightforward"
- Goal: "make eCash a more practical tool for everyday Bitcoin use"

## v0.7

- Fresh UI enabling Fedimint to run as a single application
- LNURL support for recurring Lightning payments (BOLT12 planned)
- Beta integration of **Iroh networking** for home setups on Signet
- Revamped Guardian UI — local machine operation without separate web server

## Featured deployments

- **BitSacco (Kenya)** — significant Human Rights Foundation funding. Building "community banking features, like digital savings groups (called chamas), peer-to-peer payments, and seamless fiat-to-bitcoin conversion" using Fedimint for custody and payments.
- **Vipr Wallet** — new web-based PWA at beta.vipr.cash. Fedimint WebSDK, Lightning, eCash, multi-federation support, Nostr mint discovery (NIP-87).

## Roadmap items mentioned

- "Running Fedimint from Home" via Start9 with Iroh networking (eliminates public IP requirement)
- BOLT12 support development
- Mainnet Start9 release pending Iroh stability

## Multi-asset / multi-currency mentions

**None.** This is the most authoritative public roadmap statement from H1 2025 and it does not mention non-BTC asset support, stablecoin modules, or multi-currency mint instances. PR #7734 (the core-layer multi-currency change) merged 2025-10-19 — ~4 months *after* this post — so its absence here is consistent with the framing as quiet plumbing rather than a flagship feature.

## Why this matters

- Establishes the official narrative through mid-2025: Fedimint's headline efforts are **scaling Bitcoin custody UX** (on-chain, Lightning, recurring payments, home-hosting), not **expanding the asset surface**.
- BitSacco is the marquee real-world deployment. Their fiat handling is *off-mint* via M-Pesa — see [[2026-05-28-bitsacco-cracktheorange-interview|BitSacco interview]] — confirming the production answer to "non-BTC currency" is currently external bridging, not native multi-asset.
- The contrast between the public narrative and the underlying core changes (#7734) suggests Fedimint is intentionally building rails before announcing destinations.

## See also

- [[2026-05-28-bitsacco-cracktheorange-interview|BitSacco interview]] — emerging-market production deployment
- [[2026-05-28-fedimint-pr-7734-multi-currency-support|PR #7734]] — quiet core-layer rails landing 4 months later
- [[2026-05-28-chapsmart-fedi-mini-app|ChapSmart Mini App]] — Fedi's payments-bridge approach to non-BTC currency
