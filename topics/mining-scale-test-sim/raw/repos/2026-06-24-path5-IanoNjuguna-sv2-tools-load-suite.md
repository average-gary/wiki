---
title: "IanoNjuguna/stratum-v2-tools :: sv2-test/PerformanceLoadTestSuite — existing SV2 load suite"
type: raw-source
source_kind: repo
source_url: https://github.com/IanoNjuguna/stratum-v2-tools/blob/main/sv2-test/examples/performance_load_demo.rs
fetched: 2026-06-24
path: 5
relevance: medium
---

# stratum-v2-tools PerformanceLoadTestSuite

Found via GitHub code search (`stratum v2 load test language:rust`). Solo
contributor repo (Ianoe Njuguna), Rust, has an honest-to-god
`PerformanceLoadTestSuite` with a `LoadTestConfig` struct.

## Config surface (from `performance_load_demo.rs`)

```rust
LoadTestConfig {
    max_concurrent_connections: 1200,        // demos go up to 1200
    test_duration_seconds: 30,
    shares_per_connection: 50,
    target_connections_per_second: 50.0,     // ramp-up rate
    memory_limit_mb: 500,
    cpu_usage_limit_percent: 85.0,
    enable_protocol_translation_test: true,  // SV1<->SV2 translation
    enable_share_validation_benchmark: true,
    enable_memory_stress_test: true,
    connection_timeout_ms: 10000,
    share_submission_rate_hz: 10.0,          // shares/sec/connection
}
```

The result struct reports:
- `successful_connections`, `failed_connections`
- `total_shares_submitted`, `total_shares_accepted`
- `performance_benchmarks.share_validation_ops_per_second`
- `performance_benchmarks.protocol_translation_ops_per_second`
- `performance_benchmarks.connection_handling_ops_per_second`
- `peak_memory_usage_mb`, `average_cpu_usage_percent`
- `overall_performance_score`

## Scale ceiling

Demos cap at **1,200 concurrent connections** — explicit goal "exceed 1000+
requirement". This is a *correctness/regression* harness, not a
million-connection scale harness. The author appears to be using it to
prove "the tool works at 1k+" rather than to find the saturation point.

Marketed numbers in demo: share validation > 1000 ops/s, protocol
translation > 500 ops/s, memory < 300 MB, CPU < 90%.

## Verdict

- Existing prior art for "Rust SV2 load test" but **wrong scale band**
  (1k, not 100k or 1M).
- Worth reading for the config-struct shape and the metric set —
  `LoadTestConfig` is a sensible field set for our own harness.
- Single-contributor repo, unclear maturity / activity.
- Not a substitute for a from-scratch tokio + noise-sv2 harness if the
  goal is to push 100k+ connections.

## Related code-search hits (other SV2 test/bench files in the wild)

- `braiins/braiins-open :: protocols/stratum/src/test_utils/v2.rs` —
  Braiins' SV2 test utilities (Rust)
- `average-gary/datum-rs :: crates/datum-stratum-sv2/tests/sv2_loopback.rs`
  — Datum-rs loopback test
- `arejula27/mining-pool :: pool/tests/sv2_server.rs`
- `vnprc/hashpool :: roles/test-utils/mining-device/benches/scaling_bench.rs`
  — this is *hashing*-scaling (FastSha256d threads), not connection-scaling

None of these are off-the-shelf million-connection harnesses; all are
correctness-test fixtures.
