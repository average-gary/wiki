---
title: "clArk evolution — tree-signing, OOR, delegation, and the road to covenants"
type: topic
created: 2026-07-16
updated: 2026-07-17
confidence: high
volatility: hot
verified: 2026-07-17
sources:
  - raw/articles/2026-07-16-news-mainnet-launches.md
  - raw/articles/2026-07-16-evolution-unlock-liquidity-tree-signing.md
  - raw/articles/2026-07-16-evolution-adios-expiry-delegation.md
  - raw/articles/2026-07-17-second-docs-learn-glossary.md
  - raw/articles/2026-07-17-second-docs-learn-payments-on-chain.md
  - raw/articles/2026-07-17-bark-repo-docs-mailbox.md
  - raw/articles/2026-07-17-bark-repo-docs-addresses.md
  - raw/articles/2026-07-17-bark-repo-docs-offboard-swaps.md
tags: [ark, clark, evolution, timeline, tree-signing, oor, delegation, intents, hark, erk, mainnet, boat-001]
aliases: [Ark evolution, Ark timeline, Ark v2]
summary: "How clArk's round/exit mechanics have evolved toward reduced interactivity: per-branch tree signing, out-of-round payments, early liquidity release, delegation/intents, delegated refresh, and — the key 2026 milestone — the LIVE January-2026 hArk hash-lock enhancement (non-interactive refresh, immediate broadcast) plus cross-Ark standardization (V-PACK/MVV, BOAT-001)."
---

# clArk evolution — tree-signing, OOR, delegation, and the road to covenants

How covenantless Ark's round/exit mechanics have changed since the 2023 proposal, and where they are heading. Note "**Ark v2**" is *not* a formal named release — the v2-style evolution is the sum of the steps below ([[../../raw/articles/2026-07-16-news-mainnet-launches.md|launch report]]).

## Timeline (Optech + launch reports)

| Date | Milestone |
|---|---|
| 2023 | Ark proposed (managed joinpool) |
| 2024 | Ark demonstrated on mainnet |
| 2024-08 | Ark Labs $2.5M pre-seed |
| 2024-11 | Tree-signing optimization + OOR (Ark Labs blog) |
| 2025-02 | Ark Wallet SDK released |
| 2025-03 | `bark` on signet; Roose "The Ark case for CTV" |
| 2025-04 | hArk/Erk (CTV+CSFS) proposals |
| 2025-07 | Arkade Delegation/Intents; arkd v0.7.0 |
| 2025-10-20 | **Arkade public beta (mainnet)** |
| 2026-01 | **bark hArk hash-lock enhancement live** (non-interactive refresh, immediate on-chain broadcast; no soft fork) |
| 2026-03 | Ark Labs $5.2M (Tether); V-PACK/MVV standard proposed |
| 2026-06-09 | **Second's `bark` live on Bitcoin mainnet** |

## Reduced interactivity — the through-line

Every major change chips at clArk's core [[clark-limitations-and-trust.md|interactivity limitation]]:

