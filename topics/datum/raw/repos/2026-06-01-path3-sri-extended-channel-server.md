---
title: "SRI ExtendedChannel<J> server-side state machine (channels-sv2)"
source: /Users/garykrause/repos/stratum/sv2/channels-sv2/src/server/extended.rs
source_type: local-code
ingested_by: path3
ingested_at: 2026-06-01
quality: high
relevance: critical
tags: [sri, sv2, channels-sv2, extended-channel, jobstore, jobfactory, datum-proxy]
---

# SRI ExtendedChannel server-side state machine

`ExtendedChannel<'a, J: JobStore<ExtendedJob<'a>>>` in
`sv2/channels-sv2/src/server/extended.rs` is the server-side abstraction that an
SV2 pool front (or, in our case, a DATUM proxy front) wraps around each
downstream extended channel.

## Key findings

- **Two constructors**, both relevant to the DATUM proxy direction question:
  - `new_for_pool(...)` — pool acts as the template authority, scriptSig
    formatted as `/pool_tag_string//`. **This is the constructor a DATUM SV2
    proxy would use** under the simplest "model (a)" architecture (proxy is the
    pool front; templates come from gateway-internal GBT).
  - `new_for_job_declaration_client(...)` — for a JDC-side channel; scriptSig
    formatted as `/pool_tag_string/miner_tag_string/`. Not relevant unless we
    federate downstream JDCs (model b).
  - The two only differ in coinbase scriptSig tag formatting; the underlying
    state machine is identical.

- **The reusable unit of work for a DATUM proxy is one `ExtendedChannel` per
  downstream miner channel.** It encapsulates: `channel_id`, `user_identity`,
  `extranonce_prefix` (an `AllocatedExtranoncePrefix`), `rollable_extranonce_size`,
  `requested_max_target`, `target`, `job_id_to_target` map, `nominal_hashrate`,
  `stable_hashrate` flag, the embedded `JobStore`, an embedded `JobFactory`,
  `ShareAccounting`, `expected_share_per_minute`, and an `Option<ChainTip>`.

- **Three update paths feed jobs into the channel:**
  1. `on_new_template(NewTemplate, Vec<TxOut>)` — the standard path for a pool
     that gets templates from a Template Provider (or, by extension, from a
     local GBT-derived synthesizer). Takes a `NewTemplate` SV2 message PLUS the
     concrete `coinbase_reward_outputs` the pool wants to add. **This is the
     hook where OCEAN's required outputs get injected.**
  2. `on_set_custom_mining_job(SetCustomMiningJob)` — only for connections with
     `REQUIRES_WORK_SELECTION` (i.e. a downstream JDC declared its own
     template). Path NOT taken under model (a).
  3. `on_group_channel_job(ExtendedJob)` — for a group channel broadcasting one
     job to many channels. Useful if the proxy serves many miners off one
     template (which is the common DATUM case). Re-stamps the job with the
     channel's own extranonce_prefix.

- **`on_set_new_prev_hash` activates the queued future job** when a chain tip
  arrives, atomically marks past jobs stale, and clears the seen-shares cache.
  This is the SV2 equivalent of the SV1 `mining.notify` clean-jobs flag and is
  the natural insertion point when DATUM's GBT-watcher detects a new tip.

- **`validate_share(SubmitSharesExtended)` is the single authoritative path**
  for share validation. Returns `ShareValidationResult::{Valid, BlockFound}`
  or `ShareValidationError::{Stale, DuplicateShare, InvalidJobId,
  BadExtranonceSize, DoesNotMeetTarget, VersionRollingNotAllowed, NoChainTip}`.
  On `BlockFound`, returns the full reconstructed coinbase plus the
  `template_id` (or None for custom jobs) — exactly what we'd need to forward
  upstream to OCEAN as the share/PoW.

## Ingest justification

This file IS the contract a DATUM SV2 proxy must talk to per channel. It
defines what the proxy can outsource (state, accounting, validation) and what
the proxy must supply (templates, coinbase outputs, chain tip). Path 3
recommendation depends on whether we can reach into this struct from a
gateway-driven event loop — and the answer is "yes, cleanly, via the public
`on_*` methods."
