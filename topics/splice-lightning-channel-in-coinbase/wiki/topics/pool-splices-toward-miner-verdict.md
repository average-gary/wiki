---
title: "Verdict: can a pool provision miner inbound by settling payouts as toward-miner splices?"
type: topic
created: 2026-07-23
updated: 2026-07-23
tags: [lightning, lsp, mining-pool, inbound-liquidity, on-the-fly-funding, jit-channel, splicing, dual-funding, verdict, thesis3]
summary: "Follow-up thesis #3 verdict. Claim: a pool can provision miners' INBOUND LN liquidity by settling payouts as liquidity-ad/dual-funded/splice txs TOWARD each miner (funds on the pool's side), unifying payout delivery and inbound provisioning in one on-chain footprint. Verdict: PARTIALLY SUPPORTED / High. The mechanism is real, spec'd (bLIP-36/52, liquidity ads, interactive-tx batching) and DEPLOYED as wallet-LSPs (Phoenix/eclair #2861). But the literal 'funds on the pool's side = payout' wording is a category error (push_msat omitted from open_channel2 → no single tx carries both inbound-for-miner and payout-value-to-miner); the genuine unification is JIT/on-the-fly, where an incoming payment triggers the open and the fee is netted from it (on-chain tx = capacity, value = off-chain HTLC). And NO mining pool does this — only wallet-LSPs; it is a novel, unbuilt synthesis, gated by fee incidence, coinbase maturity, custody, and whether the miner will use the inbound."
---

# Verdict — pool provisions miner inbound via toward-miner splices

Follow-up **thesis #3** (surfaced by [[splice-vs-bolt12-verdict|thesis #2's verdict]]):

