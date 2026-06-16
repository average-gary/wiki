---
title: "Fedimint Nix internals — flake.nix + nix/flakebox.nix + ci-nix.yml"
sources:
  - https://github.com/fedimint/fedimint/blob/master/flake.nix
  - https://github.com/fedimint/fedimint/blob/master/nix/flakebox.nix
  - https://github.com/fedimint/fedimint/blob/master/.github/workflows/ci-nix.yml
  - https://github.com/fedimint/fedimint/blob/master/scripts/release/sign.sh
  - https://github.com/fedimint/fedimint/blob/master/justfile.fedimint.just
  - https://github.com/fedimint/fedimint/blob/master/docs/nix-ci.md
type: repo
maintainer: Fedimint maintainers (Eric Sirion / @elsirion, Dawid Ciężarkiewicz / @dpc, +)
year: 2024-2026
ingested: 2026-06-15
tags: [fedimint, flake, flakebox, crane, fenix, cachix, replaceGitHash, bbe]
confidence: high
quality: 5
---

# Fedimint Nix internals

Deep technical layer that the round-1 Fedimint flake.nix ingest pointed at
but didn't open. Combines the flake, the Flakebox build pipeline, the CI
workflow, and the release-signing script.

## Pinned inputs (`flake.nix`)

| Input | Pin | Notes |
|-------|-----|-------|
| `nixpkgs` | `nixos-25.11` (channel) | flake.lock provides the actual hash |
| `nixpkgs-unstable` | `nixos-unstable` (channel) | same |
| `fenix` | rev `6b5325a017a9a9fe7e6252ccac3680cc7181cd63` (hash-pinned) | "fenix#235" comment |
| `flakebox` | rev `34701639bceb5b12e81e2fff913797c0891c919d` (hash-pinned) | **`dpc/flakebox`** fork, not `rustshop/flakebox` upstream |
| `wild` | `0.9.0` | alt linker via `linker.wild.enable = true` |
| `cargo-deluxe` | rev `3e9bb6051a6461dd841d5e415de9c3f315c3be81` | hash-pinned |
| `bundlers` | rev `b0bc45a7626d94b4b3a17f8cc3c95e288625c8db` | hash-pinned |
| `advisory-db` | `rustsec/advisory-db` | `flake = false`; consumed for `cargo audit` only |

## The `replaceGitHash` / `bbe` pattern

Fedimint solves the "embed git hash in binary without making the build
impure" problem with a two-step:

1. **Build with placeholder** — Rust binaries are compiled with environment
   variable `FEDIMINT_BUILD_FORCE_GIT_HASH = "01234569abcdef7afa1d2683a099c7af48a523c1"`
   (40-char placeholder, identifiable on inspection).
2. **Post-build patch** — separate stdenv derivation runs
   `bbe -e 's/${placeholder}/${gitHash}/'` over every executable in the
   output. Build input: `pkgs.bbe`.

For dirty trees: `${first16OfDirtyRev}00000000${last16OfDirtyRev}` (zeros in
the middle to flag dirty). `dontStrip = !pkgs.stdenv.isDarwin`.

This is the same pattern criticized in the b10c Nix↔Guix Bitcoin Core work
(post-build patching). For Fedimint it's **not** about closing toolchain
divergence — it's purely about embedding identity without breaking
derivation purity.

See dpc's own writeup: <https://dpc.pw/posts/embedding-git-version-hash-in-a-binary-in-a-nix-friendly-way/>.

## Crane three-stage caching

Fedimint's `nix/flakebox.nix` uses Crane for three-stage incremental builds:

1. **`workspaceDeps`** — `cargo check + doc + build --all-targets --locked`
   on a *dummy-source* workspace. Output: `target.tar.zst` (~936 MB
   compressed, ~4.2 GB uncompressed per `docs/nix-ci.md`).
2. **`workspaceBuild`** — same flags, real sources, `cargoArtifacts =
   workspaceDeps`.
3. **`workspaceTest` / `workspaceClippy` / `workspaceTestDoc`** — layer on
   top.

