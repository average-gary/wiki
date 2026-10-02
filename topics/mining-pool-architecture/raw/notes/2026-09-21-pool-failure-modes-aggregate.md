---
title: "Failure modes and abandonments: SPV-mining fork, NOMP/MPOS decay, slush0's own implementation, p2pool variance, spam-driven exhaustion"
source: "https://en.bitcoin.it/wiki/Comparison_of_mining_pools"
related_sources:
  - "https://github.com/zone117x/node-open-mining-portal/issues"
  - "https://github.com/slush0/stratum-mining/issues"
  - "https://github.com/jtoomim/p2pool/blob/master/README.md"
  - "https://blog.lopp.net/history-bitcoin-transaction-dust-spam-storms/"
  - "https://github.com/filipnyquist/node-stratum-pool"
type: notes
ingested: 2026-09-21
tags: [failure-modes, spv-mining, 2015-fork, nomp, mpos, abandonment, slush0-stratum-mining, job-id-tracking, p2pool-variance, variance-death-spiral, dust-spam, resource-exhaustion, language-choice, postmortem]
summary: "Five failure stories aggregated, ranked by evidence quality. Best-evidenced: the 4 July 2015 SPV-mining fork, where F2Pool, AntPool and BTC Nuggets mined on unvalidated headers and miners lost over $50,000 — a latency optimisation with multi-pool systemic consequences, and the operational counterpart to the measured finding that empty blocks have shorter intervals than non-empty ones. Second: p2pool's variance death spiral, documented by its own fork maintainer in 2018 — blocks every ~25 days on jtoomimnet and ~108 days on mainnet, with the README advising 'do not mine on BTC p2pool unless you are very patient and can tolerate receiving no revenue for several months'; decentralised pooling failed on variance, not on implementation. Third: slush0's own stratum-mining repository, archived read-only in March 2023, whose issue list is a catalogue of job-tracking fragility ('Job id c3a6 not found'), ntime range validation, and a request for per-port difficulty tiers — the protocol's inventor abandoned his own implementation, and the same bug classes recur in SV2 thirteen years later. Weaker: NOMP/MPOS abandonment (issues open 2022-2026, payment RPC failures, ASIC connection problems) where the inference that Node.js is unsuitable is asserted rather than demonstrated. Also recorded: dust-spam storms crashing over 10% of reachable nodes in October 2015, as evidence that adversarial transaction load is a pool resource-exhaustion vector."
credibility: medium
credibility_score: 2
credibility_rationale: "Mixed. The 2015 fork and the p2pool variance figures are well-documented with named parties and numbers. The Jameson Lopp spam analysis is a well-sourced historical piece. The NOMP/MPOS abandonment section is issue-tracker archaeology plus the reporting agent's own inference about language suitability, which no source states. Aggregated at the lower bound."
confidence: low
confidence_rationale: "Individual incidents are credible; the causal claims about WHY software was abandoned are the agent's reasoning, not source claims. Graded per item below."
research_round: 1
research_agent: contrarian
extraction_note: "Aggregated from one subagent's lower-tier sources. Items are individually attributed and individually graded. Where the agent supplied a causal explanation the sources do not contain, it is marked INFERENCE."
---

# Failure modes and abandonments

Ranked by how well the evidence supports the architectural conclusion drawn from it.

## 1. The 4 July 2015 SPV-mining fork — well evidenced

- Miners lost **over $50,000 USD** during the fork.
- **F2Pool, AntPool and BTC Nuggets** are named as having engaged in SPV mining — building on block
  headers before validating the full block.
- Consequence for the network: a state "where small numbers of confirmations are much less useful than
  they normally are."

**The architecture in one line**: minimising orphan risk means starting the successor as early as
possible; validating the predecessor takes time; so the latency-optimal choice is to mine on an
unvalidated header. When one pool builds on an invalid block, others following the same logic extend
it, and a fork results.

**This is the failure mode where individual optimisation destroys a network property.** It also
connects directly to a measurement: Wang/Chu/Yang found empty blocks have *significantly shorter block
intervals* than non-empty ones — the on-chain signature of exactly this behaviour, visible years later.

