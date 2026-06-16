---
title: "The Full-Source Bootstrap: Building from Source All the Way Down"
source: https://guix.gnu.org/en/blog/2023/the-full-source-bootstrap-building-from-source-all-the-way-down/
type: article
authors: Janneke Nieuwenhuizen, Ludovic Courtès
venue: GNU Guix official blog
year: 2023
ingested: 2026-06-15
tags: [guix, bootstrap, mes, hex0, trusting-trust, why-not-nix]
confidence: high
quality: 5
---

# The Full-Source Bootstrap

Primary-source documentation of Guix's full-source bootstrap chain — the
load-bearing argument for "why Guix, not Nix" in Bitcoin Core today.

## Key claims

- Guix achieved a **357-byte hex0 seed** for x86-linux. Full bootstrap graph
  spans 22,000+ nodes from that seed.
- Chain: hex0 → M2-Planet → Mes → TinyCC → GCC, now mainline in Guix.
- Explicit citation of **Carl Dong's 2020 "Breaking Bitcoin" talk**: "the holy
  grail for bootstrappability will be connecting `hex0` to `mes`" — which
  this milestone delivers.
- Dramatic reduction from prior ~250+ MiB opaque bootstrap binaries.
- Acknowledged remaining gap: 25 MiB statically-linked Guile build driver
  still trusted (honest limitation, not propaganda).
- Funded by NLnet.

## Implication for Nix

Nix's bootstrap still relies on a much larger pre-built `bootstrap-tools`
tarball (~50–100 MB of opaque binaries from a previous Nix). This is the
single biggest reason Bitcoin Core picked Guix over Nix — see
[NixOS Discourse maintainer admission](2026-06-15-nixos-discourse-bootstrap-admission.md).

## Why this matters

The wiki cannot honestly compare Nix and Guix as Bitcoin-build substrates
without engaging with this property. It's the closest thing the open-source
world has to a defense against
[Wheeler's trusting-trust theorem](../papers/2026-06-15-wheeler-2010-diverse-double-compiling.md),
and Guix has it; Nix does not.
