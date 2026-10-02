---
title: "Pool Sizing Model"
category: reference
sources:
  - raw/data/2026-09-21-pool-scale-and-sizing-constants.md
  - raw/data/2026-09-21-sv2-claimed-performance-gains-vendor.md
  - raw/notes/2026-09-21-adjacent-systems-design-transfer.md
  - raw/repos/2026-09-21-public-pool-and-miningcore-managed-runtime-pools.md
  - raw/articles/2026-09-21-dmnd-datum-decentralised-template-deployments.md
created: 2026-09-21
updated: 2026-09-21
tags: [sizing, capacity-planning, shares-per-second, difficulty-math, nonce-exhaustion, connection-memory, bandwidth, validation-cost, derived-constants]
aliases: ["capacity planning", "shares per second", "sizing constants"]
confidence: medium
volatility: warm
summary: "Citable constants for sizing a pool, with the derivations shown and two commonly-quoted figures corrected. The central relation: aggregate share rate is connection_count / vardiff_interval and contains no hashrate term, so a pool's load is set by how many sockets it holds, not by how much hashrate is behind them."
---

# Pool Sizing Model

> **Status.** Network-scale figures are observational (2026-09). The difficulty arithmetic is
> canonical. Everything else is derived, and two widely-quoted derived figures are corrected here.
>
> **Corrected 2026-09-22.** This article previously said no benchmark of any pool software existed. That
> was wrong: two empirical SV1-vs-SV2 benchmarks on real ASICs are published, with a reusable open-source
> harness — see **Measured latency** below. What does *not* exist is any benchmark comparing pool
> **implementations** to each other, so implementation-choice arguments still rest on architecture rather
> than measurement.

## Canonical arithmetic

```
difficulty        = difficulty_1_target / current_target
expected_hashes   = D × 2⁴⁸ / 0xffff          (≈ D × 2³²)
network_hashrate  = D × 2³² / 600
time_to_solve     = D × 2³² / hashrate
shares_per_second = H / (D × 2³²)          ← per connection, at that connection's difficulty
```

Retarget every 2,016 blocks. pdiff-1 target `0x00000000FFFFFFFF…FF`; bdiff-1 target
`0x00000000FFFF0000…00`.

## Network state, 2026-09

| | |
|---|---|
| Network hashrate | **945.80 EH/s** |
| Difficulty | **132.76 T** |
| Largest pool | Foundry USA, 233.7 EH/s (**23.40%**) |
| Top 3 concentration | ~60% (Foundry + AntPool + F2Pool) |
| Top 5 concentration | ~78% |
| Pools tracked | 18 |
| Block subsidy | 3.125 BTC; observed fees 0.01–0.07 BTC in a low-fee period |

Cross-check performed: `132.76e12 × 2³² / 600 ≈ 9.50e20 H/s = 950 EH/s` against the reported 945.80.
Self-consistent — the pair can be trusted.

Caveat: pool hashrate is *inferred from blocks found*, so a 7-day window carries ~√n variance. Two
trackers reported Foundry at 191.61 and 233.7 EH/s in the same month; that gap is the measurement
noise.

## The central relation (and the figure it corrects)

**Commonly quoted, and wrong**: "Foundry at 233.7 EH/s with pool difficulty 50,000 must validate
`2.337e20 / (5e4 × 2³²) ≈ 1.09 million shares/sec`, i.e. 94 billion shares/day."

The arithmetic is right; the model is wrong. **Pool difficulty is not a property of the network — it
is a per-connection control variable the pool sets**, and vardiff exists to hold each connection near a
target submission interval. If it succeeds:

```
aggregate_shares_per_second ≈ connection_count / target_interval_seconds
```

**No hashrate term.**

| Connections | Target interval | Aggregate shares/sec |
|---|---|---|
| 23,000 | 10 s | **2,300** |
| 23,000 | 5 s | 4,600 |
| 280,000 | 10 s | 28,000 |
| 2,000,000 | 10 s | 200,000 |

So a ~23,000-connection pool at Foundry's scale is doing **~2,300 shares/sec, not 1.09 million** —
three orders of magnitude lower. Recovering the larger figure would need ~11 million connections.

