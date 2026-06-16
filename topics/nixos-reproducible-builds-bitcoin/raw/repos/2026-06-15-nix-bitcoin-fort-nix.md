---
title: "nix-bitcoin — NixOS modules for Bitcoin nodes"
source: https://github.com/fort-nix/nix-bitcoin
deployment: https://nixbitcoin.org
type: repo
maintainer: fort-nix (Jonas Nick et al.)
year: 2018–2026
ingested: 2026-06-15
tags: [nix-bitcoin, nixos, deployment, lightning, full-node, canonical]
confidence: high
quality: 5
license: MIT
---

# nix-bitcoin

The de-facto canonical "Nix + Bitcoin" project. Provides flake-based NixOS
modules for the full Bitcoin/Lightning service surface.

## Key claims

- **Modules shipped**: `bitcoind`, `clightning` (with `clboss`, `currencyrate`,
  `monitor`, `rebalance`, `zmq`, `trustedcoin` plugins), `lnd` (with Loop /
  Pool), `liquid`, `electrs`, `fulcrum`, `btcpayserver`, `mempool`,
  `joinmarket`, `RTL`, `HWI` (`bitcoin-core-hwi`).
- **Defense-in-depth**: hardened-kernel option, systemd confinement, DAC,
  Linux namespaces, dbus firewall, seccomp-bpf.
- **Governance**: merge commits cryptographically signed; multi-developer
  approval; 2-of-3 multisig vulnerability bounty fund.
- **Activity** (snapshot 2026-05): 606 stars, 138 forks, 137 releases, 2,202
  commits; latest v0.0.137 (May 2026).
- **Reproducibility scope**: standard Nixpkgs guarantee (input-addressed store
  paths) — *not* bit-for-bit Guix-matched binaries. Trust assumption is
  Nixpkgs maintainers + locked inputs.
- Production deployment at nixbitcoin.org runs `bitcoind + clightning +
  electrs + btcpayserver` on Hetzner with ZFS.

## Reference talks

- Jonas Nick, "Demystifying nix-bitcoin", btcpp 2023:
  <https://nickler.ninja/slides/2023-btcpp.pdf>
- NixCon 2024 "Introduction to nix-bitcoin":
  <https://talks.nixcon.org/nixcon-2024/talk/XPXBHT/>

## Why this matters

This is *the* canonical practitioner stack for "I want to run a Bitcoin /
Lightning node on NixOS." It demonstrates Nix's strength as a deployment
substrate but also clarifies what nix-bitcoin does *not* claim: it does not
attempt to bit-match Bitcoin Core's Guix-built upstream binaries.
