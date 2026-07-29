---
title: Parasite Pool
category: concept
created: 2026-05-26
confidence: medium
tags: [parasite-pool, zk-shark, lottery-pplns, finder-bonus, lightning-payouts, novel-accounting, partially-custodial]
volatility: warm
updated: 2026-07-29
summary: "A 2025-launched Bitcoin mining pool by pseudonymous developer zk-shark with a hybrid lottery + cumulative-proportional payout scheme: a flat 1 BTC to the block finder as their own coinbase output, remainder fanned out over Lightning."
verified: 2026-07-27
sources:
  - "raw/data/2026-07-27-parasite-blitzpool-onchain-and-code-verification.md"
  - "raw/articles/2026-05-26-bitcoin-manual-parasite-pool.md"
  - "raw/articles/2026-05-26-blockspace-media-parasite-emerges.md"
  - "raw/articles/2026-05-26-coindesk-parasite-second-block.md"
  - "raw/articles/2026-05-26-solosatoshi-bitaxe-parasite-setup.md"
  - "raw/articles/2026-05-26-zkshark-parasite-pool-substack.md"
  - "raw/repos/2026-05-26-parasitepool-para-github.md"
---

# Parasite Pool

A 2025-launched Bitcoin mining pool by pseudonymous developer **zk-shark** with a hybrid **lottery + cumulative-proportional** payout scheme: a flat 1 BTC to the block finder as their own coinbase output, remainder fanned out over Lightning. Launched in beta around May 2025; **5 mainnet blocks as of July 2026** (#938,713 · #945,601 · #954,873 · #958,212 · #958,527). Endpoint `parasite.wtf:42069`, dashboard at `parasite.space`, code at [`parasitepool/para`](https://github.com/parasitepool/para) (CC0).

## Defining mechanism

The block-finder gets a flat **1 BTC bounty**. The remaining ~**2.125 BTC + tx fees** (post-2024-halving subsidy of 3.125 BTC) is distributed to other contributing miners weighted by share contribution.

> **Correction 2026-07-27.** This article previously described the share weighting as a continuous-time exponential-decay EMA. **That is wrong** — verified against `parasitepool/para` master. The decay code exists but drives hashrate stats and vardiff, not payout weighting. Corrected below. The same pass established that the 1 BTC bounty **is** paid non-custodially as a coinbase output (only the remainder is custodial), and that the pool is now at **5 blocks, not 2**.

- **Share weighting is cumulative unpaid difficulty since account inception** — `total_diff − already_paid_diff`, per `src/subcommand/server/database.rs`. **No decay, no half-life, no sliding window**; a sweep of all 162 Rust files for `decay|half.?life|exp(|lambda` in the payout path returns zero hits. Accumulated unpaid difficulty never ages out.
  - Consequence: **this is not PPLNS in Rosenfeld's sense and does not inherit PPLNS's hop-resistance.** The founder-side "all cumulative shares since the pool's most recent block" narrative is closer to the truth than this wiki's prior decay-EMA description, though the real accounting is per-account unpaid difficulty rather than per-round.
  - `src/decay.rs` does implement a `DecayingAverage` (`1 − e^(−x)` with bias correction), but its consumers are `src/metatron/stats.rs`, `src/vardiff.rs`, and `src/subcommand/miner/metrics.rs` — display and difficulty adjustment, not payout.
- **The finder is *excluded* from the remainder**, not paid on top of it: `WHERE username != COALESCE($2, '')` in the payout SQL, and `total_payment_amount = coinbasevalue − COIN_VALUE` in `src/subcommand/server/payouts.rs:253`. `tests/payouts.rs` asserts *"Block finder should have zero payout amount"* and carries a dedicated `test_multiple_users_with_finder_exclusion`. So the bounty is an either/or, not a bonus — the winner-only variant in [[lottery-pplns|Lottery-PPLNS]].
- **The 1 BTC is a hardcoded constant, not config**: `if total_reward <= 100_000_000 { return Ok(Vec::new()) }`, commented *"1 BTC of coinbase value is reserved for miner who found the block."*
- **Zero pool fee.**
- **Lightning payouts** with **10-sat minimum** — effectively no minimum.
- **"Coinbase alchemy"**: pool fronts liquidity over Lightning so payouts settle before the 100-block coinbase maturity.

## Trust model

The trust model is **split**: the bounty is trustless, the remainder is custodial. Verified on-chain 2026-07-27 against blocks 938713, 945601, and 958527 — each coinbase has exactly 3 outputs:

| Output | Value | Destination |
|---|---|---|
| 0 | exactly 100,000,000 sats | **a different address every block** — the finder's own |
| 1 | remainder (~2.13 BTC) | `bc1qkgef7pl8vdrtuc4wk8fssycz366xp5ukzsm8gp` — **same across all blocks**, pool-controlled |
| 2 | 0 | OP_RETURN (witness commitment) |

Output 0 addresses observed: `bc1qsmdhm009ukwayz90dkyydaw9qyk9zvvmz8ttae` (938713), `bc1q2l474n3qqpnmkg0y82ydt9f9jkyhz6dhqv04lt` (945601), `bc1qnd2xkan4kmdh6x89z2s7096n6nlkhcm2x29vkv` (958527).

So the **1 BTC bounty is genuinely non-custodial and publicly auditable** — anyone can verify the finder was paid by the block they found. The custody exposure applies only to the remainder:

- Remainder goes to a single pool-controlled address, then fans out over Lightning (Sati infrastructure + Xverse wallet integration), operator-run.
- Custody risk window = block-find → Lightning fanout. Operator solvency required during this window.
- This is a narrower critique than "the coinbase has a single pool output," which is how this article previously characterized it.
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
| Custody | **Bounty: none (coinbase-direct).** Remainder: pool (single coinbase output → LN fanout) |
| Hop-resistant | **No** — cumulative unpaid difficulty since inception, no decay and no window (corrected 2026-07-27) |
| IC-provable (Schrijvers) | No (PPLNS-family hybrid; non-IC under [[../../raw/papers/2026-05-23-schrijvers-2016-incentive-compatibility|Schrijvers 2016]]) |
| Operator reserve req | Low (event-driven on block-find) |
| Auditable on-chain | **Bounty: yes** (finder's own coinbase output). Remainder: no (single pool output → off-chain LN) |
| Template control | Pool (Stratum V1 — no JD support) |
| Sybil-resistance | Open — Shapley analysis ([[../../raw/papers/2026-05-26-kiayias-aft-2025-shapley-oceanic-games|Kiayias et al. AFT'25]]) suggests proportional-residual schemes are vulnerable |

## What's actually novel

Stripped of the marketing, two axes are genuinely new:

1. **Lottery-finder bonus** as a structural reward component (not just a tip), **paid trustlessly in the coinbase** — ckpool solo gives the finder everything; classical PPLNS gives the finder nothing extra; Parasite pays a fixed 1 BTC as the finder's own coinbase output while excluding them from the remainder. See [[lottery-pplns|Lottery-PPLNS]].
2. **Lightning-as-payout-rail with coinbase-maturity sidestep** — operator fronts liquidity to deliver sub-100-block-maturity payouts at 10-sat granularity.

*Struck 2026-07-27:* "continuous decay weighting" was listed here as a third novel axis. It isn't in the payout path at all — see the correction above. The weighting is cumulative unpaid difficulty, which is *less* sophisticated than PPLNS-N, not more.

## What's not novel (and arguably regressive)

- **Stratum V1** reproduces the template-control problems that SV2/JD, TIDES, and SLICE attempt to solve, and the **custodial remainder** reproduces the operator-trust problem for ~68% of the reward (the bounty itself is exempt — see the trust-model table).
- The **share scheme is weaker than PPLNS, not a variant of it** — no window and no decay means no hop-resistance, on top of the PPLNS incentive-compatibility limitations from [[../../raw/papers/2026-05-23-schrijvers-2016-incentive-compatibility|Schrijvers 2016]].
- The "loyalty" metric on the dashboard is undefined publicly — opaque governance.

## Status (July 2026)

- Production / mainnet, **5 blocks** (verified via mempool.space pool API 2026-07-27): 938713 (2026-02-28), 945601 (2026-04-18), 954873 (2026-06-22), 958212 (2026-07-15), 958527 (2026-07-18). Total ~15.68 BTC.
- **The cadence accelerated sharply**: the first two blocks were 48 days apart; the last three landed within ~26 days, the final two only 3 days apart. This resolves CoinDesk's April framing ("a third block inside the next two months would settle the case") in Parasite's favor.
- Hashrate fluctuating 24–182 PH/s; ~52 PH/s reported April 2026, down from a 182 PH/s peak in June 2025 — so the block cluster is not explained by hashrate growth, and the earlier "the bounty didn't solve retention" read looks premature.
- Active dev cadence on `parasitepool/para` (v0.5.x in late 2025, ongoing commits May 2026).
- BCH derivative pool (`bch.ee`) explicitly self-styled as the BCH parasite pool with its own variant (1 BCH bonus + 99% remainder + 1% fee).
- The "parasite.wtf scam" dispute (`Distortions81` GitHub issue, Dec 2025) is **half-true**. On-chain analysis ([[../../raw/articles/2026-05-26-parasite-pool-coinbase-onchain-analysis|verified against blocks 938,713 and 945,601]]) confirms output #1 always goes to a single pool-controlled address `bc1qkgef7pl8vdrtuc4wk8fssycz366xp5ukzsm8gp` rather than fanning out on-chain — but that address drains aggressively (8 txns total, 6.77 BTC received, ~700 sat retained). The behavior pattern matches a Lightning channel hot-wallet, not an accumulation sink. Whether the drained funds actually reach miners via LN as advertised is **unprovable from on-chain data alone** and requires operator-published payout proofs.

## Open questions / gaps

1. ~~Decay constant in production~~ — **resolved 2026-07-27: there is no decay in the payout path.** The open question becomes: does unbounded cumulative unpaid difficulty create an exploitable hopping pattern, given accumulated weight never ages out?
2. Stale/uncle share handling — undocumented.
3. Withholding-attack analysis — none published.
4. Trust model for funds-at-rest between block and Lightning fanout — undisclosed. Now scoped to the remainder only.
5. Why no Stratum V2 / JD migration — no public answer; `entangle` repo (Feb 2026, undocumented) may be the planned V2 vehicle.
6. **Why the 3-block cluster in June–July 2026** while hashrate was reportedly declining — luck, unreported hashrate growth, or a change in accounting? Not answerable from public data.
7. **Is there any published critique of large flat finder bounties?** A nine-framing search sweep (bitcointalk, Delving Bitcoin, Reddit, game-theory literature) found **none** — the variance critique has to be constructed, not cited. The bitcointalk Blitzpool thread has two posts, both by the operator, with zero community response. The gap is itself a finding.

## Sources

- [[../../raw/articles/2026-05-26-zkshark-parasite-pool-substack|zk-shark Substack]] — founder rationale
- [[../../raw/articles/2026-05-26-blockspace-media-parasite-emerges|Blockspace Media]] — technical narrative
- [[../../raw/articles/2026-05-26-bitcoin-manual-parasite-pool|The Bitcoin Manual]] — economic critique with variance math
- [[../../raw/articles/2026-05-26-coindesk-parasite-second-block|CoinDesk]] — mainnet validation
- [[../../raw/articles/2026-05-26-solosatoshi-bitaxe-parasite-setup|SoloSatoshi]] — operator config
- [[../../raw/repos/2026-05-26-parasitepool-para-github|`parasitepool/para` repo]]

## See also

- [[lottery-pplns|Lottery-PPLNS]] — the general mechanism Parasite instantiates; covers the expectation-neutrality result, the per-finder coinbase requirement Parasite sidesteps by being custodial, and the Blitzpool comparison
- [[payout-schema-taxonomy|Payout Schema Taxonomy]]
- [[pplns|PPLNS]] — parent family
- [[tides|TIDES]] — non-custodial PPLNS variant for contrast
- [[pplns-jd|SLICE / PPLNS-JD]] — SV2-decentralized counterpart
- [[ehash|eHash]] — alternative non-custodial payout layer
- [[radpool|Radpool]] — alternative decentralized FPPS via DLCs
- [[coinbase-address-rotation|Coinbase Address Rotation]] ([Coinbase Address Rotation](../concepts/coinbase-address-rotation.md)) — `parasitepool/para` carries the only shipped implementation of wildcard-descriptor payout rotation, and is the persistence-correctness baseline there
- [[ark-for-mining-payouts.md|Ark for Mining Payouts]]
- [[braidpool.md|Braidpool]]
