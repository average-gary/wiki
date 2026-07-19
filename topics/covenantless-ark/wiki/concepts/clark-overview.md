---
title: "clArk overview — covenantless Ark on today's Bitcoin"
type: concept
created: 2026-07-16
updated: 2026-07-17
confidence: high
volatility: hot
verified: 2026-07-17
sources:
  - raw/articles/2026-07-16-foundations-ark-protocol-org-docs.md
  - raw/papers/2026-07-16-foundations-ark-litepaper.md
  - raw/articles/2026-07-16-foundations-optech-ark.md
  - raw/articles/2026-07-16-news-mainnet-launches.md
  - raw/articles/2026-07-17-second-docs-learn-intro.md
  - raw/articles/2026-07-17-second-docs-learn-glossary.md
  - raw/articles/2026-07-17-bark-repo-readme.md
tags: [ark, clark, covenantless, hark, vtxo, asp, overview]
aliases: [clArk, covenantless Ark, covenant-less Ark, Ark protocol]
summary: "Orientation for the whole wiki: Ark is a Bitcoin L2 where many users share one on-chain UTXO via a tree of pre-signed off-chain transactions coordinated by an ASP; value is held as VTXOs. clArk is the covenantless variant that swaps OP_CTV for an n-of-n MuSig2 pseudo-covenant (1-of-n honesty). Two production implementations: Second's bark (Rust; hArk hash-lock enhancement live Jan 2026) and Ark Labs' arkd/Arkade (Go)."
---

# clArk overview — covenantless Ark on today's Bitcoin

**Ark** is a Bitcoin Layer-2 protocol in which many users share control of a single on-chain UTXO through a tree of pre-signed, off-chain transactions coordinated by an **Ark Service Provider (ASP / operator / server)**. Value held off-chain is represented as a **Virtual UTXO (VTXO)**.

**Covenantless Ark ("clArk")** is the variant that runs on Bitcoin *as it exists today* — no soft fork, no `OP_CHECKTEMPLATEVERIFY` (CTV) or other covenant opcode. Where covenant-based Ark uses a covenant to constrain how a shared output may be spent, clArk substitutes an **n-of-n multisignature "pseudo-covenant"**: all parties affected create a multisig, **pre-sign** the intended spend tree, and (for refreshes) **delete their signing keys** so no alternative spend can ever be produced ([[../../raw/articles/2026-07-16-foundations-ark-protocol-org-docs.md|ark-protocol.org]], [[../../raw/papers/2026-07-16-foundations-ark-litepaper.md|Ark litepaper §3.2]]).

## The covenant substitution in one line

> "A simple example of a covenant would be an *n-of-n* multi-signature output script, in which the *n* signers agree to only sign transactions that spend the output in a prearranged way. Note that this covenant relies on at least 1 out of the *n* signers to stick to the arrangement." — Ark litepaper §3.2

The security of clArk therefore rests on a **1-of-n honesty assumption**: it holds "as long as at least one user in the entire group commits to deleting their key." A real covenant (CTV) removes even that assumption — which is why covenantless Ark is framed by its own designers as the *inferior efficiency fallback* pending a covenant soft fork ([[../../raw/articles/2026-07-16-foundations-optech-ark.md|Optech]]).

## What clArk is made of

- **The round** (a.k.a. batch swap): a periodic ceremony where the ASP and participating users jointly build and sign a tree, then the ASP broadcasts its root on-chain. See [[clark-round-lifecycle.md|round lifecycle]].
- **The n-of-n batch/pool output**: the single on-chain output the round produces, spendable either by unrolling the tree or by the ASP after expiry. See [[n-of-n-batch-output.md|batch output]].
- **The VTXO tree**: the pre-signed transaction tree that subdivides the batch output into individual VTXOs. See [[vtxo-and-vtxo-tree.md|VTXOs and the tree]].
- **Tree presigning**: the MuSig2 signing session + ephemeral-key deletion that emulates the covenant. See [[tree-presigning-musig2.md|tree presigning]].
- **Forfeits and connectors**: how a user hands an old VTXO back to the ASP atomically with receiving a new one. See [[forfeit-and-connectors.md|forfeits and connectors]].
- **Dropout / round abort**: what happens when a participant goes offline mid-round. See [[dropout-and-round-abort.md|dropout]].
- **Unilateral exit and timeouts**: the timeout-driven refund path if the ASP disappears. See [[unilateral-exit-and-timeouts.md|unilateral exit]].
- **Boarding**: getting on-chain funds into a VTXO. See [[boarding.md|boarding]].
- **Out-of-round (arkoor) payments**: instant P2P sends, since rounds can't admit pure receivers. See [[out-of-round-payments.md|OOR payments]].
- **Offboarding & on-chain payments**: the cooperative single-tx way out. See [[offboarding-and-onchain-payments.md|offboarding]].
- **Lightning integration**: the ASP as a Lightning gateway. See [[lightning-integration.md|Lightning integration]].
- **VTXO lifetime & liquidity**: why VTXOs expire and what refresh costs. See [[vtxo-lifetime-and-expiry.md|VTXO lifetime and expiry]].
- **Ark addresses & delivery**: bech32m addresses and VTXO delivery. See [[ark-addresses-and-delivery.md|Ark addresses and delivery]].

