---
title: "IanoNjuguna/stratum-v2-tools PerformanceLoadTestSuite — deep-read & fork-vs-rewrite decision"
source_url: https://github.com/IanoNjuguna/stratum-v2-tools/blob/main/sv2-test/src/performance_load_tests.rs
type: repo
ingested: 2026-06-24
quality: 4
confidence: high
tags: [stratum-v2, load-test, rust, tokio, mock-only, fork-vs-rewrite, scale-test]
---

# stratum-v2-tools PerformanceLoadTestSuite — round 2 deep-read

Round 1 (path-5) identified that `IanoNjuguna/stratum-v2-tools` contains a
`PerformanceLoadTestSuite` but only inspected the demo entry-point. This
deep-read pulls the actual implementation
(`sv2-test/src/performance_load_tests.rs`, 852 lines, commit `f4b9bd90`)
and the workspace surface to settle the fork-vs-write-from-scratch
question.

## Repo metadata

- `full_name`: `IanoNjuguna/stratum-v2-tools`
- `description`: "Self-Hosted Sovereign Mining Infrastructure"
- `default_branch`: `main`
- `created_at`: 2025-09-20
- `last_push`: 2025-10-25 (8 months stale as of 2026-06-24)
- `stars`: 0, `forks`: 0
- `size`: 435 KB
- `license`: **none declared** (LICENSE file absent, `license` field null
  via the API). README closes with bare "This project is open source."
- contributors: 1 (`xyephy`, 13 commits — the `IanoNjuguna` account does
  not appear as a commit author at all)
- 13 total commits across the history; from "Initial commit" 2025-09-20
  through "doc update" 2025-10-25.

Commit log shows a heavy "demo-shipping" cadence (workshop guides,
README/docs, demo scripts) and only a single bug-fix commit
("Fix sv2d and sv2-cli pipe blocking and auto-start bugs", 2025-10-23).
Hallmarks of a workshop-grade artifact, not an actively maintained tool.

## Workspace layout

```
sv2-core/   # daemon library — SRI-based SV2 + SV1 wrappers
sv2d/       # daemon binary
sv2-cli/    # CLI front-end
sv2-web/    # web UI
sv2-test/   # *** the load-test crate ***
```

`sv2-test/Cargo.toml` deps: only `sv2-core` + `tokio`, `serde`,
`anyhow`, `async-trait`, `bitcoin`, `uuid`, `chrono`, `rand`, `tempfile`,
`env_logger`, `reqwest`, `tracing`. **No `noise-sv2`, no `framing-sv2`,
no `codec_sv2` directly — load-test crate does not speak SV2 wire
protocol**. (The workspace's SRI deps — `codec_sv2`, `mining_sv2`,
`sv1_api`, `roles_logic_sv2` — live in `sv2-core` but the load-test
crate does not import them in its load tests.)

## The PerformanceLoadTestSuite, in detail

File: `sv2-test/src/performance_load_tests.rs` (852 lines).

### Architecture (verbatim from source)

```rust
pub struct PerformanceLoadTestSuite {
    config: LoadTestConfig,
    results: Arc<Mutex<LoadTestResults>>,
    connection_semaphore: Arc<Semaphore>,
}
```

Five phases, run sequentially in `run_comprehensive_load_tests`:

1. `run_connection_load_test` — spawns `max_concurrent_connections`
   tokio tasks, each holds a `Semaphore` permit.
2. `run_share_validation_benchmark` — 10k iterations of `validate_mock_share`.
3. `run_protocol_translation_benchmark` — 5k SV1→SV2 mock translations.
4. `run_memory_cpu_stress_test` — allocates 1 MB `Vec<u8>` chunks in a
   30 s loop, plus a tight integer-add loop, to simulate "CPU work".
5. `run_sustained_load_test` — maintains ~100 active `MockConnection`s
   over `test_duration_seconds`.

### The killer detail: it is 100% mock

