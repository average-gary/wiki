---
title: "Out-of-round (OOR / arkoor) payments"
type: concept
created: 2026-07-16
updated: 2026-07-17
confidence: high
volatility: warm
verified: 2026-07-17
sources:
  - raw/articles/2026-07-16-foundations-ark-protocol-org-docs.md
  - raw/articles/2026-07-16-foundations-optech-ark.md
  - raw/articles/2026-07-17-second-docs-learn-payments.md
  - raw/articles/2026-07-17-second-docs-learn-vtxo.md
  - raw/articles/2026-07-17-bark-repo-docs-addresses.md
tags: [ark, clark, oor, arkoor, offchain, payment, double-spend, co-signature, preconfirmed, statechain, offline-receiving]
aliases: [OOR, arkoor, out-of-round payment, spend VTXO, Ark out-of-round]
summary: "Instant P2P off-chain payments that create spend VTXOs via sender+server co-signature — the way to actually pay others, since clArk rounds cannot admit pure receivers. Enables offline receiving; secured like a statechain (trust the sender+server not to collude until you refresh); double-spend is deterred by detectability, reputation, collusion requirement, and fee-drain."
---

# Out-of-round (OOR / arkoor) payments

Because clArk rounds effectively [[dropout-and-round-abort.md|cannot admit pure receivers]], sending value to *another* person cannot rely on the round ceremony. **Out-of-Round (OOR)** payments — Second calls the resulting VTXOs **"arkoor"**; Arkade calls them **preconfirmed / offchain Arkade transactions** — are the instant P2P path ([[../../raw/articles/2026-07-16-foundations-ark-protocol-org-docs.md|ark-protocol.org]]).

## How it works

An OOR payment is an off-chain transfer that requires **co-signatures from both the sender and the ASP** (the VTXO's collaborative 2-of-2 path). It settles instantly off-chain; the recipient later **refreshes** the OOR VTXO into a future round to obtain a canonical batch-confirmed VTXO. arkd's offchain flow implements this via `SubmitTxRequest` / `FinalizeTxRequest` with [[checkpoint-transactions.md|checkpoint transactions]]. bark's term is literally "**Ark out-of-round**" — arkoor — and the resulting VTXO "extends board and refresh VTXOs" by adding new leaf transactions ([[../../raw/articles/2026-07-17-second-docs-learn-vtxo.md|bark VTXO docs]]). Payments are directed at [[ark-addresses-and-delivery.md|Ark addresses]] and delivered out-of-band since there is no off-chain mempool.

A stated headline benefit is **offline receiving**: because the sender and server co-sign, a payment can be created "at any time" without the recipient participating synchronously ([[../../raw/articles/2026-07-17-second-docs-learn-payments.md|bark payments]]). This is precisely the capability clArk rounds cannot offer.

## The trust caveat (statechain-like) and double-spend deterrents

OOR payments weaken the trust model relative to a batch-confirmed VTXO: "each payment transaction requires co-signatures from both the sender and the Ark operator, meaning receivers must trust that the sender will not collude with the operator to double-spend," and "any sender in the chain could collude with the operator to double-spend the entire chain" ([[../../raw/articles/2026-07-16-foundations-optech-ark.md|Optech]]). bark frames this as **state chain** security: the guarantee holds as long as *either* the sender or the server is honest. Refreshing into a round removes the exposure by anchoring the VTXO to an on-chain commitment tx — early refresh is more secure but costlier, late refresh cheaper but exposed for longer, and exposure is time-bounded because all VTXOs must refresh before ~30-day [[vtxo-lifetime-and-expiry.md|expiry]].

Even before refresh, bark enumerates four deterrents that make a double-spend unattractive ([[../../raw/articles/2026-07-17-second-docs-learn-payments.md|bark payments]]):

1. **Detection inevitability** — multiple refresh attempts reveal a double-spend; the duplicate signatures are publicly provable.
2. **Reputational risk** — a caught server loses its business.
3. **Collusion requirement** — it takes *both* the sender and the server; a lone party cannot do it.
4. **Fee consumption** — a competing emergency exit triggers transactions that drain the disputed VTXO in miner fees, so there is little left to steal.

## Payment chains and change

A received spend VTXO can be spent onward, forming a chain. **Change inherits the source VTXO's trust properties**: change from a trustless refresh VTXO is itself trustless (a sender "can't collude against themselves"), whereas change derived from a spend VTXO carries the same sender+server trust caveat. Because a payment's change VTXO shares a transaction with the recipient's VTXO, one party's exit can affect the other — the **neighbour-exit** problem that motivates [[checkpoint-transactions.md|checkpoint transactions]].

## See also

- [[clark-overview.md|clArk overview]]
- [[dropout-and-round-abort.md|Dropout and round abort]]
- [[clark-round-lifecycle.md|Round lifecycle]]
- [[checkpoint-transactions.md|Checkpoint transactions]]
- [[ark-addresses-and-delivery.md|Ark addresses and VTXO delivery]]
- [[lightning-integration.md|Lightning integration]]
- [[offboarding-and-onchain-payments.md|Offboarding and on-chain payments]]
- [[vtxo-lifetime-and-expiry.md|VTXO lifetime and expiry]]
- [[../topics/clark-limitations-and-trust.md|Limitations and trust model]]

## Sources

- [ark-protocol.org docs](../../raw/articles/2026-07-16-foundations-ark-protocol-org-docs.md) — OOR as the instant P2P path; arkoor / preconfirmed naming
- [Optech — Ark](../../raw/articles/2026-07-16-foundations-optech-ark.md) — the chained-payment double-spend trust gap
- [Ark payments / arkoor (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-payments.md) — offline receiving, four double-spend deterrents, payment chains and change inheritance
- [Ark VTXOs (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-vtxo.md) — spend VTXOs extend board/refresh; statechain security
- [Ark Addresses (bark docs/addresses.md)](../../raw/articles/2026-07-17-bark-repo-docs-addresses.md) — arkoor transactions directed at Ark addresses
