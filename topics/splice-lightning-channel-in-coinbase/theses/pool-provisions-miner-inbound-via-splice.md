---
title: "Thesis: A pool can provision miners' inbound LN liquidity by settling payouts as toward-miner splices/dual-funds, unifying delivery + provisioning in one on-chain footprint"
type: thesis
status: completed
created: 2026-07-23
updated: 2026-07-23
verdict: "Partially Supported — mechanism real & deployed (as wallet-LSP); literal 'funds on pool's side = payout' is a category error; a mining pool doing it is unbuilt"
confidence: High
core_claim: "A mining pool can provision its miners' INBOUND Lightning liquidity by settling payouts as liquidity-ad / dual-funded / splice transactions TOWARD each miner (funds contributed on the pool's side), unifying payout delivery and inbound provisioning in one on-chain footprint."
key_variables: [toward-miner-channel-op, funds-on-funders-side-inbound, push-msat-value-delivery, jit-on-the-fly-fusion, fee-incidence, coinbase-maturity, batching-scale, pool-as-lsp-deployment]
falsification: "Fails if (a) no mechanism lets a funder give a counterparty inbound while delivering value in one footprint, OR (b) the 'funds on the pool's side' framing is a category error — pool-side funds provision inbound but are NOT a payout (the miner is unpaid), and delivering value requires a separate push/HTLC. Deployment sub-claim fails if no mining pool does this."
parent_thesis: "splice-lightning-channel-in-coinbase (follow-up #3, surfaced by thesis #2)"
---

# Thesis: Pool provisions miner inbound via toward-miner channel ops

