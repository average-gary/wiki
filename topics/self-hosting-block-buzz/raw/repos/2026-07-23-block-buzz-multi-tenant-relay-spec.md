---
title: "block/buzz — multi-tenant relay spec (DRAFT) + tenant boundary reality"
source: https://github.com/block/buzz/blob/main/docs/multi-tenant-relay.md
type: repo
tags: [buzz, multi-tenant, community, postgres-rls, security-boundary, tla-plus]
confidence: high
ingested: 2026-07-23
summary: "Multi-tenant per-community isolation (relay-side community_id resolution + Postgres RLS + community-prefixed Redis keys) is a DRAFT TLA+/Tamarin spec, NOT shipping. Today the relay PROCESS is the security boundary."
---

# block/buzz — multi-tenant relay spec (draft)

**Important resolution of a cross-agent contradiction:** this doc describes a *proposed* design. SECURITY.md + the doc's own status say **today "a Buzz relay process is the security boundary,"** with `channel_id` as the only sub-relay locality. Per-community row-level isolation is the future, not what ships in v0.4.x. Running many teams/communities on one relay is NOT yet a hardened boundary — run one relay per trust domain for now.

## Proposed design (draft — TLA+ `MultiTenantRelay.tla` + Tamarin `MultiTenantAuth.spthy`)
- The **community** is the tenant/security boundary: owns channels, membership, a signing keypair, a token namespace, workflows, an audit hash chain, and its messages. Communities are INSERT-only DB rows.
- `community_id` is **resolved by the relay, never trusted from the client `h` tag.** Channel-bearing ops: `resolve: channel_id → community_id`. Channel-less ops (profiles, DMs, lists): `resolve_host: host → community_id`. Unmapped host = fail-closed reject (no default community) — blocks the confused-deputy cross-tenant escape.
- **Postgres Row-Level Security** as fail-closed backstop: every tenant table has RLS `community_id = current_setting('app.community_id')::uuid`; relay DB role is `NOBYPASSRLS` non-superuser; `app.community_id` set via `SET LOCAL` per transaction. Uniqueness constraints must be composite `(community_id, …, id)`.
- **Redis keys carry community:** `buzz:{community}:channel:{id}`, `buzz:{community}:presence:{pubkey}`, `buzz:{community}:typing:{id}`. Unprefixed keys only for single-tenant / physically isolated Redis.
- **Explicit non-goals (spec does NOT prove):** liveness/performance, physical-resource isolation (communities share CPU/pool/id-space), "above-the-interface" client leakage.
- Note: `#2600` — per-owner community cap hardcoded to 3.
