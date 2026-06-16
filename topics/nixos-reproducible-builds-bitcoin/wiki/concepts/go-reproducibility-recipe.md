---
title: "Go reproducibility recipe (CGO_ENABLED=0 + -trimpath)"
type: concept
created: 2026-06-15
updated: 2026-06-15
confidence: high
tags: [go, lnd, trimpath, cgo, sumdb, recipe]
sources:
  - "[[../../raw/articles/2026-06-15-go-reproducible-builds-cox.md|Cox 2023 / Valsorda 2022 / Ayer 2025]]"
---

# Go reproducibility recipe

Two-flag recipe for byte-identical Go binaries (per Cox 2023):

```sh
CGO_ENABLED=0 go build -trimpath
```

## What each flag does

- **`-trimpath`** — strips the local source directory (`/home/alice/lnd`) from
  the binary's debug info and panic traces.
- **`CGO_ENABLED=0`** — removes the host C toolchain, dynamic linker
  (`/lib64/ld-linux-x86-64.so.2` vs musl), and system libraries from the
  input set.

## Toolchain pivot date

**Go 1.21.0 (August 2023)** is the first Go toolchain that is itself
perfectly reproducible. Earlier toolchains required significant effort.

## Dependency layer

`go.mod` + `go.sum` + the **Checksum Database (sumdb)** make Go's transitive
dependency graph content-addressed by default — no separate lockfile needed.
Minimal version selection means transitive deps are pinned to the dep's own
`go.mod`, not floated.

This gives Nix's `buildGoModule` a tractable hashing surface: `vendorHash`
content-addresses the entire vendored tree, computed deterministically from
`go.sum`.

## Caveats (Ayer 2025)

- macOS toolchains carry non-reproducible Google signatures (must strip).
- `GOARM` env drift broke Go 1.21.0 silently (released with `GOARM=7` instead
  of `GOARM=6`).
- `go.sum` doesn't cover original source tarballs.

## Why this matters for LN

**LND should be MORE reproducible than Bitcoin Core** because Go is
structurally easier than C++. That Nix-built LND doesn't hash-match upstream
is a derivation gap (`nixpkgs#lnd` omits `-trimpath` + ldflags), not a
toolchain limitation. See
[[../topics/lightning-node-reproducibility-under-nix.md|Lightning node reproducibility under Nix]].

## See also

- [[reproducibility-tooling.md|Reproducibility tooling]]
- [[derivation-output-modes.md|Derivation output modes]] — `vendorHash` is a FOD
