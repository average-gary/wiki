---
title: "Fedimint .github/workflows/ci-nix.yml — flake-driven OCI release pipeline"
type: repo
source_url: https://github.com/fedimint/fedimint/blob/master/.github/workflows/ci-nix.yml
ingested: 2026-06-15
confidence: high
relevance: direct
evidence_strength: primary-source
direction: supports-with-nuance
tags: [fedimint, ci, github-actions, dockerTools, oci, multi-arch, nix-flake, supports-thesis]
research_session: 2026-06-15-sv2-apps-easy-oci-reproducibility-thesis
---

# Fedimint `ci-nix.yml` — flake-driven OCI release pipeline

The CI workflow that produces and pushes the Fedimint OCI images on Docker
Hub. Closes a critical question for the thesis "sv2-apps could easily adopt
reproducible builds for OCI containers like Fedimint": **are Fedimint's
Docker Hub images actually produced by the Nix flake, or by a separate
Buildx pipeline?** Answer: by the flake.

## Build → push pattern

The pipeline is morally:

```yaml
- run: nix build -L .#container.${{ matrix.image }}
- run: docker load < ./result
- run: docker tag <local> ${{ env.REGISTRY }}/fedimint/${{ matrix.image }}:${{ tag }}
- run: docker push ${{ env.REGISTRY }}/fedimint/${{ matrix.image }}:${{ tag }}
```

The image that lands on Docker Hub is **byte-identical** to the tarball
emitted by `nix build .#container.<name>` on any machine with the same
flake-locked inputs. No buildx, no Dockerfile, no apt-get-driven base image
state.

## Multi-arch via native runners (NOT cross-compile)

Fedimint runs the workflow on **both `runs-on: ubuntu-latest`** (amd64) **and
self-hosted `[self-hosted, linux, arm64]`** runners. After both per-arch
images are pushed, a final job stitches them with:

```bash
docker manifest create fedimint/<image>:<tag> \
  fedimint/<image>:<tag>-amd64 \
  fedimint/<image>:<tag>-arm64
docker manifest push fedimint/<image>:<tag>
```

This sidesteps the "Nix cross-compile rust + capnproto + ring on arm64 from
amd64" problem entirely. Each arch builds natively under its own Nix daemon.

**Implication for sv2-apps**: replicate the pattern with GitHub-hosted
Linux arm64 runners (free for public repos since 2025-08; see
[[../articles/2026-06-15-github-arm64-runners-ga.md]]). No self-hosted
infra required.

## What the flake's `container.*` output actually does

`packages.${system}.container.<name>` is wired in `nix/flakebox.nix` to
`pkgs.dockerTools.buildLayeredImage { name; contents; config; }` — the
binary derivation flows in via `craneLib.buildPackageGroup` ⊃
`replaceGitHash` ⊃ `pickBinary`. See
[[2026-06-15-fedimint-nix-flakebox-internals.md]] for the inside.

Container images shipped this way:
- `fedimintd`
- `fedimint-cli`
- `gatewayd`
- `gateway-cli`
- `fedimint-recurringd` (and `fedimint-recurringdv2`)
- `fedimint-devtools`

## Honest limitations

- **Cachix is the trust root for binaries**: the flake outputs are
  bit-deterministic, but most operators consume the prebuilt artifacts via
  `cachix.org/fedimint`, which is a TOFU single-key cache. Reproducibility
  ≠ verified reproducibility. See
  [[../articles/2026-06-15-fedimint-issue-4305-and-pr-4339.md]].
- **No `SHA256SUMS.asc` for the published images**: Docker Hub digest
  pinning is the only integrity surface for image consumers; no signed
  release manifest mapping `<tag>:<arch> → sha256:<digest>` is published.
- **No SLSA provenance / cosign attestation**: the workflow does not run
  `cosign attest` or emit SLSA v1.0 provenance; verification is by
  rebuilding from the same flake commit, not by attestation transport.

## Why this dissolves the central thesis-opposing argument

Before this source: a plausible falsifier was "Fedimint's *binaries* are
reproducible but the *Docker Hub images* are baked by Buildx, so adopting
the flake doesn't actually buy sv2-apps reproducible OCI images."

After this source: false. The OCI image hash on Docker Hub corresponds to a
`dockerTools.buildLayeredImage` output. sv2-apps adopting the same pattern
would yield reproducible Docker Hub images, modulo the same Cachix/TOFU
caveat Fedimint also has.

## See also

- [[2026-06-15-fedimint-nix-flakebox-internals.md|Fedimint Flakebox internals]]
- [[2026-06-15-fedimint-flake-nix.md|Fedimint flake.nix top-level]]
- [[../articles/2026-06-15-github-arm64-runners-ga.md|GitHub free arm64 runners]]
- [[../articles/2026-06-15-fedimint-flake-nix-evolution.md|Flake evolution timeline]]
