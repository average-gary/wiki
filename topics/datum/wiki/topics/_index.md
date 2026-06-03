---
title: Topics
type: index
updated: 2026-06-01
---

# Topics (3)

## Contents

| File | Summary | Tags | Updated |
|------|---------|------|---------|
| [datum-gateway-overview.md](datum-gateway-overview.md) | Anchor article: what DATUM Gateway is, where it sits between node/miner/pool. | datum, ocean, mining, decentralized-templates, beta | 2026-06-01 |
| [datum-sv2-proxy-playbook.md](datum-sv2-proxy-playbook.md) | **Sidecar proxy** synthesis (2026-06-01 plan-mode session). External Rust binary running alongside C gateway. ~1500 LOC new + ~9600 LOC SRI reuse. | playbook, sv2-proxy, sidecar, datum, ocean, sri | 2026-06-01 |
| [drop-in-rust-datum-gateway.md](drop-in-rust-datum-gateway.md) | **Drop-in replacement** synthesis (2026-06-01 question-mode session). Single Rust binary that replaces `datum_gateway` entirely. ~4,000-5,500 Rust LOC. SV1+SV2 dual-protocol downstream. The sidecar's natural endgame. | playbook, drop-in, rust, datum_gateway, sv1, sv2 | 2026-06-01 |

## How the two SV2 topics relate

The 2026-06-01 plan-mode session compiled the **sidecar proxy** topic — a separate Rust binary that runs alongside the C gateway and exposes SV2 downstream via the gateway's existing SV1 stratum endpoint. ~1,500 LOC, low risk, no drop-in commitment.

The 2026-06-01 question-mode session (later that day) compiled the **drop-in replacement** topic — a single Rust binary that replaces the C gateway entirely. ~4,000-5,500 LOC, drop-in commitment to operator-facing surfaces, dual-protocol downstream so SV1-only OCEAN miners aren't bricked.

The sidecar is the de-risked intermediate; the drop-in is the project endgame. They share the SV2 server-side design; the drop-in additionally takes over the upstream DATUM speaker, GBT, dashboard, config, and dist channels.
