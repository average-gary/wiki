---
title: "The Purely Functional Software Deployment Model (PhD thesis)"
source: https://edolstra.github.io/pubs/phd-thesis.pdf
type: paper
authors: Eelco Dolstra
venue: Utrecht University (PhD dissertation)
year: 2006
ingested: 2026-06-15
tags: [nix, deployment, derivation, content-addressed, foundational]
confidence: high
quality: 5
---

# The Purely Functional Software Deployment Model

Foundational thesis introducing the Nix store, hashed-input store paths, and
the derivation graph as a content-addressed deployment model.

## Key claims

- Builds are pure functions of source + dependencies; side-effects confined to
  `/nix/store`.
- Correctness properties for atomic upgrades, rollbacks, and per-user profiles.
- Build-input hash prevents the dependency-hell and reproducibility problems of
  FHS distros.
- Establishes the theoretical basis later inherited by Guix (which Bitcoin
  Core uses for its release reproducibility pipeline).

## Why this matters for Bitcoin

This is the *primary academic source* for everything Nix and the academic root
of modern reproducible-builds-via-functional-package-management. The Guix
toolchain Bitcoin Core uses for releases (`contrib/guix/`) descends directly
from this model — Guix replaced the Nix DSL with Scheme but preserved the
content-addressed store, derivation graph, and purity constraints.
