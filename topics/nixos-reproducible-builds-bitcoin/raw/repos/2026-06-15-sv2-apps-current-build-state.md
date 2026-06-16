---
title: "sv2-apps current OCI build state (2026-06-15 snapshot)"
type: repo
source_url: https://github.com/stratum-mining/sv2-apps
ingested: 2026-06-15
confidence: high
relevance: direct
evidence_strength: primary-source
direction: ground-truth
tags: [sv2-apps, stratum-v2, dockerfile, oci, baseline, buildx, qemu]
research_session: 2026-06-15-sv2-apps-easy-oci-reproducibility-thesis
---

# sv2-apps current OCI build state

Snapshot of the build pipeline being assessed by the thesis. The ground
truth that the "could adopt easily" claim has to land on.

## Repo layout (relevant)

```
sv2-apps/
├── docker/Dockerfile
├── docker/docker-compose.yml
├── .github/workflows/
│   ├── docker-release.yaml
│   ├── binary-release.yaml
│   └── ci.yaml
├── pool-apps/{pool,jd-server}/
├── miner-apps/{jd-client,translator}/
├── stratum-apps/         # local SRI workspace shim
├── bitcoin-core-sv2/     # local Bitcoin Core SV2 wrapper crate
├── rust-toolchain.toml
└── RELEASE.md
```

Three release binaries: `pool_sv2`, `jd_client_sv2`, `translator_sv2`.

## Current Dockerfile (paraphrased)

```dockerfile
FROM rust:1.85-slim-bookworm AS builder
RUN apt-get update && apt-get install -y --no-install-recommends \
    capnproto libcapnp-dev curl
WORKDIR /app
ARG APP
COPY <Cargo.tomls and stub src/lib.rs files for each workspace>
RUN cargo fetch --manifest-path=<APP>/Cargo.toml
COPY <full source>
RUN cargo build --release --manifest-path <APP>/Cargo.toml --target-dir ./

FROM debian:bookworm-slim AS runtime
RUN apt-get update && apt-get install -y --no-install-recommends gettext-base
COPY --from=builder /app/release/${APP} /app/${APP}
ENTRYPOINT ["/bin/sh", "-c", "/app/${APP}"]
```

## Reproducibility-relevant facts

- **Base image is mutable**: `rust:1.85-slim-bookworm` and
  `debian:bookworm-slim` are tag-pinned, not digest-pinned. Docker Hub
  resolves them to whatever sha256 is current at build time.
- **`apt-get update` reads rolling Debian repo state** with no
  `snapshot.debian.org`-style epoch pin. Reproducible Builds requires
  pinned package state.
- **`cargo build` runs without `--locked` or `--frozen`** (lines 49–51 of
  `docker/Dockerfile`). Lockfile drift can occur silently.
- **No `SOURCE_DATE_EPOCH`**, no `--remap-path-prefix`, no rustflags pinning.
- **`rust-toolchain.toml` does pin** the Rust channel (good — sv2-apps is
  ahead on this knob versus a vanilla Cargo project).
- The Dockerfile is **single-stage cargo, no Crane / cargo-chef-style
  layer caching for deps separately from sources** — every source change
  busts the dep cache, leading to long cold builds.

## CI / release workflow

`docker-release.yaml`:

```yaml
strategy:
  matrix:
    app: [pool_sv2, jd_client_sv2, translator_sv2]
runs-on: ubuntu-latest
steps:
  - uses: docker/setup-qemu-action@v3
  - uses: docker/setup-buildx-action@v3
  - uses: docker/build-push-action@v6
    with:
      context: .
      file: docker/Dockerfile
      build-args: APP=${{ matrix.app }}
      platforms: linux/amd64,linux/arm64
      tags: stratumv2/${{ matrix.app }}:${{ github.ref_name }}
```

- **Multi-arch via QEMU** on a single amd64 runner — emulation, not native
  arm64. Reproducibility under QEMU is theoretically OK but harder to verify
  because the rebuilder needs the same QEMU version.
- **Buildx, not Nix.** The image is whatever Buildx produces on that runner
  at that moment.

## Dependency model — the inconvenient bit

`stratum-apps/Cargo.toml`:

```toml
stratum-core = { git = "https://github.com/stratum-mining/stratum", branch = "main" }
```

A **moving git branch**, not a tag or pinned rev. Recent commits show
constant churn:

- `b06201f3` — chore(deps): update stratum-core to `083b217`
- `9e89c21a` — chore(deps): update stratum-core to `a15c224`
- prior weeks include bumps to `127e654`, `f465e0a`, etc.

There's an automated `stratum-core-sync` workflow (`repository_dispatch`
from upstream) that auto-bumps the lockfile. **Each bump invalidates any
Nix-side `cargoHash`/`vendorHash`/`cargoLock.outputHashes`** — so Nix
adoption requires either (a) freezing stratum-core to tags (changes the
upstream contract), or (b) extending the auto-sync workflow to recompute
Nix dep hashes.

There's an inline comment elsewhere in the workspace: *"MUST be changed
before stratum-apps is published to crates.io"* — confirming the
maintainers already see the `branch = "main"` dep as a ship-blocker.

## C-shim surface (much smaller than the thesis assumed)

Audit of `pool-apps/Cargo.lock` finds **zero** of: `openssl-sys`, `ring`,
`libssh2`, `native-tls`, `webpki`, `aws-lc-rs`. The non-Rust surface is
basically:

- `capnpc` build.rs invokes `capnproto` (translatable directly to
  `pkgs.capnproto`).
- Pure-Rust crypto via `secp256k1` + `miniscript` (clean).

This is materially cleaner than e.g. LND (Go + cgo + `libltcd`) or
Bitcoin Core (C++ + libsecp256k1 + boost + sqlite + zmq).

## Implication for the thesis

sv2-apps' build surface is *favorable* for Nix adoption:

- Smaller workspace than Fedimint (3 binaries vs 7+).
- Cleaner C-shim surface (no openssl, no ring).
- Existing `rust-toolchain.toml` pin.
- Public repo → free GH-hosted arm64 runners available
  ([[../articles/2026-06-15-github-arm64-runners-ga.md]]).

The *unfavorable* bit is the `stratum-core branch=main` dep model. That's
the single largest moderating cost the thesis has to grapple with, and it's
already on the maintainers' "to fix" list.

## See also

- [[2026-06-15-fedimint-ci-nix-workflow.md|Fedimint ci-nix.yml]] — the pattern to copy
- [[../articles/2026-06-15-mitchellh-nix-with-dockerfiles.md|Mitchell Hashimoto: Nix with Dockerfiles]]
- [[2026-06-15-rustshop-loglog-minimal-flake.md|loglog minimal Rust+OCI flake]]
