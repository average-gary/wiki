---
title: "Ark addresses and VTXO delivery (bech32m, BOAT-001, mailbox)"
type: concept
created: 2026-07-17
updated: 2026-07-17
confidence: medium
volatility: hot
verified: 2026-07-17
sources:
  - raw/articles/2026-07-17-bark-repo-docs-addresses.md
  - raw/articles/2026-07-17-bark-repo-docs-mailbox.md
tags: [ark, clark, bark, address, bech32m, boat-001, vtxo-policy, mailbox, delivery, privacy]
aliases: [Ark address, ark1, tark1, BOAT-001, Unified Mailbox, VTXO delivery]
summary: "How value is addressed and delivered inside an Ark: bech32m Ark addresses (ark1/tark1) specified by the cross-Ark BOAT-001, encoding a server-pubkey hash + VTXO policy + delivery methods; and the (mostly planned) Unified Mailbox that notifies a user of new VTXOs without per-pubkey polling."
---

# Ark addresses and VTXO delivery (bech32m, BOAT-001, mailbox)

> Because an Ark has no off-chain mempool, receiving a payment is not just "someone spends to my script" — the cosigned [[out-of-round-payments|arkoor]] ([out-of-round](../concepts/out-of-round-payments.md)) VTXO has to be *delivered* to the recipient out-of-band. An **Ark address** is the bech32m string that tells a sender which Ark the recipient is on, what VTXO to build, and how to hand it over; the **Unified Mailbox** is bark's optional notification hub that makes that delivery reliable without the recipient polling every key.

## The Ark address format

Payments between users of the same Ark are **arkoor transactions**, and they are directed at **Ark addresses** ([bark docs/addresses.md](../../raw/articles/2026-07-17-bark-repo-docs-addresses.md)):

- **Encoding**: **bech32m** (the same encoding as native SegWit v1 / Taproot bitcoin addresses), with human-readable prefix **`ark1`** on mainnet and **`tark1`** on test networks.
- **Standardization**: the format is defined by **BOAT-001**, the first in a universal repository of **cross-Ark specifications** (`github.com/ark-protocol/boats`). "BOATs" are to Ark roughly what BIPs are to Bitcoin or BOLTs are to Lightning — a new primitive signalling that the two divergent implementation lineages are converging on shared standards (see [[clark-evolution|evolution]] ([evolution](../topics/clark-evolution.md)) for the parallel V-PACK/MVV effort).

## What the address encodes

An Ark address commits to **three** things:

1. **Ark server identifier** — a **4-byte hash of the server's fixed main public key**. A sender can compare this against its own server to tell whether the recipient is on the *same* Ark (a cheap intra-Ark arkoor) or a different one (which needs a cross-Ark path).
2. **VTXO policy** — the spend condition under which the recipient wants to receive. Today this is the simple **`Pubkey`** policy (receive to the user's public key). The format is designed to carry richer policies in future: multisig, or generalized **miniscript**-based policies.
3. **VTXO delivery methods** — *how* the freshly cosigned arkoor VTXO should reach the recipient.

The presence of an explicit **VTXO policy** field is what makes the address more than a key: it is the receiver's half of the [[vtxo-and-vtxo-tree|VTXO script]] ([VTXO script](../concepts/vtxo-and-vtxo-tree.md)) that the sender and server will build.

## Delivery — why it needs its own mechanism

There is **no off-chain mempool** in an Ark, so a newly created arkoor VTXO does not simply "appear" to the recipient the way a broadcast bitcoin transaction does. Someone has to notify the recipient that new money exists and hand them the presigned data they need to hold (and eventually to [[unilateral-exit-and-timeouts|exit]] ([exit](../concepts/unilateral-exit-and-timeouts.md))).

- **Default**: the **server acts as a message-passer**, notifying users of VTXOs addressed to them.
- **Trust concern**: a user may not want to depend on the server for delivery, so the address can list **multiple** receive methods. This keeps delivery from becoming a single point of censorship.

## The Unified Mailbox (mostly planned)

The **Unified Mailbox** is an optional bark-server feature that acts as a per-user notification hub. Its stated benefit is that **all of a user's VTXOs are found together**, so a wallet need not poll separately per receive-pubkey; the server can push a notification whenever something lands in the mailbox ([bark docs/mailbox.md](../../raw/articles/2026-07-17-bark-repo-docs-mailbox.md)). The doc is explicit that **most of the mailbox is planned, not yet shipped**.

Planned mailbox event types:

- receiving **arkoor** payments;
- receiving **BOLT-11** invoice payments and **BOLT-12** invoice requests (see [[lightning-integration|Lightning integration]] ([Lightning integration](../concepts/lightning-integration.md)));
- receiving new VTXOs after a **non-interactive hArk refresh** — corroborating that the now-live [[clark-vs-covenant-ark|hArk]] ([hArk](../topics/clark-vs-covenant-ark.md)) enhancement lets the server issue refreshed VTXOs that the user simply *picks up*, rather than co-signing synchronously;
- creating arkoor addresses with a **blinded mailbox ID**.

### Privacy property

The mailbox "gives privacy from the public, but **not** from the Ark server." Using it, the server can **link all of a user's Ark activity together**, but the *counterparties* a user transacts with cannot link any of that user's other payments. This is the standard client-server privacy trade-off — the operator is a trusted observer, outsiders are not.

## See Also

- [[out-of-round-payments|Out-of-round (OOR / arkoor) payments]] ([Out-of-round payments](../concepts/out-of-round-payments.md)) — the payment type that Ark addresses direct and the mailbox delivers
- [[lightning-integration|Lightning integration]] ([Lightning integration](../concepts/lightning-integration.md)) — BOLT-11/12 receiving is a planned mailbox event
- [[clark-overview|clArk overview]] ([clArk overview](../concepts/clark-overview.md)) — where addressing sits in the whole system
- [[clark-evolution|clArk evolution]] ([clArk evolution](../topics/clark-evolution.md)) — BOAT-001 and cross-Ark standardization
- [[clark-glossary-and-timelocks|Glossary + timelock reference]] ([timelock reference](../reference/clark-glossary-and-timelocks.md)) — Ark address / BOAT / mailbox terms

## Sources

- [Ark Addresses (bark docs/addresses.md)](../../raw/articles/2026-07-17-bark-repo-docs-addresses.md) — bech32m format, BOAT-001, the three encoded fields, delivery methods
- [Unified Mailbox (bark docs/mailbox.md)](../../raw/articles/2026-07-17-bark-repo-docs-mailbox.md) — planned mailbox features, privacy model, non-interactive hArk-refresh delivery
