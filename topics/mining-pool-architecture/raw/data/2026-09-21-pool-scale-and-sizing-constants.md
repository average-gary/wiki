---
title: "Pool sizing constants — network scale, difficulty math, ASIC share rates, and a correction to the shares/sec model"
source: "https://hashrateindex.com/hashrate/pools"
related_sources:
  - "https://en.bitcoin.it/wiki/Difficulty"
  - "https://mempool.space/mining/pool/foundryusa"
  - "https://en.bitcoin.it/wiki/Mining_hardware_comparison"
  - "https://github.com/benjamin-wilson/public-pool"
type: data
ingested: 2026-09-21
tags: [sizing-constants, network-hashrate, pool-concentration, difficulty-math, shares-per-second, vardiff-as-control-variable, nonce-exhaustion, version-rolling, connection-count, share-validation-cost, derived-figures]
summary: "Quantitative constants for sizing a pool, with the headline derived figure corrected. Network state as reported for 2026-09: 945.80 EH/s total, difficulty 132.76 T (self-consistent — 132.76e12 x 2^32 / 600 = 950 EH/s), 18 pools tracked, Foundry USA 233.7 EH/s / 23.4%, AntPool 204.3 / 20.45%, F2Pool 161.0 / 16.13%, ViaBTC 96.2 / 9.64%, SpiderPool 82.5 / 8.26%; top 3 ~60%, top 5 ~78%. Canonical math confirmed: expected_hashes = D x 2^48 / 0xffff; hashrate = D x 2^32 / 600; shares/sec = H / (D x 2^32). Nonce exhaustion at 100 TH/s: 43 microseconds on the 32-bit nonce alone, 720 seconds with BIP320 version rolling (+24 bits) — which is why version rolling is mandatory, not an optimisation. CORRECTION: the reported 'Foundry must validate ~1.09M shares/sec' is an artefact of assuming a uniform pool difficulty of 50,000. Difficulty is a per-connection CONTROL variable; if vardiff holds a target submission interval per connection, aggregate share rate is (connections / interval) and is INDEPENDENT of hashrate — roughly 2,300 shares/sec for 23,000 connections at one share per 10 s, three orders of magnitude below the reported figure. Also corrected: per-share validation cost is ~1 microsecond (standard channel, one 80-byte double-SHA256) to ~10 microseconds (extended channel with coinbase and merkle-path rebuild), not the reported 50-100 microseconds, and Schnorr verification is per-connection handshake work, not per-share — so 1M shares/sec would need single-digit cores, not 100."
measurement_window: "Hashrate/difficulty snapshot 2026-09; ASIC table current only through ~2023"
credibility: medium
credibility_score: 3
credibility_rationale: "Network-state figures come from observational trackers (Hashrate Index, mempool.space) that infer pool hashrate from blocks found — statistically noisy over a 7-day window. Difficulty math is canonical and was verified for internal consistency by this session. ALL load, bandwidth, memory and CPU figures are DERIVED, several from bad assumptions; see the corrections."
confidence: medium
research_round: 1
research_agent: data
corrections_applied: true
correction_note: "This session recomputed the load model and the per-share cost rather than carrying the agent's figures. Corrections are marked inline with CORRECTED. The original reported values are preserved so the error is auditable."
extraction_note: "Subagent extraction across five sources. Observational hashrate figures are as reported. Every derived figure is labelled."
---

# Pool sizing constants

> **How to read this file.** Figures are tagged **[READ]** (taken from a source), **[DERIVED]**
> (computed from read figures, arithmetic shown), or **[CORRECTED]** (the agent's derived figure was
> wrong; the original and the correction are both shown). Nothing here is a benchmark of pool
> software — no such benchmark was found in this round.

## Network state, 2026-09 [READ]

| Pool | Hashrate (EH/s) | Share | Blocks (7 d) |
|---|---|---|---|
| Foundry USA | 233.7 | 23.40% | 238 |
| AntPool | 204.3 | 20.45% | 208 |
| F2Pool | 161.0 | 16.13% | 164 |
| ViaBTC | 96.2 | 9.64% | 98 |
| SpiderPool | 82.5 | 8.26% | 84 |
| Luxor | 31.4 | 3.15% | 32 |
| Binance Pool | 16.7 | 1.67% | 17 |
| Braiins Pool | 13.7 | 1.38% | 14 |

