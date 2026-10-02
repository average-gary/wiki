---
title: "Block withholding economics: power-splitting games (Luu et al. 2015) and smart-contract-incentivised withholding (Velner et al. 2017)"
source: "https://eprint.iacr.org/2015/155"
related_sources: ["https://eprint.iacr.org/2017/230"]
type: papers
ingested: 2026-09-21
tags: [block-withholding, pps-vulnerability, pplns, game-theory, mixed-strategy-equilibrium, infiltration-attack, reward-scheme-design, incentive-attack, pool-economics]
summary: "Two peer-reviewed results that together make attack-resistance a first-class input to pool architecture rather than an operational afterthought. Luu, Saha, Parameshwaran, Saxena & Hobor (IEEE CSF 2015) model hashpower allocation across pools as a power-splitting game and show that under current reward schemes block withholding stays profitable over long horizons, and that equilibrium is a MIXED strategy — rational miners probabilistically attack rather than participating honestly. Velner, Teutsch & Luu (IACR 2017/230) then remove the attacker's capital requirement: a smart contract that pays other miners to withhold lets an adversary holding 0.0000002% of network hashpower drive a large PPS pool's revenue to zero at no net cost, versus the >1% of network hashrate classical withholding needs for a 5% revenue dent. The architectural consequence is that the reward scheme, not the wire protocol, determines this attack surface — and PPS carries the variance risk that makes it the target."
authors: [Loi Luu, Ratul Saha, Inian Parameshwaran, Prateek Saxena, Aquinas Hobor, Yaron Velner, Jason Teutsch]
affiliation: "National University of Singapore; Hebrew University; University of Alabama at Birmingham"
published: 2015
published_second: 2017
venue: "28th IEEE Computer Security Foundations Symposium (CSF 2015) / IACR ePrint 2017/230"
credibility: high
credibility_score: 5
credibility_rationale: "CSF 2015 is peer-reviewed; the 2017 companion is an ePrint from the same research line. Both were surfaced independently by two agents this round (academic listed 2015/155 and referenced 2017/230; contrarian extracted 2017/230 in full)."
confidence: high
research_round: 1
research_agent: "academic + contrarian"
relevance_note: "Two papers in one file because they are one argument: the 2015 paper establishes that withholding is profitable under existing schemes, the 2017 paper removes the capital barrier. Reward-scheme design itself belongs to bitcoin-mining-payout-schemas; kept here only as the architectural constraint it imposes."
extraction_note: "Subagent extractions; the 2015 paper was read mainly at abstract/result level (the detailed withholding mechanics were reported as 'referenced, not fully detailed'). Effect sizes quoted below are as reported by the agents — verify the 0.0000002% figure and the >1% comparison against the PDFs before quoting them in published output."
---

# Block withholding economics

Two papers, one argument: **the reward scheme chooses the attack surface.**

## Luu, Saha, Parameshwaran, Saxena, Hobor — *On Power Splitting Games in Distributed Computation: The Case of Bitcoin Pooled Mining* (IEEE CSF 2015, ePrint 2015/155)

**Framing.** Over 70% of Bitcoin's computational capacity ran through public pools. The paper models
how rational miners split hashpower across competing pools to maximise reward — a *computational
power-splitting game*.

**Results as reported.**

- Existing pool reward protocols are vulnerable to the **block withholding attack**, and it remains
  profitable **over extended periods** (the paper notes it may not be over a short duration — the
  time horizon matters, which is why operators may not notice it).
- **Equilibrium is not honest.** Participants do not uniformly choose honest strategies; mixed-strategy
  equilibria emerge in which miners probabilistically split hashpower and probabilistically withhold.
- Current reward schemes therefore **incentivise wasteful competition and attack behaviour** — the
  network's security does not follow from miners being rational.
- Systematic exploitation could cause "substantial financial losses within months."

**Mechanics** (as referenced rather than fully extracted): the attacker joins a pool, solves and
submits shares to earn credit, but withholds any solution that is a full block, denying the pool the
block reward while still drawing payouts. The damaging variant is **infiltration** — splitting
hashpower across multiple pools.

**Architectural consequence.** PPS and PPLNS have *different* vulnerability profiles; the reward
function is therefore a security parameter. There is a direct tension between the pooling benefit
(variance reduction) and manipulation resistance: the more variance risk the operator absorbs, the
more there is to drain.

## Velner, Teutsch, Luu — *Smart Contracts Make Bitcoin Mining Pools Vulnerable* (IACR 2017/230)

**The escalation.** Classical withholding is unprofitable *for the attacker* — it hurts the target
pool and benefits competing pools, so someone else captures the gain. A smart contract fixes that
coordination problem by paying withholders trustlessly.

- "We introduce smart contracts that reward pool miners who withhold their blocks." Rational pool
  members can then be *hired* to attack.
- Reported effect: an adversary with **0.0000002% of Bitcoin's computation power can reduce a big
  pool's revenue to zero without financial loss**; "an adversary with a single mining ASIC can, in
  theory, destroy all big mining pools without losing any money (and even make some profit)."
- **Baseline for comparison**: classical withholding needs **over 1% of network hashpower** to cause
  a large pool a **>5% revenue decrease**. The contract version achieves far more with negligible
  hashrate because it buys other people's hashrate instead of supplying its own.
- **Target class**: pools running **pay-per-share**. PPS pools hold the variance risk, so sustained
  withholding drains reserves until the pool cannot meet payouts.

## Why this sits in an architecture wiki

1. **No protocol upgrade fixes it.** Stratum V2's encryption and authentication do not touch
   withholding: the attacker is an authenticated, paying-customer miner submitting valid shares and
   silently dropping the one that matters. Defences have to live in the accounting/reward layer.
2. **It bounds the "PPS is better UX" argument.** Absorbing miner variance is a product decision with
   a documented adversarial cost, which any recommendation of PPS/FPPS must price in.
3. **Detection is an architectural requirement.** Withholding is statistically invisible in a short
   window — the pool observes a valid share stream and merely an unlucky block rate. Detecting it
   needs per-worker expected-vs-actual block attribution over long horizons, which in turn means the
   share pipeline must retain enough per-worker history to support that test. That is a storage and
   retention requirement produced by a game-theory result.
4. **Countermeasures exist and were not evaluated here.** Lee & Kim, *Countering Block Withholding
   Attack Efficiently* (IACR 2018/1211, IEEE INFOCOM CryBlock 2019) claims defences adoptable
   "without changing their mining environment." Not ingested this round — a gap.
