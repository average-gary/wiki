---
title: "eltoo: A Simple Layer2 Protocol for Bitcoin"
source: "https://blockstream.com/eltoo.pdf"
type: papers
ingested: 2026-07-16
tags: [eltoo, ln-symmetry, sighash-noinput, anyprevout, lightning, off-chain, rebindable-signatures, decker, russell, osuntokun]
summary: "The primary academic paper introducing eltoo (Decker, Russell, Osuntokun). Eltoo replaces LN-Penalty's punishment/revocation model with a state-number-ordered update mechanism where any newer state can rebind onto and override any older state on-chain. Depends on SIGHASH_NOINPUT (the technique later specified as SIGHASH_ANYPREVOUT / BIP-118) to make update transactions 'floating' / rebindable."
---

# eltoo: A Simple Layer2 Protocol for Bitcoin

**Authors**: Christian Decker, Rusty Russell, Olaoluwa Osuntokun ("Decker-Russell-Osuntokun"). *(Do not confuse with the separate "Channel Factories" paper by Burchert/Decker/Wattenhofer.)*

## Core contribution

Eltoo replaces Lightning's original **LN-Penalty** design. Instead of storing all
historical channel states plus penalty (revocation) transactions to punish a
counterparty who broadcasts a revoked state, participants store only the **latest**
state.

## Mechanism

- Uses **`SIGHASH_NOINPUT`** (the technique later formalized as `SIGHASH_ANYPREVOUT`,
  BIP-118) so a signature does **not** commit to the specific output being spent.
  A signed update transaction becomes a **"floating" / rebindable** transaction that
  can attach to *any* prior state's output with a matching script.
- Each state = an **update transaction** (spends the prior contract output, creates
  a new one) plus a **settlement transaction** (distributes funds).
- States carry incrementing **state numbers**; a higher-numbered update can always
  override (rebind onto) a lower-numbered one on-chain.
- **Short-circuiting**: the final update binds directly to the funding output — you
  never replay the whole chain of intermediate updates on-chain. "Only the last
  settlement transaction can ever be confirmed."

## Why it reduces state storage vs LN-Penalty

LN-Penalty requires storing revocation secrets/transactions for *every* historical
state to threaten punishment (this is "toxic information" — losing or leaking a
backup can cost all funds). Eltoo/NOINPUT instead uses monotonic state numbers where
any new state rebinds onto and overrides any old one, so only the *latest* update +
settlement + active HTLCs need be kept. Old states are harmless (cost only fees)
rather than toxic.

## Downstream benefits (per the paper and later Optech framing)

- Reduces risk from node/backup failures.
- Simplifies **multi-party channels** (up to ~7 parties) and **channel factories**.
- Lets storage-limited devices (hardware wallets) safely participate.

## Provenance note

Content extracted/summarized during the 2026-07-16 research session from the primary
PDF. An automated fetch summary misattributed the authorship to
"Burchert/Decker/Wattenhofer" — corrected here to Decker/Russell/Osuntokun.
