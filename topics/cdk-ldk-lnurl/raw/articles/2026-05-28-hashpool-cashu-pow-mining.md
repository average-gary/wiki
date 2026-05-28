---
title: "Hashpool — Cashu mint backed by mining proof-of-work (eHash)"
type: article
source: https://hashpool.dev/articles/what-is-hashpool/
fetched: 2026-05-28
confidence: medium
tags: [hashpool, ehash, cashu-mining, motivating-use-case, vnprc]
summary: Built by vnprc — a Cashu mint inside a Stratum V2 mining pool that issues eHash tokens (proof-of-work-backed ecash). Lightning interop is the redemption path. Motivating use case for embedding LDK Node directly into a CDK mint.
---

# Hashpool — eHash + Cashu + Mining

Built by **vnprc**. Site indicates 2026 copyright; in early development.

## What it is

A Cashu mint embedded in a Stratum V2 mining pool. Mining shares are redenominated as **eHash tokens**: ecash bearer tokens whose value is backed by proof-of-work, not BTC at the moment of issuance.

## Token model

- Each eHash token represents a quantum of mining work
- Tokens accrue value as blocks are mined (the pool's expected revenue per share unit grows with hashrate / fee market)
- Tokens are **eventually redeemable for BTC** via Lightning settlement

## Cashu mint as "private accountless custodian"

The pool runs the mint. Miners receive eHash directly — no per-miner accounts, no payout balances, just bearer tokens. Privacy-by-default and atomic transferability come for free from the Cashu protocol.

## Lightning interop

The redemption path is **Lightning**:

- Miner holds eHash tokens
- Miner runs NUT-05 melt against the pool mint with their own LN invoice
- Pool's LN backend settles → eHash redeemed for sats

This requires the pool to run an LN node tied to the mint. **Embedding `cdk-ldk-node` directly into the pool process** is exactly the architectural fit — single binary, single state-management story, no separate LN daemon to babysit.

## Why this is the motivating use case

For a Cashu mint that *wants* the entire stack in one process (no separate CLN/LND ops), the embedded LDK Node path makes sense. Hashpool is the canonical example of where this design pays off: a mining-pool operator wouldn't typically also want to run a full CLN/LND ops practice for the payout side.

LNURL on top of Hashpool would let miners receive payouts directly to a Lightning Address (`miner-id@pool.com`), with no manual invoice copy-paste.

## Adjacent

- This wiki's [[../../bitcoin-mining-payout-schemas/_index.md|bitcoin-mining-payout-schemas]] topic covers the broader payout-redenomination space (PPLNS-JD, eHash, btc++ tracks).
- The [[../../sv2-p2pool-integration/_index.md|sv2-p2pool-integration]] topic covers the SV2 share-chain side that Hashpool connects to.
