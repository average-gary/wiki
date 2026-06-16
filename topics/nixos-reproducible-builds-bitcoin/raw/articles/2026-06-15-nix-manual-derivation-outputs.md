---
title: "Nix Reference Manual — Derivation Outputs (input-addressed, fixed-output, content-addressed)"
source: https://nix.dev/manual/nix/2.29/store/derivation/outputs/
deeper: https://releases.nixos.org/nix/nix-2.29.0/manual/store/derivation/outputs/content-address.html
type: spec
maintainer: NixOS Foundation (official Nix manual, v2.29)
year: 2026
ingested: 2026-06-15
tags: [nix, derivation, fixed-output, content-addressed, vocabulary]
confidence: high
quality: 5
---

# Nix Manual — Derivation Outputs

Authoritative taxonomy of three Nix derivation output models. Required
vocabulary anchor for everything else in this wiki.

## Key claims

- **Input-addressed**: store path = hash of inputs. Pure (all inputs hashed
  upfront), but cannot pre-fetch any external content.
- **Fixed-output (FOD)**: store path declared in advance via `outputHash`.
  Allows network access in the build sandbox — the only mechanism for
  legitimate `fetchurl`/`fetchTarball`/`fetchgit` ops. **The escape hatch
  through which any source-fetching step (e.g. fetching the Bitcoin Core
  tarball) enters an otherwise-sealed sandbox.**
- **Content-addressed (CA)**: store path = hash of post-build *content*.
  Currently experimental (`ca-derivations` flag). Enables early-cutoff
  optimization (skip rebuilds when inputs change but output content doesn't)
  and store-deduplication.

## Why this matters

Every reproducibility question in Nix ultimately routes through which of these
three modes a derivation uses. FODs are *both* the source of impurity (network
fetch) and the mechanism by which impurity is *captured* (`outputHash` pins
the result). Misuse of FODs (e.g. `fetchgit` without commit pinning) is one
of the main IFD-adjacent sources of irreproducibility — see contrarian sources
on this topic.
