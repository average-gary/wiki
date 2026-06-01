---
title: "Introduction to the Lightning Network"
source: "https://ocean.xyz/docs/intro-to-lightning"
type: articles
ingested: 2026-05-28
tags: [ocean, lightning, bolt11, bolt12, htlc, education, payment-channels]
summary: "OCEAN's 2026 educational primer on the Lightning Network. Covers payment-channel mechanics (multisig + HTLCs), LN's TPS / fee improvements, real-world adoption (~11k nodes by mid-2025), the BOLT11 single-use invoice limitation, BOLT12 reusable offers, and how OCEAN integrates BOLT12 into its payout flow. Companion article to /docs/lightning."
collection: "ocean-docs"
adapter: "wayback-cdx"
upstream_id: "intro-to-lightning"
upstream_type: "wayback-snapshot"
canonical_url: "https://ocean.xyz/docs/intro-to-lightning"
content_format: "html"
authors: ["OCEAN Team"]
fetched: 2026-05-28
extraction_tool: "WebFetch"
---

# Introduction to the Lightning Network

> Educational primer; companion to OCEAN's `/docs/lightning` how-to.

## Why Lightning Exists

- Bitcoin: ~10-min blocks, fees spike with demand, ~7 TPS — impractical for
  micropayments.
- Lightning is Layer-2: payment channels avoid each transaction touching the
  base chain.

## How Channels Work

- Two parties lock BTC in a 2-of-2 multisig.
- They run unlimited off-chain transactions by updating signed balance
  commitments via **HTLCs** (Hashed Time-Locked Contracts).
- Routing across intermediaries forms a mesh; only final balances settle
  on-chain.
- Bar-tab analogy: avoid settling each round; settle the total at close.

## Advantages

- Millions of TPS (vs Bitcoin's ~7 TPS).
- Fees typically <$0.01.
- Settlement in milliseconds (no block confirmation wait).
- Privacy-improved off-chain hops.
- Enables machine-to-machine payments, podcast tipping, instant retail,
  cross-border remittances, EV charging.

## Adoption Snapshot

- Mid-2025: >11,000 nodes, billions in locked value.
- Particular growth in Latin America.

## BOLT11 (Today's Standard)

- Single-use invoice format. Each payment requires a new invoice.
- Inefficient for recurring transactions, merchants, or static "pay me"
  links.
- Privacy concerns from traceable payment hashes.

## BOLT12 Offers

- Reusable, static payment requests — like an email address for payments.
- Tagged hashes + signatures verify invoice authenticity.
- One offer can serve unlimited transactions over time.

## OCEAN's Lightning Integration

- Miner generates a BOLT12 offer in a compatible wallet
  (Core Lightning, Alby, Phoenix planned).
- Pastes it on the OCEAN dashboard.
- Signs an OCEAN-generated message with the on-chain payout address.
- Submits the signature.

Once linked, miner rewards arrive via Lightning. If inbound liquidity is
insufficient, payouts revert to on-chain once thresholds are reached
(see `/docs/lightning` — 0.01048576 BTC fallback).

## Cross-Reference

- This is an educational/context companion to
  `2026-05-28-ocean-lightning-payouts.md`.
- Out of scope for DATUM Gateway proper; included for completeness of the
  OCEAN docs corpus.
