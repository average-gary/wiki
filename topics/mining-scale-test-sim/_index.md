---
title: mining-scale-test-sim
type: topic-wiki
created: 2026-06-24
status: active
sources: 51
articles: 9
rounds: 2
---

# Mining scale testing via simulation

Knowledge base for **scale-testing Stratum V2 / mining-pool stacks via
simulation**. Central question: connection count vs hashrate — which
bottleneck hits first?

## Verdict (one paragraph)

**Connections saturate before share validation does**, because
[[concepts/vardiff-decoupling|vardiff clamps each connection's share
rate to `r*`]] independent of underlying hashrate. [[concepts/share-validation-cost-model|Per-share validation costs
5-20 µs]] → single-core ceiling of 50-200k shares/sec → at sv2-apps
default SPM=6, 1M connections is ~2 cores of validation work. Meanwhile
[[concepts/connection-scale-bottlenecks|kernel TCP memory hits 10-20
GB at 1M connections, Linux ephemeral ports cap at 64k per source IP,
public-pool (Node.js) trips backpressure at ~10k conns/worker, and SRI
Noise handshake CPU bottlenecks reconnect storms at ~45k conn/sec on
8 cores]]. Two caveats: ckpool's actual vardiff is ~10× denser
(`drr=0.3` ≈ 1 share / 3.3s) than the user's mental model; lock
contention and burst-handshake CPU operate below the steady-state
ceiling and require their own measurement.

## Start here

- [[wiki/topics/the-bottleneck-thesis|The bottleneck thesis]] —
  central premise + verdict
- [[wiki/topics/simulator-architecture|Simulator architecture]] —
  recommended design
- [[wiki/reference/gimballock-vardiff-sim|gimballock's primary reference]]
  — `vardiff/simulation-framework` branch

## Indexes

- [wiki/_index.md](wiki/_index.md) — compiled articles (9)
- [raw/_index.md](raw/_index.md) — ingested sources (51 across 2 rounds)
- [log.md](log.md) — session log

## See also

- `topics/sv2-p2pool-integration` — p2poolv2 + sv2-apps integration; includes p2poolv2's JMeter load-test note that this wiki extends
- `topics/stratum-sri` — SRI workspace; the `channels-sv2/sim` crate this work primarily references
- `topics/sv2-coinbase-identity` — channel-level surface the scale-test exercises
- `topics/datum` — alternative pool architecture; comparison fixture
