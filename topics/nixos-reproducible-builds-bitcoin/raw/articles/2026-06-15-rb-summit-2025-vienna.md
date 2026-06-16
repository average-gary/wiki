---
title: "Reproducible Builds Summit 2025 — Vienna session notes"
source: https://reproducible-builds.org/events/vienna2025/agenda
sessions:
  - https://reproducible-builds.org/events/vienna2025/agenda/d2-tampering
  - https://reproducible-builds.org/events/vienna2025/agenda/d1-distributedverification
type: article
attendees: [Debian, Guix, Nix/NixOS, F-Droid, in-toto, Apache, Google, Arch, Fedora, Eclipse]
year: 2025-10
ingested: 2026-06-15
tags: [reproducible-builds, summit, xz-postmortem, distributed-verification]
confidence: high
quality: 5
---

# Reproducible Builds Summit 2025 — Vienna

Definitive 2025 community position on the post-xz reproducibility landscape.

## Key claims

### xz post-mortem (consensus)

- **"Reproducible builds can only protect against tampering with the binary
  artifacts, not against tampering with the input."** RB alone would NOT have
  caught CVE-2024-3094 because the malicious code shipped in the official
  tarball.
- The right mental model post-xz: RB + source attestation + diverse build
  paths form a *combined* defense, none sufficient alone.
- Provenance attestation and reproducible builds are **complementary**, not
  alternatives — community pushed back against vendors framing them as
  competitors.

### Distributed verification

- Explicit move toward "trustless binary distribution" with multi-party
  verification at scale.
- Holger Levsen's framing — "if the russians, the chinese and the US agree,
  the build output is probably fine" — generalizes Bitcoin Core's
  `guix.sigs` quorum.
- Source-tarball-reproducibility track (`d3-sourcerepro`) is *new in 2025* and
  directly targets the xz-style input-tampering gap.

## Implication for Bitcoin

Bitcoin Core's `guix.sigs` model (≥16 distinct signers per release per arch,
see [bitcoin-core-guix-sigs](../data/2026-06-15-bitcoin-core-guix-sigs.md)) is
already a reference implementation of the "distributed verification" model
the broader RB community is moving toward. Any Nix-based Bitcoin
reproducibility effort should target compatibility with this regime
(produce hashes verifiable against `guix.sigs`) rather than create a parallel
attestation universe.
