---
title: "SV2-downstream architecture for a DATUM proxy"
category: concept
sources:
  - raw/repos/2026-06-01-path3-sri-extended-channel-server.md
  - raw/repos/2026-06-01-path3-sri-jobstore-jobfactory.md
  - raw/repos/2026-06-01-path3-sri-extranonce-allocator.md
  - raw/repos/2026-06-01-path3-sri-handlers-async-trait.md
  - raw/repos/2026-06-01-path3-stratum-translation-and-codec.md
  - raw/articles/2026-06-01-path3-pool-vs-jds-vs-jdc-roles.md
  - raw/notes/2026-06-01-path3-process-boundary-and-config.md
created: 2026-06-01
updated: 2026-06-01
tags: [sv2-proxy, sri, channels-sv2, handlers-sv2, datum-proxy, architecture]
confidence: high
---

# SV2-downstream architecture for a DATUM proxy

How the SRI codebase maps onto the engineering question: **expose Stratum V2 to ASICs, talk DATUM upstream to OCEAN.** Built from Path 3's read of `/Users/garykrause/repos/stratum`.

## Recommended model: plain SV2 pool front (no JDS, no JDC)

Three candidate models were considered:

- **(a) Plain SV2 pool front** — proxy builds templates internally (or relays from the existing C gateway), ships `NewExtendedMiningJob` to SV2 miners, no Job Declaration. **Recommended.**
- **(b) JDS exposing per-miner JDCs** — every downstream ASIC runs its own JDC + bitcoind, declares templates to the proxy's JDS. Federation-style.
- **(c) Internal JDC ↔ JDS plumbing** — pure overhead, no external benefit.

Justification for (a):

1. DATUM is already a **centralized template authority** (one local bitcoind builds GBT for many ASICs at one site). JDS/JDC federation contradicts that paradigm.
2. OCEAN's coinbase-output enforcement is **gateway-policy**, not per-miner-policy. A JDS layer would re-validate each declared template against OCEAN rules — pure duplication.
3. The SV2 spec **explicitly permits pools to operate without JDS**, distributing work via `NewExtendedMiningJob` from internally-constructed templates. SRI's `ExtendedChannel::new_for_pool` + `JobFactory::new_extended_job` is the supported code path.
4. (b) requires every ASIC to run a bitcoind+JDC, which DATUM operators don't want. (c) is plumbing with zero functional benefit.

**See**: [[../../raw/articles/2026-06-01-path3-pool-vs-jds-vs-jdc-roles|SV2 role taxonomy]].

## Process & language boundary

| Boundary | Decision |
|---|---|
| Process | **Separate Rust binary** `datum-sv2-proxy` running alongside the existing C `datum_gateway`. No FFI, no in-process tokio/libevent mixing. |
| Language | Rust async (Tokio) for everything; the C gateway is treated as an opaque service. |
| Phase 1 (v0) | Proxy speaks SV1 stratum upstream to `datum_gateway:23334` (the gateway already exposes SV1 server) and SV2 downstream to miners. **Translator-proxy with directions inverted** relative to SRI's existing translator role. Zero gateway-side modifications. ~1500 LOC. |
| Phase 2 | Native DATUM-protocol speaker in Rust (reimplement `T_DATUM_PROTOCOL_*` types); proxy talks directly to OCEAN, gateway becomes optional. ~3000-5000 LOC. |

