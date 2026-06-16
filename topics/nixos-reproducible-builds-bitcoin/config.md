---
title: Topic Config — nixos-reproducible-builds-bitcoin
type: config
created: 2026-06-15
---

# Config

- **Sensitivity**: public-shareable
- **Confidence policy**: Multi-source corroboration → high. Single primary source → medium. Blog/anecdote → low.
- **Vocabulary**:
  - "Bitcoin Core" — the upstream `bitcoin/bitcoin` repository.
  - "Reproducible build" — bit-for-bit identical binary from clean inputs (per [reproducible-builds.org](https://reproducible-builds.org)).
  - "Deterministic build" — used loosely as a synonym; reproducible-builds.org
    distinguishes them but Bitcoin docs do not.
  - "Gitian" — pre-2021 legacy build system using Ubuntu LXC + apt-mirror.
  - "Guix" — current Bitcoin Core deterministic build toolchain
    (`contrib/guix/`).
  - "Nix" — the package manager / language; **NOT** Bitcoin Core's official
    build system, but used by many Bitcoin downstreams (BTCPayServer/NixBitcoin/
    Fedimint/LDK/sv2-apps).
  - "Flake" — `flake.nix` style Nix project pinning.

## Empty raw/ subdirectory placeholders

Raw subdirectories (`papers/`, `articles/`, `repos/`, `data/`) are seeded empty
on init. Their `_index.md` files appear after the first ingestion.
