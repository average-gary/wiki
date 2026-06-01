---
title: "Mempool.space Mining Pool Rankings - 2026"
url: https://mempool.space/mining/pools
source_type: live-stats
ingested_by: path5
ingested_on: 2026-06-01
quality: high
relevance: high
hypotheses_addressed: [1, 4]
---

# Mempool.space Mining Pool Rankings - 2026

## Provenance
mempool.space, public Bitcoin mining dashboard, 1-week trailing window.
Snapshot taken 2026-06-01.

## Key Findings (1-week share, 2026-06-01)

| Pool        | Share  | Blocks |
|-------------|--------|--------|
| Foundry USA | 27.19% | 279    |
| AntPool     | 19.49% | 200    |
| MARA Pool   | 4.19%  | 43     |
| **OCEAN**   | **3.22%** | **33** |

OCEAN is rank ~10th, mid-tier. Cross-checked against the OCEAN frontend
showing **32.56 EH/s self-reported hashrate** at ingest time.

## Hypothesis Implications

- **H1 (TAM for SV2 fleet wanting TIDES):** PARTIALLY SUPPORTED. OCEAN at ~3%
  network share is non-trivial but not dominant. The pool of BraiinsOS+ /
  SV2-native miners that would *consider* OCEAN is the relevant TAM, not the
  whole SV2 fleet. Even capturing 10% of SV2-firmware miners onto OCEAN via a
  proxy would be a meaningful single-digit-percent boost to OCEAN's hashrate.
- **H4 (hashpool front-ending OCEAN):** UNCLEAR. OCEAN's size means a
  hashpool-as-customer is a viable but niche play - hashpool's value prop
  is largely orthogonal to which upstream pool is used.

## Threat-Model Implications
At 3.22% share, OCEAN finds blocks roughly every ~5 days (33 / week). TIDES
windowing means an SV2-fronted miner mining via the proxy must trust both the
proxy operator AND the pool's window math through ~5 days of share
accumulation per payout cycle. Long custody-of-record window for the
proxy-operator trust assumption.

## Ingest Justification
Quantitative grounding for "is OCEAN big enough to matter as an upstream
target?" Answer: yes, but as a niche / decentralization-aligned target, not as
a default for the median operator.
