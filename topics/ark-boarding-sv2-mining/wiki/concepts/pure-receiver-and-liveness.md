---
title: "The pure-receiver / liveness problem for miner payees"
type: concept
created: 2026-07-17
updated: 2026-07-17
confidence: high
volatility: warm
verified: 2026-07-17
tags: [pure-receiver, receiver-dos, griefing, liveness, n-of-n-scaling, round-abort, proxy, delegation]
sources:
  - raw/articles/2026-07-17-narula-ark.md
  - raw/articles/2026-07-17-roose-ark-case-for-ctv.md
  - raw/articles/2026-07-17-ark-protocol-clark.md
  - raw/articles/2026-07-17-braidpool-spec.md
  - raw/articles/2026-07-17-optech-ark.md
  - raw/articles/2026-07-17-sv2-job-negotiation-proxy.md
  - raw/articles/2026-07-17-arklabs-adios-expiry.md
summary: "The strongest objection to the thesis. A clArk round is synchronous and atomic: one no-show forces a full re-round, and a pure receiver (nothing at stake) can grief for free. Miners receiving a payout ARE pure receivers, and clArk is 'perfectly secure' only where sender=receiver. Plus n-of-n does not scale to a pool's miner count (Braidpool caps ~50). The mitigations — online-while-mining, proxy/JDC key custody, delegated renewal, stake+bans — are what keep the thesis alive, but pull toward a smaller n or pool-as-ASP trust."
---

# The pure-receiver / liveness problem for miner payees

This is where "viable" is contested. See the parent treatment at
[[../../../covenantless-ark/wiki/concepts/dropout-and-round-abort|dropout & round abort]].

## Three linked objections

**1. Synchronous, atomic rounds — one no-show aborts all.** "If even one user
doesn't show up to sign, S has to reconstruct the transaction tree … just one user
each round can keep S from making progress"
([[../../raw/articles/2026-07-17-narula-ark.md|Narula]]). The round completes fully
or aborts with no on-chain footprint; honest users retry.

**2. Pure-receiver DoS asymmetry.** A receiver has no VTXO at stake, so "they can't
be penalized and have nothing to lose in performing a DoS attack on the round";
"co-signed (clArk) VTXOs cannot be issued without the presence of the eventual
owner" ([[../../raw/articles/2026-07-17-roose-ark-case-for-ctv.md|Roose #1528]]).
clArk is "perfectly secure" specifically where **sender = receiver** (self-refresh)
([[../../raw/articles/2026-07-17-ark-protocol-clark.md|ark-protocol.org]]). **A pool
paying independent miners is the opposite case** — the sender (pool) and receivers
(miners) differ, which is exactly the configuration clArk does not make trustless.

**3. n-of-n does not scale.** Braidpool: "signing very large threshold Schnorr
outputs is impractical"; its signer set is capped "around 50"
([[../../raw/articles/2026-07-17-braidpool-spec.md|Braidpool spec]]). Optech: Ark
covenantless works "but would support significantly more users … if covenant
features like OP_CTV were added" ([[../../raw/articles/2026-07-17-optech-ark.md|Optech]]).
A full pool has thousands of hashers.

## Why the thesis survives these (the mitigations)

The "online-while-mining" clause is the intended antidote, and it is not empty —
but it needs a correction and some help:

- **The online party is a proxy, not the hashboard.** In SV2 the continuously-online
  component is "a lightweight Stratum V2 proxy on a separate low-power device …
  while the main mining hardware focuses purely on hashing"
  ([[../../raw/articles/2026-07-17-sv2-job-negotiation-proxy.md|SV2 job negotiation]]).
  That proxy/JDC can hold the cosigning key and participate in the ~seconds MuSig2
  ceremony. Liveness therefore rests on proxy infrastructure, not on ASICs.
- **Delegated VTXO renewal.** A miner can "authorize a third party to renew their
  VTXOs on their behalf" while keeping "full unilateral control"
  ([[../../raw/articles/2026-07-17-arklabs-adios-expiry.md|Ark Labs, Adios Expiry]]),
  shrinking the passive-payee liveness burden.
- **Stake + identity + bans.** Unlike an anonymous Ark receiver, a miner has a
  persistent pool identity, contributed hashrate, and pending balance — so it is
  *not* a free pure receiver: it can be penalized/banned, blunting the DoS
  asymmetry. (This is the thesis's strongest original argument; no source models it
  quantitatively — an open gap.)

## Net effect on the verdict

The liveness/receiver objection is **mitigable, not dismissible**. Every mitigation
either reduces the effective *n* (small signer set, à la Braidpool) or leans on
proxy/pool infrastructure (pool-as-ASP), which trades some of the trustlessness the
thesis is trying to preserve. That is why the verdict is *partially supported*
rather than *supported*.

## See Also

- [[../topics/thesis-analysis-viability.md|Viability analysis (verdict)]]
- [[covenantless-batch-output-mechanics.md|Batch output mechanics]]
- [[../reference/alternatives-and-prior-art.md|Alternatives & prior art]]