The phased approach exploits the [[gateway-internals-c-architecture#the-queue-seam-the-architectural-finding|queue seam]] in the existing C gateway: phase 1 sits in front of the SV1 server; phase 2 replaces the SV1 server entirely while keeping `datum_protocol.c`'s upstream behavior intact.

## Code organization (Phase 1)

```
datum-sv2-proxy/src/
├── main.rs / config.rs            # bootstrap, TOML config
├── proxy.rs                       # HandleMiningMessagesFromClientAsync impl
├── channel_state.rs               # HashMap<channel_id, ExtendedChannel<DefaultJobStore<ExtendedJob>>>
├── upstream/
│   ├── sv1_local.rs               # phase 1: SV1 client to local datum_gateway
│   └── datum_native.rs            # phase 2: native DATUM protocol speaker
├── gbt_to_template.rs             # NewTemplate synthesis
├── vardiff.rs                     # uses channels_sv2::vardiff
└── extranonce_bridge.rs           # 32-byte hierarchical → 12-byte flat
```

## Reusable-vs-write-from-scratch breakdown

**Reused verbatim from SRI** (~9600 LOC):

| Component | Crate / type |
|---|---|
| Wire framing + Noise NX handshake | `codec_sv2`, `noise_sv2`, `framing_sv2` |
| SV2 message types | `mining_sv2`, `template_distribution_sv2` |
| Message-frame parsing + dispatch (TLV-aware) | `handlers_sv2` (default trait methods) |
| Per-channel state machine | `channels_sv2::server::extended::ExtendedChannel::new_for_pool` |
| Job storage (future/active/past/stale lifecycle) | `channels_sv2::server::jobs::DefaultJobStore` |
| Coinbase synthesis + BIP141 strip + merkle | `JobFactory::new_extended_job` |
| Share validation (extranonce, target, dedup, block detection) | `ExtendedChannel::validate_share` + `ShareAccounting` |
| Extranonce allocation (hierarchical bitmap) | `ExtranoncePrefix` + `ExtranonceAllocator` (with `total_extranonce_len = 12`) |
| Vardiff | `channels_sv2::vardiff` |

**Written from scratch** (~1500 LOC):

| Component | LOC |
|---|---|
| `HandleMiningMessagesFromClientAsync` impl (7 leaf handlers) | ~400 |
| Channel registry (HashMap + tokio::Mutex) | ~150 |
| GBT → `NewTemplate` synthesizer (or SV1-notify → NewTemplate for phase 1) | ~200 |
| OCEAN required-outputs deserializer → `Vec<TxOut>` | ~80 |
| Upstream client (phase 1: SV1 over TCP; phase 2: DATUM binary) | ~400 |
| Extranonce 12-byte bridge (concat prefix+rolling for upstream submit) | ~50 |
| Config (TOML) + main loop bootstrap | ~250 |

**NOT used**: `stratum_translation` (SV1↔SV2 helpers) — only relevant if the proxy also accepts SV1 miners directly. Skip for v1.

**Reuse ratio: ≈ 6:1.**

**See**: [[../../raw/repos/2026-06-01-path3-sri-extended-channel-server|ExtendedChannel server]], [[../../raw/repos/2026-06-01-path3-sri-jobstore-jobfactory|JobStore + JobFactory]], [[../../raw/repos/2026-06-01-path3-sri-extranonce-allocator|extranonce allocator]], [[../../raw/repos/2026-06-01-path3-sri-handlers-async-trait|handlers async trait]].

## Coinbase-output flow

OCEAN's "must include generation outputs in the order provided" requirement maps cleanly:

```
DATUM Prime ─[binary V2 coinbaser blob]─▶ datum_gateway core
                                              │ Vec<TxOut> (decoded)
                                              ▼
                                          datum-sv2-proxy
                                              │ additional_coinbase_outputs: Vec<TxOut>
                                              ▼
                                          JobFactory::new_extended_job
                                              │ NewExtendedMiningJob (SV2)
                                              ▼ coinbase_tx_outputs
                                          SV2 ASIC
```

The hard invariant `sum(outputs) == template.coinbase_tx_value_remaining` is already enforced by OCEAN — the proxy just propagates the outputs unchanged.

## Extranonce mismatch — bridgeable by configuration

| Side | Layout |
|---|---|
| SV2 (downstream) | 32-byte hierarchical: `[server_prefix][channel_prefix][rollable]` |
| DATUM (upstream) | 12-byte flat: pool sees a single 12-byte field |

Bridge: set `ExtranonceAllocator`'s `total_extranonce_len = 12`, partition as `[local_prefix=0, local_index=2, rollable=10]` (or 4/8). For upstream submission, **concatenate prefix+rolling into the single 12-byte field** the DATUM share-submit opcode `0x27` expects.

## Open architectural questions

1. **Per-miner unique-identifier propagation.** DATUM's coinbase scriptSig has a 16-bit unique-identifier slot for share attribution. SV2's analog is `extranonce_prefix` for per-channel uniqueness, OR `user_identity` (see the sibling [[../../sv2-coinbase-identity/_index|sv2-coinbase-identity]] wiki). Whether the proxy maps `user_identity` → DATUM's unique-identifier per-channel is an open product question.
2. **Where does Knots policy live?** The proxy doesn't run bitcoind directly in Phase 1; it relies on the C gateway's bitcoind which is Knots-recommended. Phase 2 must surface this configuration.
3. **Block-found escape hatch.** The C gateway has `datum_submitblock.c` for direct submission to bitcoind on block discovery. Phase 2 must replicate this; Phase 1 inherits it through the gateway.

## See also

- [[gateway-internals-c-architecture]] — the C gateway code being replaced/wrapped
- [[datum-protocol]] — what the upstream half speaks
- [[operator-value-and-threat-model]] — why build this at all
- [[ocean-sv2-stance-and-prior-art]] — what already exists (almost nothing)
- [[../topics/datum-sv2-proxy-playbook]] — the build path
