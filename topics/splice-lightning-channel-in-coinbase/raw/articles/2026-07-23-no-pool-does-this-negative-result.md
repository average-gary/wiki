---
title: "Negative result + custody/fee conditions — no mining pool acts as an inbound-provisioning LSP"
source: "https://ocean.xyz/docs/lightning"
source_secondary: "https://ocean.xyz/docs/tides"
source_tertiary: "https://github.com/vnprc/hashpool"
source_quaternary: "https://pool2win.github.io/braidpool/"
type: article
subtype: project-docs
retrieved: 2026-07-23
tags: [mining-pool, lsp, ocean, tides, braidpool, hashpool, ecash, custody, fee-incidence, negative-result, coinbase-maturity]
credibility: med-high
evidence_strength: docs+negative-result
direction: "opposes (thesis #3's 'a pool does this') — thorough search finds NO mining pool acting as an inbound-provisioning LSP; deployed pools do the OPPOSITE"
bears_on: [pool-provisions-miner-inbound-via-splice]
summary: "The negative result and the conditions that gate thesis #3. Thorough search across Optech, LSP/bLIP specs, Braidpool, hashpool and the web finds NO mining pool acting as an inbound-provisioning LSP, and no 'pool-as-LSP' pattern named anywhere. Deployed pools do the OPPOSITE: OCEAN requires the MINER to supply 'sufficient inbound liquidity and open channels' and a BOLT12 offer, and is a payment SENDER not an LSP; hashpool/Braidpool deliberately route AROUND LN liquidity via Cashu ehash / one-way channels. Conditions: fee incidence (pool must eat it or the miner is net-worse), coinbase maturity (fresh-coinbase funding hits the 100-block wall; matured-treasury funding fronts working capital), custody (pool-as-LSP concentrates more trust than TIDES' non-custodial coinbase payout), and use (standing inbound is deadweight for a hold-only miner)."
---

# Negative result + custody/fee conditions

Why [[../../wiki/topics/pool-splices-toward-miner-verdict|thesis #3]] is *unbuilt* and
*conditional*, even though its mechanism is deployed elsewhere (Phoenix).

## Negative result: no pool does this

Thorough search across Optech topics, the LSP/bLIP specs, Braidpool docs, hashpool, and
web search surfaced **no mining pool acting as an inbound-provisioning LSP**, and **no
source that names "pool as LSP" as a pattern** or describes payout-delivery fused with
inbound-provisioning in a single on-chain footprint for miners. The closest deployed
analog is exclusively **wallet-LSPs** (Phoenix/phoenixd). Braidpool uses one-way payment
channels + UHPO — no pool-provisioned inbound. The d-central mining glossary links
miners-as-LN-receivers to LSPs *generically* but does not propose the pool being that LSP.

## Deployed pools do the OPPOSITE

OCEAN — the flagship pool doing LN payouts — pushes the inbound burden onto the miner:

> (miner requirements) "Sufficient inbound liquidity and open channels to receive
> payments" ... "Paste your BOLT12 offer into the form."

> (fallback) "If a Lightning payout fails (e.g., due to insufficient liquidity), OCEAN
> will retry... every block until the accumulated earnings reach the on-chain threshold."

OCEAN is a payment **sender**, not an LSP. The ecash pools dodge LN liquidity entirely:
hashpool "issues an 'ehash' token for each share accepted" via a Cashu mint (no channels,
no inbound); the Delving "Ecash TIDES" thread frames Cashu as "micro payouts with zero
prior liquidity requirements."

## Conditions that gate the thesis

| Axis | Condition under which thesis holds |
|------|-----------------------------------|
| **Fee incidence** | Pool eats the mining/lease fee (or nets it against a payout the miner *wants* inbound for). If the miner pays, they are net-worse than a plain on-chain/BOLT12 payout. |
| **Coinbase maturity** | Pool funds from **matured treasury/hot-wallet UTXOs** — funding from the *fresh* coinbase hits `COINBASE_MATURITY = 100` (~16.7 h unenforceable + reorg-voided). Matured funding sidesteps the wall but fronts working capital. |
| **Custody** | Miner accepts zero-conf trust + pool-fronts-capital. This is *more* trust than OCEAN TIDES' non-custodial coinbase payout ("without the pool ever even having control"), less than fully-custodial ecash. |
| **Use** | Miner is a genuine future **receiver** (routing/merchant/further payouts). For a hold-only miner, standing inbound is deadweight capital and its fee is pure loss; JIT-on-first-payout already covers a one-off receive. |

## Custody spectrum (how the miner gets paid)

TIDES on-chain coinbase (non-custodial, no counterparty) < pool-splices/JIT-toward-miner
(non-custodial post-open; zero-conf trust + pool fronts capital & could withhold the open)
< OCEAN BOLT12 push into miner's node (non-custodial, needs pre-existing inbound) <
fedimint federated t-of-n < ecash/Cashu ehash (fully custodial).

Cross-refs:
[[2026-07-23-eclair-2861-phoenix-on-the-fly-deployed|deployed wallet-LSP reality]] ·
[[../../wiki/concepts/pool-as-lsp-inbound-provisioning|pool-as-LSP provisioning]] ·
[[../../../bitcoin-mining-payout-schemas/_index|bitcoin-mining-payout-schemas]] ·
[[../../../ldk-server/_index|ldk-server]]