This is **follow-up thesis #3**, surfaced directly by
[[splice-in-vs-bolt12-miner-liquidity|thesis #2's verdict]] ("the true
inbound-provisioning path is a counterparty (pool/LSP) splicing *toward* the miner — a
distinct next thesis"). Where thesis #2 showed a miner *self*-splicing gets outbound (not
inbound), this asks whether the **pool** can be the counterparty that provisions the
miner's **inbound** — and deliver the payout in the same on-chain footprint.

## Core Claim

A mining pool can provision its miners' **inbound** Lightning liquidity by settling payouts
as **liquidity-ad / dual-funded / splice transactions toward each miner** (funds
contributed on the **pool's** side), **unifying** payout delivery and inbound provisioning
in **one on-chain footprint**.

## Key Variables

- **Toward-miner channel op** — the pool as funder/LSP opening or splicing a channel whose
  contributed funds land on the pool's side = the miner's inbound.
- **Funds-on-funder's-side = inbound** — BOLT #2 credits each contribution to the
  contributor's own balance.
- **`push_msat` / value delivery** — the only "opener gives receiver initial balance"
  primitive; *omitted* from `open_channel2` and absent from splicing.
- **JIT / on-the-fly fusion** — bLIP-36/52: an incoming payment triggers the open and the
  fee is netted from it.
- **Fee incidence, coinbase maturity, batching scale, pool-as-LSP deployment** — the
  gating conditions.

## Testable Prediction

If true, there exists a spec'd (ideally deployed) construction in which a single on-chain
tx (or one batched tx per many miners) both provisions a miner's inbound and delivers their
payout, with the cost netted from the payout — and a mining pool could adopt it.

## Falsification Criteria

- No mechanism lets a funder give a counterparty inbound while delivering value in one
  footprint, **or**
- "Funds on the pool's side" is a **category error**: pool-side funds provision inbound but
  are **not** a payout (the miner is unpaid); delivering value needs a *separate*
  push/HTLC. The deployment sub-claim fails if **no mining pool** does this.

## Scope Boundary (bloat filter)

**Not part of this thesis**: PPLNS/FPPS fairness math (cross-link
`bitcoin-mining-payout-schemas`); general LN routing economics; Ark boarding; covenant
politics; the parent's Reading A/B coinbase-structure questions. Skip anything not touching
toward-miner channel ops, inbound provisioning, payout delivery, or pool-as-LSP design.

## Evidence For

Sorted strongest first.

- **[Strong · mechanism spec'd]** [[../wiki/concepts/pool-as-lsp-inbound-provisioning|Pool-side
  contribution → miner inbound]]. BOLT #2 (verbatim): "MUST compute the channel balance for
  each side by adding **their respective** `funding_contribution_satoshis` to **their
  previous** channel balance." A pool funding on its side = the miner's inbound; interactive-tx
  lets the miner contribute zero. *(BOLT #2)*
- **[Strong · genuine fusion spec'd]** [[../raw/papers/2026-07-23-blip36-on-the-fly-funding|bLIP-36
  on-the-fly funding]] specifies a funder creating an on-chain tx "using dual-funding,
  splicing and liquidity ads" *before relaying* a payment to a recipient lacking inbound,
  then collecting the funding cost from that payment via a `funding_fee` TLV. One footprint,
  fee-from-payment. *(bLIP-36; corroborated by bLIP-52)*
- **[Strong · unification is real in JIT]** [[../raw/papers/2026-07-23-blip52-jit-and-pushmsat-omitted|bLIP-52/LSPS2
  JIT]] (verbatim): a channel "opened in response to an incoming payment... have the cost of
  their inbound liquidity be deducted from their first received payment"; "The LSP forwards
  the payment to the client, deducting the channel opening fee." *(bLIP-52, verified verbatim)*
- **[Strong · deployed]** [[../raw/articles/2026-07-23-eclair-2861-phoenix-on-the-fly-deployed|eclair
  PR #2861]] (merged 2024-09-25) ships this in Phoenix: on-chain deposits splice into the
  existing channel or dual-fund a new one; fee = the on-chain mining fee. *(eclair impl,
  ACINQ blog, Optech)*
- **[Strong · scale]** [[../raw/articles/2026-07-23-batched-channel-opens-scale|Batching
  works]]: BOLT #2 interactive-tx "open multiple channels in a single transaction"; LSPS1
  batch opens; LND `BatchOpenChannel`; CLN multi-channel splice. A pool could provision many
  miners in one footprint. *(BOLT #2, bLIP-51, LND/CLN impl)*
- **[Moderate · dual construction]** LSPS1 `lsp_balance_sat` (= miner inbound) +
  `client_balance_sat` (= value to miner) shows one *order* can carry both — the closest the
  specs come to explicitly bundling inbound + value. *(bLIP-51)*

## Evidence Against

- **[Strong · category error in the literal wording]** `push_msat` — the only "opener
  unconditionally gives the receiver initial balance" primitive — is **omitted from
  `open_channel2`** ("Note that `push_msat` has been omitted." — verified verbatim) and has
  no splice analogue. So contributing on the pool's side gives the miner **capacity only,
  zero spendable value**. Within one funding output, sats are *either* the pool's (miner
  inbound, not a payout) *or* pushed to the miner (a payout, but outbound). The same sats
  can't be both. *(BOLT #2, verified verbatim)* →
  [[../wiki/concepts/pool-as-lsp-inbound-provisioning|pool-as-LSP]]
- **[Strong · no pool does this]** [[../raw/articles/2026-07-23-no-pool-does-this-negative-result|Negative
  result]]: thorough search finds **no mining pool** acting as an inbound-provisioning LSP
  and no "pool-as-LSP" pattern named anywhere. Deployed pools do the **opposite** — OCEAN
  requires the miner to supply "sufficient inbound liquidity and open channels" + a BOLT12
  offer, and is a payment *sender*, not an LSP. *(OCEAN docs, Optech, Braidpool, hashpool)*
- **[Moderate · value crosses off-chain]** Even in the genuine JIT fusion, the on-chain tx
  supplies *capacity*; the payout *value* crosses as the forwarded off-chain HTLC. So "one
  on-chain tx delivers the payout" is imprecise — it's one *footprint* + one *economic
  event*, not one on-chain value movement. *(bLIP-52 flow, verified verbatim)*
- **[Moderate · fee flips the calculus]** On-the-fly liquidity costs the *receiver* an
  on-chain mining fee (Phoenix: "mining fees are paid by the user"). Deducted from a payout,
  this makes a *hold-only* miner strictly worse off than a plain on-chain/BOLT12 payout —
  standing inbound is deadweight unless the miner is a genuine future receiver. *(ACINQ blog)*
- **[Moderate · trust + maturity]** JIT relies on **zero-conf** trust ("LSP SHOULD default
  to 'LSP trusts client'"), and funding from the *fresh* coinbase hits `COINBASE_MATURITY =
  100`. Only matured-treasury funding sidesteps the wall — at the cost of the pool fronting
  working capital. *(bLIP-52; Bitcoin Core consensus)*

## Nuances & Caveats

- **Three claims, three verdicts.** *Mechanism* — Supported (spec'd + deployed).
  *Unification* — Supported only in the JIT/on-the-fly reading; the literal "funds on the
  pool's side = payout" is a category error. *A mining pool doing it* — Contradicted today
  (only wallet-LSPs).
- **Complementary, not rival — again.** As with thesis #2, provisioning (capex, O(1 tx per
  batch)) and BOLT12 payouts (opex, zero on-chain per payout) operate at different layers.
  On-chain provisioning only "wins" if the miner reuses the inbound.
- **The reframing that saves it.** Read as "one economic act (JIT/on-the-fly) opening or
  splicing toward the miner and netting the fee from the payout," it is real, spec'd, and
  deployed — the pool-as-LSP specialization is just novel and unbuilt.
- **Custody spectrum.** Pool-as-LSP sits *above* TIDES' non-custodial coinbase payout on
  trust (zero-conf + capital fronting) and *below* fully-custodial ecash.

## Verdict

**Status: Partially Supported — High confidence.**

**Summary**: The mechanism the thesis names is **real, specified, and deployed** — a funder
contributing on its side of a toward-recipient channel provisions the recipient's inbound
(BOLT #2, verbatim), and bLIP-36/52 fuse that provisioning with payment delivery by having
an incoming payment trigger the open and netting the fee from it, shipped today in Phoenix
(eclair #2861) with batching achievable per spec + impl. But the thesis's **literal wording
is a category error**: `push_msat` is omitted from `open_channel2`, so funds on the pool's
side give the miner *inbound capacity, not a payout* — the same satoshis cannot be both the
miner's inbound and their spendable value; the payout must cross as a separate (off-chain)
HTLC. So "unification in one on-chain footprint" is precise only as *one footprint + one
economic event*, not one on-chain value movement. And the **deployment sub-claim is
Contradicted today**: no mining pool acts as an inbound-provisioning LSP — only wallet-LSPs
(Phoenix); OCEAN does the opposite. It is a genuinely novel, unbuilt synthesis.

**Strongest supporting evidence**: bLIP-36 on-the-fly funding + bLIP-52 JIT (fee deducted
from the first payment, verified verbatim) + eclair #2861 merged/Phoenix deployed +
interactive-tx / LSPS1 / LND / CLN batching → the mechanism and scale exist now.

**Strongest opposing evidence**: `push_msat` omitted from `open_channel2` (verified
verbatim) → funds-on-pool's-side = capacity, not a payout (category error); + the negative
result that no mining pool does this (OCEAN pushes the burden onto the miner).

**Key caveats**: value crosses off-chain even in the genuine fusion; fee incidence flips the
calculus for hold-only miners; JIT is zero-conf trusted; fresh-coinbase funding hits the
100-block maturity wall; complementary to BOLT12, not a rival.

**What would change this verdict**: a deployed mining pool running the LSP role (on
`ldk-server` / CLN) that opens or splices toward miners, nets the fee from the payout, funds
from matured treasury, and targets miners who are genuine receivers — would move the
deployment sub-claim from Contradicted to Supported. The mechanism and scale are already
there; only the actor is missing.

**Suggested follow-up thesis**: "Running the pool-as-LSP role on `ldk-server`/CLN — funding
toward-miner channels from a matured treasury and netting the fee from PPLNS payouts —
beats OCEAN's miner-supplies-own-inbound model on total miner onboarding friction." (Tests
the one missing piece: an actual pool deployment, and whether it beats the status quo on
onboarding rather than footprint.)

Full reasoning: [[../wiki/topics/pool-splices-toward-miner-verdict|pool-splices-toward-miner verdict]].