**Consequence**: share-validation load scales with **connection count**, not hashrate. A pool absorbs
more hashrate at constant share rate by raising difficulty, which production pools do (solo.ckpool's
10,000 floor; ckpool's ≥1M-difficulty rental ports). **The connection layer saturates first.** See
[[vardiff-as-control-loop|Vardiff as a Control Loop]] ([Vardiff as a Control Loop](../concepts/vardiff-as-control-loop.md)).

## Per-share validation cost (corrected)

**Commonly quoted**: ~50–100 µs per share, therefore ~100 cores at 1M shares/sec.

Two errors in that estimate:

1. **Schnorr verification is not per-share.** In SV2 the BIP340 signature is in the
   `SIGNATURE_NOISE_MESSAGE` of the Noise handshake certificate — once per *connection*. Per-message
   cost is ChaCha20-Poly1305 AEAD, ~0.1 µs on a 24-byte payload.
2. **A standard-channel share needs one hash, not a merkle rebuild.** The merkle root is fixed for the
   job; validation substitutes the submitted nonce/nTime/version into the 80-byte header and takes one
   double-SHA256.

| Channel type | Work | Cost |
|---|---|---|
| Standard | 1 × double-SHA256 of 80 B (~3 compressions) | **~1 µs** |
| Extended | coinbase txid + ~12–14 level merkle path (~40 compressions) | **~10 µs** |

**Corrected**: 1M shares/sec needs **1–10 cores**, not 100. At a realistic ~2,300 shares/sec it is
**~0.2% of one core**. Share validation is not the bottleneck.

## Search space and nonce exhaustion

At 100 TH/s:

| Search space | Size | Time to exhaust |
|---|---|---|
| 32-bit nonce only | 2³² | **43 µs** |
| + BIP320 version rolling (+24 bits) | 2⁵⁶ | **720 s (12 min)** |
| + 3-byte extranonce | 2⁸⁰ | ~3.8×10¹² s |

**This is the hardest constraint in pool architecture.** Without version rolling a single modern ASIC
would need a fresh job every few tens of microseconds — no pool could serve that at any connection
count. Version rolling is what bounds the job-push rate and makes the fan-out problem tractable. 2⁵⁶
also means a device faster than ~72 PH/s exhausts a standard job in under a second.

## Wire sizes (SV2)

| Message | Payload |
|---|---|
| `SubmitSharesStandard` | **24 B** (channel_id, sequence_number, job_id, nonce, ntime, version — 6 × U32) |
| `SubmitShares.Success` | 20 B |
| `NewMiningJob` (standard) | ~45 B |
| `OpenStandardMiningChannel` | ~60–80 B |
| Noise handshake, both directions | 298 B |

**Add to every message**: the 6-byte SV2 frame header (`extension_type` U16 + `msg_type` U8 +
`msg_length` U24), a 16-byte ChaChaPoly MAC, and ~40 bytes of TCP/IP. So a 24-byte share is ~46 B
framed and encrypted, **~86 B on the wire** — an overhead ratio nearer 3.5× the payload than the
"20–40%" sometimes quoted.

*Caveat: the `NewMiningJob` size assumes a `future_job: bool` field; current sv2-spec uses
`min_ntime: OPTION[u32]`. Verify against the spec before capacity planning.*

## Bandwidth

At 23,000 connections, one share per 10 s, 86 B on the wire:

- Share ingest: `2,300 × 86 ≈ 198 kB/s ≈ 1.6 Mbit/s`
- Job push (45 B + 6 B framing, per template change at one per 10 s): `23,000 × 51 / 10 ≈ 117 kB/s`

**Order of magnitude: single-digit Mbit/s. Bandwidth is not a constraint for a stratum pool at any
plausible scale.** The exception is the *template* path: a ~10 MB `getblocktemplate` response fetched
frequently from the node, which is why ckpool sizes 64 MB socket buffers there.

This is also why the vendor bandwidth-reduction claims for SV2, whatever their true magnitude, are
optimising a resource that was never binding. See
the [SV2 vendor claims audit](../../raw/data/2026-09-21-sv2-claimed-performance-gains-vendor.md).

## Connections and memory

| Figure | Value | Source |
|---|---|---|
| Kernel memory per connection | **~3 KB** (~3 GB/million) | measured at 12M connections (MigratoryData) |
| Connections per worker, public-pool | **10,000** (configured default) | public-pool docs |
| Documented example total | 28 workers × 10,000 = **280,000** on one port | public-pool docs |
| DATUM gateway guidance | **~1 GB per 1,000 clients** (~1 MB each) | Ocean docs |

The 3 KB and 1 MB figures differ by ~300×. The former is kernel-side only; the latter is
application-state guidance and possibly conservative. Both are useful: connection *count* is cheap at
the kernel, and per-miner application state is what actually sets the ceiling. A single listening port
is never the limit — uniqueness is on the four-tuple.

## Hardware reference (stale)

| Model | TH/s | J/TH |
|---|---|---|
| Antminer S9 | 14.0 | 98.2 |
| Antminer S19 | 110 | 29.5 |
| Whatsminer M30S++ | 112 | 31.0 |

Table is current only through ~2023; 2025–26 models reach 200+ TH/s. A 1 MW farm at 30 J/TH is
**~33 PH/s**.

## Consolidated

| Constant | Value | Basis |
|---|---|---|
| Aggregate shares/sec | **connections / vardiff interval** | derived — the key relation |
| Share validation, standard | ~1 µs | corrected |
| Share validation, extended | ~10 µs | corrected |
| Cores at 1M shares/sec | 1–10 | corrected (was 100) |
| Nonce-only exhaustion @100 TH/s | 43 µs | derived |
| With version rolling | 720 s | derived |
| SV2 share on the wire | ~86 B | derived |
| Kernel memory/connection | ~3 KB | measured (other domain) |
| Template size | ~10 MB JSON | read |
| Network hashrate | 945.8 EH/s | read, cross-checked |

## Measured latency (SV1 vs SV2)

From two published benchmarks on real ASICs (testnet4, WAN latency injected from live pool RTT), the only
measured pool-software figures on record:

| Metric | SV1 | SV2 | Run |
|---|---|---|---|
| New job latency (mean) | 142 ms | **7.33 ms** | Oct 2025, 10× S21Imm |
| New job after block | 158 ms | 57.3 ms | Oct 2025 |
| Block propagation | 50.5 ms | **1.43 ms** | Oct 2025 |
| Share acceptance | 98.7% | 100% (0 stale of 164,408) | Oct 2025 |
| New job latency (mean) | 115 ms | 16 ms | Sep 2024, 6× S19k Pro |
| Block propagation | 79 ms | 1.5 ms | Sep 2024 |

**SV1 stale rate: 1.34%** (1,114 of 82,870). Zero stale observed for SV2 — consistent with a small
non-zero rate over a ~4-day window, not evidence of a 0% protocol property.

**Bandwidth is a trade, not a reduction**: SV2 used *more* at the farm (521 vs 245 B/s) and *less* at the
pool (402 vs 551 B/s), because Job Declaration moves roles onto the miner's premises. Both are hundreds of
bytes per second — confirming bandwidth was never binding.

Limitations: testnet4 only, 6–10 ASICs, simulated WAN latency, a *solo* pool as the SV1 arm, and a
non-independent evaluator. And the SV2 project's published figures (228 → 57.7 → 2.44 ms) **do not match
these reports** and remain unsourced.

## The gap

A real sizing model still needs a harness that measures **one pool implementation against another** under
synthetic load. The `stratum-mining/benchmarking-tool` harness is reusable and closes the
protocol-comparison half; the `mining-scale-test-sim` hub topic covers the vardiff/scale half, and its
thesis — vardiff smooths share-validation rate so the connection layer saturates first — is independently
reproduced by the arithmetic above.

## See Also

- [[vardiff-as-control-loop|Vardiff as a Control Loop]] ([Vardiff as a Control Loop](../concepts/vardiff-as-control-loop.md))
- [[connection-layer-scaling|Connection Layer Scaling]] ([Connection Layer Scaling](../concepts/connection-layer-scaling.md))
- [[the-two-hot-paths|The Two Hot Paths]] ([The Two Hot Paths](../concepts/the-two-hot-paths.md))
- [[optimal-pool-architecture|Optimal Pool Architecture]] ([Optimal Pool Architecture](../topics/optimal-pool-architecture.md))
