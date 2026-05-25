---
title: "hashpool — accountless mining pool with Cashu ecash share mint"
author: vnprc
publication: github.com/vnprc/hashpool
url: https://github.com/vnprc/hashpool
homepage: https://hashpool.dev
type: repo
ingested: 2026-05-23
quality: 4
credibility: medium
confidence: medium
tags: [hashpool, eHash, Cashu, ecash, blind-signature, non-custodial, SV2]
---

# Hashpool / eHash

Bitcoin mining pool that **issues a Cashu ecash bearer token (eHash) for each accepted share** instead of maintaining a per-miner share ledger. Most experimental payout-accounting model in the post-2024 wave. Status: testnet4 PoC, sole credited dev `vnprc`.

## Core architectural inversion

Traditional pool (FPPS/PPLNS): pool keeps a per-miner share ledger; pays out at block-find or threshold.

Hashpool: **the share *is* the token**. Pool maintains no per-user accounts. The bearer token itself is the share-accounting record.

> *"Instead of internally accounting for each miner's proof of work shares, hashpool issues an 'ehash' token for each share accepted by the pool."*

## Mechanism (Cashu BDHKE — NUT-00)

1. Wallet (in SV2 translator proxy) picks secret `x`, blinding factor `r`. Computes `B_ = hash_to_curve(x) + rG`.
2. Pool-mint signs: `C_ = kB_`. Mint never sees `x`.
3. Wallet unblinds: `C = C_ - rK = k·hash_to_curve(x)`. Token = `(x, C)`.
4. To redeem: present `(x, C)` to mint. Mint verifies `k·hash_to_curve(x) == C`, marks `x` spent.

`x` is bound to the share submission. Mint cannot link issuance-time shares to redemption-time payouts → privacy property no FPPS/PPLNS pool offers.

## Three-component stack

- **Pool-side mint** — issues blinded sigs (CDK: cashubtc/cashu-dev-kit).
- **Proxy-side wallet** — bundles blinded messages with shares; stores token pairs.
- **Bitcoin Core 30.2 multiprocess** + sv2-tp v1.0.6 Template Provider via IPC + SV2 pool + SV2 translator proxy with Cashu wallet.

## Novel payout dynamic

eHash tokens **accrue BTC value during a maturity period** after issuance. Miners can:
- (a) **hold to maturity** → capture block-luck upside;
- (b) **sell early on a secondary market** → guaranteed payout (variance offloaded to buyer).

Variance becomes a tradeable asset. Distinct from FPPS (pool eats variance) and PPLNS (miners eat variance).

## Trust assumptions (project's own admission)

> *"The most common criticism ecash faces from bitcoiners is that it is a custodial system. This is absolutely true."*

- Mint can in principle exit-scam or refuse all redemptions.
- Mint inflation (issuing eHash unbacked by real shares) is **not technically prevented** in the current spec — Proof of Liabilities is invoked as a future dependency.
- Defensive framing: accountlessness prevents *targeted* censorship, but not global rugpull.
- Mitigation guidance is "don't store life savings here" — in tension with the use case of accumulating between payouts.

## Cashu NUT references used

- NUT-00 (BDHKE) — core crypto.
- NUT-02 (keysets) — denomination buckets ↔ share-difficulty buckets.
- NUT-04/05 (mint/melt) — issuance and BTC redemption.
- NUT-12 (DLEQ) — wallet verifies mint signed with advertised key.
- NUT-11 (P2PK) / NUT-14 (HTLCs) — conditional eHash redeemable only after block-find resolution.

## Federation path (Fedimint)

Single-mint custody is the project's biggest risk. Fedimint generalizes Cashu to threshold custody by N guardians. Maps onto a federated mining-pool mint (e.g. a co-op of small farms) — likely the production-grade variant of hashpool.

## Connection to broader landscape

This is a **third payout schema category** beyond:
- Pool-eats-variance (FPPS)
- Miners-eat-variance (PPLNS / TIDES / SLICE)
- **Variance-as-tradeable-asset** (eHash)
