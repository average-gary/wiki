---
title: "Tailscale ACL Tags"
source_url: https://tailscale.com/kb/1068/acl-tags
type: docs
ingested: 2026-06-01
quality: 5
confidence: high
tags: [tailscale, acl, tags, fleet-identity, prior-art]
relevance: [single-slot-identity]
---

# Tailscale ACL Tags

"Tags are essentially service accounts" — the explicit framing of single-slot fleet identity decoupled from any human user.

## Semantics

- Identity = **union** (not intersection) of all assigned tags
- ACLs match on `tag:prod`, `tag:postgresql`, etc.
- "Applying a tag to a device removes any user-based authentication" — mutual-exclusivity rule that makes fleet identity persistent across personnel changes
- `tagOwners` in policy file gates who can mint a given tag (e.g., `"tag:server": ["dave@example.com"]`)
- Retagging mints a **new NodeKey** but preserves the Tailscale IP — identity rotation without losing reachability

## Tag application

- At enrollment: `tailscale up --auth-key=... --advertise-tags=tag:prod-2`
- Post-hoc: `tailscale login --advertise-tags=...`

## Why it matters

Defines the actual semantics of tag-as-identity, including ownership, rotation, and IP stability — the heart of the single-slot pattern. Critical for understanding what "the tag is the identity" actually means at the policy layer.

## See also

- [[2026-06-01-tailscale-auth-keys]]
- [[2026-06-01-specterops-tailscale-keys]] — tag scoping is NOT least-privilege