> A mining pool can provision its miners' **inbound** Lightning liquidity by settling
> payouts as liquidity-ad / dual-funded / splice transactions **toward** each miner (funds
> contributed on the pool's side), **unifying** payout delivery and inbound provisioning in
> **one on-chain footprint**.

**Verdict: Partially Supported — High confidence.** The mechanism is real, specified, and
deployed as a wallet-LSP; the literal wording contains a category error; and no *mining
pool* actually does it.

## The three claims inside the thesis

The sentence bundles a **mechanism** claim, a **unification** claim, and a **deployment**
claim. They resolve differently:

| Claim | Verdict | Why |
|-------|---------|-----|
| **Mechanism** — a pool can contribute on its side of a toward-miner channel to give the miner inbound | **Supported** | BOLT #2 credits each contribution to the contributor's own side; interactive-tx lets the pool fund 100%. Liquidity ads settle "with either dual-funding or splicing." |
| **Unification** — payout delivery + inbound provisioning in **one on-chain footprint** | **Supported only in the JIT/on-the-fly reading** | Genuine in bLIP-36/52: an incoming payment triggers the open and the fee is netted from it. But the on-chain tx supplies *capacity*; the *value* crosses as an off-chain HTLC. Literally ("funds on the pool's side = the payout") it's a **category error** — `push_msat` is omitted from `open_channel2`, so no single tx puts payout value on the miner's side while also giving them inbound. |
| **Deployment** — a mining **pool** does this | **Contradicted (today)** | Deployed only as **wallet-LSPs** (Phoenix/phoenixd, eclair #2861). No mining pool does it; OCEAN does the opposite. A novel, unbuilt synthesis. |

## Why the literal wording is a category error

Within one 2-of-2 funding output, sats are **either** on the pool's side (the miner's
inbound — but the pool still owns them; not a payout) **or** pushed to the miner's side (a
payout — but the miner's *outbound*; not inbound). You cannot make the *same satoshis* be
both. The spec closes the only loophole: `push_msat` (the sole "opener gifts receiver
initial balance" primitive) is **omitted from `open_channel2`** and has no splice analogue
(verified verbatim, [[../concepts/pool-as-lsp-inbound-provisioning|pool-as-LSP]]). So in
pure dual-funding/splice, contributing on the pool's side provisions **capacity only** —
the payout must be a *separate* value movement.

## What makes it genuinely hold (the JIT/on-the-fly reading)

[[../../raw/papers/2026-07-23-blip36-on-the-fly-funding|bLIP-36]] /
[[../../raw/papers/2026-07-23-blip52-jit-and-pushmsat-omitted|bLIP-52 JIT]] fuse the two
because the **incoming payment itself** triggers the open and pays the fee. One on-chain
footprint, one economic event. Correctly stated: the funding tx supplies **inbound
capacity**; the payout **value** crosses as the forwarded off-chain HTLC (fee netted via
`funding_fee`/`extra_fee` TLV, non-standard forwards). This is deployed —
[[../../raw/articles/2026-07-23-eclair-2861-phoenix-on-the-fly-deployed|eclair #2861 /
Phoenix]] — but as a wallet-LSP, with the receiver paying the mining fee.

## Conditions map (when does it hold?)

| Condition | Holds? |
|-----------|--------|
| Read literally: "payout = funds on the pool's side" | **No** — category error; the miner is unpaid, only given inbound |
| Read as JIT/on-the-fly: one economic act, fee netted from the payout | **Yes** — spec'd + deployed (as wallet-LSP) |
| Miner has **no** channel | Holds via JIT-open / dual-funded open toward the miner |
| Miner **has** a channel | Holds via pool-initiated splice-in top-up (needs quiescence + both peers live) |
| **Scale** — batch many miners into few txs | **Yes, per spec + impl** (interactive-tx multi-open, LSPS1 batch, LND `BatchOpenChannel`, CLN multi-splice) — but atomic batches abort on any peer failure |
| Fee borne by the **miner** | **Weakens/flips** — miner net-worse than a plain payout unless they'll *use* the inbound |
| Fee borne by the **pool** | Holds — but it's a pool subsidy competing with just paying on-chain/BOLT12 |
| Funded from the **fresh coinbase** | **No** — `COINBASE_MATURITY = 100` (~16.7 h unenforceable + reorg) |
| Funded from **matured treasury** | Holds on consensus — but the pool fronts working capital |
| Miner just wants to be **paid and hold** | **Pointless** — standing inbound is deadweight; JIT-on-first-payout already covers a one-off receive |
| Miner wants to **receive future LN payments** | **Worth it** — inbound is genuinely used; fee amortizes |
| Custody-sensitive miner wanting max sovereignty | **Weakens** — pool-as-LSP concentrates more trust (zero-conf + capital fronting) than TIDES' non-custodial coinbase payout |

## Footprint vs thesis #2's BOLT12

Not a head-to-head: provisioning is one-time/occasional **capex** (O(1 tx per batch));
BOLT12 payouts are recurring **opex** at **zero** on-chain per payout. On-chain
provisioning only "wins" if the miner reuses the inbound many times. They operate at
different layers — the same "complementary, not rivals" conclusion as thesis #2.

## Verdict

**Status: Partially Supported — High confidence.**

- **Mechanism: real and deployed** (bLIP-36/52, liquidity ads; Phoenix/eclair #2861), with
  scale achievable via batching.
- **Unification: precise only in the JIT/on-the-fly reading** — an incoming payment
  triggers the open and the fee is netted from it (on-chain tx = capacity; value =
  off-chain HTLC). The literal "funds on the pool's side = payout" wording is a **category
  error** (`push_msat` omitted from `open_channel2`).
- **A mining pool doing this: unbuilt.** Deployed only as wallet-LSPs; OCEAN does the
  opposite. Genuinely **novel**, gated by fee incidence, coinbase maturity, custody, and
  whether the miner will actually *use* the inbound.

**What would change it:** a deployed mining pool running the LSP role (e.g. on
[[../../../ldk-server/_index|ldk-server]] / CLN) that opens or splices toward miners and
nets the fee from the payout, funded from matured treasury, for miners who are genuine
receivers — would move the deployment claim from Contradicted to Supported. The mechanism
and scale are already there.

## Cross-links

- [[../concepts/pool-as-lsp-inbound-provisioning|pool-as-LSP inbound provisioning]] — the mechanism.
- [[../concepts/inbound-vs-outbound-liquidity|inbound vs outbound liquidity]] — the direction rule this builds on.
- [[splice-vs-bolt12-verdict|thesis #2 verdict]] — surfaced this thesis; complementary-not-rivals conclusion.
- [[../../../bitcoin-mining-payout-schemas/_index|bitcoin-mining-payout-schemas]] — custody spectrum, which schemas deliver over LN.
- [[../../../ldk-server/_index|ldk-server]] — the concrete pool-side node that would run the LSP role.
- [[../../../ark-boarding-sv2-mining/_index|ark-boarding-sv2-mining]] — the batch-atomicity / receiver-only / maturity parallels.
