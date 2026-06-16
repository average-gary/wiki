---
title: "Nix OCI tooling — open issues in nix2container and nixpkgs dockerTools (2025-2026)"
type: article
source_url: https://github.com/nlewo/nix2container/issues
ingested: 2026-06-15
confidence: medium
relevance: direct
evidence_strength: primary-source
direction: opposes
tags: [nix2container, dockerTools, nixpkgs, opposes-thesis, multi-arch, cross-compile]
research_session: 2026-06-15-sv2-apps-easy-oci-reproducibility-thesis
---

# Nix OCI tooling — open issues (2025-2026)

Catalog of known limitations in the two tools the thesis depends on:
`nlewo/nix2container` and nixpkgs `dockerTools.buildLayeredImage` /
`streamLayeredImage`. Falsification material for the "easily" qualifier
that has to be weighed against the supporting evidence.

## nix2container

Maintainer: nlewo (single primary).

Recent / relevant issues:

- **#138 "Cannot cross-build images for a foreign architecture"** —
  closed Apr 2025. Cross-compile worked for Linux→Linux but not
  Darwin→Linux historically. Resolution arrived recently; older
  revisions of nix2container don't have it.
- **#173 "buildImage exec format error on darwin"** — opened Jun 2025,
  open. Mac developers can't always test images locally even after
  cross-compile fixes upstream.
- **#86 "Cross-copying still problematic"** — open since Aug 2023.
  Edge cases in symlink/permission preservation when image is built
  cross-arch.
- **PR #153 "PoC: Add cross-compilation support"** — landed in 2024.
  This is a recently-added capability, not a stable cornerstone.

Performance: nix2container claims 4-5× faster rebuilds than
`dockerTools.streamLayeredImage` (~1.8s vs ~7.5s on benchmark). Worth
the trade only if (a) iteration speed dominates or (b) per-layer push
is needed.

## nixpkgs `dockerTools`

Maintainer: nixpkgs `dockerTools` topic team.

Recent / relevant issues:

- **#416467 "Build with dockerTools fails in GitHubRunner"** — `runAsRoot`
  breaks specifically on **aarch64-linux** while passing on x86_64-linux.
  Exactly the GitHub Actions cross-arch matrix sv2-apps would use under
  the native-runners pattern.
- **#257172 "Missing /tmp"** — years stale. Some images need a writable
  `/tmp`; users hit this and have to add `pkgs.coreutils` + manual
  `/tmp` creation.
- **#281672 "Inconsistent interface between buildImage and
  buildLayeredImage/streamLayeredImage"** — open. Migrating between the
  three is non-mechanical.
- **#374290 "Incomplete documentation: dockerTools"** — open, stale.
  Contributors learn by reading nixpkgs source.
- **#175486 "Support nix2container format"** — open since 2022.
  No bridge between the two tooling worlds.

## What this means for sv2-apps

Acknowledging the gaps:

1. **Native arm64 runners (the recommended path)**: works around the
   nix2container cross-compile gap entirely. nixpkgs #416467 is the
   immediate risk — `runAsRoot` issues on `ubuntu-24.04-arm`. **Mitigate**
   by avoiding `runAsRoot` in the OCI config (sv2-apps doesn't need it
   — runtime is `apt install gettext-base` for envsubst, which can be
   replaced with `pkgs.gettext` in `contents = [ ... ]`).
2. **Cross-compile from amd64**: not recommended; all of the above issues
   compound.
3. **Documentation gap (#374290)**: real cost. Adopters spend 2-4× longer
   on first-time setup than the loglog-103-line example suggests.

## Honest "easily" calibration

The supporting case (loglog 103-line flake; Fedimint's working
ci-nix.yml) holds at the **happy-path level**. Adopters who hit any of
the issues above pay a 1-2 week debug tax.

For sv2-apps specifically: the runtime image is *very* simple (Rust
binary + envsubst + glibc), so the surface area where these issues bite
is small. The recommendation stands: native arm64 runner pattern, no
`runAsRoot`, no nix2container.

## See also

- [[../repos/2026-06-15-fedimint-ci-nix-workflow.md]] — working pattern that avoids these
- [[2026-06-15-fedimint-flake-nix-evolution.md]] — Fedimint's accumulated workarounds for upstream issues
- [[2026-06-15-mitchellh-nix-with-dockerfiles.md]] — opinion-grade nuance
