---
title: "Alternatives & prior art for covenantless non-custodial mining payout"
type: reference
created: 2026-07-17
updated: 2026-07-17
confidence: medium
volatility: warm
verified: 2026-07-17
tags: [prior-art, ocean-datum, hashpool, braidpool, mercury-statechains, timeout-trees, revealed-preference]
sources:
  - raw/articles/2026-07-17-ocean-datum.md
  - raw/articles/2026-07-17-hashpool.md
  - raw/articles/2026-07-17-braidpool-spec.md
  - raw/articles/2026-07-17-braidpool-covenants-delving.md
  - raw/articles/2026-07-17-mercury-statechains.md
  - raw/articles/2026-07-17-ctv-csfs-letter.md
summary: "No exact prior art for a post-block-found covenantless Ark-boarding SV2 extension — it is novel, not proven infeasible. But the neighborhood is well-populated: OCEAN/DATUM (non-custodial coinbase payout today, capped ~100/coinbase), hashpool (custodial ecash), Braidpool (FROST + covenant wishlist), Mercury statechains (covenantless per-UTXO transfer), timeout-trees. Revealed preference leans toward covenants/custody — a yellow flag the thesis must answer."
---

# Alternatives & prior art

**Headline: no one has shipped the specific construction.** No source describes an
SV2 extension carrying a post-block-found n-of-n Ark boarding ceremony for coinbase
payouts. That makes the thesis **novel, not proven infeasible** — but the
surrounding design space is instructive.

## The baseline the thesis extends

- **OCEAN / DATUM** — non-custodial coinbase payout **works today, no covenant**:
  "coinbase payouts go directly to miners, instantaneously and without custodial
  oversight." But it hits a hard wall: "the number of payouts a miner can make
  directly from the coinbase transaction is limited to **roughly 100** due to ASIC
  firmware limitations" ([[../../raw/articles/2026-07-17-ocean-datum.md|OCEAN/DATUM]]).
  A batched n-of-n output that fans out to many more recipients is the natural next
  step — **this is the thesis's actual value proposition.**

## Covenantless alternatives for the same goal

- **hashpool** — represents shares as **custodial Cashu ecash** (`ehash`) tokens,
  redeemable via Lightning/on-chain. The team building covenantless mining payout
  chose custody, not Ark ([[../../raw/articles/2026-07-17-hashpool.md|hashpool]]).
- **Mercury Layer / statechains** — covenantless off-chain transfer of UTXO
  ownership via blind cosign + key-update + operator key deletion, with presigned
  unilateral exit. But **per-UTXO, not batched** — cannot pack many miners into one
  output the way Ark can ([[../../raw/articles/2026-07-17-mercury-statechains.md|Mercury]]).

## Covenant-wanting designs (the revealed-preference flag)

- **Braidpool** — chose a **FROST federation** (signer set capped ~50) plus an
  explicit covenant wishlist (APO+CTV), because "signing very large threshold
  Schnorr outputs is impractical" and the federation itself is a 51/67% fund-theft
  attack surface they want covenants to remove
  ([[../../raw/articles/2026-07-17-braidpool-spec.md|spec]],
  [[../../raw/articles/2026-07-17-braidpool-covenants-delving.md|Delving #1370]]).
- **CTV+CSFS support letter** — files "non-custodial mining" under *covenant-gated*
  functionality ([[../../raw/articles/2026-07-17-ctv-csfs-letter.md|letter]]).
- **Timeout-Trees** (John Law) — the academic lineage of shared-UTXO trees;
  covenantless variants exist "but require greater interaction," while Law's own
  construction uses a covenant.

## Unverified idea-in-the-water

- A 2026 grubles/notgrubles tweet floated "a mining pool that mines blocks directly
  to Ark onboarding … faster payouts via VTXO" — the *closest* thing to prior art,
  but **unverified** (fetch blocked; snippet only). Treat as evidence the idea is
  circulating among Ark practitioners, not as a spec.
  (URL: https://x.com/notgrubles/status/2077375328737988626)

## Takeaway

Every serious builder either accepts custody (hashpool) or reaches for a soft fork
(Braidpool, Ark's own team). The thesis's covenantless-at-scale path is the road
not taken. That is a yellow flag — but the OCEAN/DATUM ceiling shows a genuine,
covenant-free, unmet need the thesis targets. Novel and worth prototyping at small
signer-set scale; unproven at pool scale.

## See Also

- [[../topics/thesis-analysis-viability.md|Viability analysis (verdict)]]
- [[../concepts/pure-receiver-and-liveness.md|Pure-receiver / liveness problem]]
- [[../../bitcoin-mining-payout-schemas/_index|bitcoin-mining-payout-schemas]]
