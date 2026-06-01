---
title: "Issue #146 — Add Stratum V2 (SV2) Support to DATUM"
source: "https://github.com/OCEAN-xyz/datum_gateway/issues/146"
type: articles
tags: [datum, stratum-v2, sv2, sri, protocol-evolution, ocean, github-issue, concept-ack]
summary: "Open GitHub issue from electricalgrade (2025-08-23) proposing native SV2 support inside datum_gateway: a self-contained C library (sv2_wire/common/mining/adapter) + optional libsv2wire shared lib for a Python translator. Scope: SetupConnection, OpenExtendedMiningChannel (with Standard fallback), SetNewPrevHash, NewExtendedMiningJob, SubmitSharesExtended. Out of scope: Template Distribution, Job Declaration. luke-jr (maintainer) responded: prefers shared library via pkg-config rather than embedded source. No formal Concept ACK as of 2026-06-01 — issue still open."
confidence: high
ingested: 2026-06-01
ingested_by: path1
quality_score: 5
canonical_url: "https://github.com/OCEAN-xyz/datum_gateway/issues/146"
---

# Issue #146 — Add Stratum V2 support to DATUM

This is the protocol-evolution conversation the wiki was looking for. It is the **only** OCEAN-side discussion of how SV2 relates to DATUM, and it directly informs the SV2-downstream-proxy design the topic now covers.

## Status (as of 2026-06-01)

- **State**: open
- **Created**: 2025-08-23 by `electricalgrade`
- **Last activity**: ~2025-08-30
- **Comments**: 2 (one from luke-jr, one from electricalgrade)
- **No formal Concept ACK or NACK** has been recorded.

## What's proposed (verbatim scope)

Messages in scope for MVP:

**Common Protocol:**
- `SetupConnection` / `SetupConnection.Success`

**Mining Protocol (Extended Channel preferred, Standard fallback):**
- `OpenExtendedMiningChannel` / `OpenExtendedMiningChannel.Success`
- `SetNewPrevHash` (with `job_id`, `prev_hash`, `ntime`, `clean_jobs=true`)
- `NewExtendedMiningJob` (with `job_id`, `version`, `merkle_root`, `nbits`, `coinb1`, `coinb2`)
- `SubmitSharesExtended` → `.Success` / `.Error`

Quoting the proposal: **"Optional (later): Reconnect, ChannelEndpointChanged, SetTarget, heartbeats, JD capabilities."**

**Explicitly out of scope:** Template Distribution and Job Declaration subprotocols — quote: *"These are unnecessary in DATUM."*

## Why TD and JD are out of scope

This is the deepest architectural insight in the issue. SV2's Template Distribution and Job Declaration subprotocols solve the exact problem DATUM already solves: letting the miner build the template locally and tell the pool what's in it. So:

- **Template Distribution (TD)**: pool gets the template from a Template Provider service. DATUM gets the template from `getblocktemplate` on the operator's local node. Same outcome, different transport — DATUM doesn't need TD because it already isn't using upstream-provided templates.
- **Job Declaration (JD)**: miner declares its job (including transaction set) to the pool. DATUM's coinbaser exchange (`0x10` request, `0x11` response) is its narrower equivalent — the miner asks for outputs, the pool returns them, the miner builds the rest locally. DATUM's `0x50` job-validation subcommands let the pool reconstruct and verify the block but don't "declare" the job in SV2's sense.

So a SV2 implementation inside DATUM would only be the **mining subprotocol** — channels, jobs, shares. The template-source plumbing is DATUM's job.

## Proposed C library structure (verbatim)

```
sv2_wire.{h,c}       # frame handling, helpers for LE/U24
sv2_common.{h,c}     # SetupConnection + common messages
sv2_mining.{h,c}     # Mining protocol messages
sv2_adapter.{h,c}    # Event loop server with callbacks
```

Frame format: `u16 ext | u8 msg | u24 len | payload` (little-endian). Build flag `ENABLE_SV2=1`. Optional shared library `libsv2wire` to expose to a Python translator.

## Coexistence with existing SV1

