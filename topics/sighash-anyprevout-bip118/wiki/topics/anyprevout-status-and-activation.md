---
title: "BIP-118 status & activation"
category: topic
sources:
  - raw/articles/2026-07-16-bip-118-anyprevout-spec.md
  - raw/articles/2026-07-16-delving-bitcoin-inquisition-29-signet-status.md
  - raw/articles/2026-07-16-delving-bitcoin-ctv-csfs-consensus-first-step.md
  - raw/articles/2026-07-16-chaincode-podcast-anyprevout-instagibbs.md
  - raw/articles/2026-07-16-spark-covenant-proposals-compared.md
  - raw/articles/2026-07-16-optech-anyprevout-topic.md
created: 2026-07-16
updated: 2026-07-16
tags: [bip-118, anyprevout, activation-status, bitcoin-inquisition, signet, ctv, csfs, lnhance, soft-fork, ajtowns]
aliases: [APO status, BIP-118 activation, anyprevout signet]
confidence: high
volatility: hot
verified: 2026-07-16
summary: "BIP-118 is a Draft consensus soft-fork proposal (Decker, Towns), NOT activated on mainnet and with no standalone activation attempt. It is live and testable only on the Bitcoin Inquisition signet (since block 106704 / 2022-09-06), bundled with CTV/OP_CAT/CSFS/OP_INTERNALKEY. Developer momentum has shifted toward CTV+CSFS ('LNHANCE'), argued to emulate APO for LN-Symmetry — a substitution APO co-author AJ Towns disputes. Signet usage is light (~1,000 txs)."
---

# BIP-118 status & activation

> **One-line status**: BIP-118 SIGHASH_ANYPREVOUT is a **Draft** consensus soft fork —
> **not on mainnet, with no active standalone activation proposal** — but **deployed and
> testable on the Bitcoin Inquisition signet** since 2022. Its flagship use case
> ([[eltoo-ln-symmetry|eltoo / LN-Symmetry]] ([eltoo / LN-Symmetry](../concepts/eltoo-ln-symmetry.md)))
> can arguably be delivered via CTV+CSFS, which has drawn away the mainnet momentum.

## Formal status

- **BIP number 118**, "SIGHASH_ANYPREVOUT for Taproot Scripts." **Authors**: Christian
  Decker, Anthony Towns. **Status**: Draft. **Layer/Type**: Consensus (soft fork).
  Builds on BIP-340/341/342.
- **Lineage**: originated as "NOINPUT" (Joseph Poon, 2016); briefly renamed
  `SIGHASH_NOINPUT_UNSAFE` (2018) to flag the
  [[signature-replay-and-chaperone-signatures|replay footgun]] ([replay footgun](../concepts/signature-replay-and-chaperone-signatures.md));
  renamed to `SIGHASH_ANYPREVOUT` and rebased onto Taproot (tapscript-only) via BIP PR
  #943 in July 2021.
- The BIP's Deployment section is still "TODO" — no mainnet activation parameters.

## Where it *is* deployed: Bitcoin Inquisition signet

Per co-author AJ Towns' Delving Bitcoin release posts:

