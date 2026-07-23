---
title: "Payout-rail economics — dust floor, ecash micro-payouts, Braidpool one-way channels"
source: "https://bitcoinops.org/en/topics/uneconomical-outputs/"
extra_sources:
  - "https://hashpool.dev/articles/what-is-hashpool/"
  - "https://pool2win.github.io/braidpool/"
  - "https://bitcoinops.org/en/topics/pooled-mining/"
type: article
subtype: aggregator-project-docs
retrieved: 2026-07-23
tags: [dust-limit, uneconomical-outputs, ecash, cashu, hashpool, ehash, braidpool, micro-payouts, custody, one-way-channels]
credibility: med-high
evidence_strength: docs
direction: "opposes the splice side for small/frequent payouts; supplies the third (ecash) custody model and Braidpool revealed-preference"
bears_on: [splice-in-vs-bolt12-miner-liquidity]
summary: "On-chain outputs below the dust limit (~546 sats) are non-standard, and any output worth less than its spend fee is uneconomical (Optech) — so a small miner's per-payout accrual can be too small to splice at all. Off-chain rails clear it: ecash/Cashu (hashpool 'eHash') has NO minimum payout ('a single satoshi… just as easily as a million sats') but is custodial with maximum dwell-time. Braidpool uses one-way channels settled from ACCUMULATED MATURED rewards for constant blockspace. Revealed preference: no deployed system splices a FRESH coinbase; they pay off-chain or settle from matured accumulation."
---

# Payout-rail economics

## The dust / uneconomical-output floor (against splice for small miners)

> "Uneconomical outputs are transaction outputs that are worth less than the fees it will
> cost to spend them." … nodes "refuse to relay or mine transactions with outputs below a
> certain value, called the dust limit." *(bitcoinops.org/en/topics/uneconomical-outputs/;
> dust limit historically ~546 sats P2WPKH)*

A solo miner's fractional-block accrual can be **smaller than a splice's on-chain fee**.
Splicing such an amount is uneconomic; an off-chain LN/ecash micro-payout is the only
rail that clears. For an industrial farm's block-sized payout the per-splice fee is
negligible — hence the size-dependent flip.

## Ecash / Cashu — the third custody model (hashpool "eHash")

> "Ehash tokens are ecash tokens backed by proof of work instead of bitcoin." … "ecash
> doesn't have a minimum payment threshold. You can send a single satoshi to a brand new
> wallet just as easily as you can send a million sats." … "This means that hashpools can
> efficiently serve even the smallest miners." *(hashpool.dev)*
> Caveat (project's own): "The most common criticism ecash faces from bitcoiners is that
> it is a custodial system. This is absolutely true." (Also: "this is a test instance …
> your ehash will be rugged!" — pre-production.)

Finest-grained + blind micro-payout, but **custodial with the longest dwell-time** (held
until reward maturity) and no proof-of-liabilities. Loses for a self-custody-seeking
miner; can win for a small privacy-seeking miner who trusts the mint. Federated (t-of-n)
custody via [[../../../fedimint/_index|fedimint]] is the production-grade variant.

## Braidpool — one-way channels from matured accumulation (revealed preference)

> "one-way payment channels for payments with fixed blockspace requirements"; "When a
> bitcoin block is found, all unaccounted for shares are added to miners Unspent Hasher
> Payout (UHPO)"; goal "Payouts in a constant size blockspace." *(pool2win.github.io/braidpool/)*

## Bearing on the thesis

Revealed preference: **no deployed system funds or splices a channel from a fresh
coinbase.** They pay off-chain (OCEAN BOLT12 / NiceHash) or settle one-way channels from
*matured accumulation* (Braidpool). Optech's "Pooled mining" topic surveys PPS/FPPS/PPLNS
with **no mention** of splicing/BOLT12/ecash as canonical payout delivery — the
LN/splice payout is not yet canonical in the aggregate reference.

Cross-ref: [[../../../bitcoin-mining-payout-schemas/_index|bitcoin-mining-payout-schemas]]
(ehash, braidpool, tides, custody-tradeoffs).
