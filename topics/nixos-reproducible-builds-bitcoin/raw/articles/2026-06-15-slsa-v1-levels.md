---
title: "SLSA v1.0 — Security Levels (Build L1 / L2 / L3)"
source: https://slsa.dev/spec/v1.0/levels
related: https://slsa.dev/spec/v1.0/requirements
type: spec
maintainer: OpenSSF / SLSA Working Group
year: 2023 (v1.0)
ingested: 2026-06-15
tags: [slsa, attestation, supply-chain, levels, framework]
confidence: high
quality: 5
---

# SLSA v1.0 — Security Levels

The lingua franca regulators and corporate buyers use to discuss build-system
security. Necessary to avoid the common "we use Nix so we're SLSA L3"
overclaim.

## Key claims

- v1.0 collapsed earlier "L4" into Build L3.
- **Build L3** requires *signed provenance from a hosted, isolated build
  platform with secrets unreachable from user build steps*.
- **Hermetic ≠ L3**. SLSA v1.0 explicitly notes hermeticity (no network) is
  *not* an L3 requirement — only future work.
- The **Source track was removed in v1.0** — currently Build-only. Any
  "SLSA-compliant Bitcoin release" claim that hand-waves source integrity is
  imprecise.
- Maps cleanly to **in-toto attestation predicates** (SLSA Provenance v1) —
  the wire format both ecosystems share.

## How Nix maps onto SLSA levels

| Setup | Approx SLSA tier |
|-------|------------------|
| Nix on a developer laptop | L1 (provenance can exist, not platform-attested) |
| Nix on Hydra / Garnix / Cachix-as-builder | L2 (signed provenance, isolated) |
| Above + signing-key isolation + non-falsifiable provenance | L3 |

Nix's hermetic sandbox actually *exceeds* SLSA on the hermeticity axis but
that doesn't grant L3 by itself — the *platform* (build runner) still has to
be hardened.

## Why this matters

When Bitcoin operators or auditors ask "is my Nix-built bitcoind SLSA L3?",
the answer depends on the *build platform*, not on Nix-the-language. Cachix +
Hydra-style hosted builders with key isolation can hit L3; ad-hoc developer
machines cannot.
