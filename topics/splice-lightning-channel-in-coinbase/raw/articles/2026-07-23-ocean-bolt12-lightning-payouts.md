---
title: "OCEAN — BOLT12 Lightning payouts + TIDES non-custodial coinbase payout"
source: "https://ocean.xyz/docs/lightning"
extra_sources:
  - "https://ocean.xyz/docs/tides"
  - "https://ocean.xyz/"
  - "https://nobsbitcoin.com (OCEAN BOLT12 launch, 2024-04-30)"
type: article
subtype: project-docs
retrieved: 2026-07-23
tags: [ocean, bolt12, lightning-payouts, tides, non-custodial, coinbase-payout, mining-pool, payout-threshold]
credibility: med-high
evidence_strength: docs
direction: "establishes the comparator (OCEAN-style off-chain BOLT12 payout) AND supports the self-custody-of-coinbase premise (TIDES pays from the generation tx)"
bears_on: [splice-in-vs-bolt12-miner-liquidity]
summary: "OCEAN ships two things relevant to the thesis: (1) TIDES, a non-custodial PPLNS-style scheme paying miners DIRECTLY from the block's generation (coinbase) transaction once they reach the on-chain threshold — the exact self-custodied UTXO the splice side proposes; and (2) live BOLT12 Lightning payouts (since ~2024-04-30) where a miner registers a signed BOLT12 offer and OCEAN pushes sub-threshold earnings to it, retrying each block, falling back on-chain at 0.01048576 BTC (2^20 sats). The BOLT12 push CONSUMES the miner's inbound liquidity; OCEAN's own failure mode is 'insufficient inbound liquidity'."
---

# OCEAN — BOLT12 Lightning payouts + TIDES

## What OCEAN actually does (verified)

**Baseline — TIDES, non-custodial, paid from the coinbase:**
> "TIDES is intended to be implemented in a non-custodial fashion, meaning miners
> should be paid via the generation transaction, and already have their split of that
> large transaction fee without the pool ever even having control over it." *(ocean.xyz/docs/tides)*
> "a pool can use that data to pay miners directly from the block's generation
> transaction without ever being responsible for the miner's earnings."

**Small-payout path — Lightning via BOLT12 (live since ~2024-04-30):**
> "OCEAN mining pool supports Lightning Network payouts using BOLT12 offers, a modern
> protocol for reusable, privacy-enhanced payment requests on the Lightning Network."
> "To maintain security and privacy, OCEAN requires a signed message linking your
> OCEAN Bitcoin address to a BOLT12 offer." *(ocean.xyz/docs/lightning, dated 2026-04-14)*

**On-chain fallback threshold:**
> "If a Lightning payout fails (e.g., due to insufficient liquidity), OCEAN will retry
> paying the owed amount via Lightning every block until the accumulated earnings reach
> the on-chain threshold (currently 0.01048576 BTC)." *(= 2^20 = 1,048,576 sats)*

**Rationale (Luke Dashjr, launch coverage):**
> "Pools traditionally have held miners' bitcoins like a bank, while on-chain Bitcoin
> transactions get increasingly expensive… For small miners, the problem is exacerbated
> since in some cases the cost of the transaction fee is higher than the reward that
> they earn. OCEAN helps overcome this risk using Lightning."
> "BOLT12 offers allow us to request multiple invoices for any amount while only
> requiring the miner to set things up once."

## Bearing on the thesis

- OCEAN's **BOLT12 payout is a push INTO a miner-supplied offer** → it *consumes the
  miner's existing inbound liquidity*; OCEAN's own troubleshooting names
  **"insufficient inbound liquidity → add liquidity"** as the top failure mode. This
  is the concrete real-world instance of the category error: to receive the payout the
  miner must already have inbound, which neither splice-in nor the payout itself
  creates. See [[../../wiki/concepts/inbound-vs-outbound-liquidity|inbound vs outbound]].
- OCEAN's **TIDES coinbase payout is itself the on-chain, self-custodied UTXO** the
  splice side wants — so the two aren't strict rivals: TIDES delivers the matured
  reward on-chain (self-custody), BOLT12 is the *dust-sized accrual convenience*.
- **Revealed preference:** OCEAN reserves on-chain for large accumulated balances and
  defaults to LN for small ones — the opposite cadence from "splice every reward."

Cross-refs: [[../../../datum/_index|datum]] (OCEAN's payout rail in depth) ·
[[../../../bitcoin-mining-payout-schemas/_index|bitcoin-mining-payout-schemas]] (TIDES/custody).
