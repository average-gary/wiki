---
title: "Cashu NUTs — Notation, Usage, Terminology specs"
publication: cashubtc/nuts (GitHub)
url: https://github.com/cashubtc/nuts
type: repo
ingested: 2026-05-23
quality: 5
credibility: high
confidence: high
tags: [Cashu, NUT, BDHKE, ecash, blind-signature, hashpool-substrate]
---

# Cashu NUTs Specification

Normative protocol spec for Cashu. The substrate hashpool implements verbatim for eHash share-token issuance.

## Key NUTs for mining-payout adaptation

- **NUT-00 — BDHKE (Blind Diffie-Hellman Key Exchange)**.
  Six-step protocol:
  1. Alice picks secret `x` and blinding factor `r`.
  2. Computes `B_ = hash_to_curve(x) + rG`.
  3. Mint signs: `C_ = kB_`.
  4. Alice unblinds: `C = C_ - rK = k·hash_to_curve(x)`.
  5. Token = `(x, C)`.
  6. Mint verifies `k·hash_to_curve(x) == C`, marks `x` spent.
  Mint never sees `x` until redemption — privacy property.

- **NUT-02 — Keysets and fees**. Denomination structure → maps to share-difficulty buckets in hashpool (token's keyset encodes difficulty class of the share).

- **NUT-04 (mint) / NUT-05 (melt)** — issuance and BTC redemption flows. For mining: mint = "share accepted, here's a token," melt = "convert mature tokens to a Lightning payout."

- **NUT-12 — DLEQ proofs**. Wallet cryptographically verifies the mint signed with its advertised public key. Important because miners need assurance the mint isn't equivocating on share acceptance.

- **NUT-11 — P2PK** / **NUT-14 — HTLCs**. Enable conditional eHash: token redeemable only after block-find resolution. Encodes the "luck risk" window.

## What this enables for mining payouts

- Pool no longer needs a per-miner share ledger. Bearer token *is* the share.
- Pool cannot link share-submission identity to redemption identity (mint privacy).
- Double-spend prevention is the mint's spent-`x` set — same operational burden as a pool's "share already submitted" check, just relocated cryptographically.
- Token is transferable → can be sold pre-maturity (variance becomes tradeable).

## Trust assumptions (from spec)

- Mint operator is custodial: holds the BTC reserves backing tokens.
- Mint blindness preserves privacy of which user submitted which token (no per-user ledger).
- Anyone can run a mint — implies competing mining-pool mints could fragment today's pool concentration.

## Federation generalization

Fedimint extends Chaumian ecash to threshold-custody by N guardians. For mining, this maps to a federated pool-mint where rugpull requires t-of-n collusion — the production-grade variant of single-operator hashpool.
