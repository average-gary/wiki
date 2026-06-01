---
title: "HandleMiningMessagesFromClientAsync: the proxy's downstream entry point"
source: /Users/garykrause/repos/stratum/sv2/handlers-sv2/src/mining.rs
source_type: local-code
ingested_by: path3
ingested_at: 2026-06-01
quality: high
relevance: high
tags: [sri, sv2, handlers-sv2, async, tokio, proxy-entry-point]
---

# `HandleMiningMessagesFromClientAsync` is the trait the DATUM proxy implements

`sv2/handlers-sv2/src/mining.rs` defines four parallel handler traits:
`HandleMiningMessagesFromServerSync/Async` and
`HandleMiningMessagesFromClientSync/Async`. The DATUM proxy is the SV2 server
endpoint downstream miners connect to, so it implements
`HandleMiningMessagesFromClientAsync`.

## Key findings

- **Trait shape (from line 887):** the trait requires:
  - `type Error: HandlerErrorType`
  - `get_channel_type_for_client(client_id) -> SupportedChannelTypes`
  - `is_work_selection_enabled_for_client(client_id) -> bool`
  - `is_client_authorized(client_id, &Str0255) -> Result<bool, Error>`
  - `get_negotiated_extensions_with_client(client_id) -> Result<Vec<u16>, Error>`
  - Plus async leaf handlers: `handle_close_channel`,
    `handle_open_standard_mining_channel`, `handle_open_extended_mining_channel`,
    `handle_update_channel`, `handle_submit_shares_standard`,
    `handle_submit_shares_extended`, `handle_set_custom_mining_job`.

- **The trait provides default `handle_mining_message_frame_from_client` and
  `handle_mining_message_from_client` methods** that handle TLV-aware frame
  parsing and dispatch. The proxy only writes the leaf handlers; framing,
  extension negotiation, and message-type dispatch come for free.

- **For DATUM model (a) the proxy returns:**
  - `get_channel_type_for_client` → `SupportedChannelTypes::Extended`
    (DATUM only really makes sense with extended channels for hierarchical
    extranonce). Could optionally support `Standard` for very small miners.
  - `is_work_selection_enabled_for_client` → `false` (no JDC custom-work).
  - The proxy never receives `SetCustomMiningJob` and never needs to
    implement `handle_set_custom_mining_job` meaningfully — but the trait
    requires the method, so it would return `Err(Self::Error::unexpected_message(...))`
    or accept it with a "work selection not negotiated" rejection.

- **Concrete share submission flow:**
  1. Miner sends `SubmitSharesExtended` over Noise+codec.
  2. Wire pipeline (codec_sv2 → framing_sv2 → parsers_sv2) decodes the frame.
  3. `handle_mining_message_frame_from_client` dispatches to
     `handle_submit_shares_extended(client_id, msg, tlv_fields)`.
  4. Proxy looks up the `ExtendedChannel` by `client_id+channel_id`, calls
     `channel.validate_share(submit)`.
  5. On `Ok(Valid)` → reply with `SubmitSharesSuccess` (batched per
     `share_batch_size`); forward to OCEAN over DATUM protocol with
     reconstructed coinbase + extranonce.
  6. On `Ok(BlockFound(_, template_id, coinbase))` → also forward as a block
     solution upstream; SRI returns the full reconstructed coinbase already.
  7. On `Err(_)` → reply with `SubmitSharesError`, optionally close channel
     for repeated abuse.

- **Two trait variants matter strategically:** `*Sync` is suitable for
  embedded / no-async firmware code; `*Async` is suitable for tokio-based
  proxies. **Since the DATUM gateway is C+threads/libevent and the proxy will
  almost certainly be a separate Rust process, the Async variant is the
  natural fit** — the proxy will use tokio for concurrent miner connections
  and IPC to the C gateway.

## Ingest justification

This is the trait that defines the DATUM proxy's downstream-facing API
surface. Establishes that the proxy's incremental code is essentially the
seven leaf handler implementations (~200-400 LOC) plus channel storage,
because everything else (frame parsing, dispatch, TLV) is provided by the
trait's defaults.