- **Total network: 945.80 EH/s.** Difficulty **132.76 T**. Average block time 10 m 14 s (4% above
  target). 18 pools in the dataset.
- Concentration: **top 3 ≈ 60%**, **top 5 ≈ 78%**. Largest single pool 23.4%.
- Attribution is by coinbase pool tag; hashrate is *inferred from blocks found*, so a 7-day window
  carries ~√n variance. A pool at true 20% share can read 21–25% by luck alone.

**Consistency check performed this session** [DERIVED]: `132.76e12 × 2³² / 600 = 132.76e12 × 7.158e6
≈ 9.50e20 H/s = 950 EH/s`, against the reported 945.80 EH/s. **Self-consistent.** Both numbers can be
trusted as a pair.

Second source (mempool.space, Foundry page) [READ]: 24 h hashrate 191.61 EH/s / 20.14% share / 29
blocks; 7 d 238 blocks / 23.40%; 8-week range **213.82–244.28 EH/s** (mean ~228, ±7% week to week);
lifetime 74,533 blocks and 361,920.94 BTC, all-time share 7.70%. Recent blocks: subsidy **3.125 BTC**
plus **0.01–0.07 BTC** fees — a low-fee period.

The 191.61 vs 233.7 EH/s gap between the two sources for the same pool in the same month is the
measurement noise, stated plainly.

## Canonical difficulty math [READ]

```
difficulty        = difficulty_1_target / current_target
expected_hashes   = D × 2⁴⁸ / 0xffff          (≈ D × 2³²)
network_hashrate  = D × 2³² / 600
time_to_solve     = D × 2³² / hashrate
shares_per_second = H / (D × 2³²)
```

- pdiff 1 target: `0x00000000FFFFFFFF…FF`; bdiff 1 target: `0x00000000FFFF0000…00`.
- At difficulty 1: ~7.16 MH/s implied network hashrate; ~2³² hashes per share.
- Retarget every **2,016 blocks** (~2 weeks).

Worked [DERIVED]: 1 GH/s at difficulty 20,000 → `20,000 × 2³² / 1e9 = 85,900 s ≈ 23.85 h` per block on
average. 100 TH/s at pool difficulty 10,000 → `1e14 / (1e4 × 4.295e9) = 2.33 shares/s`. Both check out.

## Nonce exhaustion and why version rolling is mandatory [DERIVED]

At 100 TH/s:

| Search space | Size | Time to exhaust |
|---|---|---|
| 32-bit nonce only | 2³² | **43 µs** |
| + BIP320 version rolling (+24 bits) | 2⁵⁶ | **720 s (12 min)** |
| + 3-byte extranonce | 2⁸⁰ | ~3.8×10¹² s |

`2³²/1e14 = 4.3e-5 s`; `2⁵⁶/1e14 = 720 s`. **This is the hardest architectural constraint in the whole
round**: without version rolling a single modern ASIC would need a fresh job every few tens of
microseconds, which no pool could serve at any connection count. Version rolling is what makes the
job-push rate bounded and therefore makes the fan-out problem tractable. 2⁵⁶ also means a device faster
than ~72 PH/s exhausts a standard job in under one second.

## ASIC reference [READ, stale]

| Model | TH/s | W | J/TH |
|---|---|---|---|
| Antminer S9 | 14.0 | 1,375 | 98.2 |
| Antminer S19 | 110 | 3,250 | 29.5 |
| Whatsminer M30S++ | 112 | 3,472 | 31.0 |
| Avalon A1246 | 90 | 3,420 | 38.0 |

Source table current only through ~2023; 2025–26 models reach 200+ TH/s and are absent. The agent's
claim that S9-era hardware is "still 20–30% of network" is **unsourced — do not carry it**.

1 MW farm at 30 J/TH [DERIVED]: `1e6 W / 30 J/TH ≈ 33,333 TH/s ≈ 33.3 PH/s`.

## CORRECTED: the share-rate model

