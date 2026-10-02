---
title: "Stratum V2's claimed performance gains (vendor figures, unverified)"
source: "https://stratumprotocol.org"
type: data
ingested: 2026-09-21
tags: [stratum-v2, performance-claims, vendor-marketing, bandwidth-reduction, job-latency, block-propagation, stale-share-rate, profitability-claim, unverified, methodology-missing]
summary: "The figures the Stratum V2 project publishes for itself, recorded as claims rather than as measurements because no methodology, dataset, or independent replication was found. Claimed: bandwidth reduction 60% for pools and 70% for miners; job latency 228 ms (V1) -> 57.7 ms (V2) -> 2.44 ms (V2 + Job Declaration); block propagation 96.3 ms -> 3.44 ms; share acceptance 99.8% -> 99.91% -> 100%; and 'up to 7.4% profit increase'. Two of these are independently implausible: a 100% share acceptance rate (0% stale) cannot hold for any protocol, since staleness is produced by propagation delay between a block being found anywhere on the network and a miner receiving the successor job — a property of the network, not of the wire format; and a 2.44 ms end-to-end job latency is below plausible WAN round-trip times for a geographically distributed miner base. The reporting agent scored this 5/5 citing 'published methodology' and 'multi-week production measurement on pools >10 EH/s'; no such methodology was produced, and that framing appears to be the agent's inference. Recorded so the claims can be tested, not cited."
credibility: low
credibility_score: 1
credibility_rationale: "Vendor self-report on the protocol's own promotional page. No published methodology, no dataset, no measurement window, no independent replication. Two figures are internally implausible. The agent's 5/5 score and its methodology paragraph are not supported by the source and are treated as agent embellishment."
confidence: low
research_round: 1
research_agent: data
do_not_cite_as_fact: true
verification_path: "Each claim is testable: bandwidth from packet capture on V1 vs V2 sessions at matched hashrate and difficulty; job latency from pool-side job emit timestamp to miner-side receipt (needs instrumented firmware or a proxy); stale rate from accepted/stale counters over a fixed window on the same hardware pointed at both protocols. The mining-scale-test-sim harness is the natural place to run the first two."
extraction_note: "Subagent extraction from the protocol's performance page. The 'methodology notes' and 'measured on pools with >10 EH/s sustained hashrate over months' text in the agent's report did not appear to come from the source and should be disregarded."
---

# Stratum V2's claimed performance gains

> **This file is ingested at `confidence: low` and marked `do_not_cite_as_fact`.** It exists so the
> claims are on record in a testable form. Every number below is a vendor self-report.

## The claims

**Bandwidth** — 60% reduction for pools, 70% for miners, from binary framing versus V1's JSON.

**Job latency** (server generating work → miner receiving it):

| | Latency | Claimed reduction |
|---|---|---|
| Stratum V1 | 228 ms | baseline |
| Stratum V2 | 57.7 ms | −74.7% |
| SV2 + Job Declaration | 2.44 ms | −98.9% |

**Block propagation** (miner finds block → pool broadcasts): 96.3 ms (V1) → 3.44 ms (SV2+JD), "28×
faster."

**Share acceptance**: 99.8% V1 (0.2% stale) → 99.91% SV2 (0.09%) → **100% SV2+JD (0% stale)**.

**Profitability**: "up to 7.4% profit increase."

## Why two of these cannot be right

**1. "100% share acceptance / 0% stale" is not achievable by a wire protocol.**

A stale share is one submitted against a job that is no longer current — overwhelmingly because *some
other miner somewhere on the network found a block* and this miner had not yet received the successor
job. The window is set by block propagation across the Bitcoin p2p network plus template regeneration
plus job push. A faster wire format shortens the last term only. No protocol can drive the total to
zero, and a reported exactly-100% figure is the signature of rounding, of a short measurement window
with no block-change event in it, or of counting only *rejected* rather than *stale* shares.

The Job Declaration gloss offered — "0% stale when miners select own transactions" — does not repair
it. A miner building its own template still must abandon that template when the chain tip moves.
Arguably self-declaration *helps* here, because the miner learns of the new tip from its own node
rather than waiting for a pool push; but "helps" is not "eliminates."

**2. A 2.44 ms end-to-end job latency is below plausible WAN RTT.**

Cross-continental round trips are 100–300 ms; even a regional connection is several milliseconds.
2.44 ms is consistent with a *localhost or LAN* measurement — which for Job Declaration is actually
coherent, since the JDC and Template Provider run *on the miner's own premises*: the job is generated
locally, so there is no WAN hop in the path being timed. If that is what the figure measures, it is
not comparable to the 228 ms V1 number, which necessarily includes a WAN hop to the pool. **The
comparison is likely between two different path definitions.** That would also explain the block
propagation figure.

Note this makes the underlying *architectural* point stronger, not weaker: moving template
construction to the miner removes a WAN round trip from the critical path. That claim is structural
and credible. The specific milliseconds are not established.

## What would make these citable

| Claim | Test |
|---|---|
| Bandwidth −60/−70% | Packet capture, V1 vs V2, matched hashrate and difficulty, same hardware. Must state whether framing, Noise MAC and TCP overhead are included. |
| Job latency | Pool-side emit timestamp → miner-side receipt. Needs instrumented firmware or an instrumented proxy. Must state the path (LAN vs WAN) and the geography. |
| Stale rate | Accepted/stale/rejected counters over a window containing many block changes, same hardware alternating protocols. Must define stale vs rejected. |
| 7.4% profit | Needs the fee environment, the hashrate, the baseline V1 implementation quality, and the window. As stated it is unfalsifiable. |

## The defensible version of the argument

Stripped of the numbers, the architectural claims that *do* follow from the design and are supported
elsewhere in this round:

- **Binary framing is smaller than JSON.** A `SubmitSharesStandard` is a 24-byte payload against a
  V1 `mining.submit` JSON object of roughly 150–250 bytes. A large reduction is arithmetic, not
  marketing — though the delivered ratio is diluted by the 6-byte frame header, 16-byte AEAD MAC and
  ~40 bytes of TCP/IP, and bandwidth was in any case shown not to be a binding constraint.
- **Fewer round trips on the job path lowers job latency**, and local template construction removes a
  WAN hop entirely.
- **Lower job latency reduces the stale window**, and a smaller stale window means less discarded
  work. Direction: certain. Magnitude: unestablished.
- **Encryption and authentication close the StraTap/BiteCoin attack class** (Recabarren & Carbunar) —
  which is a security result with a peer-reviewed basis, and a far stronger argument for SV2 than any
  of the performance figures above.
