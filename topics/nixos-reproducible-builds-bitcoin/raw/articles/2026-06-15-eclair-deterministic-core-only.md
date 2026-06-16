---
title: "Eclair reproducibility — eclair-core deterministic since 2020, but the user-facing JAR still isn't"
sources:
  - https://github.com/ACINQ/eclair/blob/master/BUILD.md
  - https://github.com/ACINQ/eclair/pull/1295
  - https://github.com/ACINQ/eclair/releases
type: article
maintainer: ACINQ
year: 2020-2026
ingested: 2026-06-15
tags: [eclair, acinq, scala, jvm, maven, single-signer]
confidence: high
quality: 4
---

# Eclair reproducibility

The weakest LN reproducibility story in the major-implementations group.

## What Eclair claims (BUILD.md)

> *"The archives are built deterministically so it's possible to reproduce
> the build and verify its equality byte-by-byte. To build the exact same
> artifacts that we release, you must use the build environment (OS, JDK...)
> that we specify in our release notes."*

Pinned environment:
- Ubuntu 24.04.1
- Adoptium OpenJDK 21.0.6
- `./mvnw clean install -DskipTests` (Maven wrapper, not sbt)
- Dependency checksum pinning via `.mvn/checksums/checksums-central.sha256`

Caveat from BUILD.md: *"dependencies are verified only if they are actually
used in the build phase that is running"* — partial coverage hazard.

## The PR #1295 reality (2020, merged)

PR #1295 added deterministic build support, but with structural limits:

- **Only `eclair-core` is reproducible.** The end-user `node` and `node-gui`
  JARs remain non-deterministic due to Maven capsule plugin quirks. Five
  years later this hasn't been fixed.
- OS-locked (Ubuntu only); does not cross OSes due to system-dependent line
  endings.
- JDK-locked (specific 11.0.x patch versions historically; 21.0.6 today).
- Initial attempt with `reproducible-build-maven-plugin` was abandoned —
  ecosystem immaturity signal.

## Trust model

- `SHA256SUMS.asc` shipped with each release.
- **Single signer**: ACINQ key id `E04E48E72C205463` (current);
  `7A73FE77DE2C4027` (legacy, key rotation event).
- No multi-builder cohort. No `eclair-sigs` repo.

## Implication for Nix

There is no Eclair Nix flake. Nixpkgs has no `eclair` derivation. Operators
either:

1. Run the upstream JAR via system JDK (no Nix involvement).
2. Run the upstream Docker image (no Nix involvement).

A Nix-built Eclair would inherit the JVM/Maven non-determinism issues — and
since the upstream `node`/`node-gui` JARs aren't even reproducible to *each
other* across rebuilds, there's no upstream hash to match.

## Reproducibility-claim ranking among LN nodes

| Project | Build determinism | Multi-signer | Multi-builder cohort |
|---------|-------------------|--------------|---------------------|
| Bitcoin Core | yes (Guix) | 16-23/release | yes (`guix.sigs`) |
| LND | yes (`-trimpath`) | 5 maintainers | no (no separate sigs repo) |
| Core Lightning | partial (Docker; PR #8638 still draft) | "release captain" + co-maintainers | no |
| Eclair | only `eclair-core` JAR | 1 (ACINQ) | no |
| LDK Node | n/a (library, not binary) | n/a | n/a |

Reproducibility erodes monotonically as you move down the stack.
