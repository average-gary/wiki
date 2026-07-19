---
title: "Monoio official benchmark (Dec 2021): the canonical 2-3x-tokio claim"
source_url: https://github.com/bytedance/monoio/blob/master/docs/en/benchmark.md
type: article
ingested: 2026-06-24
quality: 4
confidence: medium
tags: [scale, monoio, tokio, rust, benchmark, primary-source, stale-2021]
---

# Monoio official benchmark (Dec 2021)

The canonical primary source for monoio's "thread-per-core io_uring is
faster than tokio" claim. **Dated 2021-12-01.** Still cited in 2024-2026
articles. Bytedance has not published a refreshed cross-runtime
benchmark.

## Hardware

- Intel Xeon Gold 5118 @ 2.30 GHz
- Intel X710 10 GbE NIC
- Linux 5.15.4-arch1-1
- Rust nightly-2021-11-26

## Claim summary

- Connection counts tested: 80, 250 (per configuration), plus "extreme
  performance" loops with varying connection counts.
- Core counts: 1, 4, 8, 16.

> "At 1 core, monoio's latency will be higher than tokio, resulting in
> lower throughput than tokio." (Stems from io_uring vs epoll
> architectural overheads when batching has nothing to batch.)
>
> "At 4 cores, monoio peak performance ~2× tokio."
>
> "At 16 cores, monoio peak performance ~3× tokio."

Detailed numbers exist in `raw_data.txt` in the repo but are
presented as charts in the README. The README does not transcribe exact
RPS/latency figures.

## Status of this benchmark as of 2026

- Tokio versions tested are 0.x / very-early-1.x (2021-11). Five years
  of tokio scheduler work since.
- io_uring kernel maturity in 2021 vs 2026: Linux 5.15 had io_uring but
  many features (multishot recv, registered buffers, IORING_OP_SEND_ZC)
  shipped in 5.19-6.0+. Monoio added zero-copy send in 2026-04 (commit
  2c05c4a).
- The 2024 cnblogs benchmark (4 cores, 80 conns) shows the gap has
  closed at this scale — within ~5% RPS for tokio/monoio. The 2-3x
  number does not reproduce in 2024 at the cnblogs config.

## Caveats vs SV2 mining-scale

- 1KB request / 1KB response. SV2 share messages are 16-512 B (smaller).
  Smaller messages reduce per-RPC cost ⇒ scheduler overhead becomes a
  larger fraction of total cost ⇒ the runtime difference may be larger
  for SV2-shaped traffic than for 1KB ping-pong. **Not measured.**
- Persistent connection model: monoio benchmark uses long-lived TCP
  connections (good match for stratum). But test connection counts are
  ~80-250, far below the 1M target for ckpool-scale pools.

## What's still useful from this benchmark

- The qualitative shape: monoio loses at single-core, gains at multi-
  core. SV2 pool servers in Rust would typically run multi-threaded ⇒
  monoio's region of advantage is the relevant region.
- The architectural argument: io_uring batching amortizes syscall cost
  over multiple completions, which scales with traffic. For a pool
  doing 300k share-submit packets/sec, batching has plenty of material.

## Source

- https://github.com/bytedance/monoio/blob/master/docs/en/benchmark.md
- Date: 2021-12-01
- Active development: monoio is still maintained (commits through
  May 2026), but no new benchmark report published.
