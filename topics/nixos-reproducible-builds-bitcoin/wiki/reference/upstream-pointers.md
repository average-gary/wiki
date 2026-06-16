---
title: "Upstream pointers"
type: reference
created: 2026-06-15
updated: 2026-06-15
---

# Upstream pointers

Canonical entry points outside this wiki.

## Bitcoin Core build infrastructure

- [`bitcoin/bitcoin` `contrib/guix/`](https://github.com/bitcoin/bitcoin/tree/master/contrib/guix) — actual deterministic-build system
- [`bitcoin-core/guix.sigs`](https://github.com/bitcoin-core/guix.sigs) — multi-builder attestations
- [`bitcoin-core/gitian.sigs`](https://github.com/bitcoin-core/gitian.sigs) — archived Gitian-era attestations (2022-11-12)
- [Bitcoin Optech: Reproducible Builds topic](https://bitcoinops.org/en/topics/reproducible-builds/)

## Nix-for-Bitcoin practitioner stacks

- [`fort-nix/nix-bitcoin`](https://github.com/fort-nix/nix-bitcoin) — NixOS modules
- [`bitcoin-dev-tools/bix`](https://github.com/bitcoin-dev-tools/bix) — Nix devShell for Bitcoin Core
- [`0xB10C/bitcoind-gunix`](https://github.com/0xB10C/bitcoind-gunix) — Nix↔Guix hash-match flake
- [`fedimint/fedimint`](https://github.com/fedimint/fedimint) — `flake.nix` (best in-the-wild Bitcoin-adjacent Rust example)

## Reproducibility ecosystem

- [reproducible-builds.org](https://reproducible-builds.org/)
- [Tools page](https://reproducible-builds.org/tools/) — diffoscope, reprotest, strip-nondeterminism, disorderfs
- [CI tests index](https://reproducible-builds.org/citests/) — which distros run RB CI
- [bootstrappable.org](https://bootstrappable.org/) — Mes / stage0 / live-bootstrap

## Nix supply-chain landmarks

- [Nix Manual — Derivation outputs](https://nix.dev/manual/nix/2.29/store/derivation/outputs/)
- [Lila — Nixpkgs reproducibility tracker](https://reproducibility.nixos.social/)
- [NixCon 2025 supply-chain panel](https://talks.nixcon.org/nixcon-2025/talk/XWQC8U/)
- [RB Summit 2025 Vienna agenda](https://reproducible-builds.org/events/vienna2025/agenda/)

## Frameworks

- [SLSA v1.0 levels](https://slsa.dev/spec/v1.0/levels)
- [in-toto attestation specs](https://github.com/in-toto/attestation/tree/main/spec)
- [Sigstore cosign](https://github.com/sigstore/cosign)

## Talks worth watching

- Carl Dong, "Breaking Bitcoin 2020 — Bootstrappable Bitcoin Core Builds"
- Jonas Nick, "Demystifying nix-bitcoin", btcpp 2023:
  <https://nickler.ninja/slides/2023-btcpp.pdf>
- Schwaighofer, "Rebuilding Builders Instead of Trusting Trust", NixCon 2024
