---
title: "block/buzz — custom NIPs & agent/git/data model"
source: https://github.com/block/buzz/tree/main/docs/nips
type: repo
tags: [buzz, nostr, nips, data-model, agents, git, event-kinds]
confidence: high
ingested: 2026-07-23
summary: "The concrete event-kind data model: ~14 custom NIPs (agent auth/attestation/metrics, channel windowing, read-state, DM visibility), git-on-object-storage, and the ACP/MCP + MeshLLM agent runtime."
---

# block/buzz — custom NIPs & data model

Everything in buzz is a signed Nostr event of one of these kinds, stored in Postgres.

## Agent identity NIPs
- **NIP-OA (Owner Attestation):** owner key authorizes an agent key to publish; agent stays the author (`event.pubkey`), the owner attestation is provenance evidence only, not impersonation. (SiliconAngle: "a second signature ties that agent back to its human owner — a verifiable passport + audit trail.")
- **NIP-AA (Agent Authentication):** agent presents its NIP-OA credential during NIP-42 AUTH (**kind 22242**); relay verifies and checks the owner is an active member — agents get access via owner membership.
- **NIP-AM (Agent Turn Metrics, kind 44200):** encrypted per-turn token usage + estimated cost, readable only by the owner.

## Channel / sync NIPs
- **NIP-CW (channel windowing):** relay-signed overlays — **kind 39005** (thread summary), **kind 39006** (window bounds: `has_more` + next cursor) for paginated timelines.
- **NIP-WP (kind 9033):** set/clear workspace profile icon (served in NIP-11 relay info).
- **NIP-RS (kind 30078):** cross-device read-state sync (encrypted, parameterized-replaceable).
- **NIP-DV (kind 30622):** per-viewer DM-visibility snapshot (hide DM without leaving).
- ~14 custom NIPs total (NIP-AA/AE/AM/AO/AP/CW/DV/ER/GS/IA/OA/PL/RS/WP).

## Git on object storage (docs/git-on-object-storage.md)
- Git repos live on **S3-compatible object storage**: content-addressed immutable pack objects + a single mutable manifest pointer updated by atomic compare-and-swap.
- `git index-pack`/`upload-pack`/`receive-pack` treated as trusted upstream binaries.
- A successful push may publish **kind 30618** so subscribers learn refs moved.
- **NIP-GS** ("Git Object Signing with Nostr Keys") signs commits/tags with the same secp256k1 keypair via `git-sign-nostr`/`git-credential-nostr`.
- Ships **formal specs** in `docs/spec`: `GitOnObjectStore.tla`, `MultiTenantRelay.tla` (TLA+), `MultiTenantAuth.spthy` (Tamarin).

## Agent runtime (docs/MCP_DRIVEN_HOOKS.md, buzz-shared-compute-dev.md)
- Runtime stack: `Buzz Desktop → buzz-acp → buzz-agent → MeshLLM SDK → local/remote compute`. Built-in agent **Fizz** (no API key, inherits default provider/model).
- **Shared compute:** "Share this machine" exposes local GPU; inference travels over **MeshLLM** via direct QUIC or encrypted **iroh** relays; Buzz membership controls which node identities are admitted.
- **MCP-driven hooks:** lifecycle hooks are ordinary MCP tools (`tools/list`/`tools/call`); `_`-prefixed tools are hooks hidden from the LLM. Defined: `_Stop`, `_PostCompact`. Safety: 2.5s timeout, 3-rejections/prompt budget, hook output injected as lower-trust tool-result messages.
