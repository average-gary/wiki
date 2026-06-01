---
title: "stratum-translation crate + codec/noise/framing/parsers wire pipeline"
source: /Users/garykrause/repos/stratum/stratum-core/stratum-translation/src/{lib.rs,sv1_to_sv2.rs}
source_secondary: /Users/garykrause/repos/stratum/sv2/codec-sv2/src/lib.rs
source_type: local-code
ingested_by: path3
ingested_at: 2026-06-01
quality: high
relevance: medium
tags: [sri, stratum-translation, codec-sv2, noise-sv2, framing-sv2, parsers-sv2, wire-pipeline]
---

# What of stratum-translation is reusable for DATUM, and the wire pipeline

## Key findings

- **`stratum_translation` is a runtime-free helper crate, not a proxy
  framework.** From `lib.rs`: "What it does not contain: networking, async
  runtimes, channels, or long-running tasks." It exposes four pure functions:
  - `sv1_to_sv2::build_sv2_open_extended_mining_channel(request_id,
    user_identity, nominal_hash_rate, max_target, min_extranonce_size) ->
    OpenExtendedMiningChannel`
  - `sv1_to_sv2::build_sv2_submit_shares_extended_from_sv1_submit(submit,
    channel_id, sequence_number, job_version, version_rolling_mask) ->
    SubmitSharesExtended`
  - `sv2_to_sv1::build_sv1_notify_from_sv2(...)` — turns SV2 job state into
    SV1 `mining.notify`
  - `sv2_to_sv1::build_sv1_set_difficulty_from_sv2_set_target(...)` and
    `build_sv1_set_difficulty_from_sv2_target(target)`

- **Relevance to DATUM proxy: low — but worth noting for ASYMMETRY.** A DATUM
  SV2 proxy is SV2-server-downstream + DATUM-protocol-upstream; there is no
  SV1 leg in the canonical design. `stratum_translation` is the SV1↔SV2
  bidirectional helper used by SRI's translator-proxy role, which sits in
  exactly the OPPOSITE direction (SV1 miners on the upstream side, SV2 pool
  downstream of translator). So this crate is not a building block for our
  proxy *unless* we choose to ALSO accept SV1 miners directly (i.e. fold
  DATUM gateway's SV1 server INTO the new Rust proxy, which is one of the
  reuse-vs-rewrite options).

- **The wire pipeline that IS reusable:**
  - **`noise_sv2`** — Noise-NX handshake + AEAD framing for the SV2
    transport. Re-exported by `codec_sv2` behind the `noise_sv2` feature flag.
  - **`framing_sv2`** — `Header`, `Frame`, `HandShakeFrame` types.
  - **`codec_sv2`** — exposes `StandardEitherFrame`, `StandardSv2Frame`,
    `StandardDecoder`, `StandardNoiseDecoder`, `Encoder`, `NoiseEncoder`,
    and `HandshakeRole::{Initiator, Responder}` (responder for the proxy's
    downstream-facing Noise side).
  - **`parsers_sv2`** — `AnyMessage`, `Mining` enum used by handlers-sv2
    default impls; `parse_message_frame_with_tlvs` for TLV-aware parsing.
  - **`mining_sv2`** — message types: `OpenExtendedMiningChannel`,
    `OpenExtendedMiningChannelSuccess`, `NewExtendedMiningJob`,
    `SetNewPrevHash`, `SetTarget`, `SubmitSharesExtended`, etc.
  - **`template_distribution_sv2`** — `NewTemplate`, `SetNewPrevHash`
    (TDP variant). Even if we don't talk to a Template Provider, we **build
    `NewTemplate` instances internally from GBT** and feed them to
    `ExtendedChannel::on_new_template`. This is the canonical glue type.
  - **`channels_sv2`** — already covered: `ExtendedChannel`, `JobFactory`,
    `DefaultJobStore`, `ExtranonceAllocator`, `ShareAccounting`, vardiff.

- **`stratum-core` is the convenience re-export crate.** Adding
  `stratum-core` with the `translation` feature pulls in everything the
  proxy needs as a single dep, so `Cargo.toml` for the proxy is roughly:
  ```toml
  [dependencies]
  stratum-core = { features = ["sv1", "translation"] }   # if also serving SV1
  # or just:
  stratum-core = {}                                       # SV2-only proxy
  tokio = { features = ["full"] }
  bitcoin = "0.32"
  ```

- **No SV2 messages need to be hand-rolled.** All wire types exist; the proxy
  is a pure assembly job at the protocol layer.

## Ingest justification

Documents the wire-pipeline crates the proxy reuses verbatim, and clarifies
that `stratum-translation` itself is not on the critical path for an
SV2-only DATUM proxy (it's only relevant if we also want native SV1 miners,
which is a separable feature).
