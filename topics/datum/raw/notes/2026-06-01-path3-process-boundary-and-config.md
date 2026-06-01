---
title: "Process boundary, language boundary, and config surface for DATUM SV2 proxy"
source: synthesis from path3 sub-agent investigations
source_type: synthesis-notes
ingested_by: path3
ingested_at: 2026-06-01
quality: medium-high
relevance: high
tags: [datum-proxy, architecture, ipc, threading, tokio, libevent, config, deployment]
---

# Threading, process boundary, and config surface

## Key findings

- **Threading impedance: C+pthreads/libevent vs Rust+tokio.** Path 2 will
  characterize the gateway's exact concurrency model, but per the DATUM
  README and source listing, it's a multi-threaded C application using
  libsodium / libcurl / jansson / libmicrohttpd plus a stratum server in
  C. SRI's relevant crates are tokio-async (`HandleMiningMessagesFromClientAsync`).
  Mixing tokio inside the C process via FFI is technically possible
  (block-on tokio runtime per request), but operationally fragile —
  scheduler interference, panic-vs-assert mismatches, allocator conflicts.

- **Path of least resistance: separate Rust process + IPC.** The DATUM SV2
  proxy ships as `datum-sv2-proxy`, a sibling binary to `datum_gateway`.
  IPC choices, ranked by cost-to-implement:
  1. **Unix domain socket carrying a small line-delimited JSON or
     length-prefixed bincode protocol** — simplest, no schema infra, easy
     to debug. Recommended for v1.
  2. **Local TCP loopback with the existing DATUM stratum protocol** — the
     proxy speaks SV1 stratum to the gateway (treating the gateway as an
     SV1 pool), translates SV1 jobs into SV2 jobs for downstream miners,
     and SV2 shares back into SV1 submits upstream. Requires zero
     gateway-side modification — the gateway already exposes SV1 server
     and would just see another SV1 client. **Strong recommendation for
     v0**: the proxy is a pure SRI translator-proxy variant (SV1 upstream,
     SV2 downstream), reusing `stratum-translation` in reverse. This is
     the spiritual sibling of the existing translator-proxy role just
     with the directions flipped.
  3. **Direct DATUM-protocol speaker in Rust** — proxy speaks the binary
     DATUM protocol upstream to OCEAN directly, bypassing the gateway core.
     Maximum work (re-implement `T_DATUM_PROTOCOL_*` types in Rust), but
     yields the cleanest one-binary deployment. v2 territory.

- **Recommended phasing:**
  - **Phase 1: SV1-tunneled bolt-on.** Proxy opens an SV1 client to the
    local datum_gateway (port 23334), accepts SV2 miners on a new port,
    translates each job and share. Gateway code unchanged. ~1500 LOC Rust.
  - **Phase 2: Direct DATUM protocol in Rust.** Reimplement the DATUM
    upstream speaker; gateway-internal share validation duplicated in
    Rust; SV1 server in gateway becomes optional. ~3000-5000 LOC.
  - **Phase 3: Full Rust port of gateway core.** Fold GBT polling,
    coinbaser, bitcoind RPC, API server into the Rust binary. ~10k LOC.
    Out of scope for the wiki's near-term concerns.

- **New config knobs the proxy exposes (TOML), beyond standard gateway
  config:**
  - `[sv2_proxy] listen_address = "0.0.0.0:34254"` — SV2 listen port
    (34254 is SRI's pool conventional port).
  - `[sv2_proxy] noise_authority_secret_key = "..."` and
    `noise_certificate_validity_seconds = 3600` — Noise NX requires a
    static keypair for the responder.
  - `[sv2_proxy] coinbase_outputs_max_additional_size = 100` —
    SV2-spec'd `coinbase_output_constraints` value (advertised to JDCs;
    irrelevant under model a but still a useful per-connection setup
    detail).
  - `[sv2_proxy] expected_shares_per_minute = 6.0` — vardiff target.
  - `[sv2_proxy] share_batch_size = 100` — `SubmitSharesSuccess` batching.
  - `[sv2_proxy] max_extranonce_total_len = 12` — to match DATUM's
    upstream extranonce[12] (see path3 extranonce note).
  - `[sv2_proxy] min_rollable_extranonce = 8` — minimum miner-rollable
    bytes; downstream miner clamps to this.
  - `[sv2_proxy] pool_tag = "DATUM Gateway"` — passed to JobFactory's
    `pool_tag_string` for scriptSig formatting; mirrors gateway's
    `mining.coinbase_tag_primary`.
  - `[sv2_proxy] upstream_kind = "sv1_local" | "datum_native"` — phase
    selector.
  - `[sv2_proxy.sv1_local] host = "127.0.0.1" port = 23334
     username = "<bitcoin-address>" password = "x"` — for phase 1.
  - The standard gateway TOML/JSON keys (`bitcoind`, `mining`,
    `datum`, `api`, `logger`, original `stratum`) remain untouched. The
    SV2 proxy is purely additive.

- **Code organization (Rust crate layout) for the proxy:**
  ```
  datum-sv2-proxy/
    Cargo.toml          # depends on stratum-core, tokio, bitcoin, serde, toml
    src/
      main.rs           # tokio::main, config loading, listener bootstrapping
      config.rs         # TOML schema
      proxy.rs          # the HandleMiningMessagesFromClientAsync impl
      channel_state.rs  # HashMap<channel_id, ExtendedChannel<DefaultJobStore>>
      upstream/
        mod.rs
        sv1_local.rs    # phase 1: SV1 client to gateway
        datum_native.rs # phase 2: native DATUM protocol speaker
      gbt_to_template.rs # NewTemplate synthesis from GBT json (or from SV1 notify)
      vardiff.rs        # uses channels-sv2 vardiff helpers
  ```

## Ingest justification

Captures the practical deployment story: separate process, phase by phase,
config additive to existing gateway config. Keeps the recommendation
implementable as an external bolt-on rather than a fork-and-rewrite.