Also noted in the same source: **GHash.IO** (which once exceeded 50% of network hashrate), **BTCC
Pool**, and **Poolin** (bankruptcy filed July 2026) all shut down. Not all SPV-related; recorded as
evidence that pool mortality is high.

**Design consequence**: a pool must decide explicitly, as policy, whether it will emit a
transaction-free template in the validation gap. There is no neutral default — declining costs
milliseconds of orphan exposure, accepting risks building on garbage.

## 2. p2pool's variance death spiral — well evidenced, from the maintainer

From **jtoomim's p2pool fork README (2018)**:

- *"The BTC p2pools currently have low hashrate, which means that payouts will be infrequent, large,
  and unpredictable."*
- Blocks roughly **once every 25 days on jtoomimnet** and **once every 108 days on mainnet** (as of
  February 2018).
- *"Do not mine on BTC p2pool unless you are very patient and can tolerate receiving no revenue for
  several months."*

**The mechanism**: low hashrate → high variance → miners leave → lower hashrate. Self-reinforcing.
Structurally, the share chain's difficulty must scale with Bitcoin's, so as network difficulty grew,
share frequency fell and variance rose. **The architecture could not scale to Bitcoin's hashrate
without unacceptable variance.**

**Corroborated independently** by the SmartPool paper's diagnosis: message count is a scalar multiple
of share count, so low share difficulty means message explosion and high share difficulty means
variance — no setting is good on both axes. Two unrelated sources, same conclusion.

**Design consequence**: any decentralised-pooling proposal must answer the variance question first.
Note that DATUM and SV2 Job Declaration sidestep it entirely by decentralising *templates* while
keeping *payout* pooled — which is precisely why they are adoptable where p2pool was not.

## 3. slush0's `stratum-mining` — archived March 2023 — moderately evidenced

The original Stratum implementation, by Stratum's author. **Repository archived read-only, March
2023.** Issues reported:

- Connection state: *"Stratum Server Exception '[coin] is not connected'"* — unreliable upstream
  daemon connection management.
