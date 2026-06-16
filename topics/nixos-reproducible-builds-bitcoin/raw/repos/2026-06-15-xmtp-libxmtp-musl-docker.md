---
title: "xmtp/libxmtp nix/musl-docker.nix — multi-arch reproducible OCI for Rust workspace"
type: repo
source_url: https://github.com/xmtp/libxmtp/blob/main/nix/musl-docker.nix
ingested: 2026-06-15
confidence: high
relevance: direct
evidence_strength: case-study
direction: supports
tags: [xmtp, multi-arch, musl, dockerTools, pkgsCross, rust, supports-thesis]
research_session: 2026-06-15-sv2-apps-easy-oci-reproducibility-thesis
---

# xmtp/libxmtp `nix/musl-docker.nix` — multi-arch reproducible OCI

Production XMTP messaging-protocol implementation that ships
`validation-service-image` for **both linux/amd64 and linux/arm64 musl
targets** via `dockerTools.buildLayeredImage` with explicit per-arch
outputs.

## Pattern

Roughly:

```nix
let
  systems = {
    "x86_64-unknown-linux-musl" = "amd64";
    "aarch64-unknown-linux-musl" = "arm64";
  };
  mkImage = rustTriple: ociArch:
    let
      crossPkgs = mkCrossPkgs rustTriple;
      package = crossPkgs.callPackage ./validation-service.nix { };
    in pkgs.dockerTools.buildLayeredImage {
      name = "xmtp/validation-service";
      tag = "${version}-${ociArch}";
      architecture = ociArch;
      contents = [ package pkgs.cacert ];
      config.Cmd = [ "${package}/bin/validation-service" ];
    };
in lib.mapAttrs' (rustTriple: ociArch:
     lib.nameValuePair "validation-service-${ociArch}" (mkImage rustTriple ociArch)
   ) systems;
```

The `architecture = ociArch` field on `dockerTools.buildLayeredImage` sets
the OCI manifest `architecture` correctly so Docker Hub / OCI registries
accept it as a per-arch image suitable for `docker manifest create`-style
stitching.

## Why it matters for sv2-apps

This is the most direct precedent for sv2-apps' multi-arch requirement.
Two options for sv2-apps:

1. **Native runners per arch** (Fedimint pattern,
   [[2026-06-15-fedimint-ci-nix-workflow.md]]) — each runner builds its own
   arch under its own Nix daemon. Simplest. Free with GH-hosted arm64
   runners ([[../articles/2026-06-15-github-arm64-runners-ga.md]]).
2. **Cross-compile from a single runner** (libxmtp pattern, this file) —
   one job builds both arches via `mkCrossPkgs`. Faster CI but inherits
   pkgsCross sharp edges for non-trivial C deps (capnproto here is OK).

Recommendation for sv2-apps: pattern 1 (native runners). Pattern 2 is
viable but the win is small relative to the new failure mode (cross-compile
breaks if any future dep introduces a cgo/C++ component that doesn't have
clean `pkgsCross.<target>.<lib>` mapping).

## Reproducibility properties

- musl-static binaries — no glibc symbol-version drift.
- `pkgs.cacert` for TLS — addresses "but my container needs CA certs"
  objection without breaking determinism.
- Per-arch image hashes are stable across rebuilders sharing the same
  `flake.lock`.
- Manifest stitching is plain `docker manifest create` glue, not part of
  the reproducibility surface (registry digest is fixed by the per-arch
  digests it indexes).

## Caveats

- libxmtp builds against musl, not glibc. sv2-apps' current runtime image
  is `debian:bookworm-slim` (glibc). Switching to musl is a reachable
  improvement (smaller image, fewer ABI surprises) but a separate decision
  from "use Nix."
- The flake input set includes a custom `mkCrossPkgs` helper not visible
  in this file alone — adopters need to copy the helper or use
  `pkgs.pkgsCross.<target>` directly.

## See also

- [[2026-06-15-fedimint-ci-nix-workflow.md]] — alternative (native runners)
- [[2026-06-15-rustshop-loglog-minimal-flake.md]] — single-arch base pattern
