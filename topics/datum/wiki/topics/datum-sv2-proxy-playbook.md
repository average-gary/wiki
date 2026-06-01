---
title: "DATUM SV2-downstream proxy — playbook"
category: topic
created: 2026-06-01
updated: 2026-06-01
tags: [playbook, sv2-proxy, datum, ocean, tides, sri, channels-sv2]
confidence: high
---

# DATUM SV2-downstream proxy — playbook

A practical synthesis. Read this article and you should know what the proxy is, why it exists, what it preserves and what it costs, where in the SRI codebase it goes, who would deploy it, and the build path of least resistance.

## What it is

A **separate Rust binary**, `datum-sv2-proxy`, running alongside the existing C `datum_gateway`. It exposes Stratum V2 to ASICs (replacing the gateway's SV1-to-ASIC leg) and forwards work upstream to OCEAN/DATUM (initially via the gateway's existing SV1 stratum endpoint, eventually via a native DATUM-protocol speaker).

```
┌──────────────────────────────────────────────────────────────────┐
│                        Operator's farm                           │
│                                                                  │
│   ┌────────────┐                ┌──────────────────────────┐     │
│   │ bitcoind   │   GBT RPC      │     datum_gateway (C)    │     │
│   │ (Knots)    │ ◀─────────────▶│  - blocktemplates        │     │
│   └────────────┘                │  - coinbaser             │     │
│                                 │  - SV1 server :23334     │     │
│                                 │  - DATUM proto upstream  │     │
│                                 └──────────────┬───────────┘     │
│                                                │                  │
│                              local TCP (SV1)   │                  │
│                                                │                  │
│   ┌──────────────────────────────────────────▼─────────────┐    │
│   │            datum-sv2-proxy (Rust, Tokio)                │    │
│   │  - SV2 mining-channel server (Noise NX)                 │    │
│   │  - channels_sv2::server::ExtendedChannel<JobStore>      │    │
│   │  - JobFactory injects OCEAN required outputs            │    │
│   │  - extranonce 12-byte bridge                            │    │
│   └──────────┬─────────────┬─────────────┬────────────┬─────┘    │
│              │             │             │            │           │
│           SV2 +Noise   SV2 +Noise   SV2 +Noise    SV2 +Noise     │
│              │             │             │            │           │
│         ┌────▼────┐   ┌────▼────┐   ┌────▼────┐  ┌────▼────┐     │
│         │ ASIC 1  │   │ ASIC 2  │   │ ASIC 3  │  │ ASIC N  │     │
│         │(BraiinsOS+) │ │(BraiinsOS+) │(BraiinsOS+) │(BraiinsOS+)│
│         └─────────┘   └─────────┘   └─────────┘  └─────────┘     │
└──────────────────────────────────────────────────────────────────┘
                                  │
                                  │ DATUM Protocol (libsodium box, port 28915)
                                  ▼
                            ┌────────────┐
                            │   OCEAN    │
                            │   pool     │
                            │ (TIDES)    │
                            └────────────┘
```

## Why it exists

DATUM Gateway is **SV1-only on the ASIC-facing leg**. An operator with BraiinsOS+ SV2-capable firmware cannot mine to OCEAN today without downgrading to SV1 client mode. The proxy unlocks SV2 fleets for OCEAN's TIDES payout — that's the entire load-bearing reason. **See**: [[../concepts/operator-value-and-threat-model]].

## What survives, what's lost

| Survives | Partially survives | Lost / regressed |
|---|---|---|
| Miner-side template authority (gateway+bitcoind) | Hierarchical extranonce (SV2 32B → DATUM 12B) | End-to-end non-custodial property (proxy is a tiny pool) |
| TIDES payout (unchanged) | Per-channel `SetTarget` (collapses to single DATUM target) | "Decentralized template choice for downstream miners" — proxy operator picks |
| Noise NX between miner ↔ proxy | Async share submit (DATUM ack is synchronous) | DATUM Prime stays closed-source — no offline test target |
| BIP-310 / BIP-320 version rolling | Multi-channel abstraction (collapses to single DATUM session) | SRI has no DATUM bridge code; greenfield |
| SRI codec / noise / handlers crate reuse | Censorship resistance (already had it via DATUM; SV2 adds nothing) | |

## The architectural finding

The C gateway has a **clean producer/consumer queue seam** between its SV1 server (`datum_stratum.c`) and its upstream DATUM-protocol client (`datum_protocol.c`), implemented in `datum_queue.c` (~80 LOC of rwlock dual-buffer).

