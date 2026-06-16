---
title: "Nix supply-chain roadmap (2024–2026 community state)"
type: topic
created: 2026-06-15
updated: 2026-06-15
confidence: high
tags: [nix, supply-chain, roadmap, nixcon, lix, ca-derivations]
sources:
  - "[[../../raw/articles/2026-06-15-nixcon-2025-supply-chain-panel.md|NixCon 2025 — Supply Chain Panel]]"
  - "[[../../raw/articles/2026-06-15-rb-summit-2025-vienna.md|RB Summit 2025 Vienna]]"
  - "[[../../raw/articles/2026-06-15-xz-cve-2024-3094-cox.md|xz CVE-2024-3094 (Cox)]]"
---

# Nix supply-chain roadmap

Where the Nix supply-chain story stands in mid-2026, with implications for
Bitcoin reproducibility.

## What's *done*

- **CA-derivations RFC merged** (RFC 62, 2022). Implementation rollout in
  Nix and Lix is the open question, not the design.
- **Sandboxed FOD fetches** by default — every `fetchurl`/`fetchgit` is
  hash-pinned.
- **Per-input lockfiles** via flakes — `flake.lock` pins everything.

## What's *in flight* (2025-2026)

From the [[../../raw/articles/2026-06-15-nixcon-2025-supply-chain-panel.md|NixCon 2025 panel]]
(John Ericson, Julien Malka, Arian van Putten, Martin Schwaighofer):

1. **Builder attestation beyond `cache.nixos.org`**. Today Nix's binary
   cache signature covers only the last hop (cache → user). Schwaighofer's
   thesis work pushes for end-to-end source → builder → store-path
   attestation, optionally TPM/remote-attestation backed.
2. **Signed Nix expressions / channel authentication**. Landweber's NixCon
   2024 talk surfaces a Guix-style `guix pull --commit` model for Nix
   inputs. RFC 100 (Nixpkgs commit signing) is the path forward.
3. **Distributed rebuilders**. Generalizing Bitcoin Core's
   [[../concepts/multi-builder-attestation.md|guix.sigs]] pattern to
   Nixpkgs at large.

## What's *unresolved*

- **Bootstrap-tools shrinkage**. No active effort to reproduce Guix's
  full-source bootstrap. ([[../concepts/bootstrap-chain.md|Bootstrap chain]])
- **Lix vs Nix governance**. Two implementations diverging on extension
  policy, language stability, and release cadence. A Bitcoin operator
  pinning a flake today doesn't know which implementation they'll be using
  in 12 months.
- **Source-tarball reproducibility**. RB Summit 2025 introduced a new track
  (`d3-sourcerepro`) to address xz-style upstream-tarball tampering. Not
  yet integrated into Nix-side workflows.

## Implications for Bitcoin

- **Today**: Nix is fine for *deployment* and *dev environments* but
  insufficient for *upstream Bitcoin Core release builds*. The gap is
  bootstrap-tools + governance turbulence + lack of multi-builder
  rebuilder cohort. ([[why-bitcoin-core-uses-guix-not-nix.md]])
- **2-3 year horizon**: if signed expressions + CA-derivations + a
  rebuilder cohort all land in mainline Nix or stable Lix, the gap closes
  enough for a Nix attester to be a credible toolchain-diversity addition
  to `guix.sigs`. ([[playbook-nix-attestation-for-bitcoin.md]])
- **Indefinite**: Guix's full-source bootstrap is not on the Nix roadmap.
  This means *for trusting-trust resistance specifically*, Nix will not
  reach Guix's level absent a major upstream commitment.

## What changed post-xz (CVE-2024-3094)

The community position from RB Summit 2025: *"Reproducible builds can only
protect against tampering with the binary artifacts, not against tampering
with the input."* RB alone would not have caught xz had it been merged
upstream. The defense is *combined*: reproducible builds + source
attestation + diverse build paths. This vindicates the multi-builder
cohort model that Bitcoin Core has run since 2019 and frames where Nix
needs to head.
