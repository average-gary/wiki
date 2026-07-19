---
title: "clArk vs covenant-based Ark (CTV / CSFS)"
type: topic
created: 2026-07-16
updated: 2026-07-17
confidence: high
volatility: hot
verified: 2026-07-17
sources:
  - raw/papers/2026-07-16-foundations-ark-litepaper.md
  - raw/articles/2026-07-16-dropout-roose-delving-ark-case-for-ctv.md
  - raw/articles/2026-07-16-foundations-roose-delving-clark-policies.md
  - raw/articles/2026-07-16-evolution-roose-hark-erk.md
  - raw/articles/2026-07-16-foundations-optech-ark.md
  - raw/articles/2026-07-17-second-docs-learn-glossary.md
  - raw/articles/2026-07-17-second-docs-learn-payments-on-chain.md
  - raw/articles/2026-07-17-bark-repo-docs-offboard-swaps.md
  - raw/articles/2026-07-17-bark-repo-docs-mailbox.md
tags: [ark, clark, ctv, csfs, hark, erk, covenant, rebindable-signatures, comparison, hashlock]
aliases: [hArk, Erk, covenant Ark, CTV Ark]
summary: "How a covenant (CTV/CSFS) would change clArk's round mechanics, and where the covenant successors stand — with the key 2026 correction that bark shipped a hash-lock hArk enhancement in January 2026 (live, no soft fork), while the CTV/CSFS-dependent Erk and full hArk remain proposals pending a soft fork."
---

# clArk vs covenant-based Ark (CTV / CSFS)

Covenantless Ark is explicitly framed — by its own designers and by Bitcoin Optech — as the **inferior fallback** available *today*, pending a covenant soft fork. This article maps what a covenant would change about the [[clark-round-transaction-mechanics.md|round mechanics]].

> **2026 status correction.** The "hArk" name now refers to two related-but-distinct things, and the earlier framing of hArk as a purely *future, CTV-dependent proposal* is out of date. Bark shipped a **hash-lock "hArk" enhancement that is LIVE since January 2026** — running on today's Bitcoin with **no soft fork** — which replaces connector-based round forfeits with **hash-lock (preimage) forfeits** and enables **non-interactive refresh** and immediate-broadcast on-chain payments. The fuller covenant-based successors (**Erk**, and CTV-assisted variants) that would remove *all* user interactivity **remain proposals pending a soft fork**. Sources below reflect both the original proposal framing and the shipped January-2026 reality; where they diverge, the shipped bark behavior is authoritative for what exists today.

## The core difference in one table

| Property | **clArk (covenantless, today)** | **Ark with CTV / CSFS** |
|---|---|---|
| Tree structure enforced by | n-of-n MuSig2 **pre-signature** + ephemeral-key deletion | **covenant opcode** (`OP_CTV`) |
| Trust assumption | 1-of-n honest key-deletion | none (covenant is unconditional) |
| Receiver must be online for issuance | **Yes** — "co-signed VTXOs cannot be issued without the presence of the eventual owner" | No — server can issue from parameters |
| Send-to-others in a round | Effectively **no** (receiver-DoS); use OOR | Yes |
| Offline / server-side refresh | **No** | Yes (Erk: "perpetual offline refresh") |
| Client-side exit-data storage | **Required** (lose it → no exit) | Not required |
| Scalability / users per round | Limited by synchronous n-of-n | "significantly more users" (Optech) |
| Fee efficiency | Lower | Higher |

