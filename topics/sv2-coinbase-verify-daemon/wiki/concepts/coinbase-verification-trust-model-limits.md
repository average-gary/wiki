---
title: "Coinbase-verification trust-model limits"
type: concept
created: 2026-07-21
updated: 2026-07-21
confidence: high
tags: [stratum-v2, trust-model, job-declaration, block-withholding, job-swapping, sybil, security]
---

# Coinbase-verification trust-model limits

A passive "coinbase matches expected" daemon is **trust-but-verify at best**, not
trustless. Verification power scales with how much of the block the miner *authors*, not
with how carefully it inspects what it's handed. Steelmanned below.

## By channel / mode

**Standard channel** — verifies *nothing* about the coinbase (there are zero coinbase
bytes on the wire; only a `merkle_root`). The pool can commit any payout, any
OP_RETURN, any censorship, invisibly.

**Extended channel** — CAN reconstruct and inspect *this specific job's* coinbase at the
moment it's received. CANNOT prove:
- that the checked job is the one that actually gets **mined/broadcast** — jobs are
  mutable; the pool may issue a new `NewExtendedMiningJob` / `SetNewPrevHash` (with a
  different coinbase) at any time after the check;
- that **other miners** receive the same coinbase — nothing forces identical jobs
  across the fleet; a pool can serve a clean coinbase to the auditing daemon and a
  skimming/censoring one to others (targeted deception);
- **aggregate** pool payout behavior — one miner can't see the fleet-wide distribution;
- that a found block was actually **broadcast** (block withholding).
- The pool controls the payout-bearing bytes (prefix/suffix = outputs); the miner
  controls only its own `extranonce`.

**Job Declaration (JDC/JDS)** — the *actual* trust-minimization mechanism: the miner
**authors** the template + coinbase (via Template Distribution from its own Core) and
declares it, so there's no "expected value" to trust the pool about. Even so, cheating
is deterred **economically** (JDC fallback: switch pool / solo), not cryptographically.
— [[raw/articles/2026-07-21-sv2-spec-job-declaration-protocol]]

## Cross-cutting limits

- **Noise auth ≠ honesty.** The encrypted, server-authenticated channel proves *who*
  the pool is, not that its jobs/coinbase/payouts are honest.
  — [[raw/articles/2026-07-21-sv2-spec-design-goals-and-security]]
- **Signed ≠ broadcast.** No in-protocol proof that the validated job is the block that
  hit the network.
- **Payout realism.** Coinbase outputs (PPLNS/FPPS) often pay the *pool*, not the miner;
  a matching coinbase says nothing about whether the miner is later paid correctly.
  Coinbase maturity (100 blocks) and reorgs further decouple "valid coinbase in this
  job" from "funds received." — [[raw/articles/2026-07-21-optech-pooled-mining-trust-model]]
- **Historical abuse is real:** pools have stolen from site operators and accidentally
  violated consensus; block withholding is a live attack class.
  — [[raw/articles/2026-07-21-optech-pooled-mining-trust-model]]

## Honest framing for the tool

The daemon is a useful **watchdog / transparency probe**: it can alert on a coinbase
that doesn't pay the expected address/value *in the jobs it is served*. That catches
misconfiguration and naive skimming, and it complements external observers like
[[wiki/concepts/prior-art-coinbase-verification|miningpool.observer]] (which ignores the
coinbase). It does **not** provide a trustless guarantee — only Job Declaration does.

## See also

- [[wiki/concepts/expected-value-checks-taxonomy]]
- [[wiki/concepts/prior-art-coinbase-verification]]
- [[wiki/topics/what-the-daemon-can-and-cannot-prove]]
- [[../ark-boarding-sv2-mining/_index|ark-boarding-sv2-mining]]
