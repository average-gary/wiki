---
title: "eltoo: A Simplified update mechanism for Lightning and Off-Chain Contracts (Decker, Blockstream blog)"
source: "https://blog.blockstream.com/en-eltoo-next-lightning/"
type: articles
ingested: 2026-07-16
tags: [eltoo, ln-symmetry, sighash-noinput, anyprevout, lightning, toxic-information, channel-factories, decker]
summary: "Christian Decker's accessible (2018-04-30) explainer of eltoo. Frames LN-Penalty's core problem as 'toxic information' (participants must retain outdated-state transactions; loss/leak can lose funds). SIGHASH_NOINPUT lets later updates bind to ANY prior update output with a matching script ('short-circuiting'). Includes the 'blockchain as a court that decides the final state' analogy."
---

# eltoo: A Simplified update mechanism for Lightning and Off-Chain Contracts

Christian Decker (co-author of the eltoo paper), Blockstream blog, 2018-04-30.

## The problem: "toxic information"

LN-Penalty's core problem: participants must **retain outdated-state transactions**;
if leaked or forgotten (e.g. after a backup restore), funds can be lost. The model is
asymmetric and punishment-based.

## The mechanism

- `SIGHASH_NOINPUT` (later APO) lets later update transactions **bind to *any* prior
  update output with a matching script**, enabling "short-circuiting" — connecting the
  final state directly to contract creation instead of replaying every intermediate
  update on-chain.
- Structure: each state = update tx + settlement tx; script permits a newer update
  before timeout, or settlement after. "Only the last settlement transaction can ever
  be confirmed."
- Storage collapses to: latest update, latest settlement, active HTLCs — no
  invalidated-state data. Enables up-to-seven-party channels and **channel factories**.

## Memorable framing

Off-chain negotiation is like presenting cases to **"a court that will decide the
final state — the court being the blockchain."** Higher state numbers always win.