Quote: *"DATUM benefits from direct SV2 upstream/downstream compatibility while keeping existing Stratum V1 paths."*

Share validation reuse: *"On on_submit_ext, DATUM reuses existing SV1 validation pipeline (reconstruct header, check hashes/target, stale/time, dupe check)."*

This means: SV2 → SV1 internal translation, then SV1 → DATUM upstream. Two protocol translations stacked. The downstream-SV2-proxy this wiki topic is being broadened to cover would do the SV2 → DATUM translation in one hop, but the proposal here goes through SV1 as a pivot.

A **separate listener** is proposed on a configurable port (default `0.0.0.0:3334`).

## Maintainer response (luke-jr, 2025-08-24)

Verbatim quote:

> "Having a library for the Sv2-specific code makes sense. But in that case, it seems like it would be better to have it be a pkg-config shared library we simply link to?"

Translation: don't embed the SV2 implementation inside datum_gateway; build it as a separate, properly-versioned shared library that gets linked. This is consistent with the rest of the gateway's dependency posture (libsodium, libcurl, libjansson, libmicrohttpd are all pkg-config linked). It's a procedural ask, not a protocol-level objection.

## Submitter response (electricalgrade, 2025-08-30)

Reports progress on:
- The Noise protocol handshake (the SV2 transport-encryption layer)
- A Python translator for testing with a CPU miner

Architecture pivot quote:

> "SV2 pool ← SV2 Translator ← SV1 Miner"

Note the direction — this is SV1 miner upstream of an SV2 translator that reaches an SV2 pool. **This is the inverse of the wiki topic's "SV2 mining-channel server downstream, DATUM Protocol client upstream to OCEAN" framing.** The submitter is testing the easier direction first (SV1 hardware → SV2 protocol → SV2 pool, useful in a non-DATUM world); the harder direction (SV2 hardware → DATUM upstream) is the topic's target.

## Implications for the SV2-downstream-proxy design

1. **The OCEAN team has not committed to SV2.** Concept ACK is still pending. A proxy built externally cannot assume DATUM will gain SV2 fluency upstream — the proxy must do the full SV2 ↔ DATUM translation itself.
2. **The proposal validates the wiki topic's plan.** If electricalgrade's PR landed, the in-tree implementation would do exactly what the proxy is building (modulo direction). That's both validation and competitive risk.
3. **Noise (SV2) and libsodium-handshake (DATUM) are non-overlapping crypto layers.** Both must be implemented. The "SV2 pool ← SV2 Translator ← SV1 Miner" diagram in the issue confirms the translator owns Noise on the upstream side.
4. **`SubmitSharesExtended` ↔ `0x27`** is the share-submission mapping. SV2's `extranonce_prefix` (variable-length) collides cleanly with DATUM's 12-byte extranonce in the share opcode.
5. **`OpenExtendedMiningChannel.Success` carries an `extranonce_prefix`** — but DATUM assigns the per-miner `coinbase_unique_id` (16-bit) at handshake. The proxy must reconcile these two identity primitives.
6. **The proposal explicitly avoids Job Declaration** — so DATUM-internal SV2 will never carry full template details in either direction. Same constraint applies to the proxy.

## Rabbit-hole leads

- **electricalgrade's progress branch.** Quoted as having a libnoise handshake working and a Python translator. Worth searching that user's GitHub for any forked or feature-branch code that pre-figures the same translation logic.
- **OCEAN's unstated stance.** Two comments only, no Concept ACK after 9 months. Either the proposal is on the back burner pending DATUM Prime's pool-side rewrite, or there's an unstated reason the OCEAN team is cool on it (e.g. they want SV2 support but only after the "almost completely blinded pool" version of DATUM lands).
- **PR 209 / Datum queue overflows.** Recent stability bugs filed 2026-06-01 around queue overflow + non-graceful recovery suggest the protocol's ack-flow has reliability problems that any proxy must be defensive about.

## Sources

- [Issue #146 — github.com/OCEAN-xyz/datum_gateway/issues/146](https://github.com/OCEAN-xyz/datum_gateway/issues/146) — original proposal text + 2 comments.
