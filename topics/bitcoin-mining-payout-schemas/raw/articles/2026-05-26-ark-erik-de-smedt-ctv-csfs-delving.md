---
title: "Evolving the Ark protocol using CTV and CSFS (Erik De Smedt + Roasbeef, Delving Bitcoin)"
publication: delvingbitcoin.org
url: https://delvingbitcoin.org/t/evolving-the-ark-protocol-using-ctv-and-csfs/1602
authors: [Erik De Smedt (Second CTO), Steven Roose, roasbeef (Lightning Labs)]
date: 2025-04-15
type: article
ingested: 2026-05-26
quality: 5
credibility: high
confidence: high
tags: [ark, ctv, csfs, erk, hark, roasbeef, critique, primary]
---

# Evolving Ark with CTV and CSFS — Delving (Apr 2025)

Erik De Smedt's primary technical writeup defining **Erk** (async, single-input/output VTXOs) and **hArk** (async, multi-input) variants. roasbeef (Olaoluwa Osuntokun, Lightning Labs CTO) provides substantive critique.

## Variants introduced

- **clArk** (current): covenantless, recursive multisigs. Works today; presence-of-receiver required to issue VTXOs.
- **Erk**: async, single-input/output VTXOs. Requires CTV + CSFS.
- **hArk**: async, multi-input. Hash-locked. Mobile-friendly delegated refreshes. Requires CTV + CSFS.
- All efficient variants need CTV + CSFS (effectively APO); none activated as of 2025.

## roasbeef's critiques (high credibility)

- **Asymmetric exit cost**: "cost for a user to attempt a malicious exit is low, while the cost for the server to retaliate is high." In Erk the ASP must broadcast the entire VTXO tree to retaliate — directly relevant to mining-payout settings where many small payees create tree-unrolling DoS pressure.
- **Out-of-round / "arkoor" payments require trust**: "trust server and prior owner to not collude" — payment chains between rounds inherit double-spend risk if the ASP cooperates with a prior holder. Breaks the "trustless mining payout" pitch.

## Roose's own admissions

- The clArk (no-covenant, MuSig2) variant requires "the presence of the eventual owner" — preventing third-party issuance. **For mining payouts, this means a pool cannot issue VTXOs to miners who are offline**, which is the entire problem you'd want Ark to solve.
- "Receivers participating in rounds is vulnerable to DoS attacks" — covenant-free Ark is fragile under adversarial miners.

## Expiration mechanic

- VTXO expiration combines absolute timeout `T_exp` with relative timelock `Δt`.
- Users (miners) **must come online before T_exp or lose funds** — directly contradicts the "passive miner receives payouts" assumption.

## Why ingestion-worthy

The cleanest authoritative critique of Ark's exit-cost asymmetry and the colluder-double-spend failure mode, both of which are most damaging when payees are mining-pool participants who cannot stay online for round cadences. Roose acknowledging the receiver-presence requirement of clArk is a load-bearing admission against any "mining payouts via covenantless Ark today" claim.

## Counter to the "Ark > CTV" framing

The thread shows: covenant-free Ark can't issue to absent receivers and is DoS-prone — so the "Ark instead of CTV" framing only holds if you assume the *covenant-using* Ark, which has the **same activation dependency** CTV-coinbase does. The "Ark > CTV" claim collapses into "Ark + CTV > CTV alone," which is much weaker and not obviously true for mining payouts where the receiver-presence and round-cadence problems dominate.

## See also

- [[2026-05-26-vnprc-ctv-coinbase-delving]] — sister thread (already in wiki)
- [[2026-05-26-second-tech-ark-intro]] — Second's spec context
- [[2026-05-26-ark-pickhardt-channel-factory-delving]] — capital-lockup critique
