---
title: "Bootstrap chain (Nix bootstrap-tools vs Guix full-source bootstrap)"
type: concept
created: 2026-06-15
updated: 2026-06-15
confidence: high
tags: [bootstrap, trusting-trust, mes, hex0, guix, nix, contrarian]
sources:
  - "[[../../raw/articles/2026-06-15-guix-full-source-bootstrap-2023.md|Full-Source Bootstrap (Guix blog 2023)]]"
  - "[[../../raw/articles/2026-06-15-nixos-discourse-bootstrap-admission.md|NixOS Discourse maintainer admission]]"
  - "[[../../raw/papers/2026-06-15-wheeler-2010-diverse-double-compiling.md|Wheeler 2010 — DDC]]"
---

# Bootstrap chain

A "bootstrap chain" is the sequence of binaries trusted *as a precondition*
for building everything else from source. Smaller chain = smaller
trusting-trust attack surface (Thompson 1984; Wheeler 2010).

## Guix (full-source bootstrap, 2023)

```
357-byte hex0 seed (x86-linux)
  → M2-Planet
    → Mes
      → TinyCC
        → GCC
          → 22,000+ node package graph
```

Hex0 is auditable by hand. The remaining trusted artifact is a 25 MiB
statically-linked Guile build driver — disclosed honestly.

This is the **only production distro** with this property.

## Nix (bootstrap-tools tarball, ongoing)

`/nix/store/...-bootstrap-tools.tar.xz` — **~50–100 MB of opaque binaries
from a previous Nix.** Contains glibc, GCC, bash, coreutils, etc., as
pre-built artifacts. Trusted on download.

NixOS Discourse (maintainer admission): *"Our approach is to download a
binary from Mozilla and then use that to recompile"* (re: Rust). A 2019
maintainer concession that closing this gap *"would still be substantial
changes to Nixpkgs"* — not on the roadmap.

## Why the gap matters

For trusting-trust resistance:

- **Wheeler 2010 (DDC)** requires a deterministic cross-compilation against
  an *independent* compiler. Guix's chain reduces "independent" to
  hex0+Mes+TinyCC, all auditable.
- **Nix's chain** depends on the integrity of the bootstrap-tools tarball.
  If a malicious maintainer of `bootstrap-tools` slipped a Thompson
  compiler into a previous bootstrap-tools build, Nix would not detect it
  on rebuild.

## Why this matters for Bitcoin

Bitcoin Core's choice of Guix over Nix is most directly explained by this
property. Carl Dong's 2019 mailing-list post citing *"Guix's focus on
bootstrappability"* maps onto this exact bootstrap-chain comparison.

A Bitcoin operator who runs a Nix-built `bitcoind` inherits the
bootstrap-tools trust assumption. A Bitcoin operator who runs a
Guix-built `bitcoind` does not.

## Caveats

- The Guix 25 MiB Guile-driver gap is real but small.
- Lix (the Nix fork) is exploring tighter bootstrap; status as of 2025: no
  comparable seed reduction announced.
- "Smaller bootstrap" is not the only security property; Nix has stronger
  hermeticity guarantees in some corners (sandbox-by-default for FODs).

See also:
- [[../topics/why-bitcoin-core-uses-guix-not-nix.md|Why Bitcoin Core uses Guix, not Nix]]
- [[../topics/nix-supply-chain-roadmap.md|Nix supply-chain roadmap (NixCon 2025)]]