- **APO has been active on the default public Inquisition signet since block 106704,
  dated 2022-09-06** (PR#84) — the concrete "anyprevout signet."
- It ships bundled with **CTV (BIP-119), OP_CAT (BIP-347), CSFS (BIP-348),
  OP_INTERNALKEY (BIP-349)**, and — as of Inquisition 29.2 (Feb 2026) — **BIP-54
  Consensus Cleanup**. APO + CTV active since Sept 2022; OP_CAT + CSFS since April 2025.
- As of the latest (Feb 2026) snapshot, APO **remains signet-only experimental**;
  transactions using it relay only among Inquisition-compatible nodes.
- Real-world signet usage is **light** — on the order of ~1,000 transactions (secondary
  figure, corroborated qualitatively by ajtowns' signet-activity observations).

## The activation debate: APO alone vs CTV+CSFS (LNHANCE)

The live covenant-activation conversation (as of a March 2025 Delving Bitcoin thread)
centers on **CTV+CSFS ("LNHANCE")** as a covenant "first step," **not** on activating
APO by itself:

- **Steven Roose** argues CTV+CSFS is "an equivalent for SIGHASH_ANYPREVOUT," enabling
  rebindable signatures / LN-Symmetry — but only emulates APO's ALL variant and costs
  extra witness bytes.
- **AJ Towns (APO co-author) is skeptical**: existing eltoo/LN-Symmetry research used
  APO plus the annex and custom relay rules, and no one has reproduced those results
  under CTV+CSFS. The dispute is **theoretical equivalence vs. demonstrated production
  utility.**
- **Greg Sanders (instagibbs)**, the main LN-Symmetry implementer, has for years
  declined to champion APO activation ("the community is pretty split"), preferring to
  build tooling (package relay, ephemeral anchors) first.

## Why APO has stalled (not a safety veto)

The stall is competitive, not a safety rejection:

1. Its flagship use case (eltoo/LN-Symmetry) can arguably be delivered by CTV+CSFS or
   the BIP-446/448 bundle **without** a new, replay-prone sighash flag.
2. APO "offers fewer use cases than CTV," weakening the case for spending scarce
   soft-fork consensus on it.
3. Lightning works today with LN-Penalty, so there is no urgency.
4. The broader post-2024 covenant stalemate and Speedy-Trial legitimacy debates dampen
   all covenant proposals.

See [[covenant-primitives-comparison|the covenant primitives comparison]] ([the covenant primitives comparison](../references/covenant-primitives-comparison.md))
for how APO stacks up against CTV / ANYONECANPAY / CSFS.

## Confidence & volatility

Marked `volatility: hot` — activation politics are fluid. The formal status (Draft,
signet-only) and the signet deployment facts are **high confidence** (primary sources,
including the co-author). Specific 2026 activation dates and miner-signaling
percentages are **low confidence** (single secondary source) and should be verified
before citing.

## See Also

- [[eltoo-ln-symmetry|eltoo / LN-Symmetry]] ([eltoo / LN-Symmetry](../concepts/eltoo-ln-symmetry.md)) — the use case driving (and failing to drive) activation
- [[covenant-primitives-comparison|Covenant primitives comparison]] ([Covenant primitives comparison](../references/covenant-primitives-comparison.md)) — CTV+CSFS as the competing path
- [[signature-replay-and-chaperone-signatures|Signature replay & chaperone signatures]] ([Signature replay & chaperone signatures](../concepts/signature-replay-and-chaperone-signatures.md)) — the historical safety concerns behind the caution
- [[coinbase-outpoint-presigning|Presigning against an unmined coinbase outpoint]] ([Presigning against an unmined coinbase outpoint](coinbase-outpoint-presigning.md)) — a use case gated on this not-yet-activated primitive

## Sources

- [BIP-118 normative spec](../../raw/articles/2026-07-16-bip-118-anyprevout-spec.md) — Draft status, authorship, lineage
- [Bitcoin Inquisition 29.1/29.2 signet status (ajtowns)](../../raw/articles/2026-07-16-delving-bitcoin-inquisition-29-signet-status.md) — signet activation block/date, bundle
- [CTV+CSFS first-step debate (Delving Bitcoin)](../../raw/articles/2026-07-16-delving-bitcoin-ctv-csfs-consensus-first-step.md) — the activation-path dispute
- [Chaincode Podcast — instagibbs](../../raw/articles/2026-07-16-chaincode-podcast-anyprevout-instagibbs.md) — implementer's activation reluctance
- [Spark — Covenant Proposals Compared](../../raw/articles/2026-07-16-spark-covenant-proposals-compared.md) — (low-confidence) 2026 activation figures
- [Optech — SIGHASH_ANYPREVOUT](../../raw/articles/2026-07-16-optech-anyprevout-topic.md) — naming/status history
