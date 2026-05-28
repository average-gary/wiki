---
title: Parasite Pool
type: concept
created: 2026-05-26
updated: 2026-05-26
confidence: medium
tags: [parasite-pool, zk-shark, lottery-pplns, lightning-payouts, novel-accounting, custodial]
---

# Parasite Pool

A 2025-launched Bitcoin mining pool by pseudonymous developer **zk-shark** with a hybrid **lottery + decay-weighted PPLNS** payout scheme and Lightning-only payouts. Launched in beta around May 2025; first mainnet block found late February 2026 (#938,713), second in April 2026 (#945,601). Endpoint `parasite.wtf:42069`, dashboard at `parasite.space`, code at [`parasitepool/para`](https://github.com/parasitepool/para) (CC0).

## Defining mechanism

The block-finder gets a flat **1 BTC bounty**. The remaining ~**2.125 BTC + tx fees** (post-2024-halving subsidy of 3.125 BTC) is distributed to other contributing miners weighted by share contribution.

- **Share weighting** is a **continuous-time exponential-decay EMA** (per `src/decay.rs`: `1 − e^(−x)`, normalized), not a fixed-N rolling window. Decay window length is a runtime config (`settings.rs`); production value not publicly documented.
- **No N-window** in the classical-PPLNS sense; in the founder-side narrative this is sometimes described as "all cumulative shares since the pool's most recent block." The implementation reality is decay-weighted continuous integration.
- **Zero pool fee.**
- **Lightning payouts** with **10-sat minimum** — effectively no minimum.
- **"Coinbase alchemy"**: pool fronts liquidity over Lightning so payouts settle before the 100-block coinbase maturity.

## Trust model

Despite "decentralization" branding, the trust model is **operator-custodial**:

- Coinbase has a single output to a pool-controlled address (`coinbase_builder.rs`).
- Lightning fanout is operator-run (Sati infrastructure + Xverse wallet integration).
- Custody risk window = block-find → Lightning fanout. Operator solvency required during this window.
- **Stratum V1**, not V2 — miners cannot independently verify templates. Operator can MEV-tax or censor without detection. This contrasts with [[pplns-jd|SLICE / DMND]], [[hydrapool|Hydrapool]], and OCEAN/DATUM, all of which decentralize template construction.

## Operator UX

- Auth string carries onchain BTC + Lightning addresses inline:
  `<onchain-addr>.<worker>.<lightning-addr>@parasite.sati.pro`
- **Hard dependency on Xverse wallet** for co-derivation of the LN address.
- No registration, no email, no rebind — mistyping the LN address forfeits payouts silently.
- Bitaxe firmwares (NerdQAxe+, NerdMiner, acs-esp-miner) have user-filed feature requests for Parasite presets — a real adoption signal.

## Variance fragility

At the hashrate observed in 2025–2026 (**~25–52 PH/s**, ~0.0025–0.005% of network), expected time-to-block is on the order of **~291 days** (Bitcoin Manual analysis). The 22% reward discount vs. solo (1 BTC carved out of 3.125 BTC) compounds this: only miners with enough hash to plausibly find the block accept the discount; everyone else effectively subsidizes finders.

The unbounded "shares since last block" narrative (if literally implemented vs. the decay-weighted reality) is exploitable by **late-joiners after a long dry spell** — a worst-case PPLNS-hopping pattern.

## Position in the taxonomy

| Axis | Parasite |
|---|---|
| Variance to | Miner (with extra lottery on the finder slot) |
| Custody | Pool (coinbase) + Pool (LN fanout) |
| Hop-resistant | Partial — decay-weighted, but unbounded inter-block window leaks |
| IC-provable (Schrijvers) | No (PPLNS-family hybrid; non-IC under [[../../raw/papers/2026-05-23-schrijvers-2016-incentive-compatibility|Schrijvers 2016]]) |
| Operator reserve req | Low (event-driven on block-find) |
| Auditable on-chain | No (single coinbase output, off-chain LN distribution) |
| Template control | Pool (Stratum V1 — no JD support) |
| Sybil-resistance | Open — Shapley analysis ([[../../raw/papers/2026-05-26-kiayias-aft-2025-shapley-oceanic-games|Kiayias et al. AFT'25]]) suggests proportional-residual schemes are vulnerable |

## What's actually novel

Stripped of the marketing, three axes are genuinely new:

1. **Lottery-finder bonus** as a structural reward component (not just a tip) — ckpool solo gives the finder everything; classical PPLNS gives the finder nothing extra; Parasite splits the difference at a fixed 1 BTC.
2. **Continuous decay weighting** instead of a fixed-N or fixed-difficulty window — closer to the geometric-method (DGM) family than to PPLNS-N.
3. **Lightning-as-payout-rail with coinbase-maturity sidestep** — operator fronts liquidity to deliver sub-100-block-maturity payouts at 10-sat granularity.

## What's not novel (and arguably regressive)

- **Stratum V1 + custodial coinbase** reproduces exactly the template-control and operator-trust problems that SV2/JD, TIDES, and SLICE attempt to solve.
- The **share scheme is a thinly disguised PPLNS variant**, inheriting all PPLNS incentive-compatibility limitations from [[../../raw/papers/2026-05-23-schrijvers-2016-incentive-compatibility|Schrijvers 2016]].
- The "loyalty" metric on the dashboard is undefined publicly — opaque governance.

## Status (May 2026)

- Production / mainnet, two blocks found 48 days apart.
- Hashrate fluctuating 24–182 PH/s.
- Active dev cadence on `parasitepool/para` (v0.5.x in late 2025, ongoing commits May 2026).
- BCH derivative pool (`bch.ee`) explicitly self-styled as the BCH parasite pool with its own variant (1 BCH bonus + 99% remainder + 1% fee).
- The "parasite.wtf scam" dispute (`Distortions81` GitHub issue, Dec 2025) is **half-true**. On-chain analysis ([[../../raw/articles/2026-05-26-parasite-pool-coinbase-onchain-analysis|verified against blocks 938,713 and 945,601]]) confirms output #1 always goes to a single pool-controlled address `bc1qkgef7pl8vdrtuc4wk8fssycz366xp5ukzsm8gp` rather than fanning out on-chain — but that address drains aggressively (8 txns total, 6.77 BTC received, ~700 sat retained). The behavior pattern matches a Lightning channel hot-wallet, not an accumulation sink. Whether the drained funds actually reach miners via LN as advertised is **unprovable from on-chain data alone** and requires operator-published payout proofs.

## Open questions / gaps

1. Decay constant in production — undisclosed.
2. Stale/uncle share handling — undocumented.
3. Withholding-attack analysis — none published.
4. Trust model for funds-at-rest between block and Lightning fanout — undisclosed.
5. Why no Stratum V2 / JD migration — no public answer; `entangle` repo (Feb 2026, undocumented) may be the planned V2 vehicle.

## Sources

- [[../../raw/articles/2026-05-26-zkshark-parasite-pool-substack|zk-shark Substack]] — founder rationale
- [[../../raw/articles/2026-05-26-blockspace-media-parasite-emerges|Blockspace Media]] — technical narrative
- [[../../raw/articles/2026-05-26-bitcoin-manual-parasite-pool|The Bitcoin Manual]] — economic critique with variance math
- [[../../raw/articles/2026-05-26-coindesk-parasite-second-block|CoinDesk]] — mainnet validation
- [[../../raw/articles/2026-05-26-solosatoshi-bitaxe-parasite-setup|SoloSatoshi]] — operator config
- [[../../raw/repos/2026-05-26-parasitepool-para-github|`parasitepool/para` repo]]

## See also

- [[payout-schema-taxonomy|Payout Schema Taxonomy]]
- [[pplns|PPLNS]] — parent family
- [[tides|TIDES]] — non-custodial PPLNS variant for contrast
- [[pplns-jd|SLICE / PPLNS-JD]] — SV2-decentralized counterpart
- [[ehash|eHash]] — alternative non-custodial payout layer
- [[radpool|Radpool]] — alternative decentralized FPPS via DLCs
