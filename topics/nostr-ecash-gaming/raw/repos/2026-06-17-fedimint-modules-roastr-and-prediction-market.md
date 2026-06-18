---
title: "Fedimint gaming-adjacent modules — ROASTr + EthnTuttle/fedimint-prediction-market"
sources:
  - https://github.com/m1sterc001guy/roastr
  - https://github.com/EthnTuttle/fedimint-prediction-market
type: repo
tags: [fedimint, fmcm, roast, frost, threshold-signing, prediction-market, gaming-adjacent, nip-87]
fetched: 2026-06-17
confidence: high
credibility: medium
quality_score: 4
relevance: indirect
direction: nuances
summary: |
  Survey of the (very thin) Fedimint module surface relevant to gaming. Two notable items:
  ROASTr (m1sterc001guy) — Fedimint module that lets guardians collectively sign Nostr
  events under a federation npub via ROAST (robust over FROST), with NIP-87 federation
  announcements; and fedimint-prediction-market (EthnTuttle) — N-outcome federated order
  books with payout-control voting weights, transferable to game-result settlement. Negative
  finding: a deep search returned ZERO Fedimint modules whose primary purpose is gaming.
---

# Fedimint Gaming-Adjacent Modules

## ROASTr — threshold Nostr signing as a Fedimint module

- Repo: https://github.com/m1sterc001guy/roastr (18 stars, active March 2026)
- Module triplet: `roastr-common`, `roastr-server`, `roastr-client`
- **ROAST** = Robust Asynchronous Schnorr Threshold Signatures — improvement over FROST by
  running parallel FROST sessions, robust to malicious / offline guardians
- Three phases: setup (joint federation pubkey), signing (per-guardian shares), aggregation
  (threshold combine into Schnorr sig)
- Implements **NIP-87 federation announcements** for discoverability + web of trust

### Gaming applications (transferable)

- Guild / DAO collective custody of in-game assets
- Multi-stakeholder tournament prize-pool announcements signed under federation key
- Federated dealer / oracle attestations for nostr-poker-style protocols
- Cross-game shared identity

## EthnTuttle/fedimint-prediction-market

- Repo: https://github.com/EthnTuttle/fedimint-prediction-market
- Rust Fedimint module with N-outcome configurable markets
- Federated order books
- Weighted payout-control voting (`payout_controls_weights`)
- CLI ops: `new-market`, `propose-payout`, `sync-orders`
- Standard module layout: `*-common`, `*-server`, `*-client`, `*-tests`

### Gaming applications (transferable)

- Outcome enumeration → loot tables
- Market resolution → match settlement
- Payout-control voting → guardian-attested randomness or judge panels

## Negative finding (the most useful signal)

A deep GitHub search returned:

- **Zero Fedimint modules whose primary purpose is gaming**
- Searches for "fedimint game", "fedimint mini-app" etc. — empty
- Closest hits: ROASTr (signing infra) and bitpension-fedimint-module (pension)

Implication: the Fedimint gaming-module surface is wide-open. Anyone wanting a "game
federation" module would build on ROASTr (signing) + fedimint-prediction-market
(market-resolution patterns) + custom escrow/state.

## Why this matters for the topic

The current state of Fedimint's gaming surface area as of mid-2026 is: there isn't one.
Tuttle's manastr deliberately uses a Cashu CDK mint (with custom units) rather than a
Fedimint module, possibly because the Fedimint module API is heavier and the upgrade tax is
real (see hub topic `fedimint`, multi-currency status). ROASTr is the most plausible
primitive a future gaming module would compose against.
