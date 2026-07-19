---
title: "locustio/locust — Python load framework with documented custom-protocol path"
type: raw-source
source_kind: repo
source_url: https://github.com/locustio/locust
fetched: 2026-06-24
path: 5
relevance: medium
---

# Locust — the inspiration for Goose, with custom-protocol docs

- Repo: https://github.com/locustio/locust  (~28k stars, Python)
- "Write scalable load tests in plain Python"
- Doc: https://docs.locust.io/en/stable/testing-other-systems.html

## Custom protocol support (officially documented)

Locust **comes with built-in support for HTTP/HTTPS only** but is explicitly
extensible:

> "Locust only comes with built-in support for HTTP/HTTPS but it can be
> extended to test almost any system."

Pattern:

1. Subclass `User` (set `abstract = True` in the base class).
2. Wrap the protocol library in a client class.
3. After each protocol call, fire Locust's `request` event with timing,
   response, and exception info — this populates the metrics pipeline.

Documented working examples in the upstream docs: **XML-RPC, gRPC, MQTT**
(via an `MqttUser` class). MQTT is the closest published analog to SV2
(stateful, binary, persistent).

## **The gevent monkey-patching constraint — critical caveat**

> "It is important that the protocol libraries you use can be
> monkey-patched by gevent."

Locust uses gevent (greenlet cooperative scheduling), not native asyncio.
Pure-Python libraries get auto-patched and play nice. **C-extension
libraries block the whole greenlet pool** unless they have a gevent-
compatible escape hatch (e.g. psycogreen for psycopg2).

For SV2 specifically:
- `noise` Python libraries are Python-only and would work, but Noise_NX
  implementations are scarce.
- A Rust-implemented `noise-sv2` via PyO3 → C → could *block* the
  greenlet pool. You'd want to wrap the entire connection in a separate
  thread per user, which throws away the lightweight-greenlet advantage.

## Distributed coordination

Locust has a first-class master/worker model:
- One master coordinates, N workers run users.
- Master + workers communicate over ZeroMQ (`pyzmq`).
- Metrics aggregated centrally; the master exposes the web UI and the
  combined timeseries.
- Workers are stateless — adding workers = adding load capacity.

Per-host scale is gated by Python + greenlet overhead. A single worker
typically tops out around 1k-5k users; for 100k users you'd want 20-100
worker hosts, all coordinated by one master. This is the **opposite end of
the spectrum** from Erlang BEAM or pure Rust async (which can put 100k
tasks on one host trivially).

## Verdict for SV2

- The **master/worker architecture is the gold-standard reference**.
- The **custom-User pattern** generalizes to any protocol.
- **Not the right tool for SV2 at scale** because (a) per-host throughput
  is lowest of the field, (b) Noise via C/Rust extensions defeats greenlet
  concurrency, (c) you'd be Frankensteining noise-sv2 anyway.
- **Right tool for SV2 at low scale (< 5k synthetic miners on one host)**
  if you specifically want the master/worker coordination + the web UI for
  free.
