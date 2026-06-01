---
title: "Stratum V2 Specification — 05-Mining-Protocol.md"
source_url: https://github.com/stratum-mining/sv2-spec/blob/main/05-Mining-Protocol.md
source_type: specification
ingested: 2026-05-28
credibility: high
confidence: high
tags: [stratum-v2, mining-protocol, user_identity, coinbase, OpenMiningChannel, NewExtendedMiningJob, extranonce_prefix]
---

# 05 — Mining Protocol (canonical SV2 spec)

## Why this matters
Defines `user_identity`, channel-open semantics, and coinbase-bearing job messages. The primary spec authority on what `user_identity` is and where coinbase bytes live in SV2.

## Key claims (with quotes)

### user_identity (Str0_255)
On both `OpenStandardMiningChannel` and `OpenExtendedMiningChannel`:
> "Unconstrained sequence of bytes. Whatever is needed by upstream node to identify/authenticate the client, e.g. 'braiinstest.worker1'."

Format/validation are "left to the upstream node's discretion." **The spec is silent on whether `user_identity` may be embedded into coinbase bytes; it neither prescribes nor prohibits it.**

### Per-channel coinbase variation
- `OpenStandardMiningChannel.Success` returns `extranonce_prefix` (B0_32) — "Bytes used as implicit first part of extranonce." Pool-chosen, per-channel.
- `OpenExtendedMiningChannel.Success` returns `extranonce_prefix` and `extranonce_size`.

### Job-bearing messages
- `NewMiningJob` (Standard channel): carries `channel_id, job_id, min_ntime, version, merkle_root` only — **no coinbase bytes** sent to the miner; the Pool computes the merkle root over its server-side coinbase.
- `NewExtendedMiningJob`: carries `channel_id, job_id, min_ntime, version, version_rolling_allowed, merkle_path, coinbase_tx_prefix (B0_64K), coinbase_tx_suffix (B0_64K)` — actual coinbase bytes are exposed to extended-channel miners.
- `NewExtendedMiningJob` may be addressed to a **group_channel_id**: "For a group channel: This acts as a broadcast message that distributes work to all channels under the same group with one single message."
- A proxy "MAY transform this multicast variant for downstream standard channels into NewMiningJob messages."

### SetCustomMiningJob
Used "on extended or group channels with REQUIRES_WORK_SELECTION flag set." Carries client-built coinbase: `coinbase_tx_version, coinbase_prefix, coinbase_tx_input_nSequence, coinbase_tx_outputs, coinbase_tx_locktime, merkle_path`, plus `mining_job_token` from JDS. **JD-only path.**

## Reading on the thesis
- Spec **does not link** `user_identity` → coinbase, but does **not forbid** it either.
- The per-channel slot for coinbase variation is `extranonce_prefix`, which is *Pool-chosen* — so a Pool that wished to encode a function of `user_identity` into the coinbase already has a normative slot to do so.
- Per-channel `NewMiningJob` issuance to a Standard channel is allowed (the broadcast-group form is opt-in via `group_channel_id`); each channel's merkle root can be computed over a different coinbase.
