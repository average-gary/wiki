---
title: "Scaling noncustodial mining payouts with CTV (jamesob, Delving Bitcoin #1753)"
source: "https://delvingbitcoin.org/t/scaling-noncustodial-mining-payouts-with-ctv/1753"
type: article
subtype: protocol-thread
retrieved: 2026-07-23
tags: [mining, coinbase, ctv, noncustodial-payouts, delving-bitcoin, jamesob, fanout, coinbase-maturity]
credibility: high
evidence_strength: primary-design-thread
direction: "supports mechanism for Reading B; nuances (does not reach LN)"
bears_on: [B]
summary: "James O'Beirne's CTV-based design for scaling noncustodial mining payouts: a tiny coinbase commits to a fanout tree of many payout outputs. Documents the presign-a-coinbase-spend pattern with explicit maturity handling ('broadcast to mempool where it sits for 100 blocks until valid to mine') and CPFP/ANYONECANPAY fee handling — the technical backbone under a coinbase-funds-downstream-structure design, though it stops short of naming Lightning channels as leaves."
---

# jamesob — Scaling noncustodial mining payouts with CTV

- Enabling primitive: **"a single tiny consensus-enforced commitment to a fanout
  transaction of arbitrary size"** — a 179-byte coinbase spending to a CTV unroll tx
  with up to 319 payout outputs + an anchor.
- Maturity handling (verbatim): **"The pool can immediately broadcast it to the
  mempool where it will sit for 100 blocks until it becomes valid to mine."** → a
  presigned/committed spend of a coinbase is a *valid signature the moment the
  coinbase exists*; only **inclusion** waits for maturity.
- Fee handling: **"use the anchor output to CPFP fee bump it … could potentially use
  `SIGHASH_ANYONECANPAY` to crowdsource the fees."**
- Honest limit: the thread does **not** discuss Lightning channels as payout leaves.
  The leap from "coinbase → committed payout UTXOs" to "one of those UTXOs funds a
  channel" is the reader's synthesis, not stated.

## Bearing on the thesis

- Strongest primary-source mechanism for a coinbase output funding a downstream
  committed structure, with explicit maturity + fee handling — the technical backbone
  under Reading B.
- But it uses **CTV** (a covenant, not on mainnet), and confirms the maturity wall
  is universal: even a committed spend sits 100 blocks before it can be mined. This
  is a payout/fanout design, not an LN channel-funding design.
