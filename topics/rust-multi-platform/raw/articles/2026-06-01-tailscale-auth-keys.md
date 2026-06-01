---
title: "Tailscale Auth Keys"
source_url: https://tailscale.com/kb/1085/auth-keys
type: docs
ingested: 2026-06-01
quality: 5
confidence: high
tags: [tailscale, auth-key, fleet-identity, single-slot, prior-art]
relevance: [single-slot-identity]
---

# Tailscale Auth Keys

Canonical reference for the "auth-key + tag" pattern that turns user-bound auth into machine-account fleet identity.

## Two key flavors

- **One-off** — single-use; ideal for cloud servers / immutable fleet members
- **Reusable** — multiple devices; "very dangerous if stolen"

## Tagged auth keys

After `tailscale up --auth-key=tskey-auth-...`, the device "assumes the identity of the auth key's tags" — replaces user identity with tag identity.

- Key expiry is **disabled by default for tagged devices** — gives stable long-lived fleet identity
- Changing tags does NOT change expiry unless device re-authenticates

## Ephemeral auth keys

"Node keys do not persist when a workload restarts, they reconnect as a different node." Useful for containers/Lambda; explicitly **not** single-slot.

## Identity primitive

`tskey-auth-...` presented at first connect; thereafter the node holds a NodeKey and is recognized server-side by tag membership.

## Rotation defaults (per Data agent)

- Node keys auto-expire every **180 days** by default
- Auth keys configurable 1–90 days, default cap 90 days
- One-off auth keys auto-revoke on single use; reusable keys require manual revocation

## Why it matters

Direct prior art for the topic's "single-slot fleet identity" pillar. The pattern: provisioning key (short-lived shared secret) → device-specific NodeKey (long-lived, tag-scoped). Maps to Balena's `provisioning-key → deviceApiKey` and Mender's `preauth-pubkey → device-key` lifecycle.

## See also

- [[2026-06-01-tailscale-acl-tags]]
- [[2026-06-01-tailscale-oauth-clients]]
- [[2026-06-01-tailscale-changelog-2026]]
- [[2026-06-01-specterops-tailscale-keys]] — adversary view