This is the showstopper. None of the load is real:

- `establish_mock_connection` (lines 691–702):

  ```rust
  async fn establish_mock_connection(connection_id: usize) -> Result<MockConnection> {
      let delay = Duration::from_millis(10 + (rand::random::<u64>() % 50));
      sleep(delay).await;
      if rand::random::<f64>() < 0.02 { return Err(...); }
      Ok(MockConnection::new(Protocol::Sv1))
  }
  ```

  No `TcpStream::connect`. No socket. No noise handshake. The
  "connection" is `tokio::time::sleep(10..60ms)` + a `MockConnection`
  struct in memory.

- `MockConnection::submit_share` (lines 158–181) is again pure
  `sleep(80..300µs)` + a counter increment. No `mining.submit` is sent
  anywhere; no SV2 `SubmitSharesStandard` frame is built.

- `validate_mock_share` (lines 704–715) is `sleep(50..150µs)` + a 95%
  coin-flip returning `ShareResult::Valid`.

- `translate_sv1_to_sv2` (lines 717–724) returns a **hard-coded literal
  string** regardless of input:

  ```rust
  Ok(r#"{"method":"SubmitSharesStandard","params":{...}}"#.to_string())
  ```

- The "memory stress" phase (lines 415–467) is just `Vec<u8>` allocation
  with a self-imposed cap; "CPU stress" is a `for i in 0..100000 {
  hash_result = hash_result.wrapping_add(i * 31); }` integer loop —
  not SHA-256, not anything mining-shaped.

- The reporting layer (`print_comprehensive_report`, lines 585–687)
  prints emoji-laden ASCII art with `PASS/FAIL` checks against thresholds
  the suite itself produced from its own mock timings. It will, by
  construction, always score whatever the synthetic sleeps add up to.

### Protocols spoken

**None on the wire.** The suite carries a `Protocol` enum tag
(`Sv1`/`Sv2`/`StratumV1`/`StratumV2`) on `MockConnection` and varies
the synthetic delay slightly (SV1: 100–300 µs, SV2: 80–230 µs), but no
SV1 JSON-RPC parser, no SV2 frame codec, no Noise handshake, no
`Setup­Connection` exchange.

### Connection-driving model

`tokio::spawn` per simulated connection, gated by `Arc<Semaphore>` whose
capacity is `max_concurrent_connections`. Ramp control is a tiny
hand-rolled rate-limit:

```rust
if i % 50 == 0 && i > 0 { sleep(Duration::from_millis(100)).await; }
```

i.e. **50 spawns every 100 ms = 500 task-spawns/s ceiling**, which is
the synthetic ramp, not the real protocol ramp. There is no source-IP
aliasing, no `SO_REUSEPORT`, no ephemeral-port awareness — because
there is no real socket.

### Reporting / metrics

- `Vec<Duration>` accumulated per-share/per-connection.
- p95 / p99 computed by `sort_unstable` then index. (Naïve but fine for
  small N.)
- No Prometheus, no OpenTelemetry, no flamegraph, no perf-counter
  integration. Stdout-only.

### Max N tested in the repo

Hard-coded ceilings:

- `LoadTestConfig::default().max_concurrent_connections = 1000` (line 37).
- `run_performance_load_tests()` CLI entry uses **1500** (line 742).
- Demo file `examples/performance_load_demo.rs` runs **1200** (Demo 2)
  and the comment explicitly says "Exceed 1000+ requirement".
- README / commit history makes no claim of larger runs.
- No CI yaml exists in `.github/workflows/` (none in the tree listing).

So: tested only at the **1k–1.5k mock-task band**, never against a real
server, never beyond ephemeral-port territory.

### Multi-source-IP aliasing for >64k connections

**Not supported, not relevant** — the suite never opens a socket. The
only IP-shaped thing is `pool_load_tests.rs` (a sibling file), which
does:

