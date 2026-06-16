---
title: "NixCon 2025 — Supply Chain Security Panel Discussion"
source: https://talks.nixcon.org/nixcon-2025/talk/XWQC8U/
video: https://www.youtube.com/watch?v=ncqy7S92UMw
type: article
panelists: [John Ericson, Julien Malka (Luj), Arian van Putten, Martin Schwaighofer]
moderator: Shahar "Dawn" Or
venue: NixCon 2025
year: 2025
ingested: 2026-06-15
tags: [nixcon, supply-chain, attestation, signed-expressions, panel]
confidence: high
quality: 5
---

# NixCon 2025 — Supply Chain Security Panel

The single best 2025 snapshot of where Nix supply-chain security stands.

## Key claims

- **Consensus framing**: "Nix is a very promising technology for fundamentally
  improving supply chain security" — but adoption + UX gaps are the
  bottleneck, not the model.
- Maps the 2025 supply-chain tooling landscape inside Nix (signatures,
  attestations, rebuilders, channel auth) and how they should compose.
- Panel composition spans:
  - **John Ericson** — RFC-100 / CA-derivations advocate
  - **Martin Schwaighofer** — rebuilders + remote-attestation researcher
    (NixCon 2024 "Rebuilding Builders Instead of Trusting Trust")
  - **Arian van Putten** — distro security
  - **Julien Malka (Luj)** — Lix governance / fork
- Open question raised: *Should `cache.nixos.org` signatures cover only the
  last hop, or end-to-end builder provenance?*

## Why this matters

Sets the baseline against which "NixOS Bitcoin builds" must be measured. The
multi-builder attestation model Bitcoin Core's `guix.sigs` already implements
in the small is exactly what the Nix community is converging toward at scale —
but the specifics of signed expressions, rebuilder UX, and CA-derivation
rollout remain unresolved as of late 2025.