- **Template registry (#20): "Job id 'c3a6' not found"** — a job referenced after removal but before
  the client stopped using it.
- **ntime validation (#11): "ntime out of range"** — improper validation of submitted timestamps.
- Difficulty (#21): a *request* for **multiple ports for different difficulties** — the original design
  had no per-connection difficulty flexibility.
- Block sync (#4): "different blocks count with stratum and real wallet transactions" — pool view
  diverging from chain state.
- Finalisation (#3): "finalize does not return true" — incomplete transaction processing.

**Why this is the most interesting item in the file.** Three of these recur *verbatim in class* in the
2026 SV2 hardening release: job-ID collision handling (`JobStore::add_future_job` dropping a displaced
job), `nTime` bounds enforcement (upper bounds were missing), and per-connection difficulty
negotiation (BIP 310's `minimum-difficulty`, then SV2 channels). **Fourteen years apart, in different
languages, by different authors.** These are not implementation slips; they are the intrinsic hard
parts of the problem: job identity is a small shared namespace with independent client lifetimes, and
submitted time is attacker-controlled input.

**Grade**: the issue list is primary. The conclusion *"Slush invented Stratum and his implementation
died, therefore V1 job/connection management is fundamentally hard to implement correctly"* is a
reasonable reading, strengthened by the SV2 recurrence, but the archiving itself has many possible
causes (he moved to Braiins, then to SatoshiLabs/Trezor).

## 4. NOMP / MPOS abandonment — weakly evidenced, inference flagged

`node-open-mining-portal` issues, open 2022–2026 without resolution:

- **#726**: payment RPC failure — `sendmany` returning "Invalid Stohn address".
- **#736**: "Error wallet file not specified" — setup failure preventing startup.
- **#742**: "Problem connect whatsminer" — ASICs not connecting reliably.
- **#747**: a community member suggesting "archive this shit" (Aug 2025).

`node-stratum-pool` (filipnyquist fork) self-documented limits: several algorithms "not working
currently" (Groestl, some Keccak variants, Hefty1); *"This software will not be useful unless you're a
Node.js developer"* — it is a library, not a pool; requires functional coin daemons.

**INFERENCE, not sourced.** The reporting agent concluded that Node.js is architecturally unsuitable
for pools — single-threaded event loop unable to handle high share frequency, GC pauses, ORM latency,
floating-point errors in payment math, dynamic typing causing runtime payment failures. **No source
states any of this.** Assessing it against other evidence in this round:

- **The share-frequency argument is wrong as stated.** Share rate is bounded by
  `connections / vardiff interval`, and validation is ~1 µs; a Node.js pool is nowhere near an event-loop
  limit on share volume. public-pool documents 10,000 connections per worker and scales by cluster.
- **The floating-point-in-payment-math argument is plausible and serious**, but is about *payout code*,
  not about pool architecture, and no cited issue demonstrates it.
- **The abandonment is real; the diagnosis is not established.** Unmaintained altcoin-era software with
  open setup-failure issues is adequately explained by the altcoin-pool business drying up.

**What survives**: NOMP/MPOS-era software is unmaintained, and operators moved to ckpool and custom
implementations. **Why** is not established by these sources. The one architectural signal worth
keeping is that a *library* requiring the operator to write the auth, payment and database layers
themselves is a worse deal than a complete daemon — which is what the README itself says.

## 5. Dust-spam storms and resource exhaustion — well evidenced, indirect relevance

Jameson Lopp's history:

- **CoinWallet.eu, 2015**: 1.34M transactions, 2.78 GB of block space, 268 BTC in fees; publicly claimed
  as a stress test, assessed by Lopp as likely "a sockpuppet used as a front for political purposes."
- **July 2015 flood**: ~10 UTXO clusters (likely 10 wallets) operating autonomously; average fees up
  **51%**, processing delays up **sevenfold**.
- **October 2015**: when spammers consolidated dust UTXOs, **over 10% of reachable Bitcoin nodes became
  unresponsive or crashed** — notably Raspberry Pi-class hardware.

**Relevance is indirect but real.** A pool's *template source* is a full node that must maintain a
mempool, build templates, and answer RPC/IPC under this load. A 10 MB template is already large; an
adversarial mempool makes template construction slower and bigger exactly when fee revenue (and thus
the value of a fresh template) is highest. This is the argument for the pool's node being a resourced,
dedicated machine with failover — which is what ckpool's `btcd` failover array and multiple
template-source support exist for.

## Ranked: what a new pool architecture must design against

**Tier 1 — well evidenced, existential:**

1. **Block withholding**, especially against PPS (peer-reviewed; see the withholding-economics file).
2. **Share replay via state reset** (SV2 release notes; the `seen_shares`/`prev_hash` and
   extranonce-recycling fixes).
3. **Consensus-invalid coinbase construction** — a found block that pays zero (SV2 PR #2243). The
   highest-consequence single failure found.
4. **Stratum V1 hashrate hijacking** (peer-reviewed: BiteCoin/WireGhost).
5. **Variance in any decentralised-payout design** (p2pool, corroborated by SmartPool).

**Tier 2 — well documented operationally:**

6. **SPV-mining fork risk** from latency optimisation (2015, $50k+, named pools).
7. **Stranded vardiff** silently underpaying slowed miners (Optech #423) — add here because it is
   silent, universal, and revenue-affecting.
8. **Job-identity and time-validation fragility** (recurring 2012 → 2026).
9. **Resource exhaustion on the template path** under adversarial mempool load.

**Tier 3 — plausible, insufficiently evidenced in this round:**

10. Payment-processing fragility as a cause of pool shutdown (NOMP issues; causality not established).
11. Language/runtime choice as a determinant of pool viability (asserted, and partly contradicted by
    the share-rate arithmetic).
12. **Database as the bottleneck** — no postmortem found. Notably, ckpool avoids a database entirely,
    so the hypothesis is untested rather than confirmed.
13. **DDoS against stratum endpoints** — rate limiting exists in ckpool and Miningcore
    (`Banning/`, subclient token buckets), but **no public incident report was found**.
14. **Reconnect storms** after a network blip — repeatedly identified as a likely operational pain
    point, with **no source documenting one**. ckpool's socket handover (`-H`) is circumstantial
    evidence that it is real enough to engineer against.

Items 12–14 are the most conspicuous evidence gaps in this topic: three failure modes everyone assumes
exist, with no published postmortem behind any of them.
