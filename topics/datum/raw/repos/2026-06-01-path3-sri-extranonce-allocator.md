---
title: "SRI ExtranonceAllocator vs DATUM 12-byte extranonce: the bridge"
source: /Users/garykrause/repos/stratum/sv2/channels-sv2/src/extranonce_manager/{mod.rs,allocator.rs,prefix.rs}
source_secondary: https://raw.githubusercontent.com/OCEAN-xyz/datum_gateway/master/src/datum_protocol.h
source_type: local-code+remote-header
ingested_by: path3
ingested_at: 2026-06-01
quality: high
relevance: high
tags: [sri, sv2, extranonce, datum-protocol, allocator, bridge]
---

# Extranonce hierarchy reconciliation

The single biggest semantic mismatch between SV2 channels and DATUM's wire
protocol is the extranonce structure.

## Key findings

- **SV2 hierarchical layout (from `extranonce_manager`):**
  `[ upstream_prefix ][ local_prefix ][ local_index ][ rollable ]` —
  total ≤ 32 bytes. The `ExtranoncePrefix` (first three regions) is what the
  channel server pins per channel and embeds into `coinbase_tx_prefix`; the
  `rollable` portion is what the miner varies inside `SubmitSharesExtended.extranonce`.
  Allocator hands out a unique `local_index` per channel via an internal bitmap
  of `max_channels` bits; capacity table:
  `max_channels=256 → 1 byte index → 32 B bitmap`,
  `max_channels=65536 → 2 bytes → 8 KB bitmap`,
  `max_channels=16M → 3 bytes → 2 MB bitmap`.
  RAII drop releases the bit (no manual release API).

- **DATUM `T_DATUM_PROTOCOL_POW.extranonce[12]`** — DATUM's upstream submission
  carries a fixed **12-byte extranonce**, not a 32-byte split. From
  `datum_protocol.h`: `unsigned char extranonce[12]`. This is the full
  per-share extranonce as DATUM/OCEAN expects it for upstream validation.
  Internally DATUM also tracks `coinbase_id` (one of up to 8 cached coinbases
  on the pool side) so the pool can rebuild the coinbase by referencing a
  pre-shared output set rather than retransmitting it on every share.

- **Bridge strategy:** the SV2 proxy must allocate extranonces such that the
  **full extranonce (prefix + rolling) the miner produces fits inside DATUM's
  12-byte upstream field.** Concrete recipe:
  - Set `total_extranonce_len = 12` on `ExtranoncePrefix`/allocator construction.
  - Reserve e.g. `local_index = 4 bytes` (16M channels: probably overkill;
    2 bytes / 65k channels is ample for a single gateway). `local_prefix`
    bytes can be 0 or a small node-id.
  - That leaves `rollable = 12 − local_index_bytes` for the miner's roll
    (8 bytes with 4-byte index, 10 bytes with 2-byte index).
  - On a `SubmitSharesExtended` with 8-or-10-byte rolling extranonce, the
    proxy concatenates `extranonce_prefix || rolling = 12 bytes` and submits
    that as the DATUM `extranonce[12]`.

- **DATUM `coinbase_id` is an upstream optimization, not a downstream
  constraint.** The proxy can submit shares carrying the full coinbase to
  OCEAN until it receives a `coinbase_id` assignment (DATUM_PROTOCOL_JOB
  flow), then use that id for subsequent shares against the same template.
  This is orthogonal to SV2 channel state; it's a pure proxy-to-OCEAN concern.

- **`AllocatedExtranoncePrefix` ownership semantics:** the `ExtendedChannel`
  takes ownership and the allocation auto-releases on channel drop. The
  proxy's per-connection state should hold the channel; closing the
  TCP/Noise connection drops the channel which drops the allocation. No
  manual cleanup required.

## Ingest justification

This is the pivotal "structural impedance mismatch" question for the proxy
design. Without resolving the 32-byte vs 12-byte extranonce question, the
upstream submission path can't function. Confirms a clean configurable bridge
exists with no SRI patching required.
