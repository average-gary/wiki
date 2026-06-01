# path4 - handlers_sv2 (bidirectional handler traits)

**Source type**: repos
**Path**: `/Users/garykrause/repos/stratum/sv2/handlers-sv2/`
**GitHub**: https://github.com/stratum-mining/stratum/tree/main/sv2/handlers-sv2
**Date observed**: 2026-05-28

## Why this matters

The `handlers_sv2` crate is the canonical message-dispatch layer for the SV2 side of any role. It is **already direction-aware** — every subprotocol exposes both `*FromClient*` and `*FromServer*` variants. The reverse translator picks the *FromClient* variants for its SV2 side (since it is the SV2 server). No fork, no patch needed.

## API exposed (handlers-sv2/src/lib.rs)

```
pub use mining::{
    HandleMiningMessagesFromClientAsync, HandleMiningMessagesFromClientSync,
    HandleMiningMessagesFromServerAsync, HandleMiningMessagesFromServerSync,
    SupportedChannelTypes,
};
pub use common::{
    HandleCommonMessagesFromClientAsync, HandleCommonMessagesFromClientSync,
    HandleCommonMessagesFromServerAsync, HandleCommonMessagesFromServerSync,
};
pub use template_distribution::{ ... }
pub use job_declaration::{ ... }
pub use extensions::{ ... }
```

Each handler trait is provided in both `Sync` and `Async` variants. The `Async` variant uses `trait_variant` for runtime-agnostic async-trait dispatch (workspace dep `trait-variant = "0.1.2"`).

## Reverse translator's handler choice

| Side | Trait |
|---|---|
| SV2 (server-side, downstream miner) | `HandleMiningMessagesFromClientAsync` + `HandleCommonMessagesFromClientAsync` |
| SV1 (client-side, upstream pool) | NOT in this crate — uses `sv1_api::IsClient` instead |

The forward translator-proxy (sv2-apps) uses the *opposite* SV2 traits: `HandleMiningMessagesFromServerAsync` + `HandleCommonMessagesFromServerAsync` (because it is an SV2 client to the SV2 pool upstream).

## Key findings

- **Q3 (does roles_logic_sv2 need new mode)**: No — the bidirectionality is already baked into `handlers_sv2`. The `*FromClient*` traits expose handlers like `handle_open_extended_mining_channel`, `handle_submit_shares_extended`, `handle_update_channel`, `handle_close_channel`. The reverse translator implements these and translates each call into outgoing SV1 messages.

- **Channel-type filtering**: `SupportedChannelTypes` enum (Standard/Extended/Group/GroupAndExtended) gates which messages are dispatched. The reverse translator advertises `Extended` only (since SV1 is fundamentally extended-channel-shaped — extranonce1 + extranonce2). Standard channel translation would require the pool to provide pre-computed merkle roots which SV1 does not.

- **TLV/extension support**: Handler traits carry `Option<&[Tlv]>` for negotiated extensions. The reverse translator likely advertises zero negotiated extensions to its SV2 downstreams (since it cannot pass them upstream to an SV1 pool that doesn't speak SV2).

- **Frame parsing**: `handle_mining_message_frame_from_<server|client>` does the codec-sv2 -> parsers-sv2 -> handler dispatch in one call. The reverse translator's tokio loop reads a frame, calls this method, and the handler implementations route to translation logic.

- **Q7 (async runtime)**: The `Async` variants use `trait_variant`, which is runtime-agnostic — this means the reverse translator can use tokio (the convention in sv2-apps) without committing handlers_sv2 to a specific runtime. The chosen runtime in the reverse translator binary should match sv2-apps' translator-proxy: tokio.

## Reuse / write-from-scratch breakdown

REUSE AS-IS:
- `HandleMiningMessagesFromClientAsync` (and Sync variant) — implement on the reverse translator's SV2-server task.
- `HandleCommonMessagesFromClientAsync` — for SetupConnection / SetupConnectionSuccess.
- Frame parsing pipeline (handle_mining_message_frame_from_client).

WRITE FROM SCRATCH:
- The actual `impl HandleMiningMessagesFromClientAsync for ReverseTranslatorState` body — translates each SV2 message variant into SV1 client-to-server messages on a tokio::sync::mpsc to the SV1 client task.

## Ingest justification

`handlers_sv2` already has bidirectional handler trait variants — the reverse translator inherits 100% of the SV2-server-side message dispatch infrastructure unchanged. This is the strongest evidence that "reverse translator" is architecturally feasible without forking SRI's low-level crates.
