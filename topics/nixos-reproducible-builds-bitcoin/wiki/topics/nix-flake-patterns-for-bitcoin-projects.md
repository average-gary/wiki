---
title: "Nix flake patterns for Bitcoin projects"
type: topic
created: 2026-06-15
updated: 2026-06-15
confidence: high
tags: [flake, patterns, fedimint, nix-bitcoin, bix, rust, cross-compile]
sources:
  - "[[../../raw/repos/2026-06-15-fedimint-flake-nix.md|Fedimint flake.nix]]"
  - "[[../../raw/repos/2026-06-15-nix-bitcoin-fort-nix.md|nix-bitcoin]]"
  - "[[../../raw/articles/2026-06-15-b10c-matching-hashes-bitcoind-nix-guix-v31.md|b10c matching-hashes Nix↔Guix]]"
---

# Nix flake patterns for Bitcoin projects

The patterns currently used by Bitcoin OSS projects that have adopted Nix.
Read this together with [[why-bitcoin-core-uses-guix-not-nix.md]] — Nix is
not the upstream Bitcoin Core build, but flakes have caught on for several
distinct use cases.

## Pattern 1 — Deployment flake (nix-bitcoin)

**Use case**: running a node on NixOS.

```nix
# flake.nix
{
  inputs.nix-bitcoin.url = "github:fort-nix/nix-bitcoin/v0.0.137";
  inputs.nixpkgs.follows = "nix-bitcoin/nixpkgs";

  outputs = { self, nixpkgs, nix-bitcoin }: {
    nixosConfigurations.my-node = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nix-bitcoin.nixosModules.default
        ({ ... }: {
          services.bitcoind.enable = true;
          services.clightning.enable = true;
          services.electrs.enable = true;
        })
      ];
    };
  };
}
```

**Reproducibility scope**: input-addressed; `flake.lock` pins everything.
Identical inputs → identical service set across operators.
**Not** bit-for-bit-Guix-matched binaries (nix-bitcoin builds via Nixpkgs,
which uses bootstrap-tools).

**Defense-in-depth shipped by default**: hardened-kernel option, systemd
confinement, DAC, Linux namespaces, dbus firewall, seccomp-bpf.

## Pattern 2 — Dev environment flake (bix)

**Use case**: hacking on Bitcoin Core itself.

```nix
# bix flake (paraphrased)
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs = { self, nixpkgs }: {
    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      packages = with nixpkgs.legacyPackages.x86_64-linux; [
        cmake ninja boost libevent sqlite zeromq
        llvmPackages_20.clang gdb lldb systemtap bpftrace
      ];
    };
  };
}
```

Provides every dependency for compiling Core; you clone Bitcoin Core
separately. Pinned to `nixos-25.05` with `flake.lock`.

**Complementary to Guix, not a replacement**: Guix for release builds, bix
for daily dev.

## Pattern 3 — Cross-compile / multi-target Rust flake (Fedimint)

**Use case**: a Rust workspace targeting native + wasm + mobile from one
flake.

Key tactics from Fedimint's `flake.nix`:

- **Pin Rust toolchain at fixed Fenix commit**:
  `inputs.fenix.url = "github:nix-community/fenix/<commit-hash>"`.
- **Pin LLVM major** to dodge clang miscompilations:
  `llvmPackages_20.clang` (not `llvmPackages.clang`).
- **Custom overlays per dep**: `wasm-bindgen.nix`, `cargo-nextest.nix`,
  `esplora-electrs.nix`, `darwin-compile-fixes.nix`.
- **Three toolchain variants**: `native`, `wasm32-unknown-unknown`, `all`
  (Android + iOS).
- **Avoid dirty-tree impurity**: substitute git-hash placeholders; separate
  clean/dirty handling; deterministic post-build patching with `bbe`.
- **CI parity**: docs explicitly say Nix is "highly recommended" because the
  same flake builds locally and in CI.

Direct template material for any Bitcoin-adjacent Rust workspace —
e.g. mining stacks, custom-protocol implementations, Lightning libs.

## Pattern 4 — Hash-matching reproducibility flake (b10c)

**Use case**: a Nix-built binary that bit-matches the Guix output.

What 0xB10C did to match `bitcoind` v31.0 (Linux x86_64):

1. Pin nixpkgs at a specific commit.
2. Override the Bitcoin Core derivation to match Guix's compiler/linker
   flags exactly.
3. Mirror Guix's `SOURCE_DATE_EPOCH`, `--remap-path-prefix`, and other
   determinism knobs.
4. **Post-build patches** (the unavoidable bit): hardcoded glibc ELF note
   replacements; debug-section CRC32 fixup using `bbe`.

**This is uncomfortable** — community pushback flags the patching as
"matching by patching" rather than true toolchain reproducibility. But the
patches reveal *exactly* what Nix and Guix disagree on: linker metadata
canonicalization and debug CRC32. A future "matched without patches" flake
would close those gaps in the toolchain itself.

**Limitation**: Linux x86_64 only. No Darwin/Windows cross — those would
require nixpkgs `pkgsCross` work that hasn't been done.

## Pattern 5 — SV2 mining-stack reproducible OCI (sv2-apps thesis)

**Use case**: a downstream Stratum V2 application repo (e.g.
`stratum-mining/sv2-apps`) shipping reproducible OCI images for
`pool_sv2` / `jd_client_sv2` / `translator_sv2` modeled on Fedimint.

This pattern is the **MVP subset of the Fedimint pattern**: Crane build →
`dockerTools.buildLayeredImage` → native runners per arch + manifest
stitching. Skips Flakebox, mobile, wasm, replaceGitHash. ~150-250 LOC of
flake + ~50 LOC of GitHub Actions workflow. Feasibility analysis lives
in [[sv2-apps-oci-reproducibility-feasibility.md]]; the verdict is in
[[../../theses/sv2-apps-can-easily-adopt-fedimint-style-oci.md]].

Direct precedents:
- [[../../raw/repos/2026-06-15-rustshop-loglog-minimal-flake.md|rustshop/loglog]] — 103-line single-binary flake
- [[../../raw/repos/2026-06-15-xmtp-libxmtp-musl-docker.md|xmtp/libxmtp]] — multi-arch musl OCI
- [[../../raw/repos/2026-06-15-fedimint-ci-nix-workflow.md|Fedimint ci-nix.yml]] — release-pipeline shape

## What no Bitcoin project has done yet (2026-06)

- **No flake** in the SRI repo (`stratum-mining/stratum`).
- **No flake** in `stratum-mining/sv2-apps` *(candidate for Pattern 5)*.
- **No flake** in `pool2win/p2poolv2`.
- **No flake** in `lightningdevkit/rust-lightning`.
- **No flake** in `selfcustody/krux` (uses Docker-based reproducibility instead).
- **No flake-based build** for Start9, Umbrel, Citadel, Embassy.

This is a real gap — most of the Bitcoin OSS surface lacks even a
dev-environment flake.

## See also

- [[../concepts/derivation-output-modes.md|Derivation output modes]]
- [[../concepts/multi-builder-attestation.md|Multi-builder attestation]]
- [[playbook-nix-attestation-for-bitcoin.md|Playbook: Nix-built attestation for Bitcoin Core]]
- [[sv2-apps-oci-reproducibility-feasibility.md|sv2-apps OCI reproducibility feasibility]] — Pattern 5 in depth
- [[fedimint-reproducible-builds.md|Fedimint reproducible builds]] — Pattern 3+5 source
