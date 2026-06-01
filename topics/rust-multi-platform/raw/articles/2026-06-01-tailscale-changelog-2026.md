---
title: "Tailscale Changelog 2024-2026 — Workload Identity Federation, Device Posture"
source_url: https://tailscale.com/changelog
type: changelog
ingested: 2026-06-01
quality: 5
confidence: high
tags: [tailscale, oidc, workload-identity-federation, ephemeral-nodes, 2026]
relevance: [single-slot-identity]
---

# Tailscale 2024-2026 — Pivot from Auth Keys to OIDC Workload Identity

The 2025-2026 chapter of Tailscale fleet ops marks the pivot from pre-shared auth keys to OIDC workload identity for fleet operators.

## Key milestones

| Date | Change |
|---|---|
| 2025-05-05 | OAuth client management exposed via APIs and Terraform Provider |
| 2025-10-30 | **Beta** of federated OIDC workload identities from third-party providers |
| 2026-01-22 | ACL device posture gained `IS SET`/`NOT SET` operators |
| 2026-01-30 | Provider-native identity token authentication for **GitHub Actions and GitLab CI** — direct OIDC from CI to Tailscale, no static keys |
| 2026-02-18 | Fleet Device Management and Huntress Managed EDR posture-signal integrations |
| **2026-02-19** | **Workload Identity Federation went GA** — eliminates long-lived auth keys for fleet automation |
| 2026-04-08 | Ephemeral nodes free up to a monthly limit, auto-converting to standard tagged devices after 4 hours |

## Why it matters

The historical arc visible at Tailscale 2025-2026 is the same one Sigstore traveled with software signing in 2021-2024: long-lived shared secrets → short-lived OIDC-bound credentials. Edge fleets shipping in 2026+ should plan for WIF as the default, with auth keys retained only for offline/air-gapped scenarios.

## See also

- [[2026-06-01-tailscale-auth-keys]]
- [[2026-06-01-tailscale-oauth-clients]]
- [[2026-06-01-k8s-sa-tokens-2025-2026]] — the upstream pattern WIF mirrors
