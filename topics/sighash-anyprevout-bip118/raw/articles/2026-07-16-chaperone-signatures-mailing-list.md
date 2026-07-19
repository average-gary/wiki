---
title: "Eltoo, ANYPREVOUT and chaperone signatures (lightning-dev / bitcoin-dev threads)"
source: "https://tldr.bitcoinsearch.xyz/summary/lightning-dev/May_2019/001997_Eltoo-anyprevout-and-chaperone-signatures"
type: articles
ingested: 2026-07-16
tags: [chaperone-signatures, anyprevout, noinput, signature-replay, mailing-list, mitigation-dropped, zmnscpxj]
summary: "Primary-source history of the chaperone-signature debate. A chaperone signature = an additional required signature (a second key signing SIGHASH_ALL) alongside the APO signature, so a third party can't unilaterally replay a floating signature. Ultimately dropped: anyone able to construct a replay could usually also produce the chaperone, and protocols like eltoo manage replay at the protocol layer. BIP-118 instead relies on the 0x01 opt-in key + tapscript-only scoping. Also documents the deliberate exclusion of APO from the taproot key path."
---

# Eltoo, ANYPREVOUT and chaperone signatures

lightning-dev / bitcoin-dev mailing-list threads (May 2019 and around). Primary-source
grounding for the most-cited historical criticism of NOINPUT/APO.
Related: https://www.mail-archive.com/bitcoin-dev@lists.linuxfoundation.org/msg10264.html

## What chaperone signatures were

- A proposed replay mitigation: an **additional required signature** (a second key
  signing with `SIGHASH_ALL`) alongside the APO signature, so a third party cannot
  unilaterally replay a floating signature. The APO key signs with APO; the chaperone
  signs with ALL.

## Why they were dropped

- The community debate concluded they add ceremony/complexity without meaningfully
  closing the replay hole in the cases that matter — anyone who could construct the
  replay could usually also produce the chaperone signature, and legitimate protocols
  (eltoo) manage replay at the protocol layer anyway.
- BIP-118 instead relies on the **0x01 opt-in key + tapscript-only scoping** to bound
  the danger; chaperone support was demoted to an optional, per-key PSBT-hint concern
  rather than a consensus requirement.

## Taproot key-path exclusion

- Documents the deliberate scoping decision to exclude APO from the taproot key path
  (ZmnSCPxj: cooperative closes don't need APO; keep it in tapscript only).
