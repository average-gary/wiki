---
title: "Coinbase maturity vs LN enforceability"
type: concept
created: 2026-07-23
updated: 2026-07-23
confidence: high
tags: [coinbase-maturity, force-close, enforceability, reorg, zero-conf, lightning-safety]
---

# Coinbase maturity vs LN enforceability

The decisive constraint on [[three-readings|Reading B]]. It is orthogonal to — and
survives — the [[presigning-unknown-coinbase-outpoint|post-block-found signing]]
trick that saves the sibling Ark thesis.

## The rule

`COINBASE_MATURITY = 100` (`consensus/consensus.h`). A coinbase output "cannot be
spent … for at least 100 blocks." A tx spending a coinbase output `< 100` deep is
rejected at mempool (`bad-txns-premature-spend-of-coinbase`) and invalid under
consensus if mined (`TX_PREMATURE_SPEND`, "tried to spend coinbase at depth X").
*(high — Bitcoin Core `tx_verify.cpp`, canonical dev reference)*

## Why it breaks a channel

Lightning's core safety property: **a party can broadcast its latest commitment
transaction and force-close at any time.** If the funding output sits on an
immature coinbase:

- The commitment / force-close tx **spends** that funding output.
- For 100 blocks that spend is **non-mineable** — not merely unconfirmed, but
  *consensus-invalid*.
- So for ~16.7 h a party's channel balance is **unenforceable on-chain.** A
  cheating counterparty faces no timely penalty.

BOLT #2 encodes exactly this: `channel_ready` "MUST wait for at least 100 blocks if
the funding transaction is the coinbase transaction." The spec doesn't forbid a
coinbase-funded channel — it forbids *using* it until maturity.

## Zero-conf does not rescue it

One might try to treat a just-mined-coinbase-funded channel as
[[../reference/specs-and-prior-art|zero-conf]]. It fails: zero-conf tolerates a
*delayed confirmation* on the funder's good faith, and assumes eventual confirmation
is the normal path. A coinbase funding output is not merely unconfirmed — it is
**unspendable** for 100 blocks. Zero-conf trust cannot paper over an output that
consensus will not let anyone spend. *(medium — Optech zero-conf channels)*

## Why Ark tolerates what LN cannot

The sibling [[../reference/specs-and-prior-art|ark-boarding-sv2-mining]] thesis lives
with the same maturity wall because an n-of-n batch output simply isn't unilaterally
exitable yet — acceptable for a cosigned batch that expects to wait. **LN requires
unilateral force-closability from the instant funds are committed**, so the same
100-block window that Ark shrugs off is fatal to a fresh-coinbase LN channel. The
practical fix — board/fund a **matured proxy UTXO** — is exactly
[[three-readings|Reading C]], at which point the funding tx is no longer the coinbase.

## Reorg

Within the maturity window an orphaned block voids the coinbase; the funding output
and all commitments over it reference a nonexistent outpoint. Maturity exists to
insure against precisely this — and LN inherits the exposure if it funds from a
fresh coinbase.

## See also

- [[coinbase-transaction-structure]] — where the rule comes from.
- [[presigning-unknown-coinbase-outpoint]] — the *other*, removable wall.
- [[three-readings]] — Reading B's verdict.
