---
title: "Hardening Stratum, the Bitcoin Pool Mining Protocol"
source: "https://arxiv.org/abs/1703.06545"
type: papers
ingested: 2026-09-21
tags: [stratum-v1, protocol-security, hashrate-inference, share-hijacking, bedrock, mining-cookie, coinbase-structure, vardiff, extranonce, encryption-overhead, stratap, bitecoin, wireghost]
summary: "Recabarren & Carbunar (FIU), PETS 2017 issue 3. The only rigorous protocol-level security analysis of Stratum V1 found in this round. Captures 138 MB of live Stratum traffic from AntMiner S7 units in the US and Venezuela over 13 days, documents the six message types and the coinbase field layout the protocol overlays, then introduces three attacks: StraTap (passive packet capture -> per-miner hashrate and BTC payout inference from share count x difficulty x 2^32), ISP Log (same inference from packet metadata alone, exploiting F2Pool's fixed initial difficulty of 1024 and its second difficulty notification after ~50 shares; mean error -9.49%), and BiteCoin (active TCP hijack via a custom tool 'WireGhost' that rewrites the username on a victim's share submission and mangles the victim's own copy so it is rejected — stealing the work and the payout). Proposes Bedrock: a per-miner secret RM whose cookie CM = H^2(RM, username) is placed in the coinbase's unused previous-transaction-hash field and folded into the puzzle, so an attacker without CM cannot reconstruct the work or re-attribute a share. Measured overhead: 12.03 s/day for a pool serving 16,000 miners, versus 1.36 h/day for full encryption and 1.01 h/day for TLS."
authors: [Ruben Recabarren, Bogdan Carbunar]
affiliation: "Florida International University"
published: 2017
venue: "Proceedings on Privacy Enhancing Technologies (PETS) 2017, Issue 3"
publication_status: "Peer-reviewed, published"
credibility: high
credibility_score: 6
credibility_rationale: "Peer-reviewed at PETS; primary measurement data (138 MB own capture); working attack implementations; proposed defence with measured overhead. Independently surfaced by two agents this round (academic + contrarian), i.e. corroborated."
confidence: high
research_round: 1
research_agent: "academic (corroborated by contrarian)"
extraction_note: "Extraction assembled from two independent subagent reports of the same paper, both working from the arXiv PDF. Section-level mechanics and headline numbers agree across both. Equations transcribed as prose; re-read the PDF before implementing Bedrock."
---

# Hardening Stratum, the Bitcoin Pool Mining Protocol

**Ruben Recabarren, Bogdan Carbunar** — Florida International University —
**PETS 2017, Issue 3** — arXiv:1703.06545

## Why it matters architecturally

Stratum V1 is described here as "the de-facto mining communication protocol" for Bitcoin and
altcoins (Litecoin, Ethereum, Monero at the time). It carries **no cryptographic protection**. The
paper's contribution is to show that this is not an abstract weakness: both *passive revenue
inference* and *active payout theft* work, and the cheapest fix is far narrower than TLS.

The threat model includes physical-safety consequences: learning a miner's payout exposes the owner
to theft, kidnapping (the paper cites documented Venezuelan cases), and prosecution where mining is
illegal. This is why per-miner hashrate is treated as a secret and not merely as telemetry.

## Protocol structure as measured (Stratum V1 over F2Pool)

TCP/IP, JSON-RPC, **cleartext**. Six observed message types:

1. **`mining.subscribe`** — miner capabilities. Server replies with the method list, `extranonce1`,
   and `extranonce2.size`. **Finding: F2Pool set `extranonce1` to the constant `\x30\x30`** rather
   than a per-connection random value. A non-random extranonce1 is an architectural defect — it
   removes the per-connection separation the field exists to provide.
2. **`mining.authorize`** — `account.minerID` plus a cleartext password **which pools ignore**. The
   auth field is decorative; there is effectively no miner authentication.
3. **`set.difficulty`** — sent after authorization and adjusted dynamically (vardiff).
4. **`mining.notify`** — `job_id`, puzzle parameters F, and the `clean_jobs` flag telling the miner
   whether to discard previous jobs.
5. **`mining.submit`** — username, `job_id`, timestamp, nonce, `extranonce2`.
6. **Result** — accept / reject / ignore.

