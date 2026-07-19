---
title: topics
---

# Topics

- [[the-bottleneck-thesis]] — central premise (vardiff smooths share validation, so connections saturate first) — verdict: supported, with two caveats (vardiff is denser than the user assumed; lock contention and reconnect-storm handshake CPU operate below the steady-state CPU ceiling).
- [[simulator-architecture]] — recommended design synthesizing all 5 research paths. New `scale-sim-harness` crate (own workspace, clones gimballock's shape), pool-under-test instrumentation patches, mock-bitcoind. Tiered plan: 10k → 100k → 1M.