```rust
let addr: SocketAddr = format!("127.0.0.1:{}", 3333 + (i % 1000)).parse().unwrap();
let conn = Connection::new(addr, Protocol::Sv2);
handler.handle_connection(conn).await
```

— but `Connection::new` returns the in-process daemon's connection
abstraction, not a real outbound TCP. There is no
`bind(client_ip, 0)` or `SO_BINDTODEVICE` anywhere.

### License & forkability

No `LICENSE` file. README says "This project is open source" but
nothing more. **Legally, this is not safely forkable** without
reaching out to the author for an explicit license grant. The GitHub
API returns `license: null`.

## Code quality assessment

- Style: tidy enough; Rust idioms are correct (Arc/Mutex, semaphore,
  tokio::spawn). No unsafe.
- Test coverage: 7 `#[tokio::test]` cases at the bottom of the file —
  all sanity-checks against the mock's own outputs.
- Maintainability concerns:
  - Heavy print-to-stdout coupling makes the suite hard to compose.
  - `results: Arc<Mutex<LoadTestResults>>` with sync `Mutex` in async
    code — fine here because lock holds are brief, but a code-smell.
  - Hard-coded thresholds in `print_comprehensive_report` (1000 ops/s,
    500 ops/s, 50.0 score) self-validate.
- No abstraction over "load driver" — every phase is bespoke; no
  pluggable workload generator.

## Fork-vs-rewrite decision

**Decision: rewrite (load suite is wrong shape).**

Reasons:

1. **It does not exercise the SV2 wire protocol.** Our entire
   requirement is to push real Noise+framing handshakes at scale; this
   suite never opens a socket. Forking it leaves us with the husk
   (config struct, p95 computation, report formatter) but **none of
   the load-driving logic exists yet**. The valuable code does not
   exist to be forked.

2. **It does not address the >64k-connections-per-host problem.** Our
   research's central technical challenge is source-IP aliasing /
   ephemeral-port exhaustion. This suite never touches a socket and
   has zero infrastructure for that.

3. **License-ambiguous.** No `LICENSE` file means a fork requires
   author outreach. Time cost is comparable to greenfield.

4. **Single-contributor, abandoned (8 months idle), unstarred.** No
   ecosystem benefit from staying in tree with upstream.

5. **The reusable surface area is ~50 lines** — `LoadTestConfig`
   struct + `LoadTestResults` struct + p95/p99 computation + the
   tokio-spawn-with-semaphore pattern. All of that is trivially
   re-derivable from `tokio::sync::Semaphore` docs and any latency
   tutorial.

What we *can* steal as inspiration (not as code):

- The `LoadTestConfig` field set — it's a reasonable surface area for
  knobs (`max_concurrent_connections`, `target_connections_per_second`,
  `share_submission_rate_hz`, `connection_timeout_ms`,
  `memory_limit_mb`). Use it as a checklist for our own config.
- The five-phase structure (connection ramp / share-rate / translation /
  resource-pressure / sustained-load). Sensible scaffold.
- The reporting table format if we want emoji-friendly stdout output.

But none of this is worth a fork + license-clear + rewrite-the-mocks
effort. We start clean.

## References

- Source file (commit `f4b9bd90`):
  https://github.com/IanoNjuguna/stratum-v2-tools/blob/f4b9bd909f9200a6a82137ea2c1201d25cdd6249/sv2-test/src/performance_load_tests.rs
- Demo:
  https://github.com/IanoNjuguna/stratum-v2-tools/blob/f4b9bd909f9200a6a82137ea2c1201d25cdd6249/sv2-test/examples/performance_load_demo.rs
- Sibling pool load test:
  https://github.com/IanoNjuguna/stratum-v2-tools/blob/main/sv2-test/src/pool_load_tests.rs
- Workspace Cargo.toml:
  https://github.com/IanoNjuguna/stratum-v2-tools/blob/main/Cargo.toml
- Repo root:
  https://github.com/IanoNjuguna/stratum-v2-tools
