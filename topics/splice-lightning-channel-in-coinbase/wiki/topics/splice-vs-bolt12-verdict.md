---
title: "Verdict: splice-in of matured coinbase vs OCEAN-style BOLT12 payouts"
type: topic
created: 2026-07-23
updated: 2026-07-23
tags: [thesis-verdict, splicing, bolt12, mining-payouts, inbound-liquidity, ocean, custody, follow-up-thesis]
summary: "Verdict synthesis for follow-up thesis #3 (Reading C of the parent). The 'beats… for miners wanting inbound LN liquidity' framing is a CATEGORY ERROR — splice-in yields outbound, receiving BOLT12 consumes inbound, neither creates inbound. Stripped of that error, the two are largely COMPLEMENTARY, not rivals: splice-in wins for large infrequent matured rewards → self-custodied outbound; BOLT12 wins for small frequent payouts (no dust floor, no per-payout on-chain fee, instant, pool absorbs maturity). Verdict: Contradicted as literally stated (inbound); Mixed/conditional once reframed to outbound. Confidence: High."
---

# Verdict — splice-in vs OCEAN-style BOLT12 payouts

> **Follow-up thesis #3** (from parent [[../../theses/splice-lightning-channel-in-coinbase|splice-lightning-channel-in-coinbase]], Reading C):
> "Splicing matured coinbase rewards into miner channels is a strictly better
> non-custodial payout primitive than OCEAN's BOLT12 off-chain payouts **for miners who
> want inbound LN liquidity.**"

## Verdict: **Contradicted as stated / Mixed once reframed — High confidence**

Two defects, one fatal to the literal claim, one softening the reframed claim:

### 1. The "inbound liquidity" framing is a category error (fatal to the literal thesis)

- **Splice-in of your own coinbase → outbound, not inbound.** BOLT #2 (verified verbatim)
  adds `funding_contribution_satoshis` to the **sender's own** balance; each side adds
  **their respective** contribution to **their own** previous balance. Your own UTXO can
  never credit the counterparty's (inbound) side.
- **Receiving a BOLT12 payout → *consumes* inbound**, converting it to outbound as the
  HTLC settles. It doesn't create inbound either; you must already hold inbound to
  receive at all (OCEAN's #1 failure mode: "insufficient inbound liquidity").
- So for the stated goal (**inbound**, to *receive*), **both options are the wrong
  tool.** Inbound comes only from a counterparty funding the far side: dual funding,
  liquidity ads (BOLT #7 `option_will_fund`), LSPS1 channel purchase, or LSPS2 JIT.
  Full mechanics: [[../concepts/inbound-vs-outbound-liquidity|inbound vs outbound liquidity]].

The thesis as literally worded — splice-in *beats* BOLT12 *for inbound* — is
**Contradicted**: it compares two things that produce/consume outbound against a goal
(inbound) neither serves.

### 2. Reframed to the defensible goal (outbound / spendable capacity), it's conditional

Strip the inbound error and read it charitably — "splice matured rewards in to get
self-custodied **outbound** LN liquidity, vs take BOLT12 payouts" — and it becomes a
**conditions-dependent Mixed**, not "strictly better." The flip axes:

| Condition | Winner | Why |
|---|---|---|
| Large farm, block-sized infrequent rewards | **Splice-in** | On-chain fee negligible; self-custody; zero-downtime single tx |
| Small/solo miner, tiny frequent accrual | **BOLT12 (or ecash)** | Accrual < splice fee → uneconomic to splice; off-chain has no dust floor |
| High-feerate environment | **BOLT12 / ecash** | Splice cost scales with feerate; LN payment fee doesn't |
| Freshly-mined reward, want it usable now | **BOLT12 from a fronting pool** | 100-block (~16.7 h) coinbase maturity blocks any splice; pool hides it |
| Self-custody / sovereignty paramount | **Splice-in** | Miner controls the UTXO the instant it matures; no pool/mint custody |
| Wants **inbound** to receive future payouts | **Neither — LSP / liquidity ad / dual fund / JIT** | Splice = outbound; receiving consumes inbound |
| Privacy paramount, trusts a mint | **Ecash / Cashu** | Blind per-share; but custodial, longest dwell |
| Constant predictable blockspace at scale | **One-way channels (Braidpool-style)** | Fixed blockspace regardless of miner count |

Sources: [[../../raw/articles/2026-07-23-splice-in-liquidity-refill-economics|splice economics]] ·
[[../../raw/articles/2026-07-23-payout-rail-economics-dust-ecash-braidpool|payout-rail economics]] ·
[[../../raw/articles/2026-07-23-ocean-bolt12-lightning-payouts|OCEAN docs]].

## They're complementary, not rivals

No high-weight source frames splicing and BOLT12 as competitors — they sit at different
layers:

- **OCEAN's BOLT12 push** *delivers* the payout and *consumes* the miner's inbound.
- **OCEAN's TIDES** already pays the matured reward **on-chain from the coinbase**,
  non-custodially — that *is* the self-custodied UTXO the splice side wants.
- **Splice-in** is how the miner then *converts* that on-chain reward into channel
  (outbound) capacity without a close+reopen.

A miner can do both: receive dust-sized accruals over BOLT12 (needs inbound), take large
balances on-chain via TIDES, and splice those matured UTXOs into a channel for outbound.
And the cleanest inbound story unifies them — a **pool/LSP splicing its own funds toward
the miner** (liquidity-ad settlement "with either dual-funding or splicing") provisions
the miner's inbound, which is the external-funding pattern, not self-splicing.

## Why the parent thesis fed this one

Parent Reading C established that a *matured* coinbase UTXO is spliceable today. This
thesis asked whether that's a *better payout primitive* than BOLT12. Answer: it's not
even the same primitive — splice-in builds the miner's outbound capacity; BOLT12 delivers
payments into it. The interesting real question the pair surfaces is the **third option**:
a pool provisioning miner **inbound** via a splice/liquidity-ad *toward* the miner —
which is the natural next thesis.

## Strongest evidence each way

- **Against the literal thesis (decisive):** BOLT #2 splice-balance accounting (verbatim)
  + the definition of inbound/outbound → self-splice is outbound, the goal was inbound.
- **For the reframed splice side:** BOLT #2 zero-downtime resume + ACINQ 1-UTXO/user
  self-custody + TIDES non-custodial coinbase payout → splice-in wins for large matured
  rewards on finality/custody/capital-efficiency.
- **For the BOLT12 side:** dust floor + per-splice on-chain fee + coinbase maturity +
  OCEAN's shipped BOLT12 (Luke Dashjr: fee cost "higher than the reward" for small
  miners) → off-chain wins for small/frequent/immediate payouts.

## What would change this verdict

- Rewording the goal from **inbound** to **outbound / spendable** flips defect #1 from
  fatal to a non-issue and leaves the conditional Mixed.
- A widely-deployed **pool-splices-toward-miner** liquidity-ad payout (inbound via
  splicing) would make "splicing" serve the inbound goal — but that's the counterparty
  splicing, not the miner self-splicing, so it still doesn't rescue the literal thesis.
