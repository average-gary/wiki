---
title: "Inbound vs outbound liquidity — why self-splice can't provision receive-side"
type: concept
created: 2026-07-23
updated: 2026-07-23
tags: [lightning, inbound-liquidity, outbound-liquidity, splicing, bolt12, liquidity-direction, category-error]
summary: "The load-bearing distinction for follow-up thesis #3. Outbound = your local balance = capacity to SEND; inbound = the counterparty's balance = capacity to RECEIVE. BOLT #2 credits a splice-in to the SENDER'S OWN balance, so splicing your own coinbase yields outbound only. Receiving a payment CONSUMES inbound. Therefore neither 'splice-in own funds' nor 'receive a BOLT12 payout' creates inbound — only a counterparty contributing funds on the far side (LSP / liquidity ad / dual fund / JIT) does."
---

# Inbound vs outbound liquidity

The distinction that decides [[../topics/splice-vs-bolt12-verdict|follow-up thesis #3]].
View is always **the miner's own node**.

| Term | = which side | Capacity to | Created by |
|------|-------------|-------------|-----------|
| **Outbound** | your **local** balance | **send** | *you* funding the channel / splicing **your** funds in |
| **Inbound** | the **counterparty's** balance | **receive** | *someone else's* funds landing on the far side |

Total capacity = local + remote = the funding-output amount.

## Spec proof: splice-in credits the sender's own side

BOLT #2, verified verbatim against `master` (2026-07-23):

> "`funding_contribution_satoshis` is the amount the sender is adding to their channel
> balance (splice-in) or removing from their channel balance (splice-out)."

> "MUST compute the channel balance for each side by adding **their respective**
> `funding_contribution_satoshis` to **their previous** channel balance."

There is **no** construction in which spending *your own* UTXO credits the
counterparty's side. So a miner splicing their own matured coinbase gains **outbound**,
never inbound. Source note:
[[../../raw/papers/2026-07-23-bolt2-splice-balance-direction|BOLT #2 splice balance direction]].

## Receiving consumes inbound, doesn't create it

When a node receives any Lightning payment (BOLT11 or BOLT12), an incoming HTLC settles:
the payer's (remote) balance moves to the receiver's **local** balance. Receiving
therefore **consumes inbound** and **produces outbound**. A miner who only ever receives
payouts monotonically drains inbound toward zero — and must already *have* inbound to
receive the first payout at all. (OCEAN's own top failure mode: "insufficient inbound
liquidity → add liquidity.")

## The category error

A miner who "wants LN liquidity **to receive payouts**" needs **inbound**. Neither
thesis option supplies it:

- **Splice-in own coinbase** → outbound only.
- **Receive a BOLT12 payout** → consumes inbound.

Inbound is provisioned only when a **counterparty** contributes funds on the far side:

- **Dual funding** — peer contributes at open ("immediately allowing spending in either
  direction").
- **Liquidity advertisements** (BOLT #7 `option_will_fund`) — seller leases inbound;
  settles "with either dual-funding **or splicing**."
- **LSPS1 / bLIP-51** — client purchases a channel; `lsp_balance_sat` = the LSP's side =
  client inbound.
- **LSPS2 / bLIP-52 (JIT)** — LSP opens a channel in response to an incoming payment, so
  "a client with no Lightning channels [can] start receiving."

Source note:
[[../../raw/articles/2026-07-23-inbound-liquidity-provisioning-lsp-liquidity-ads|inbound provisioning]].

## The one splice that *does* give the miner inbound

If the **counterparty** (an LSP or the pool) splices *its own* funds onto *its* side of
the shared channel — a liquidity-ad / lease settlement — the miner gains inbound. But
that is external funding (the OCEAN-style pattern), **not** the miner self-splicing their
own coinbase. The elegant convergence: a pool could open/refill a channel *toward* the
miner via splicing, making splice and off-chain-payout **complementary**, not rival.
