---
title: "Thesis: A Nix-built attestation can join bitcoin-core/guix.sigs as toolchain-diversity insurance"
type: thesis
status: candidate
created: 2026-06-15
updated: 2026-06-15
verdict: pending
confidence: pending
core_claim: "A Nix-built `bitcoind` binary can be made bit-for-bit identical to the Guix release output for at least one mainline architecture, and a corresponding GPG-signed attestation should be accepted into `bitcoin-core/guix.sigs` as a toolchain-diversity check."
key_variables: [nix-toolchain-alignment, post-build-patching, cross-compile-feasibility, guix-sigs-policy-acceptance, bootstrap-tools-trust]
falsification: "Bitcoin Core maintainers explicitly reject Nix attestations because the bootstrap-tools dependency duplicates risk rather than diversifying it; OR the post-build patching required to match remains structural and cannot be upstreamed to nixpkgs."
---

# Thesis: A Nix-built attestation can join `guix.sigs`

## Core claim

A Nix-built `bitcoind` binary can be made bit-for-bit identical to the Guix
release output for at least Linux x86_64 (already demonstrated by 0xB10C in
2026), and a corresponding GPG-signed attestation should be accepted into
`bitcoin-core/guix.sigs` as a toolchain-diversity insurance against bugs or
backdoors confined to the Guix toolchain.

## Key variables

- **Nix toolchain alignment** — Can flake-pinned compilers match Guix's exact
  flag set?
- **Post-build patching** — Is the b10c-style ELF-note + debug-CRC32 fixup
  load-bearing or accidental?
- **Cross-compile feasibility** — Can `pkgsCross` reach Windows / macOS /
  ARM / RISC-V parity with Guix?
- **`guix.sigs` policy acceptance** — Will Bitcoin Core maintainers accept a
  signature from a non-Guix builder into the same repo?
- **bootstrap-tools trust** — Does sharing nixpkgs' bootstrap-tools across
  many Nix attesters duplicate risk rather than diversifying it?

## Testable prediction

If accepted: at least one Bitcoin Core release in the next 2-3 years should
have ≥1 attestation in `guix.sigs/<release>/` produced via Nix, with a
public flake reproducing the hash.

## Falsification criteria

- Bitcoin Core maintainers explicitly reject Nix attestations on the
  bootstrap-tools-correlated-risk argument.
- 0xB10C-style hash matches require permanent post-build patches that cannot
  be upstreamed into nixpkgs (i.e. they're papering over real toolchain
  divergences).
- Cross-compile to Windows/macOS proves infeasible without separate SDK
  distribution that breaks Nix purity.

## Status

Candidate. Promote to investigation via `/wiki:research --mode thesis` if a
follow-up wants to render a verdict.

## See also

- [[../wiki/topics/playbook-nix-attestation-for-bitcoin.md]]
- [[../wiki/topics/why-bitcoin-core-uses-guix-not-nix.md]]
- [[../wiki/concepts/multi-builder-attestation.md]]