1. **Per-branch tree signing** ([[../../raw/articles/2026-07-16-evolution-unlock-liquidity-tree-signing.md|Ark Labs, 2024-11]]): from each participant signing **(2n−1)** txs with ephemeral keys to each user signing only **~log₂(n)** txs with wallet keys. Cuts the signing burden and removes ephemeral-key management for that scheme.
2. **Out-of-Round (OOR / arkoor)** payments: instant P2P sends without a round, so receivers aren't forced into the synchronous ceremony; refreshed into a round later. See [[../concepts/out-of-round-payments.md|OOR]].
3. **Early liquidity release**: server reclaims pool liquidity before `T_exp` via user collaboration when sibling VTXOs are spent externally and settled.
4. **Delegation + Intents (Arkade, 2025-07)**: a third-party **delegate** auto-renews VTXOs within **BIP322**-signed authorized windows, removing the user's active-liveness burden without a covenant. Adds a third VTXO spend path `A+B+S` (user+delegate+server) and uses `SIGHASH_ALL|ANYONECANPAY` so delegates add inputs without changing outputs ([[../../raw/articles/2026-07-16-evolution-adios-expiry-delegation.md|Adios, Expiry]]). bark's equivalent is **delegated refresh** — designated co-signers refresh VTXOs "on the user's behalf," aimed at mobile devices ([[../../raw/articles/2026-07-17-second-docs-learn-glossary.md|bark glossary]]).
5. **hArk hash-lock enhancement (bark, live Jan 2026)**: the largest shipped interactivity reduction to date. hArk replaces connector-bound round forfeits with **hash-lock (preimage) forfeits**, which enables **non-interactive refresh** — the server can issue refreshed VTXOs a user simply picks up (e.g. from the planned Unified Mailbox) rather than co-signing synchronously — and makes on-chain payments **broadcast immediately upon completion** ([[../../raw/articles/2026-07-17-second-docs-learn-payments-on-chain.md|on-chain payments]], [[../../raw/articles/2026-07-17-bark-repo-docs-mailbox.md|mailbox]]). It runs on today's Bitcoin **without a soft fork**. The trade-off — hArk forfeits no longer commit to the whole funding tx — breaks in-round offboards, motivating **connector swaps** ([[../../raw/articles/2026-07-17-bark-repo-docs-offboard-swaps.md|offboard-swaps]]).

## The covenant horizon

hArk (as shipped) is a covenantless step. The fuller endgame for removing interactivity is a covenant soft fork — **Erk** (CTV+CSFS rebindable signatures → async signup + perpetual offline refresh) and the CTV-based hArk proposal. See [[clark-vs-covenant-ark.md|clArk vs covenant Ark]].

## Cross-implementation standardization

**V-PACK / Minimal Viable VTXO (MVV)** (Optech #395, 2026-03): a proposed stateless VTXO-verification standard to translate between Ark "dialects" (Arkade vs Bark) into a neutral format (`libvpack-rs`, vtxopack.org). Verifies unilateral-exit merkle paths; ASP-backdoor (path-exclusivity) detection flagged as future work — a signal the ecosystem is maturing toward interop despite the two divergent lineages.

A second standardization thread is **BOAT-001** (github.com/ark-protocol/boats), the first cross-Ark specification — it defines the bech32m **Ark address** format. "BOATs" are positioned as Ark's analogue to BIPs/BOLTs, reinforcing the convergence signal. See [[../concepts/ark-addresses-and-delivery.md|Ark addresses and delivery]].

## See also

- [[clark-round-transaction-mechanics.md|Round transaction mechanics]]
- [[clark-vs-covenant-ark.md|clArk vs covenant-based Ark]]
- [[clark-limitations-and-trust.md|Limitations and trust model]]
- [[../concepts/ark-addresses-and-delivery.md|Ark addresses and VTXO delivery]]
- [[../concepts/offboarding-and-onchain-payments.md|Offboarding and on-chain payments]]

## Sources

- [Mainnet launch report](../../raw/articles/2026-07-16-news-mainnet-launches.md) — timeline, "Ark v2" is not a formal release
- [Ark Labs — unlock liquidity / tree signing](../../raw/articles/2026-07-16-evolution-unlock-liquidity-tree-signing.md) — per-branch signing optimization, early liquidity release
- [Adios, Expiry — delegation](../../raw/articles/2026-07-16-evolution-adios-expiry-delegation.md) — delegation/intents, third VTXO spend path
- [Ark protocol glossary (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-glossary.md) — hArk as Jan 2026 enhancement; delegated refresh
- [On-chain payments (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-payments-on-chain.md) — immediate broadcast since the hArk update
- [Unified Mailbox (bark docs/mailbox.md)](../../raw/articles/2026-07-17-bark-repo-docs-mailbox.md) — non-interactive hArk refresh
- [Ark Addresses (bark docs/addresses.md)](../../raw/articles/2026-07-17-bark-repo-docs-addresses.md) — BOAT-001 cross-Ark spec
- [Offboard Swaps (bark docs/offboard-swaps.md)](../../raw/articles/2026-07-17-bark-repo-docs-offboard-swaps.md) — connector swaps prompted by hArk