Sources: [[../../raw/articles/2026-07-16-dropout-roose-delving-ark-case-for-ctv.md|Roose, Delving #1528]], [[../../raw/articles/2026-07-16-foundations-roose-delving-clark-policies.md|Delving #1602]], [[../../raw/articles/2026-07-16-evolution-roose-hark-erk.md|roose.io hArk/Erk]], [[../../raw/articles/2026-07-16-foundations-optech-ark.md|Optech]].

## Why the covenant matters — the litepaper framing

An n-of-n multisig covenant "relies on at least 1 out of the *n* signers to stick to the arrangement." New opcodes "would allow for stronger covenants that do not require this 1-of-*n* honesty assumption," but "would require a Bitcoin soft fork." The litepaper deliberately builds Ark "purely with the means that are currently available in Bitcoin Script" ([[../../raw/papers/2026-07-16-foundations-ark-litepaper.md|litepaper §3.2]]).

## The covenant successors (Roose) — and what actually shipped

- **Erk** ("Ark, by Erik") — uses **CTV + CSFS "rebindable signatures"** (APO-like: "signatures don't commit to the input utxos"). Enables asynchronous single-user round signup (submit a new pubkey `A'` + a signed refund tx) and **perpetual offline refresh** (server chains refreshes recursively). Removes synchronous user participation from rounds entirely. **Still a proposal — needs a soft fork.**
- **hArk** ("hash-lock Ark") — the proposal, as originally described, needs **only CTV, not CSFS**: the server generates per-VTXO secrets; users sign forfeit txs letting the server claim inputs by revealing secrets, eliminating tree-unrolling costs and handling multiple inputs efficiently.

Both were pitched to "remove all need for user interactivity in rounds" — the central limitation of clArk. Even Erk retains a residual exit cost: to exit the server "has to unroll the entire new vtxo's tx tree branch," which is "particularly problematic for onboard vtxos."

### What bark actually shipped in January 2026

Second's `bark` deployed a **hash-lock hArk enhancement that is live on mainnet without a soft fork**. Its glossary defines hArk plainly as "a protocol enhancement introduced in January 2026" ([bark glossary](../../raw/articles/2026-07-17-second-docs-learn-glossary.md)). Concretely, the shipped hArk:

- **Replaces connector-based round forfeits with hash-lock (preimage) forfeits**: a forfeit now "commit[s] only to a single unlock preimage/hash," not to the entire round funding tx ([offboard-swaps](../../raw/articles/2026-07-17-bark-repo-docs-offboard-swaps.md)). See [[../concepts/forfeit-and-connectors.md|forfeits and connectors]].
- **Enables non-interactive refresh**: the server can issue refreshed VTXOs that a user simply picks up (e.g. from the planned Unified Mailbox), rather than co-signing synchronously ([mailbox](../../raw/articles/2026-07-17-bark-repo-docs-mailbox.md)). See [[../concepts/ark-addresses-and-delivery.md|Ark addresses and delivery]].
- **Makes on-chain payments broadcast immediately upon completion** ([on-chain payments](../../raw/articles/2026-07-17-second-docs-learn-payments-on-chain.md)). See [[../concepts/offboarding-and-onchain-payments.md|offboarding and on-chain payments]].

The trade-off: because the hArk forfeit no longer commits to the whole funding tx, the old trick of bundling an offboard into a round breaks, motivating **connector swaps** to keep offboards instant. So hArk is best read as a **shipped, incremental, covenantless step** toward the reduced-interactivity endgame — not the full CTV/CSFS covenant future, which still awaits a soft fork.

## What clArk does NOT fix

A common misconception is that unilateral-exit liveness is a clArk-specific defect. It is not: "clArk doesn't improve this fundamental requirement" — *all* Ark variants require the user to come online before `T_exp` to refresh or exit. What clArk *adds* on top is the mandatory **synchronous n-of-n signing session** for issuance/refresh ([[../../raw/articles/2026-07-16-evolution-roose-hark-erk.md|roose.io]]).

## See also

- [[clark-round-transaction-mechanics.md|Round transaction mechanics]]
- [[clark-limitations-and-trust.md|Limitations and trust model]]
- [[clark-evolution.md|Evolution]]
- [[../concepts/tree-presigning-musig2.md|Tree presigning (MuSig2)]]
- [[../concepts/forfeit-and-connectors.md|Forfeit transactions and connectors]] — hArk changes forfeits from connector-bound to hash-lock-bound
- [[../concepts/offboarding-and-onchain-payments.md|Offboarding and on-chain payments]] — the live-hArk immediate-broadcast and connector-swap changes

## Sources

- [Ark litepaper §3.2](../../raw/papers/2026-07-16-foundations-ark-litepaper.md) — the 1-of-n honesty assumption and the soft-fork framing
- [Roose, Delving #1528 — the Ark case for CTV](../../raw/articles/2026-07-16-dropout-roose-delving-ark-case-for-ctv.md) — why receivers need a covenant; scalability contrast
- [Roose, Delving #1602 — clArk policies](../../raw/articles/2026-07-16-foundations-roose-delving-clark-policies.md) — recursive n-of-n signing as the clArk-specific cost
- [roose.io — hArk / Erk](../../raw/articles/2026-07-16-evolution-roose-hark-erk.md) — the original Erk/hArk proposals and residual exit cost
- [Optech — Ark](../../raw/articles/2026-07-16-foundations-optech-ark.md) — clArk-as-fallback framing, users-per-round
- [Ark protocol glossary (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-glossary.md) — hArk defined as a January 2026 enhancement; clArk = recursive multisigs vs CTV
- [On-chain payments (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-payments-on-chain.md) — immediate broadcast "as of the January 2026 hArk update"
- [Offboard Swaps (bark docs/offboard-swaps.md)](../../raw/articles/2026-07-17-bark-repo-docs-offboard-swaps.md) — hArk forfeits commit only to a preimage/hash
- [Unified Mailbox (bark docs/mailbox.md)](../../raw/articles/2026-07-17-bark-repo-docs-mailbox.md) — non-interactive hArk refresh delivery
