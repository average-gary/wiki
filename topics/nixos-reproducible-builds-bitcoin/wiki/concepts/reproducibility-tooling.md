---
title: "Reproducibility tooling (diffoscope, reprotest, strip-nondeterminism)"
type: concept
created: 2026-06-15
updated: 2026-06-15
confidence: high
tags: [tools, diffoscope, reprotest, vocabulary]
sources:
  - "[[../../raw/articles/2026-06-15-reproducible-builds-tools.md|Reproducible Builds — Tools]]"
---

# Reproducibility tooling

Canonical vocabulary for "is this build reproducible?" investigations.
Required for any Nix-on-Bitcoin work; you cannot debug a hash mismatch
without these.

## diffoscope

Recursively unpacks archives and renders binary formats human-readable.
First tool invoked when two independent Bitcoin Core builders' outputs
disagree.

```sh
diffoscope expected.tar.gz actual.tar.gz
```

Used by 0xB10C in the [matching-hashes Nix↔Guix work](../../raw/articles/2026-06-15-b10c-matching-hashes-bitcoind-nix-guix-v31.md)
to chase divergences down to ELF notes and debug-section CRC32.

## reprotest

Varies environment axes (timezone, locale, hostname, build path, umask, CPU
count) on the same source to surface latent non-determinism *before*
declaring a Nix derivation reproducible.

```sh
reprotest 'nix build .#bitcoind' result/bin/bitcoind
```

## strip-nondeterminism

Post-process canonicalization (gzip / zip / jar) for upstreams that can't be
patched. Pragmatic stopgap pattern Nix overlays can adopt as a `postBuild`
phase.

## disorderfs

FUSE that randomizes `readdir` order — actively *attacks* one's own build
for directory-order bugs that Nix's sandbox would otherwise mask.

## The Unreproducible Package catalogue

`reproducible-builds.org/docs/issues/` curates failure modes — a checklist
when auditing a Bitcoin-Nix derivation: timestamps, build paths, locale,
parallelism order, ASLR-influenced output.

## Canonical sources of non-determinism

(from [[../../raw/papers/2026-06-15-lamb-zacchiroli-2022-reproducible-builds.md|Lamb & Zacchiroli 2022]])

- File timestamps (use `SOURCE_DATE_EPOCH`)
- Build paths (Nix `/nix/store/{hash}-...` paths leak; Bitcoin Core uses
  `--remap-path-prefix`)
- Locale (`LANG=C.UTF-8`)
- Parallelism order (some compilers; clang LTO is the modern offender)
- ASLR-influenced output (rare but real for some link orders)
