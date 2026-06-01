---
title: "SV2 Spec — Design Goals (02) and Motivation (01)"
url: https://github.com/stratum-mining/sv2-spec/blob/main/02-Design-Goals.md
type: paper
source: stratum-mining/sv2-spec
captured: 2026-05-28
quality: 8
path: 3
tags: [design-goals, motivation, sv1-deficiencies, bandwidth, header-only, channel-multiplexing]
---

# SV2 Spec — Design Goals (02) + Motivation (01)

## Why this matters for the reverse translator

These two documents define *what SV2 is for*. Reading them as a checklist against an SV1 upstream yields a depressing inventory: most of the design goals require both endpoints to speak SV2. The reverse translator delivers maybe two of the eight stated goals.

## Stated SV1 problems (Motivation 01)

- "JSON-based and lacks cryptographic authentication, making it slower, heavier, and less secure"
- No cryptographic auth → MITM exposure
- JSON overhead → excess data; limits submission rate, increases payout variance
- Pool-imposed templates → centralized work-construction power
- Empty extranonce / Merkle-path handling burden on miners

## Stated design goals (02) and where they live in the topology

| Design goal | Mechanism | Survives reverse translator? |
|---|---|---|
| Binary protocol, precise definition | Removes JSON, unambiguous spec | **survives** internal only; egress is JSON |
| Simplified subscription | Removes mining.subscribe; native extranonce | **lost** — translator must re-emit mining.subscribe upstream |
| Improved difficulty management | Per-channel SetTarget | **partially-lost** — SV1 has one difficulty per connection |
| Bandwidth reduction (~20-byte shares, header-only) | Binary framing + HOM | **partially-lost** — internal binary; egress is JSON-RPC text |
| Header-only mining | "Not touching coinbase tx in as many situations as possible" | **lost** — SV1 pool ships full coinbase work |
| Miner template autonomy | Three-mode work declaration | **lost** — see JDP doc |
| Channel multiplexing | Different jobs same TCP conn | **partially-lost** — SV1 collapses to one upstream socket per worker |
| Latency / lower stale ratios | Native BIP320, efficient share txn | **partially-lost** — version rolling survives, batched submit doesn't |
| Encryption | Not listed as a design goal in 02 (handled in 04) | **partially-lost** — internal yes, egress no |

## Key quote on bandwidth

"Dramatically reduce network traffic...while still being able to send and receive hashing results rapidly." Mechanism cited: "smaller share messages (~20 bytes); header-only mining support."

The 20-byte share figure is the *binary-framing* win. It applies only between SV2 endpoints. The reverse translator gets it on the internal segment but pays SV1 JSON-RPC overhead at egress — so the *aggregate-network bandwidth* win is split, not full.

## Key quote on miner template autonomy

"Allow miners to (optionally) choose the transaction set they mine through work declaration." This is the political feature. It is impossible without an SV2 pool. See [[2026-05-28-path3-sv2-spec-job-declaration-protocol.md]].

## Feature-survival verdict (reverse translator, summary roll-up)

Of 9 stated design goals, only **1 fully survives** (binary internal framing on the operator's own network), **6 are partially-lost or lost-but-replaceable**, and **2 are fully lost** (header-only mining, miner template autonomy).

## Ingest justification

Establishes the *original intent* of SV2. A reverse-translator deployment delivers a fraction of that intent. Useful for operators evaluating whether the deployment effort is worth the residual benefit.
