---
title: "BLAKE3 vs SHA-256 benchmark numbers (specs repo + iroh hashing-multi-blobs)"
source: https://github.com/BLAKE3-team/BLAKE3-specs/blob/master/benchmarks/bar_chart.py, https://www.iroh.computer/blog/hashing-multiple-blobs-with-BLAKE3
type: article
tags: [blake3, sha256, benchmark, simd, avx-512, neon, hashing-throughput]
date: 2026-06-01
quality: 5
confidence: high
agent: 8
summary: "AWS c5.metal Cascade Lake-SP (AVX-512), single-thread, 16 KiB input: BLAKE3 6866 MiB/s; SHA-256 484 MiB/s — ~14.2x faster. 0.49 cycles per byte on Cascade Lake-SP with AVX-512. Apple M1 (NEON, 1 GiB total = 1,048,576 × 1024-byte blobs): sequential 1.28 s (~819 MB/s); SIMD only 547.3 ms (~1.92 GB/s); SIMD + Rayon 75.2 ms (~13.9 GB/s) — 17x speedup, ~2.5x faster than SHA-256 on the same hardware."
---

# BLAKE3 throughput numbers

Anchors the wiki's BLAKE3-on-Pascal-host estimate.

## AWS c5.metal (Cascade Lake-SP, AVX-512), single-thread, 16 KiB input

| Hash         | MiB/s | vs SHA-256 |
|--------------|------:|----------:|
| **BLAKE3**   | 6,866 | 14.2× |
| BLAKE2b      | 1,312 | 2.7× |
| SHA-1        | 1,027 | 2.1× |
| BLAKE2s      |   876 | 1.8× |
| MD5          |   740 | 1.5× |
| SHA-512      |   720 | 1.5× |
| **SHA-256**  |   484 | 1× |
| SHA3-256     |   394 | 0.81× |

**0.49 cycles per byte** on Cascade Lake-SP with AVX-512 (Wikipedia BLAKE).

## Apple M1 (NEON, 1 GiB total = 1,048,576 × 1024-byte blobs)

| Configuration         | Time   | Throughput |
|-----------------------|-------:|----------:|
| Sequential reference  | 1.28 s |  ~819 MB/s |
| Rayon (multi-thread, no SIMD) | 151.5 ms | ~6.9 GB/s |
| SIMD only (single-thread NEON) | 547.3 ms | ~1.92 GB/s |
| **SIMD + Rayon combined** | 75.2 ms | **~13.9 GB/s** |

- 17× speedup SIMD+Rayon vs sequential
- ~2.5× faster than SHA-256 on the same hardware

## Pascal-host estimate (i7-7700HQ, AVX2 only, 4 cores / 8 threads)

By cycles-per-byte extrapolation:

- 0.49 cpb @ 3.5 GHz with AVX-512 = ~7.1 GiB/s
- AVX2 typically runs ~0.6-0.8× of AVX-512 on the same core
- **Single-thread estimate: ~3-4 GiB/s on i7-7700HQ**
- Multi-thread (4-thread Rayon): ~12-15 GiB/s plausible

→ BLAKE3 hashing is **not** the bottleneck for iroh-blobs on this class of CPU. Network/disk dominates.

## Caveat — BLAKE3 issue #315

On M2 Max single-thread, BLAKE3 ran ~37% slower than OpenSSL's hardware-accelerated SHA-256 (2.58 s vs 1.71 s, 4 GB file). On Apple Silicon, SHA-256 has dedicated instructions that BLAKE3 can't compete with. **Pre-AVX2 x86 hosts (Sandy/Ivy Bridge era) get the SSE4.1 path — slowest BLAKE3 profile.**

The GTX 1060 server's i7-7700HQ has AVX2, so it's not in the worst case, but is also not in the AVX-512 best case.

## See also

- [[2026-06-01-blake3-specs-bao]]
- [[2026-06-01-iroh-blobs-1-0-rc]]