## Two production implementations

clArk exists in two independently-built lineages, which use different terminology and made different design choices ([[../../raw/articles/2026-07-16-news-mainnet-launches.md|launch report]], [[../../raw/articles/2026-07-17-bark-repo-readme.md|bark README]]):

| | **Second — `bark`** | **Ark Labs — `arkd` / Arkade** |
|---|---|---|
| Language | Rust | Go |
| Components | wallet `bark`, server `captaind` (a.k.a. `barkd` REST daemon) | `arkd` |
| Round term | "round" / "round transaction" | "batch swap" / "commitment transaction" |
| VTXO tree radix | **quad tree (radix 4)** | binary (radix 2) |
| Round-forfeit atomicity | **hash-lock (preimage)** | **connector output** |
| VTXO lifetime (default) | ~28-30 days (~3 d Lightning-receive) | ~7 days (604672 s) |
| Milestone | mainnet 2026-06-09; **hArk hash-lock enhancement live Jan 2026** | public beta 2025-10-20 |

Both implement the same n-of-n MuSig2 presigned-tree core; see [[../reference/clark-glossary-and-timelocks.md|glossary + timelock reference]] for the full terminology map.

## hArk is live (not just a proposal)

An important 2026 correction: "**hArk**" now names a **shipped** hash-lock enhancement in bark — introduced in the **January 2026 hArk update** — not merely a future CTV proposal. bark's glossary defines clArk as an implementation variant using "recursive multisigs instead of CTV covenants," and hArk as a January-2026 protocol enhancement ([[../../raw/articles/2026-07-17-second-docs-learn-glossary.md|bark glossary]]). The live hArk replaces connector-bound round forfeits with **hash-lock forfeits**, enables **non-interactive refresh**, and makes on-chain payments broadcast immediately — all **without a soft fork**. The fuller CTV/CSFS covenant successors (Erk, and CTV-assisted variants) remain proposals. See [[../topics/clark-vs-covenant-ark.md|clArk vs covenant-based Ark]].

## See also

- [[clark-round-lifecycle.md|Round lifecycle]]
- [[out-of-round-payments.md|Out-of-round (arkoor) payments]]
- [[lightning-integration.md|Lightning integration]]
- [[vtxo-lifetime-and-expiry.md|VTXO lifetime and expiry]]
- [[ark-addresses-and-delivery.md|Ark addresses and VTXO delivery]]
- [[../topics/clark-round-transaction-mechanics.md|Round transaction mechanics (synthesis)]]
- [[../topics/clark-vs-covenant-ark.md|clArk vs covenant-based Ark]]
- [[../topics/clark-limitations-and-trust.md|Limitations and trust model]]

## Sources

- [ark-protocol.org docs](../../raw/articles/2026-07-16-foundations-ark-protocol-org-docs.md) — the pseudo-covenant framing
- [Ark litepaper §3.2](../../raw/papers/2026-07-16-foundations-ark-litepaper.md) — the n-of-n covenant and 1-of-n honesty assumption
- [Optech — Ark](../../raw/articles/2026-07-16-foundations-optech-ark.md) — covenantless-as-fallback
- [Mainnet launch report](../../raw/articles/2026-07-16-news-mainnet-launches.md) — the two implementations and their milestones
- [Intro to the Ark protocol (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-intro.md) — client-server model, VTXO types, ~30-day lifetime
- [Ark protocol glossary (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-glossary.md) — clArk = recursive multisigs; hArk = Jan 2026 enhancement
- [bark repository README](../../raw/articles/2026-07-17-bark-repo-readme.md) — bark/captaind components, positioning vs Lightning
