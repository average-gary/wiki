---
title: Concepts
type: section-index
---

# Concepts

Definitions and primitives — schemes, attacks, variance.

## Schemes

- [[payout-schema-taxonomy|Payout Schema Taxonomy]] — overarching map of all schemes by who absorbs variance
- [[pplns|PPLNS — Pay Per Last N Shares]] — Rosenfeld 2011, hop-resistant
- [[fpps|FPPS — Full Pay Per Share]] — variance to operator, dominant scheme today
- [[tides|TIDES (OCEAN)]] — PPLNS done right, non-custodial coinbase payout
- [[pplns-jd|PPLNS-JD / SLICE (DMND)]] — PPLNS bound to SV2 Job Declaration
- [[sv2-share-accounting-ext|SV2 Share Accounting Extension]] — SV2 extension (type 32) for miner-verifiable PPLNS-JD payout auditing
- [[ehash|eHash / hashpool]] — Cashu blind-signature share tokens
- [[p2pool-share-chain|p2pool / p2poolv2]] — on-chain PPLNS, no operator
- [[p2poolv2-accounting|p2poolv2 Accounting (deep-dive)]] — code-level: 133k-share window, 90% uncle weight, atomic-swap HTLCs
- [[hydrapool|Hydrapool — 256 Foundation pool]] — public-audit-API PPLNS, uses `p2poolv2_lib`
- [[lottery-pplns|Lottery-PPLNS (Finder-Bonus Hybrid)]] — flat bounty to the block finder + PPLNS on the remainder; expectation-neutral variance trade, forces per-finder coinbase construction
- [[parasite-pool|Parasite Pool]] — lottery + decay-EMA hybrid, custodial Lightning fanout, Stratum V1
- [[radpool|Radpool]] — DLC + FROST decentralized FPPS (proposal stage)
- [[braidpool|Braidpool]] — DAG sharechain, Full Proportional payout, covenant-based custody (prototype)
- [[datum|DATUM]] — OCEAN's miner-side template-construction protocol (orthogonal to TIDES payout)
- [[ark-for-mining-payouts|Ark for Mining Payouts]] — hypothetical ASP-backed payout layer; one BitMag mention; structural critiques on capital lockup, expiry, and exit cost
- [[ctv-coinbase-payout-tree|CTV Coinbase Payout Tree]] — OP_CTV (BIP-119) coinbase fanout for non-custodial payouts; flat (~319-output TRUC ceiling) vs layered tree, MuSig-node + P2Pool-reboot endgame (vnprc coinbase-playground)

## Attacks

- [[pool-hopping|Pool Hopping]] — original miner-vs-pool attack, killed proportional payout
- [[block-withholding|Block Withholding (BWH) and FAW]] — inter-pool sabotage, Eyal/Schrijvers/Kwon
- [[selfish-mining|Selfish Mining]] — pool-vs-network attack, Eyal/Sirer/Sapirshtein

## Cross-cutting

- [[variance-and-risk-shifting|Variance & Risk-Shifting]] — the central design dimension
- [[tides-variance-derivation|TIDES Variance — Closed-Form Derivation]] — quantitative σ at multiple horizons (Rosenfeld → TIDES, sanity-checked vs heatpunks 2025)
- [[coinbase-address-rotation|Coinbase Address Rotation]] — fresh payout address per block from a wildcard descriptor + persisted index; the `has_wildcard()` footgun, the persistence split between `para` and sv2-apps, and the ledger-identity wall blocking per-miner xpub usernames
- [[payout-attribution-privacy|Payout Attribution Privacy]] — what a pool structurally knows; attribution comes from share validation, not payment, so blinding the payout rail only addresses third-party observers
- [[hashrate-inference-side-channels|Hashrate Inference Side Channels]] — measured recovery of a miner's hashrate and earnings from Stratum traffic, including from packet timestamps alone; VarDiff calibration is itself the channel
- [[xpub-payout-identity|xpub Payout Identity]] — miner-supplied wildcard descriptors as pool identity; the ledger-key/payout-script split, the unresolved rotation trigger, firmware field-width ceilings, and why BIP 352 is structurally impossible in a coinbase
- [[coinbase-amount-linkability|Coinbase Amount Linkability]] — payout amounts leak share weight independently of addresses; a coinbase is a strictly easier subset-sum instance than a CoinJoin (one known-value input, no input shuffling, no padding)
- [[blind-share-accounting|Blind Share Accounting]] — PPLNS credit is a running weighted sum while ecash is a one-shot denominated bearer object; BBA+/Black-Box Wallets is the only primitive that fits. **Corrected 2026-07-29**: the Canard–Gouget "impossibility" this article carried as its single-operator blocker had the prescription *inverted* — the BBA line cites it as the reason issuer and accumulator **must** share one key. No theorem makes accumulation harder than issuance, the 16-bit range limit binds redemption not crediting, and the per-credit cost was overstated 4× by using the spending row. What survives is interactivity and the hashrate side channel
- [[nullifier-vs-pseudonym|Nullifier vs Pseudonym]] — single-use pool-side state is not a persistent handle; three independently written Bitcoin pool implementations (SRI, Ocean/DATUM, p2pool-v2) already reject duplicate shares with **no identity term in the key**, which falsifies sub-claim C of the blinded-share-credit thesis
- [[self-blinding-architectures|Self-Blinding Architectures (cross-domain)]] — OHTTP split-trust, blind-signature admission, multi-vendor TEEs, Prio/DAP, and the client-enforced-transparency mechanism worth more than the enclave it protects