**Coinbase field layout Stratum overlays on the Bitcoin coinbase** (paper's Figure 2):
`coinbase1` (the first five input fields plus part of the script — meaningless for a coinbase, which
has no input transaction) ‖ `extranonce1` (intended per-connection pseudo-random) ‖ `extranonce2`
(miner increments when the nonce space is exhausted) ‖ `coinbase2` (remainder). The **unused 32-byte
previous-transaction-hash field** is the space Bedrock later repurposes for the mining cookie.

**Puzzle.** The miner iterates nonce and `extranonce2` until `H²(nonce ‖ F) < target`, where
`F = (block version ‖ prev block hash ‖ merkle root ‖ timestamp ‖ nBits)` and the merkle root covers
the transactions including the constructed coinbase. Difficulty relates to target as
`difficulty = target₁ / target` with `target₁ = 2²²⁴ − 1` (difficulty 1 = 32 leading zero bits).
Pools set an easier share target so progress is provable.

**Measurement setup**: 138 MB of Stratum traffic from AntMiner S7 devices (US and Venezuela) over
13 days.

## Attacks

### StraTap (passive, full packet capture)

Count share submissions and their associated difficulty. Expected hashes per share `E = difficulty ×
2³²`, so `hashrate = difficulty × 2³² / t` where `t` = time between difficulty changes divided by
accepted shares in that window. Convert to BTC with the pool's published rate (F2Pool: 0.00246248
BTC per TH/s at the time). §9.1 validates low payout-prediction error experimentally.

### ISP Log (passive, metadata only)

Adversary sees only timestamps, IPs, ports, connection flags. Exploits a **pool implementation
choice**: F2Pool's first post-subscribe difficulty notification is always the minimum, 1024, and the
second arrives after roughly 50 shares. Timing the first ~50 packets is enough to infer hashrate by
the same formula. **Mean percentage error −9.49%** with a single inference per day.

The architectural lesson is sharp: a *fixed, publicly known* starting difficulty converts packet
counts into a hashrate oracle. Vardiff's initial condition is a privacy parameter, not only a
convergence parameter.

### BiteCoin (active, TCP hijack)

The adversary subscribes its own device to the pool, then hijacks the victim's TCP connection with
**WireGhost** — a custom hijacker with *active re-synchronisation*, rewriting sequence numbers so
payload changes do not trigger ACK storms or resets. It relays the pool's job into the victim's
connection, intercepts the victim's `mining.submit`, **rewrites the username to its own** and sends
it over its own connection, while simultaneously sending a mangled copy of the victim's original so
that submission is rejected. Result: the victim's work and payout are stolen.

This is the concrete mechanism behind the general claim that V1 permits hashrate hijacking.

## Bedrock (the proposed extension)

Three parts:

1. **Mining cookies.** Pool generates a 256-bit random seed `RM` per miner, computes
   `CM = H²(RM, M.uname)`, stores `(KM, RM, target)`, and sends `E_KM(RM)`. The miner recomputes
   `CM` and writes it into the coinbase's unused previous-hash field, so `F` now includes `CM`.
   Without `CM`, an adversary can neither reconstruct the puzzle (no hashrate inference) nor
   re-attribute a share (no hijack). Nonce iteration uses a **pseudo-random permutation rather than a
   sequential scan**, to deny inference from nonce ordering. Cookie refresh is needed only when the
   miner actually finds a block — expected once per **7.44 years** for an AntMiner S7 at 4.73 TH/s.
2. **Protect communicated secrets.** A new `mining.encrypted` message carrying
   `E_KM(param_list)` with `param_list = [["difficulty", value], ["secret", RM]]` — i.e. encrypt only
   the difficulty notifications and the secret, not the whole session.
3. **Secure hashrate computation.** The miner *reports* its hashrate at subscribe time (encrypted),
   removing the pool's need to infer it — which is what the ISP Log attack exploited. The pool still
   corrects difficulty later if observed submission rate deviates.

**Binding property.** Even if the adversary recovers `RM`, it cannot hijack shares, because
`CM = H²(RM, M.uname)` ties the cookie to the username; re-attribution would require a partial hash
collision per share. An adversary able to invert the hash would mine directly instead.

**Cost.** **12.03 s/day** of extra pool-server work at **16,000 miners**. Full encryption: **1.36
h/day**. TLS: **1.01 h/day**. Bedrock is deliberately minimal — encrypt the sensitive messages only.

**Residual leak.** The cookie becomes public when the miner mines a block (it is in the chain). An
adversary holding previously captured traffic can then retroactively infer hashrate for that window
— years-long for a single miner, days for an entity running many homogeneous machines. Suggested
mitigation: randomly vary operating frequency within an acceptable range.

## Architectural takeaways

- **Auth is the gap, not just confidentiality.** Encryption alone does not fix re-attribution; the
  share must be cryptographically bound to the miner identity. SV2's Noise layer addresses the
  channel; this paper argues the *work* needs binding too.
- **Timing leaks survive encryption.** Packet timestamps alone yielded −9.49% mean error. Any design
  that treats per-miner hashrate as confidential must consider traffic shaping, not only ciphertext.
- **Pool implementation choices are the attack surface, not only the protocol.** Constant
  `extranonce1` and a fixed minimum starting difficulty were both F2Pool decisions, and both are
  what made inference cheap.
- **Selective encryption is 300× cheaper than TLS here.** A useful counterexample to "just put TLS
  in front of it" — the overhead ratio (12 s vs 1.01 h per day at 16k miners) is the argument.
