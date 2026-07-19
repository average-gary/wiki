---
title: SHA-256 throughput on modern CPUs (SHA-NI extension)
source_type: articles
source_url: https://en.wikipedia.org/wiki/Intel_SHA_extensions
fetched: 2026-06-24
path: 4
tags: [sha256, performance, sha-ni, share-validation, hashing-cost]
---

# SHA-256 throughput — share-validation cost baseline

Share validation does ~14 SHA-256 rounds per share (1 coinbase txid +
~12 merkle path reductions + 1 block-header SHA256d). Knowing per-byte
SHA-256 cost gives us a hard floor on validation throughput.

## SHA-NI hardware acceleration support

From the Wikipedia "Intel SHA extensions" article:

> Intel SHA Extensions were originally specified in 2013...
> **AMD: Zen microarchitecture (2017 onwards) supports the original
> SHA instruction set.**
> **Intel: Goldmont Atom (2016+), Cannon Lake/Ice Lake (2018-2019),
> Rocket Lake for desktops (2021+) all support original SHA extensions.**

So **any post-2017 server CPU** has SHA-NI. SHA-512 is much rarer
(Intel Arrow/Lunar Lake 2024+), but Bitcoin uses SHA-256.

## Throughput baselines (industry-published, not from this fetch but well-known)

| Variant | Cycles/byte | Throughput @ 3 GHz |
|---|---|---|
| Generic C (pre-SHA-NI) | ~10 cpb | ~300 MB/s |
| SSE4 | ~6 cpb | ~500 MB/s |
| AVX2 | ~4–5 cpb | ~600–700 MB/s |
| SHA-NI | ~1.6–1.9 cpb | ~1.7 GB/s |

(Bitcoin Core ships all four variants — see
`src/bench/crypto_hash.cpp`: `SHA256_STANDARD`, `SHA256_SSE4`,
`SHA256_AVX2`, `SHA256_SHANI`. `SHA256D64_1024_SHANI` benchmarks the
double-SHA256 path specifically.)

## Per-share validation cost (back-of-envelope)

Inputs:
- Coinbase tx: ~250–800 B (varies with extranonce + outputs)
- Merkle path: 12 × 64 B = 768 B
- Block header: 80 B

Total bytes hashed: ~1.0–1.6 KB per share.

At SHA-NI throughput 1.7 GB/s on one core:
- ~0.6–1.0 µs of pure SHA work per share.
- Plus SHA round setup overhead (per-message init/finalize is roughly
  fixed cost ~30–50 cycles), with 14 rounds × ~50 cycles ≈ 700 cycles ≈
  0.25 µs at 3 GHz.

**Total SHA cost ≈ 1–2 µs per share on a SHA-NI core.**

Adding the non-hash work (deserialize coinbase tx, HashMap lookup,
hashtable insert, lock acquire), realistic ckpool/SRI numbers come to
**5–20 µs per share** as measured empirically (see ckpool / SRI source
notes). One x86 core can therefore sustain **50,000–200,000
shares/sec** of validation throughput — well above any realistic
N × SPM aggregate rate for pools below 1M connections.

## Comparison to network rate

100,000 connections at 6 SPM = 10,000 shares/sec aggregate.
- Validation: 0.05–0.2 cores
- Network egress: 10k × ~150 B SubmitShares.Success batched at
  share_batch_size=10 = 150 KB/s ≈ 1.2 Mbit/s.
- Network ingress: 10k × ~140 B SubmitSharesExtended = 1.4 MB/s ≈
  11 Mbit/s.

So at the **default SV2 defaults**, network I/O dominates validation
by a factor of ~10× even for the validation-friendly numbers.

## Sources

- Wikipedia, "Intel SHA Extensions" (verified 2026-06-24).
- Bitcoin Core `src/bench/crypto_hash.cpp` for the canonical Bitcoin
  SHA256 benches (BUFFER_SIZE=1e6, SHA256D64_1024 variants).
- Throughput numbers from Intel/AMD published benchmarks (well-known
  industry figures, ~1.7 GB/s SHA-NI single-core).
