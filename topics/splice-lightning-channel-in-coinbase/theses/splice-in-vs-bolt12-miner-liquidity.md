---
title: "Thesis: Splicing matured coinbase rewards into miner channels beats OCEAN-style BOLT12 payouts for miners wanting LN liquidity"
type: thesis
status: completed
created: 2026-07-23
updated: 2026-07-23
verdict: "Contradicted (as stated — inbound category error) / Mixed (reframed to outbound); complementary not rival"
confidence: High
core_claim: "For a miner who wants Lightning liquidity, splicing matured coinbase rewards into their own channel (Reading C) is a superior payout primitive to receiving off-chain BOLT12 Lightning payments (OCEAN-style)."
key_variables: [splice-in-matured-coinbase-utxo, bolt12-offchain-payout, liquidity-direction-inbound-vs-outbound, custody-model, payout-fee-latency-economics]
falsification: "Fails if BOLT12 off-chain payouts dominate on every axis that matters (cost, latency, small-payout support, custody flexibility), OR if the 'inbound liquidity' framing is a category error — splicing your own funds in yields OUTBOUND, not inbound, liquidity, so it cannot serve a goal of receiving payments."
parent_thesis: "splice-lightning-channel-in-coinbase (Reading C follow-up #3)"
---

# Thesis: Splice-in of matured coinbase rewards vs OCEAN-style BOLT12 payouts

This is **follow-up thesis #3** from the parent thesis
[[splice-lightning-channel-in-coinbase]] (its Reading C). Where the parent asked
*whether* a matured coinbase UTXO can be spliced into a channel (yes), this asks
whether doing so is a *better payout primitive* than off-chain BOLT12 payments for
a miner who wants Lightning liquidity.

## Core Claim

For a miner who wants Lightning liquidity, **splicing matured coinbase rewards into
their own channel** (parent thesis Reading C — CLN `splicein` / LND / Phoenix) is a
**superior payout mechanism** to receiving **off-chain BOLT12 Lightning payments**
(OCEAN-style).

## Key Variables

- **Splice-in of a matured coinbase UTXO** — an on-chain interactive-tx that adds the
  miner's own confirmed reward UTXO to an existing channel.
- **BOLT12 off-chain payout** — a reusable offer the miner publishes; the pool pays it
  over Lightning with no per-payout on-chain footprint.
- **Liquidity direction** — inbound (ability to *receive*) vs outbound (ability to
  *send*). The load-bearing distinction.
- **Custody model** — non-custodial on-chain finality vs pool-custodied off-chain
  accrual vs bearer ecash.
- **Payout economics** — on-chain fee floor / dust vs sub-dust micro-payouts; maturity
  latency; payout cadence.

## Testable Prediction

If true, there exists a class of miners for whom splice-in **dominates** BOLT12 on
cost, custody, and the resulting liquidity outcome.

## Falsification Criteria

- BOLT12 payouts dominate on every axis that matters (cost, latency, small-payout
  support, custody flexibility), **or**
- The "inbound liquidity" goal is a **category error**: splicing your *own* funds into
  your side of a channel adds **outbound** balance and *consumes* nothing toward
  inbound; receiving a payment is what consumes inbound. If the miner's real goal is to
  *receive* payouts over LN, splice-in of own funds does not serve it — the two options
  are not even substitutes for the same goal.

## Scope Boundary (bloat filter)

**Not part of this thesis**: general LN routing economics; pool payout-fairness math
(PPLNS/FPPS — cross-link `bitcoin-mining-payout-schemas`); Ark boarding; covenant
politics. Skip anything not touching miner payouts, LN channel liquidity, splicing,
BOLT12, or pool payout design.

## Evidence For

The thesis wins only when *reframed* to the OUTBOUND goal; the strongest pro-splice
evidence is scoped accordingly. Sorted strongest first.

