---
title: "Lightning node reproducibility under Nix"
type: topic
created: 2026-06-15
updated: 2026-06-15
confidence: high
tags: [lightning, lnd, cln, eclair, ldk, nix, reproducibility, gap]
sources:
  - "[[../../raw/repos/2026-06-15-lnd-release-md.md|LND release.md + multi-sig manifest]]"
  - "[[../../raw/repos/2026-06-15-nixpkgs-lnd-trimpath-gap.md|Nixpkgs LND trimpath gap]]"
  - "[[../../raw/articles/2026-06-15-cln-repro-and-pr-8846.md|CLN reproducibility (Docker + flake + PR #8846)]]"
  - "[[../../raw/articles/2026-06-15-eclair-deterministic-core-only.md|Eclair eclair-core-only reproducibility]]"
  - "[[../../raw/articles/2026-06-15-go-reproducible-builds-cox.md|Go reproducible builds (Cox 2023)]]"
---

# Lightning node reproducibility under Nix

The state of LN node reproducible builds, and where Nix specifically fits in
(and doesn't).

## Headline: LN reproducibility erodes monotonically below Bitcoin Core

| Project | Lang | Build determinism | Multi-signer | Multi-builder cohort | Nix flake |
|---------|------|-------------------|--------------|---------------------|-----------|
| Bitcoin Core | C++ | yes (Guix) | 16-23/release | yes (`guix.sigs`) | none upstream |
| **LND** | Go | yes (`-trimpath` + Docker) | 5 maintainers | inline-attached, no separate repo | none |
| **Core Lightning** | C + Rust | partial (Docker; PR #8638 draft) | release captain + co-maintainers | no | yes (path-based, broken paths) |
| **Eclair** | Scala/JVM | only `eclair-core` JAR | 1 (ACINQ) | no | none |
| **LDK Node** | Rust | n/a (library, not binary) | n/a | n/a | none |

Three structural observations:

1. **LND's reproducibility is materially strong** but the cohort is small (5
   maintainers, no separate sigs repo).
2. **Eclair's user-facing JAR has *never* been reproducible** despite a 2020
   PR adding deterministic build support to `eclair-core` only.
3. **LDK ships a library**, not a binary — pushing the reproducibility burden
   to consumer apps (Mutiny, Phoenix, BitKit). No canonical artifact to attest.

## Where Nix fits (today)

### Pattern A — Nixpkgs derivations (drift from upstream)

`nixpkgs#lnd`, `nixpkgs#clightning` produce **deterministic-but-different**
binaries than the upstream signed releases:

- **`nixpkgs#lnd`**: `buildGoModule` with `CGO_ENABLED=0` ✓ but **no
  `-trimpath`**, **no `-X main.Commit=...` ldflags** matching LND's
  `make/release_flags.mk`. Result: cannot match Roasbeef's manifest signature.
  See [[../../raw/repos/2026-06-15-nixpkgs-lnd-trimpath-gap.md|trimpath gap]].
- **`nixpkgs#clightning`**: `fetchurl` of the upstream release zip, then
  autotools build. **Does not include** `cln-grpc` or `clnrest` Rust plugins
  that the upstream flake assembles. Functional drift, not just build drift.

### Pattern B — nix-bitcoin module (pass-through)

nix-bitcoin **does not package LND or CLN itself**. Both inherit from
`pkgsUnstable` via `pkgs/pinned.nix`. Implication: nix-bitcoin's LN supply
chain trust = "nixpkgs maintainers + git rev TOFU + per-tarball SHA256."
*Not* Roasbeef's manifest, *not* Eclair's `SHA256SUMS.asc`.

### Pattern C — CLN's own flake (path-based)

`ElementsProject/lightning/flake.nix` exists but uses `src = ../../.;` (the
active checkout) and `nixos-unstable` channel. Useful for hacking, useless
for hermetic releases.

## Where Nix could fit (low-hanging fruit)

### Quick win 1 — Close the Nixpkgs LND `-trimpath` gap

A nixpkgs PR adding:

```nix
ldflags = [
  "-X main.Commit=v${version}"
  "-X main.CommitHash=${commitHash}"
  # ... matching make/release_flags.mk RELEASE_TAGS
];
buildFlagsArray = [ "-trimpath" "-buildvcs=false" ];
```

would let any NixOS user verify their `lnd` binary against Lightning Labs'
multi-sig manifest. Estimated effort: 1-2 days. **No such PR exists** as of
2026-06.

### Quick win 2 — Hermetic CLN flake (release-tag pinned)

Replace `src = ../../.;` with `fetchFromGitHub` pinned to release tag, and
move from `nixos-unstable` channel to a hash-pinned nixpkgs commit. Then a
`nix build .#clightning` could in principle match the upstream
`cl-repro-noble` Docker output (modulo the Rust toolchain pinning issues
documented in PR #8846).

### Larger play — LN attestation cohort

Generalize Bitcoin Core's `guix.sigs` pattern. A `lightningnetwork/lnd-sigs`
repo with N independent builders would address LND's "5 maintainers, all
inside Lightning Labs" cohort weakness — and Nix could provide a second
toolchain (alongside LND's homegrown Docker-based pipeline) to catch
toolchain-correlated failures.

## Why none of this has happened

(Hypotheses with primary-source backing)

- **Toolchain non-determinism by language is real**: PR #8846's clnrest
  Rust 368-byte drift required FOUR simultaneous fixes
  (`SOURCE_DATE_EPOCH`, `RUSTFLAGS=-C link-arg=-Wl,--build-id=none`, Docker
  `no-cache`, Rust pin to 1.92.0). Bitcoin Core's C++ has fewer such traps.
- **Maintainer culture**: LN devs prioritize feature velocity. Bitcoin Core
  has paid full-time maintainers (Optech, Chaincode). LND's Go reproducibility
  was a side-project of Roasbeef's, not a Carl-Dong-equivalent ~3-year focused
  effort.
- **Plugin ecosystem**: CLN's plugins mean the "binary" is a constellation;
  harder to reduce to one hash.
- **Hot upgrade path**: LN node operators upgrade frequently. Reproducibility
  is slower-moving infrastructure than feature work.
- **Docker as escape hatch**: shipping `lightninglabs/lnd:vX.Y.Z` Docker image
  lets devs ignore toolchain reproducibility because the image *is* the
  artifact (with all the Docker-Hub-typo-squatting risks that implies).
- **No Carl Dong**: no champion has spent 2-3 years porting an LN node to
  Guix or Nix-with-attestation.

## See also

- [[why-bitcoin-core-uses-guix-not-nix.md|Why Bitcoin Core uses Guix, not Nix]]
- [[nix-flake-patterns-for-bitcoin-projects.md|Nix flake patterns for Bitcoin projects]]
- [[playbook-nix-attestation-for-bitcoin.md|Playbook: Nix-built attestation for Bitcoin Core]]
- [[../concepts/multi-builder-attestation.md|Multi-builder attestation]]
