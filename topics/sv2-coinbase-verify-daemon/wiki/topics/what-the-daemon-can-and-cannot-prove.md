---
title: "What the daemon can and cannot prove"
type: topic
created: 2026-07-21
updated: 2026-07-21
confidence: high
tags: [stratum-v2, trust-model, verification, job-declaration, threat-model, synthesis]
---

# What the daemon can and cannot prove

The honest scoping of the tool. Read alongside
[[wiki/concepts/coinbase-verification-trust-model-limits]]. The governing principle:
**verification power scales with how much of the block the miner authors, not with how
carefully it inspects what it's handed.**

## Can prove

- **On an extended channel**, that a *given job's* coinbase pays an expected
  scriptPubKey / value / carries an expected tag, at the moment the job is received
  (checks a–d in the [[wiki/concepts/expected-value-checks-taxonomy|taxonomy]]).
- **Coinbase↔merkle-root integrity** (check e): the reconstructed coinbase actually
  folds to the root the pool expects you to hash.
- Its own **PoW / share validity** and, via `network_target.is_met_by`, whether a share
  is a **block** (reusing `ExtendedChannel::validate_share`).
- A useful **watchdog signal**: alert when a served coinbase deviates from the expected
  address/value — catching misconfiguration and naive skimming.

## Cannot prove

- **Anything on a standard channel** — no coinbase bytes exist on the wire, only a
  `merkle_root`. Structurally impossible.
- **That the checked job is what gets mined/broadcast** — jobs are mutable; the pool can
  swap in a new `NewExtendedMiningJob` after the check ("signed ≠ broadcast").
- **That other miners get the same coinbase** — a pool can serve a clean coinbase to the
  auditing daemon and a different one to everyone else (targeted deception).
- **Aggregate pool payout** — one miner can't see the fleet-wide distribution.
- **Block withholding** — the daemon sees jobs/shares, not the pool's relay behavior.
- **That the miner is ultimately paid correctly** — PPLNS/FPPS coinbases pay the *pool*;
  maturity (100 blocks) and reorgs decouple "valid coinbase in this job" from "funds
  received." — [[raw/articles/2026-07-21-optech-pooled-mining-trust-model]]
- **Honesty from authentication** — Noise proves *who* the pool is, not that it's honest.
  — [[raw/articles/2026-07-21-sv2-spec-design-goals-and-security]]

## The real trust-minimization is Job Declaration

To move from "trust-but-verify" to actual trust-minimization, the miner must **author**
the coinbase, not inspect it: SV2 **Job Declaration** (JDC) + **Template Distribution**
from the miner's own Bitcoin Core. Then there is no "expected value" to trust the pool
about. Even then, enforcement is **economic** (JDC fallback: switch pool / solo), not
cryptographic. — [[raw/articles/2026-07-21-sv2-spec-job-declaration-protocol]],
[[raw/articles/2026-07-21-sv2-spec-template-distribution-protocol]]

## Where it fits among existing tools

It fills a real gap — no existing tool does per-miner SV2 coinbase-payout assertion
(miningpool.observer ignores the coinbase; stratum.work is V1 and non-asserting; JD
inverts the trust model). See [[wiki/concepts/prior-art-coinbase-verification]].

## See also

- [[wiki/concepts/coinbase-verification-trust-model-limits]]
- [[wiki/concepts/expected-value-checks-taxonomy]]
- [[wiki/topics/daemon-build-playbook]]