**What was reported.** Foundry at 233.7 EH/s with "average pool difficulty 50,000" →
`2.337e20 / (5e4 × 2³²) ≈ 1.09e6` **shares/sec**, i.e. **94 billion shares/day**, therefore
">1M shares/sec validation" as a headline requirement.

**The arithmetic is right. The model is wrong.**

Pool difficulty is not a property of the network; it is a **per-connection control variable the pool
sets**. Vardiff exists precisely to hold each connection's submission rate near a target (commonly one
share per 5–30 s). If the pool succeeds at that, then:

```
aggregate_shares_per_second ≈ connection_count / target_interval_seconds
```

— which contains **no hashrate term at all.** [DERIVED]

| Connections | Target interval | Aggregate shares/sec |
|---|---|---|
| 23,000 | 10 s | **2,300** |
| 23,000 | 5 s | 4,600 |
| 280,000 | 10 s | 28,000 |
| 2,000,000 | 10 s | 200,000 |

So Foundry's ~23,000-connection estimate implies **~2,300 shares/sec, not 1.09 million** — three orders
of magnitude lower. The reported figure describes a pool that has pinned every connection to difficulty
50,000 regardless of its hashrate, which is exactly what vardiff is designed to prevent. Recovering
1.09M shares/sec would require ~11 million connections at a 10 s interval.

**Consequence, and it is the central sizing insight of this round:** share-validation load scales with
**connection count**, not with hashrate. A pool can absorb an order of magnitude more hashrate at
constant share rate by raising difficulty — which is what production pools do (ckpool ships
high-difficulty rental ports at ≥1M minimum; solo.ckpool enforces a 10,000 floor). The component that
saturates first is therefore the **connection layer**, not the validator.