- **[Strong · reframed-outbound]** BOLT #2 permits **zero channel downtime**: "Once
  `tx_signatures` have been exchanged, the splice transaction can be broadcast… normal
  operation can resume while waiting for the transaction to confirm." *Verified verbatim
  vs master 2026-07-23.* A matured reward splices in with a single on-chain footprint,
  which close+reopen cannot match. *(BOLT #2)* →
  [[../wiki/concepts/inbound-vs-outbound-liquidity|inbound vs outbound]]
- **[Strong · trust-minimization]** OCEAN **TIDES pays non-custodially from the coinbase
  generation tx** — "miners should be paid via the generation transaction… without the
  pool ever even having control." That is the self-custodied matured UTXO the splice side
  wants; the BOLT12 path is by contrast the *accrual* path where the pool holds an
  off-chain balance until a threshold. *(OCEAN TIDES docs)* →
  [[../wiki/topics/splice-vs-bolt12-verdict|verdict]]
- **[Moderate · capital efficiency]** ACINQ Phoenix uses splice-in to go from "N
  UTXOs/user to 1 UTXO/user… the current optimum for self-custody," replacing the
  1%/3000-sat open fee with "the mining fee for the underlying on-chain transaction."
  *(ACINQ blog, CLN `splicein` docs)* →
  [[../wiki/topics/splice-vs-bolt12-verdict|verdict]]
- **[Moderate · mechanism maturity]** Splice-in ships across CLN (native
  `splicein`/`spliceout`), eclair/Phoenix, LDK, and LND — a broadly available primitive,
  not experimental. *(Optech splicing, release artifacts; LND attribution via secondary
  sources — treat as med)*

## Evidence Against

- **[Strong · kills the literal "inbound" thesis]** **Category error.** BOLT #2 (verbatim)
  credits a splice-in to the **sender's own** balance — "the amount the sender is adding
  to their channel balance" and "adding **their respective** `funding_contribution_satoshis`
  to **their previous** channel balance." So self-splice yields **outbound**, never
  inbound. And receiving a BOLT12 payout **consumes** inbound (HTLC settles onto local),
  never creates it. For the stated goal (inbound), **both options are the wrong tool**;
  inbound requires a counterparty funding the far side (dual fund / liquidity ad / LSPS1
  / LSPS2-JIT). *(BOLT #2, Optech dual-funding, bLIP-51/52)* →
  [[../wiki/concepts/inbound-vs-outbound-liquidity|inbound vs outbound liquidity]]
- **[Strong · small/frequent payouts]** Each splice is an **on-chain tx paying a mining
  fee**; below the dust limit (~546 sats) outputs are non-standard and any output worth
  less than its spend fee is "uneconomical" (Optech). A small miner's per-payout accrual
  can be smaller than the splice fee → uneconomic to splice at all. BOLT12/ecash carry no
  on-chain minimum. *(Optech uneconomical-outputs; hashpool "no minimum threshold")* →
  [[../wiki/topics/splice-vs-bolt12-verdict|conditions map]]
- **[Strong · immediacy]** `COINBASE_MATURITY = 100` blocks any splice of a *freshly*-mined
  reward for ~16.7 h (and reorg voids it). A fronting pool paying BOLT12 hides this — the
  miner is paid immediately from pool liquidity while the coinbase matures on the pool's
  books. *(Bitcoin Core `consensus.h`; jamesob Delving #1753)*
- **[Moderate · revealed preference]** Every deployed mining→LN system routes around
  fresh-coinbase splicing: OCEAN pays BOLT12 (on-chain only at the 0.01048576 BTC
  threshold), Braidpool settles one-way channels from *matured accumulation*. Optech's
  "Pooled mining" topic names no LN/splice/ecash payout rail as canonical. *(OCEAN,
  Braidpool, Optech)*
- **[Moderate · shipped comparator]** OCEAN genuinely ships BOLT12 payouts (live ~2024-04-30).
  Luke Dashjr's stated rationale is the exact small-miner case splice-in loses: "the cost
  of the transaction fee is higher than the reward… OCEAN helps overcome this risk using
  Lightning." *(OCEAN Lightning docs, launch coverage)*

## Nuances & Caveats

- **They're complementary, not rivals.** BOLT12 *delivers* a payout (and consumes the
  miner's inbound); splice-in *converts* an on-chain reward into outbound capacity;
  TIDES *sources* the matured on-chain UTXO. A miner can use all three. No high-weight
  source frames splice vs BOLT12 as competitors — they sit at different layers.
- **The defensible reading is "outbound," not "inbound."** Reframed to "get self-custodied
  **spendable** LN capacity from matured rewards," the splice side is genuinely strong —
  but only for **large, infrequent** rewards in a **tolerable fee** environment, so it's a
  conditional Mixed, never "strictly better."
- **The interesting third option** is a pool/LSP splicing *its own* funds **toward** the
  miner (liquidity-ad settlement "with either dual-funding or splicing") — that *does*
  provision the miner's inbound, but it's the counterparty splicing, not self-splice.
  This is the natural next thesis.
- **Ecash is a third custody model** (hashpool eHash / fedimint): finest-grained,
  blind, no minimum — but custodial with the longest dwell. Wins for tiny/private
  payouts, loses for self-custody.

## Verdict

**Status**: **Contradicted (as literally stated) / Mixed (reframed)** — the "inbound
liquidity" framing is a category error; reframed to the outbound goal it's a
conditions-dependent Mixed, not "strictly better."
**Confidence**: **High**

**Summary**: As written — splice-in *beats* BOLT12 *for miners wanting **inbound** LN
liquidity* — the thesis is **Contradicted**. Splicing your own matured coinbase adds
**outbound** (send-side) capacity (BOLT #2 credits the sender's own balance, verified
verbatim), and receiving a BOLT12 payout **consumes** inbound rather than creating it, so
neither option serves the stated inbound goal; inbound is provisioned only by a
counterparty funding the far side (dual funding / liquidity ads / LSPS1 / LSPS2-JIT).
Stripped of that error and read charitably as "self-custodied **outbound** capacity from
matured rewards vs off-chain payouts," it becomes a **Mixed**, condition-dependent result:
splice-in wins for large, infrequent, self-custody-seeking miners in tolerable fee
environments; BOLT12 (or ecash) wins for small, frequent, fee-sensitive, or
immediacy-seeking miners. And the two are largely **complementary** — BOLT12 delivers,
TIDES sources the UTXO, splice-in converts it to outbound.

**Strongest supporting evidence**: BOLT #2 zero-downtime resume + ACINQ 1-UTXO/user
self-custody + OCEAN TIDES non-custodial coinbase payout → splice-in is the capital-
efficient, self-custodied way to build **outbound** from large matured rewards.

**Strongest opposing evidence**: BOLT #2 splice-balance accounting (verbatim) + the
inbound/outbound definition → self-splice produces outbound while the goal was inbound
(category error); plus the dust floor + per-splice on-chain fee + 100-block maturity that
make off-chain BOLT12 win for small/frequent/immediate payouts.

**Key caveats**: splice and BOLT12 are complementary, not rivals; the defensible reading
is "outbound," not "inbound"; the true inbound-provisioning path is a counterparty
(pool/LSP) splicing *toward* the miner — a distinct next thesis.

**What would change this verdict**:
- Rewording the goal from **inbound** to **outbound/spendable** removes the fatal category
  error and leaves the conditional Mixed.
- A widely-deployed **pool-splices-toward-miner** liquidity-ad payout would let "splicing"
  serve the inbound goal — but as counterparty funding, not self-splice.

**Suggested follow-up thesis**: "A mining pool can provision its miners' **inbound**
Lightning liquidity by settling payouts as liquidity-ad / dual-funded splices *toward*
each miner (funds on the pool's side), unifying payout delivery and inbound provisioning
in one on-chain footprint." (Tests the third option this thesis surfaced.)
