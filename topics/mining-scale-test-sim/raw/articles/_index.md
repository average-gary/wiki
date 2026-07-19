---
title: raw/articles
---

# raw/articles

## Path-2 (connection-scale bottlenecks) — 2026-06-24

- [2026-06-24-path2-sri-noise-sv2-benches.md](2026-06-24-path2-sri-noise-sv2-benches.md) — SRI noise-sv2 cargo bench: 317 µs/handshake, 5-16 µs/frame transport.
- [2026-06-24-path2-ckpool-architecture.md](2026-06-24-path2-ckpool-architecture.md) — ckpool design for million-client scale: passthrough, epoll, maxclients=90% RLIMIT, vardiff drr=0.3.
- [2026-06-24-path2-public-pool-backpressure.md](2026-06-24-path2-public-pool-backpressure.md) — public-pool.io's published backpressure thresholds: 10k conn/listener, 2.5 GB RSS, 2s event-loop p95.
- [2026-06-24-path2-cloudflare-million-packets.md](2026-06-24-path2-cloudflare-million-packets.md) — Cloudflare: SO_REUSEPORT unlocks 1.1M pps on a 10G NIC; 4x NUMA penalty.
- [2026-06-24-path2-c10k-kegel.md](2026-06-24-path2-c10k-kegel.md) — Kegel's C10K: kernel architectures, per-client cost model. C10K solved, C10M live.
- [2026-06-24-path2-tokio-scheduler.md](2026-06-24-path2-tokio-scheduler.md) — Tokio work-stealing scheduler benches: 152k req/s Hyper, ~170 ns/wake fast path.
- [2026-06-24-path2-cloudflare-tcp-port.md](2026-06-24-path2-cloudflare-tcp-port.md) — Linux TCP port states; ephemeral port exhaustion for the simulator side.
- [2026-06-24-path2-sv2-spec-security.md](2026-06-24-path2-sv2-spec-security.md) — SV2 spec §04: Noise_NX, no resumption, secp256k1 + ChaCha20-Poly1305.

## Path-4 (share-validation cost model) — 2026-06-24

- [2026-06-24-path4-sha256-throughput-modern-cpus.md](2026-06-24-path4-sha256-throughput-modern-cpus.md) — SHA-NI throughput baseline (~1.7 GB/s/core), per-share SHA cost ~1–2 µs, total realistic 5–20 µs per share

## Round-2 path-D (vardiff ramp-up vs steady state) — 2026-06-24

- [2026-06-24-r2-pathD-ckpool-startdiff-code.md](2026-06-24-r2-pathD-ckpool-startdiff-code.md) — quoted code from ckpool.c (startdiff=42, mindiff=1 defaults), stratifier.c (initial assignment at line 3456, the 72-share/240-second gate at 5783, hysteresis (0.15, 0.4) at 5805, retarget rule dsps×3.33 at 5821), libckpool.c decay_time EWMA primitive, plus first-retarget latency table by miner class.

## Round-2 path-C (modern tokio benchmarks 2024-2026) — 2026-06-24

- [2026-06-24-r2-pathC-tokio-modern-benchmarks.md](2026-06-24-r2-pathC-tokio-modern-benchmarks.md) — Synthesis: 2019 per-wake number survives; LIFO regression +8.5% CPU on µs-handler workload (1.51/1.52.0/1.52.1); no public 1M-conn 2024+ benchmark exists.
- [2026-06-24-r2-pathC-tokio-changelog-2024-2026.md](2026-06-24-r2-pathC-tokio-changelog-2024-2026.md) — Tokio CHANGELOG.md 1.42-1.52: perf-relevant PRs and dates; io_uring is fs-only.
- [2026-06-24-r2-pathC-tokio-lifo-regression.md](2026-06-24-r2-pathC-tokio-lifo-regression.md) — Issue #8065: production +8.5% CPU on high-QPS µs-handler service; 18× worker-steal rate; pin tokio to 1.50.x or ≥1.52.2.
- [2026-06-24-r2-pathC-cnblogs-4runtime-2024.md](2026-06-24-r2-pathC-cnblogs-4runtime-2024.md) — Dec 2024 4-runtime k6 benchmark, 4-core GCP / 80 conns: tokio 110,883 RPS, monoio 113,239, glommio 108,493; all within 5%.
- [2026-06-24-r2-pathC-shbhmrzd-tokio-uring-2024.md](2026-06-24-r2-pathC-shbhmrzd-tokio-uring-2024.md) — Dec 2024 tokio (4,560 ops/s) vs tokio-uring (3,932 ops/s) on TCP+Kafka; tokio +13%, tokio-uring stalls under load.
- [2026-06-24-r2-pathC-monoio-benchmark-2021.md](2026-06-24-r2-pathC-monoio-benchmark-2021.md) — Canonical 2-3× tokio claim is from Dec 2021 / 16-core / 1KB; not refreshed; doesn't reproduce at smaller scale in 2024.
- [2026-06-24-r2-pathC-tokio-perf-prs-2026.md](2026-06-24-r2-pathC-tokio-perf-prs-2026.md) — Modern perf PRs: sharded spawn_blocking (-91% @ 16 threads), alt timer, eager driver handoff, LIFO re-enable proposal.
