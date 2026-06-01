---
title: "SV2 Spec — Mining Protocol (05): Channel types, extranonce, async share submit"
url: https://github.com/stratum-mining/sv2-spec/blob/main/05-Mining-Protocol.md
type: paper
source: stratum-mining/sv2-spec
captured: 2026-05-28
quality: 10
path: 3
tags: [channels, standard-channel, extended-channel, group-channel, extranonce, async-submit, header-only-mining, sv1-upstream]
---

# SV2 Spec — Mining Protocol (05)

## Why this matters for the reverse translator

This document is the *operational core* of what the reverse translator must collapse. Channel types, extranonce semantics, and async share submission are where SV2 wins on the wire — and most of those wins evaporate when the upstream is a single SV1 socket carrying JSON-RPC.

## Channel types

### Standard Channel
- For end Mining Devices using **header-only mining** (HOM)
- Modifiable bits only in `version`, `nonce`, `nTime` (Merkle root fixed)
- Search space ~280 Th per nTime when fixed
- Messages: `NewMiningJob`, `SubmitSharesStandard`

### Extended Channel
- For proxies; enables search-space distribution across downstream
- Carries `extranonce_prefix` (upstream-allocated) + `extranonce_size` (locally distributable)
- Search space: `2^(nonce_bits + version_rolling_bits + extranonce_size*8)` per nTime — exponentially larger than Standard
- Messages: `NewExtendedMiningJob`, `SubmitSharesExtended`

### Group Channel
- Broadcast-style job distribution to multiple Standard/Extended channels at once
- Single `NewExtendedMiningJob` reaches all members; `SetTarget` applies uniform difficulty across the group
- All channels in a group must have identical Extended Extranonce sizes
- Cannot be used with `REQUIRES_STANDARD_JOBS` flag

## Extranonce architecture vs SV1

- SV2 extended extranonce = `extranonce_prefix` + locally reserved + downstream reserved (3 regions, hierarchical)
- Up to 32 bytes (`B0_32`) total
- SV1 = single `extranonce1` (typically 4 bytes), flat, per-connection
- SV2 hierarchical allocation prevents search-space collision across nested proxy layers
- Standard Jobs without enough nonce/extranonce risk exhausting nonce space before nTime advances at modern hashrates

## Share submission semantics (SV2)

- `SubmitSharesStandard` / `SubmitSharesExtended` carry `sequence_number`
- Server batches via `last_sequence_number` + `new_submits_accepted_count` in success response
- Spec note: "The server does not have to double check that the sequence numbers sent by a client are actually increasing" → optional ordering, client owns correctness
- Async pipelining: submission decoupled from acknowledgment (no per-share blocking RTT)

## Compared to SV1 mining.submit

- SV1 = strict request/response per share, JSON-RPC, blocking until pool responds
- SV2 = pipelined, batched ack, no per-share RTT cost

## What survives reverse translation to SV1

**Survives:**
- PoW core (nonce, ntime, target)
- Per-connection user_identity (mappable to SV1 worker name)
- Share accept/reject logic
- Difficulty adjustment via target update

**Lost:**
- **Multi-channel abstraction** — SV1 collapses to single connection, channel granularity gone
- **Hierarchical extranonce partitioning** — SV1's flat `extranonce1` cannot represent nested layers; translator must select one fixed allocation
- **Group-channel broadcast** — SV1 needs per-miner job distribution
- **Extended-job flexibility** — Merkle-root rolling, custom job declaration not expressible in SV1
- **Per-channel SetTarget** — translator must converge to single difficulty
- **Async pipelined submit** — SV1 forces synchronous mining.submit roundtrips; sequence-number metadata cannot be reconstructed without translator-side buffering
- **Header-only mining (merkle_root_only)** — SV1 has no NewMiningJob-with-fixed-merkle-root semantics; the upstream still ships full coinbase information

## Feature-survival verdict (reverse translator)

| Feature | Status | Why |
|---|---|---|
| Standard channel (HOM) downstream | **partially-lost** | Works between miner and proxy; HOM benefit collapsed at SV1 egress |
| Extended channel | **partially-lost** | Internal split works; only one extranonce1 upstream |
| Group channel broadcast | **lost** | SV1 has no broadcast primitive; must fan out per-worker |
| 32-byte extranonce_prefix | **partially-lost** | Internal allocation works; upstream still bound by SV1's ~4-byte extranonce1 |
| Async batched share submit | **partially-lost** | Internal async; egress is synchronous mining.submit RTTs |
| Sequence-number ordering | **lost** | No SV1 equivalent; translator must buffer + reorder |
| Per-channel SetTarget | **lost** | SV1 = one difficulty per connection |
| Header-only mining / merkle_root_only | **lost** | Needs upstream cooperation; SV1 ships full coinbase |
| Version rolling (BIP310/320) | **survives** | Both SV1 (mining.configure) and SV2 support it |

## Ingest justification

Single most quantitatively useful document for the path-3 thesis: it lets us mark each SV2 mining-protocol feature as survives / partially-lost / lost with concrete reasoning grounded in the message formats themselves.