This is precisely the thesis of the `mining-scale-test-sim` hub topic ("vardiff smooths
share-validation rate, so the connection layer saturates first"). Independent arithmetic here agrees
with it.

**What difficulty is actually traded against**: raise it and you cut share rate and bandwidth, but you
increase per-miner payout variance and lengthen the feedback interval for hashrate estimation and for
detecting a dead miner. That is the real vardiff trade — not validator CPU.

## CORRECTED: per-share validation cost

**What was reported**: "~50–100 µs per share", built from ~15–20 double-SHA256 operations *plus*
"signature verification if using authenticated channels (Schnorr ~50 µs)", giving "~10 cores per 100k
shares/sec" and "~100 cores at 1M shares/sec".

**Two errors:**

1. **Schnorr verification is not per-share.** In SV2 the BIP340 signature lives in the
   `SIGNATURE_NOISE_MESSAGE` of the **Noise handshake certificate** — one verification per
   *connection*. Per-message cost is ChaCha20-Poly1305 AEAD, ~0.1 µs on a 24-byte payload. Including a
   50 µs signature per share inflates the estimate by roughly an order of magnitude on its own.
2. **A standard-channel share needs one hash, not a merkle rebuild.** The merkle root is fixed for the
   job. Validating a standard share means substituting the submitted nonce/nTime/version into the
   80-byte header and taking one double-SHA256 — about **3 SHA-256 compressions, ~0.3–0.5 µs**. Only an
   **extended** channel, where the miner varies extranonce inside the coinbase, requires rebuilding the
   coinbase txid and walking the merkle path (~12–14 levels × 3 compressions ≈ **4–10 µs**).

**Corrected** [DERIVED]: **~1 µs/share standard, ~10 µs/share extended.** At 1M shares/sec that is
**1–10 CPU-seconds per second — single-digit cores, not 100.** At the corrected realistic rate of
~2,300 shares/sec it is **~0.2% of one core.**

**Therefore: share validation is not the bottleneck, and no source in this round showed otherwise.**
ckpool's design agrees — it keeps validation in-process and in-memory and spends its complexity budget
on the connection layer and on process isolation instead.

## SV2 wire sizes [READ, from spec]

| Message | Payload bytes |
|---|---|
| `SubmitSharesStandard` | **24** (channel_id 4 + sequence_number 4 + job_id 4 + nonce 4 + ntime 4 + version 4) |
| `SubmitShares.Success` | 20 |
| `NewMiningJob` (standard) | ~45 |
| `OpenStandardMiningChannel` | ~60–80 |
| `…Success` | ~50 |
| Noise handshake, both directions | 298 |

Handshake detail: part 1 = 64 B ephemeral pubkey; part 2 = 234 B (64 ephemeral + 64 encrypted static
pubkey + 16 MAC + 74 `SIGNATURE_NOISE_MESSAGE` + 16 MAC). The signature message is version 2 B +
valid_from 4 B + not_valid_after 4 B + **BIP340 signature 64 B**.

**Not included in those payload numbers** [DERIVED]: the SV2 frame header (extension_type 2 B +
msg_type 1 B + msg_length 3 B = **6 B**), the ChaChaPoly **16 B MAC**, and TCP/IP (~40 B). A 24-byte
share is therefore ~46 B framed and encrypted, ~86 B on the wire — so the real overhead ratio is closer
to 3.5× the payload than the "20–40% higher" the agent allowed.

**Caveat**: `NewMiningJob`'s `future_job: bool` field was reported, but current sv2-spec uses
`min_ntime: OPTION[u32]`. The message-size table may reflect an older spec revision. Verify against
sv2-spec before using these for capacity planning.

## Bandwidth [DERIVED, corrected basis]

At the corrected share rate, bandwidth is trivial. 23,000 connections at one share per 10 s, 86 B on
the wire per share: `2,300 × 86 ≈ 198 kB/s ≈ 1.6 Mbit/s` for share ingest. Job push at 45 B + 6 B
framing to 23,000 connections on every template change, at one change per 10 s:
`23,000 × 51 / 10 ≈ 117 kB/s`.

**Total order of magnitude: single-digit Mbit/s**, not the 0.5–2 Gbit/s reported (which followed from
the 1M shares/sec error). **Bandwidth is not a constraint for a stratum pool at any plausible scale.**
The one exception is the *template* path: a ~10 MB `getblocktemplate` response fetched frequently from
the node, which is why ckpool sizes 64 MB buffers there.

## Connection capacity [READ + DERIVED]

- **public-pool**: `STRATUM_MAX_CONNECTIONS_PER_LISTENER` default **10,000 per worker per port**;
  documented example 28 workers → **280,000** on one port. A configured cap, **not a measured
  ceiling**.
- Kernel memory per connection, measured elsewhere (MigratoryData, 12M connections): **~3 KB**
  (~3 GB per million). Application state adds per-miner difficulty, extranonce, last-share time,
  rolling averages.
- [DERIVED] 23,000 connections ≈ 70 MB kernel + application state — negligible on any server.

The agent's "~40 KB per connection → 11.2 GB for 280,000" conflates *configured TCP buffer size* with
*resident memory*; buffers are allocated as needed, and the measured figure from a 12M-connection
deployment is ~3 KB. Prefer 3 KB.

## Consolidated constants

| Constant | Value | Basis |
|---|---|---|
| Network hashrate | 945.8 EH/s | READ (2026-09) |
| Difficulty | 132.76 T | READ, cross-checked |
| Largest pool | 233.7 EH/s (23.4%) | READ |
| Top-5 concentration | ~78% | READ |
| shares/sec per connection | **1 / vardiff target interval** | DERIVED — the key relation |
| Aggregate shares/sec | **connections / interval** (no hashrate term) | CORRECTED |
| Share validation, standard channel | ~1 µs | CORRECTED |
| Share validation, extended channel | ~10 µs | CORRECTED |
| Cores at 1M shares/sec | 1–10 | CORRECTED (was 100) |
| Nonce-only exhaustion @100 TH/s | 43 µs | DERIVED |
| With version rolling | 720 s | DERIVED |
| SV2 share on the wire | ~86 B framed+encrypted+TCP | DERIVED |
| Kernel memory per connection | ~3 KB | READ (MigratoryData) |
| Connections per worker (public-pool) | 10,000 (configured) | READ |
| Template size | ~10 MB JSON | READ |

## The gap this file cannot close

**No source in this round published a benchmark of any pool software** — no measured shares/sec, no
measured connections, no CPU-per-share, no comparison across implementations. Every implementation
claims high performance; none substantiates it. The numbers above are network-scale observations plus
arithmetic. A real sizing model needs a harness, which is what `mining-scale-test-sim` exists to build.
