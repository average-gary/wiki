---
title: "OCEAN TIDES Payout Mechanics and Trust Boundary"
url: https://ocean.xyz/docs/tides
source_type: official-docs
ingested_by: path5
ingested_on: 2026-06-01
quality: high
relevance: critical
hypotheses_addressed: [1, 4]
---

# OCEAN TIDES Payout Mechanics and Trust Boundary

## Provenance
OCEAN official TIDES technical documentation page. Authoritative on TIDES
mechanics and on OCEAN's "non-custodial" claim.

## Key Findings

- **TIDES = Transparent Index of Distinct Extended Shares.** Window-based
  reward (8 * block difficulty worth of shares per window) paid via the
  generation transaction (coinbase output) on each block found.
- **Non-custodial path is via coinbase splits**, not via OCEAN holding funds.
  OCEAN's role: "minimal, if any, control over funds distributed." Trust is in
  the share-tracking and window arithmetic being honest, not in custody.
- **Provably-accurate auditing is theoretically open** but "requires technical
  capability from individual miners" - in practice few miners audit. The
  non-custodial property is real but the *honest-share-counting* property is
  social trust + transparent share log.

## Hypothesis Implications

- **H1 (SV2 fleet wants TIDES):** SUPPORTED as a real value prop. TIDES is a
  genuinely differentiated payout that BraiinsOS+ pools (e.g., Braiins Pool
  FPPS / SLP) and Foundry FPPS+ do not match.
- **H4 (hashpool intermediation):** SUPPORTED with friction. Cashu eHash
  shares mint a per-share token immediately. TIDES is a per-block coinbase
  split. Putting hashpool *between* an SV2 miner and OCEAN means hashpool
  owns the OCEAN payout address and re-mints eHash; miner trades TIDES
  variance for eHash early-redemption, but loses TIDES's coinbase-direct
  property. Combining the two is *technically possible* but each layer adds a
  trust hop.

## Threat-Model Implications

- **Trust boundary in the proxy world:** The SV2-front DATUM proxy operator
  configures *one* OCEAN bitcoin address as the TIDES payout destination. All
  downstream SV2 miners' rewards land at that address. The proxy operator is
  now a payout-bridge (a tiny pool). They must:
  1. correctly attribute shares-by-downstream-channel internally,
  2. translate TIDES coinbase receipts into per-downstream payouts,
  3. ship those payouts (lightning? on-chain? off-chain credit?).
- This is *exactly the custodial role TIDES was designed to eliminate.* The
  proxy regresses the non-custodial property at the proxy boundary even
  though OCEAN itself remains non-custodial relative to the proxy operator.
- **Mitigation:** if the SRI extranonce_prefix model is used to give each
  downstream a unique extranonce slice, *and* if OCEAN can attribute coinbase
  splits per-extranonce-prefix via DATUM Gateway's split logic, then in
  principle the proxy could pass-through the non-custodial property.
  Evidence DATUM Gateway supports this granularity at the SV1-channel level
  is not in current docs.

## Ingest Justification
TIDES is the value prop. Without TIDES, hypothesis #1 collapses. Critical to
quantify the actual trust delta the proxy introduces.
