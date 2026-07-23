---
title: "BOLT #2 push_msat omitted from open_channel2 + bLIP-52 JIT fee-from-payment fusion"
source: "https://github.com/lightning/blips/blob/master/blip-0052.md"
raw_source: "https://raw.githubusercontent.com/lightning/blips/master/blip-0052.md"
source_secondary: "https://raw.githubusercontent.com/lightning/bolts/master/02-peer-protocol.md"
type: paper
subtype: spec
retrieved: 2026-07-23
verified_verbatim: true
tags: [lightning, bolt2, blip52, lsps2, jit-channel, push-msat, open-channel2, fee-deduction, inbound, fusion]
credibility: high
evidence_strength: spec
direction: "nuances (thesis #3) — the ONLY genuine payout+inbound fusion is JIT/on-the-fly (fee deducted from the incoming payment); pure dual-funding/splice CANNOT carry value to the miner because push_msat is omitted from open_channel2"
bears_on: [pool-provisions-miner-inbound-via-splice]
summary: "Two verified-verbatim spec facts that jointly decide thesis #3's 'unification in one footprint' claim. (1) BOLT #2 OMITS push_msat from open_channel2 ('Note that push_msat has been omitted.') — so in v2 dual-funding and in splicing there is NO field to assign the non-opener an initial balance; each side's balance = its own contribution. A pool contributing on its side gives the miner INBOUND CAPACITY but ZERO spendable value. (2) bLIP-52/LSPS2 JIT is the one construction that genuinely fuses provisioning with delivery: an incoming payment triggers a 0-conf channel open TOWARD the client, and the opening fee is deducted straight out of that payment via non-standard forwards. Default trust model is 'LSP trusts client'."
---

# push_msat omitted (BOLT #2) + bLIP-52 JIT fee-from-payment fusion

The two load-bearing facts for [[../../wiki/topics/pool-splices-toward-miner-verdict|thesis #3]],
**re-verified verbatim against `master` on 2026-07-23** by direct WebFetch of both raw
specs (not agent recall — the verdict pivots on these).

## A. `push_msat` is OMITTED from `open_channel2` (BOLT #2)

The v1 single-funded open defines the only opener-gifts-receiver primitive:

> "an amount of initial funds that the sender is unconditionally giving to the receiver"
> — (`open_channel`, v1, describing `push_msat`)

The v2 dual-funding open (the interactive-tx path liquidity ads and on-the-fly funding
use) explicitly drops it:

> "Note that `push_msat` has been omitted."
> — (`open_channel2` rationale)

And splicing credits only the contributor's own side (re-confirming the
[[2026-07-23-bolt2-splice-balance-direction|splice balance direction]] note):

> "`funding_contribution_satoshis` is the amount the sender is adding to their channel
> balance (splice-in) or removing from their channel balance (splice-out)."

> "MUST compute the channel balance for each side by adding their respective
> `funding_contribution_satoshis` to their previous channel balance."

**Why load-bearing:** in dual-funding v2 and in splicing there is **no mechanism for the
opener to assign the non-opener an initial balance**. Each side's balance = its own
contribution. So a pool contributing on its side provisions the miner's **inbound
capacity** but delivers **zero spendable value** to the miner. Value delivery must be a
*separate HTLC*. The only single tx that puts payout value directly on the miner's side is
legacy v1 `open_channel` with `push_msat` — which is funds moved to the *miner's* side
(outbound for the miner), the opposite of "funds on the pool's side," and is neither
dual-funded nor a splice. This is the spec-level reason the thesis's literal wording
("payouts settled as funds on the pool's side") is a **category error**.

## B. bLIP-52 / LSPS2 JIT — the one genuine fusion

JIT channels *do* fuse provisioning and delivery — because the incoming payment itself
triggers the open and pays the fee:

> "A 'JIT Channel' is a channel opened in response to an incoming payment from the public
> network to a client, via the LSP. This allows a client with no Lightning channels to
> start receiving on Lightning, and have the cost of their inbound liquidity be deducted
> from their first received payment."

> "The LSP recognizes the next hop SCID as being a JIT channel request, and opens a
> 0-confirmation channel to the client, which must be connected to the LSP at that time.
> The LSP forwards the payment to the client, deducting the channel opening fee."

> "The LSP generates non-standard forwards, where the amount received by the client is
> smaller than specified in the onion; the client MUST accept the non-standard forward(s),
> provided they sum to at least `payment_size_msat - opening_fee`."

Default trust posture:

> "The LSP SHOULD default to 'LSP trusts client' model."

**Why load-bearing:** the fusion is at the level of **one on-chain footprint and one
economic event** — but the funding tx supplies *capacity*, while the payout *value*
crosses as the forwarded (off-chain) HTLC that pushes balance onto the client's side. So
the thesis is right that provisioning and payment can be unified in one economic act with
the fee netted from the payout, but imprecise to say the *on-chain tx* "delivers the
payout." And bLIP-52 is a **wallet-LSP** spec with a zero-conf trust assumption — not a
mining-pool design.

Cross-refs:
[[../../wiki/concepts/pool-as-lsp-inbound-provisioning|pool-as-LSP provisioning]] ·
[[../../wiki/concepts/inbound-vs-outbound-liquidity|inbound vs outbound]] ·
[[2026-07-23-blip36-on-the-fly-funding|bLIP-36 on-the-fly funding]] ·
[[../../wiki/topics/pool-splices-toward-miner-verdict|thesis #3 verdict]]