`--locked` is enforced everywhere — `Cargo.lock` is non-negotiable.

## Build outputs

`fedimintd`, `fedimint-cli`, `fedimint-dbtool`, `fedimint-recoverytool`,
`gatewayd`, `gateway-cli`, `fedimint-load-test-tool`,
`fedimint-recurringd[v2]`. Group packages: `client-pkgs`, `gateway-pkgs`,
`fedimint-pkgs`, `devimint`. Plus `wasmBundle` (separate `wasm-pack` pipeline,
`CARGO_PROFILE_RELEASE_OPT_LEVEL = "z"`).

Containers: `pkgs.dockerTools.buildLayeredImage` for `fedimintd` (ports
8173/8174), `fedimint-cli`, `gatewayd`, `gateway-cli`, `fedimint-recurringd`.

Static-link knobs: `ROCKSDB_<arch>_STATIC = "true"`, ditto SQLite/SQLCipher/
Snappy. **`rocksdb_8_11`** pinned (`enableLiburing = false`).

## Cachix configuration

In `flake.nix` `nixConfig`:

```
extra-substituters = [ "https://fedimint.cachix.org" ];
extra-trusted-public-keys = [
  "fedimint.cachix.org-1:FpJJjy1iPVlvyv4OMiN5y9+/arFLPcnZhZVVCHCDYTs="
];
```

CI uses `cachix/cachix-action@v17` with `CACHIX_AUTH_TOKEN` secret — every
CI build pushes to the cache. `continue-on-error: true` so cache outages
don't fail builds.

## CI architecture (`.github/workflows/ci-nix.yml`)

- **Self-hosted Linux runners** (`[self-hosted, linux, x64]`) for most jobs;
  `macos-14` (aarch64) GitHub-hosted for Darwin.
- Hourly cron, twice-daily cron, per-PR runs.
- Build job flow: `nix build .#ci.workspaceBuild` → `Clippy` → `Doc` →
  `TestDoc` → `wasm32-unknown.ci.ciTestAll`.
- **300 MB closure-size guardrail** via `nix path-info -rS --json`.
- Release job: per-bin `nix build .#$bin` → Cachix push of full closure +
  Cachix pin → `nix bundle` (Linux) or `dylibbundler` + ad-hoc
  `codesign --force --sign -` (macOS).
- Per-build perfit telemetry to `https://perfit.dev.fedimint.org`.

## Release signing (`scripts/release/sign.sh`)

Triggered manually by `just sign-release v0.X.Y`:

1. `git+file:${REPO_ROOT}?rev=${rev}` — flake URL pins the build to commit
   hash inside the Nix store path itself (workaround for `nixos/nix#11266`).
2. Per-bin `nix build`; copy `result/bin/*` into
   `releases/bins/${tag}-${system}/nixos/`.
3. On Linux: also `nix bundle --bundler "$repo" "$out"`.
4. Checksum: `find ${prefix} -type f -print0 | LC_ALL=C sort -z | xargs -0 sha256sum > releases/${prefix}.SHA256SUMS`.
5. GPG detached signing: `gpg --sign --detach-sign -a [--local-user $GPG_SIGNING_KEY] --output - ${sha256sum_path} >> ${sha256sum_path}.asc`.

**Per-system SHA256SUMS** — `${tag}-${system}.SHA256SUMS` — so x86_64-linux
and aarch64-darwin produce different files. **No cross-system reproducibility
check.** Single-builder signing, not multi-builder attestation.

Only **@elsirion and @dpc** have crates.io publish permissions
(`just publish-release` runs `cargo workspaces publish --from-git --allow-dirty`).

## What's NOT in the flake

- No `SOURCE_DATE_EPOCH`.
- No SLSA / sigstore / cosign integration.
- No multi-builder attestation cohort (no `fedimint.sigs` repo).
- No documented "rebuild from source and confirm hash matches Cachix" exercise.
- `dpc/flakebox` is a single-maintainer fork (Dawid Ciężarkiewicz) of
  `rustshop/flakebox`, which the upstream README itself describes as "very
  immature."
