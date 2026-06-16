---
title: "rustshop/loglog flake.nix — minimal Rust binary → OCI image recipe"
type: repo
source_url: https://github.com/rustshop/loglog/blob/master/flake.nix
ingested: 2026-06-15
confidence: high
relevance: direct
evidence_strength: case-study
direction: supports
tags: [crane, dockerTools, rust, minimal, flake, dpc, supports-thesis]
research_session: 2026-06-15-sv2-apps-easy-oci-reproducibility-thesis
---

# rustshop/loglog `flake.nix` — minimal Rust→OCI flake

A 103-line `flake.nix` that builds a Rust binary and packages it as a
reproducible OCI image. Same author (dpc) as Fedimint's Flakebox, so
directly demonstrates that the Fedimint pattern scales DOWN to a tiny
project.

## The OCI block (~10 lines)

```nix
docker = pkgs.dockerTools.buildLayeredImage {
  name = "loglog";
  contents = [ package ];
  config = {
    Cmd = [ "${package}/bin/loglog" ];
    ExposedPorts = { "8080/tcp" = {}; };
  };
};
```

That's it. `name`, `contents`, `Cmd`, optional `ExposedPorts`. The output
is consumed by `nix build .#docker | docker load`.

## Whole flake shape

The 103 lines comprise:

- 4 inputs: `nixpkgs`, `flake-utils`, `crane`, `fenix`
- 1 toolchain definition (`fenix.complete.toolchain`)
- 1 craneLib instance
- `commonArgs` (src, deps, build-time pkgs)
- `cargoArtifacts = craneLib.buildDepsOnly commonArgs` — vendored deps cache
- `package = craneLib.buildPackage (commonArgs // { inherit cargoArtifacts; })`
- `dockerTools.buildLayeredImage` block above
- `devShells.default` for hacking

## Why this is a load-bearing piece of evidence for the thesis

The thesis's "easily" qualifier requires a concrete LOC budget. loglog
gives one:

- 1 Rust binary → 103-line flake
- sv2-apps has 3 binaries → linear extrapolation ≈ 130-160 lines for
  the binaries + container outputs (plus a small `lib.mapAttrs'` to
  generate the matrix).

Plus the ci-nix.yml pattern from
[[2026-06-15-fedimint-ci-nix-workflow.md]] = ~50 lines of GitHub Actions
workflow.

Total budget: **roughly 200 lines** for a flake-driven multi-arch
reproducible OCI release pipeline for sv2-apps.

## Caveats

- loglog is not multi-arch. The arm64 story comes from
  [[2026-06-15-xmtp-libxmtp-musl-docker.md]] (matrix `mkCrossPkgs`) or
  from the native-runners-per-arch pattern in
  [[2026-06-15-fedimint-ci-nix-workflow.md]].
- loglog has no git deps. sv2-apps' `stratum-core { git, branch = "main" }`
  needs `craneLib.cleanCargoSource`-style overlay for Nix's flake.lock to
  pin the git rev properly — adds ~5–10 lines.
- loglog has no `replaceGitHash`-style version embedding. If sv2-apps
  ever adds vergen/git_version macros, that's another ~10 lines (see
  [[../articles/2026-06-15-rust-nix-tooling-stack.md]]).

## See also

- [[2026-06-15-fedimint-nix-flakebox-internals.md]] — the full-fat version
- [[2026-06-15-fedimint-ci-nix-workflow.md]] — release-pipeline counterpart
- [[../articles/2026-06-15-rust-nix-tooling-stack.md]] — Crane / Fenix context
