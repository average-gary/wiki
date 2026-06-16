---
title: "Nixpkgs LND derivation — the trimpath / ldflags gap"
sources:
  - https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/ln/lnd/package.nix
  - https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/go.section.md
type: repo
maintainer: Nixpkgs maintainers (bleetube, cypherpunk2140, prusnak)
year: 2026 (LND v0.20.1-beta pin)
ingested: 2026-06-15
tags: [lnd, nixpkgs, buildgomodule, vendorhash, trimpath, gap, contrarian]
confidence: high
quality: 4
---

# Nixpkgs LND — the trimpath / ldflags gap

The smoking gun for "why Nix-built LND doesn't hash-match upstream LND."

## The derivation

`pkgs/by-name/ln/lnd/package.nix`:

```nix
buildGoModule rec {
  pname = "lnd";
  version = "0.20.1-beta";

  src = fetchFromGitHub {
    owner = "lightningnetwork";
    repo = "lnd";
    rev = "v${version}";
    hash = "sha256-EHyyUleCKLEAnYNH7+PYwE/uTz445EQmtfosFxf10wU=";
  };

  vendorHash = "sha256-jF/yQE0xH0MFKI7CCGHy/HFzp6tgTM5T/MP2uB62vKk=";

  env.CGO_ENABLED = 0;

  subPackages = [ "cmd/lnd" "cmd/lncli" ];

  # ... no -trimpath, no -ldflags -X main.Commit=..., no buildvcs=false
}
```

## What's right

- `vendorHash` content-addresses the entire vendored Go module tree.
- `env.CGO_ENABLED = 0` — half of Go's reproducibility recipe (per
  [Russ Cox 2023](2026-06-15-go-reproducible-builds-cox.md)).
- `fetchFromGitHub` pinned to `v${version}` git rev with FOD `hash`.

## What's wrong (vs upstream LND release.sh)

| Knob | Upstream LND | Nixpkgs LND | Result |
|------|--------------|-------------|--------|
| `-trimpath` | yes | **NO** | Build path leaks into binary |
| `-ldflags -X main.Commit=...` | yes (release-tag commit) | **NO** | No version stamp |
| `-tags="${buildtags}"` | RELEASE_TAGS from `make/release_flags.mk` | partial / missing | Different feature set |
| `-buildvcs=false` | no (known gap) | inherited Nixpkgs default | Same gap |
| `BUILD_DATE=2020-01-01` | yes | not set | Different mtime in tar |
| `CGO_ENABLED=0` | yes | yes ✓ | OK |

## Implication

A `nix build nixpkgs#lnd` produces a deterministic binary, but **not** the
binary that matches Roasbeef's manifest signature. The Nix path discards
LND's published signing infrastructure entirely.

## What it would take to close the gap

A nixpkgs PR adding:

```nix
ldflags = [
  "-trimpath"  # actually goes in buildFlagsArray for buildGoModule
  "-X main.Commit=v${version}"
  "-X main.CommitHash=${commitHash}"
];
buildFlagsArray = [ "-trimpath" "-buildvcs=false" ];
```

plus matching the `RELEASE_TAGS` from `make/release_flags.mk`. Estimated
effort: 1-2 days for a Go-fluent contributor. **No such PR exists** as of
2026-06.

## Why this matters

This single gap is the most actionable item in the entire wiki. Closing it
would:

- Let a NixOS user verify their `lnd` binary matches Lightning Labs' upstream.
- Provide a path for nix-bitcoin to gain "second toolchain" verification of
  LND releases (similar to what 0xB10C demonstrated for Bitcoin Core).
- Remove the silent-divergence trap where two operators on different distros
  think they're running the same `lnd` and aren't.