This is what makes the SV2 swap on the downstream leg a tractable refactor: the line is drawn at the queue, and the upstream side does not care which protocol the producers speak. **See**: [[../concepts/gateway-internals-c-architecture#the-queue-seam-the-architectural-finding|the queue seam]].

## Recommended model: plain SV2 pool front

No JDS, no JDC. The proxy is the template authority for its downstream SV2 channels. Justified by:

1. DATUM is already a centralized template authority (one bitcoind for many ASICs).
2. OCEAN's coinbase enforcement is gateway-policy, not per-miner-policy.
3. SV2 spec permits pools without JDS (`ExtendedChannel::new_for_pool` is the supported path).
4. JDS-with-per-miner-JDC requires every ASIC to run bitcoind+JDC, which DATUM operators don't want.

Issue #146's submitter (`electricalgrade`) made the same call: TDP and JDP "unnecessary in DATUM."

**See**: [[../concepts/sv2-downstream-architecture#recommended-model-plain-sv2-pool-front-no-jds-no-jdc]].

## Build path of least resistance (Phase 1)

```
Phase 1 (~1500 LOC new Rust + ~9600 LOC SRI reuse):
  - Proxy speaks SV2 downstream to ASICs (channels-sv2 server)
  - Proxy speaks SV1 client upstream to local datum_gateway:23334
  - Zero gateway modifications
  - Translator-proxy with directions inverted

Phase 2 (~3000-5000 LOC):
  - Native DATUM-protocol speaker in Rust
  - Reimplement T_DATUM_PROTOCOL_* types (libsodium box, ChaCha20-Poly1305)
  - Direct OCEAN connection; gateway becomes optional
  - Replicate datum_submitblock.c block-found escape hatch
```

## Reusable-vs-write breakdown (Phase 1)

| Reused (verbatim) | LOC | Written from scratch | LOC |
|---|---|---|---|
| `codec_sv2`, `noise_sv2`, `framing_sv2` | ~3000 | `HandleMiningMessagesFromClientAsync` impl (7 leaves) | 400 |
| `mining_sv2`, `template_distribution_sv2` types | ~2000 | Channel registry (HashMap + tokio::Mutex) | 150 |
| `handlers_sv2` (default trait methods) | ~600 | GBT → `NewTemplate` synthesizer | 200 |
| `channels_sv2::server::extended::ExtendedChannel::new_for_pool` | ~1500 | OCEAN required-outputs deserializer | 80 |
| `channels_sv2::server::jobs::DefaultJobStore` | ~300 | Upstream SV1 client (Phase 1) | 400 |
| `JobFactory::new_extended_job` (BIP141 strip + merkle) | ~500 | Extranonce 12-byte bridge | 50 |
| `ExtendedChannel::validate_share` + `ShareAccounting` | ~700 | Config (TOML) + main loop | 250 |
| `ExtranoncePrefix` + `ExtranonceAllocator` (`total_extranonce_len=12`) | ~400 | | |
| `channels_sv2::vardiff` | ~600 | | |
| **Total reused** | **~9600** | **Total new** | **~1530** |

Reuse ratio ≈ **6:1**.

**See**: [[../concepts/sv2-downstream-architecture#reusable-vs-write-from-scratch-breakdown|reuse table]].

## Hard problems baked in

1. **SV2 32B-hierarchical → DATUM 12B-flat extranonce**. Bridgeable by configuring `ExtranonceAllocator::total_extranonce_len = 12`, partitioning `[local_prefix=0, local_index=2, rollable=10]`, and concatenating prefix+rolling for upstream submit.
2. **OCEAN required-outputs propagation**. Pool-supplied outputs flow `DATUM Prime → datum_gateway core → proxy → JobFactory.additional_coinbase_outputs → NewExtendedMiningJob.coinbase_tx_outputs`. Hard invariant `sum(outputs) == template.coinbase_tx_value_remaining` already enforced by OCEAN.
3. **Per-miner unique-identifier propagation**. DATUM's coinbase scriptSig has a 16-bit unique-ID slot. SV2 has `extranonce_prefix` per-channel and `user_identity` per-channel. Whether the proxy maps `user_identity` → DATUM unique-ID per-channel is an open product question.
4. **Authentication mismatch**. SV2 uses Noise public-key auth; DATUM uses libsodium long-term Ed25519 + handshake. Proxy holds OCEAN credentials per proxy instance.
5. **Closed-source DATUM Prime**. No offline test target. Integration tests must hit the live OCEAN pool.
6. **Trust regression**. The proxy operator becomes a tiny pool. Downstream miners must trust the proxy to redistribute TIDES correctly.
7. **OCEAN hostility to SV2**. No spec ground; PR/issue submission to the OCEAN org is unlikely to land in their gateway. Build it externally.

## Customer segments

1. **Small/mid SV2-firmware farms aligned with OCEAN's politics** — the only crisp value-add.
2. **SRI contributors** — non-trivial real-world test target.
3. **Mining-Lightning service providers** — anti-hijack on hostile networks.
4. *Not customers*: solo miners, OCEAN customers happy on SV1, p2pool, hashpool (today).

**See**: [[../concepts/operator-value-and-threat-model#honest-operator-fit-read|operator-fit read]].

## Spec ground

- **Issue #146** ([`OCEAN-xyz/datum_gateway#146`](https://github.com/OCEAN-xyz/datum_gateway/issues/146)) is the only public, named, sourced proposal. Open since 2025-08-23. Submitter `electricalgrade` has a stalled `sv2` repo (Noise + SetupConnection only). Cite this issue in any design doc.
- **OCEAN docs** explicitly reject SV2 ("bolted onto centralized design"). No spec collaboration likely.
- **SRI** has zero documented engagement with DATUM. The bridge will be solo work.

**See**: [[../concepts/ocean-sv2-stance-and-prior-art]].

## See also

- [[../concepts/datum-protocol]] — wire-format reference
- [[../concepts/gateway-internals-c-architecture]] — what the SV2 layer replaces / wraps
- [[../concepts/sv2-downstream-architecture]] — full architectural breakdown
- [[../concepts/ocean-sv2-stance-and-prior-art]] — political and prior-art landscape
- [[../concepts/operator-value-and-threat-model]] — who deploys this and why
- [[../../sv1-upstream-reverse-translator/wiki/topics/reverse-translator-playbook]] — generic version of this pattern
- [[../../bitcoin-mining-payout-schemas/wiki/concepts/datum]] — DATUM in payout-schema context
- [[../../stratum-sri/_index]] — the SRI codebase the proxy reuses
