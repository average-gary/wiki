---
title: p2poolv2 run-swarm.sh — heterogeneous synthetic-miner swarm orchestrator
source_url: https://github.com/p2poolv2/p2poolv2/blob/main/load-tests/sim/run-swarm.sh
type: repos
ingested: 2026-06-24
quality: A
confidence: high
tags: [swarm, scale-test, zipf, hashrate-distribution, asert, p2poolv2, load-test]
---

# `run-swarm.sh` — heterogeneous synthetic-miner swarm

Bash script that launches N copies of `p2poolv2_sim` (one node per
process), each with a distinct port, RNG seed, fresh store, and
modeled hashrate, all pointed at one shared regtest bitcoind. It does
the **outer-loop** that turns the in-process `SimEmitter` (per-miner
Poisson share generator) into a multi-miner network simulation.

Companion scripts in the same folder:
- `metrics.sh` — log-based summary (load-immune; reads only logs/configs)
- `observe.sh` — live HTTP API watcher
- `stop-swarm.sh` — kill from pids.txt
- `nightly.sh` — full-CI harness
- `plot-metrics.{py,sh}` — graphs from metrics.sh CSV

## Hashrate distributions

```bash
HASHRATE="${HASHRATE:-1.0e12}"           # mean per-node, in h/s
HASHRATE_DIST="${HASHRATE_DIST:-zipf}"   # equal | zipf
ZIPF_ALPHA="${ZIPF_ALPHA:-1.0}"
```

Zipf weights (computed in awk, seeded by `DIST_SEED=42` for
reproducibility):
```
wᵢ = (i+1)^(-alpha)
hashrateᵢ = N · HASHRATE · wᵢ / Σw       # total preserved
```

This is the key for "1M virtual miners" testing: a real pool's miner
population is power-law, so testing with equal hashrate is a lie. Zipf
preserves the total network hashrate so aggregate share rate matches
between equal and zipf modes — only the per-miner split is skewed.

## Latency model

`LATENCY_DIST=spread` gives log-uniform per-node propagation delay in
`[0.3, 2.5] × LATENCY_MS` (mean ≈ `LATENCY_MS`). Models heterogeneous
network links. Raise `LATENCY_MS` to start producing uncle blocks (the
uncle rate scales with `latency / share_interval`).

## ASERT anchor — the steady-state trick

```bash
ASERT_ANCHOR="${ASERT_ANCHOR:-$(date +%s)}"
NETWORK_HASHRATE="${NETWORK_HASHRATE:-$(awk -v n="$N" -v h="$HASHRATE" 'BEGIN{printf "%.0f", n*h}')}"
```

The shared ASERT anchor time + total network hashrate lets the genesis
difficulty start at the *steady state*, so the chain doesn't climb for
15–20 min while ASERT discovers the population. **This is the
difference between a useful 30-min test and a 4-hour one**.

## Per-node config (TOML emitted into each node-i.toml)

```toml
[sim]
enabled = true
miner_address = "$node_addr"        # distinct per node from getnewaddress
hashrate = $node_hashrate            # zipf weight × mean
block_to_share_ratio = $SHARES_PER_BLOCK   # default 10000
seed = $seed                         # i + 1
propagation_delay_ms = $node_latency
asert_anchor_time = $ASERT_ANCHOR
network_hashrate = $NETWORK_HASHRATE
ideal_block_time_secs = $IDEAL_BLOCK_TIME  # default 10, allows time-compression
```

## Time-compression knob

`IDEAL_BLOCK_TIME=10` (seconds) is the share-interval target. Shorten
it (e.g. 5s) for faster data collection; latencies are auto-scaled
proportionally so the uncle rate (latency/interval) is preserved.

## Topology

```bash
DIAL_FANOUT="${DIAL_FANOUT:-3}"
# each node dials up to DIAL_FANOUT earlier nodes (chain + chords)
```

Yields a single connected component. Node 0 dials nobody. This is
**libp2p**-level peer connectivity, separate from the stratum
connection layer (each node also runs its own stratum server on a
distinct port).

## What this scales to in practice (claimed by repo authors)

The script defaults to N=20. The release-profile mandate is because
`libp2p-request-response` has a `debug_assert_eq!` in
`on_connection_closed` that fires under the connection churn of a
many-node swarm and aborts in debug. So the upper bound here is gated
by libp2p connection-churn behavior at the p2p layer, not by the
share-emission layer.

## Insight for scale-testing a *stratum* layer (not p2p layer)

Reverse the architecture: one pool process, N stratum-client
connections (each driven by its own emitter task). p2poolv2's
in-process emitter goes directly into `emissions_tx`, skipping the
network and Noise handshake — so you need a separate "fake stratum
client" that opens a real TCP/Noise connection then runs the same
Poisson exponential-sleep loop and submits real `SubmitSharesStandard`
frames.

That's the gap. None of these published harnesses cleanly separate
"per-miner Poisson emission logic" from "transport: in-process vs.
TCP+Noise". A clean `SyntheticMiner` trait should do exactly this
split.
