---
title: "Fully Countering Trusting Trust through Diverse Double-Compiling"
source: https://arxiv.org/abs/1004.5534
type: paper
authors: David A. Wheeler
venue: George Mason University (PhD dissertation, 2009; arXiv 2010)
year: 2010
ingested: 2026-06-15
tags: [trusting-trust, ddc, bootstrap, compiler]
confidence: high
quality: 5
---

# Fully Countering Trusting Trust through Diverse Double-Compiling

Provides the **formal proof** that Diverse Double-Compiling (DDC) — recompiling
a compiler with a second, independent compiler and comparing bit-for-bit —
defeats Thompson's trusting-trust attack.

## Key claims

- DDC formally counters the trusting-trust class of attacks.
- Demonstrated empirically against four compilers including GCC and a
  deliberately-corrupted Lisp compiler.
- DDC presupposes deterministic output — links *bootstrappable* and
  *reproducible* properties.
- Directly motivates Guix's bootstrap chain (Guix descends from a tiny seed
  binary precisely so DDC-style verification is feasible end-to-end).

## Why this matters for Bitcoin

Without DDC-style argumentation, "reproducible build" is just a hygiene
practice rather than a security property. Bitcoin Core's choice of Guix (with
its full-source bootstrap chain reaching to a 357-byte hex0 seed, see
[guix-full-source-bootstrap-2023](../articles/2026-06-15-guix-full-source-bootstrap-2023.md))
is the practical realization of Wheeler's theoretical defense. Nix's larger
bootstrap-tools blob is the gap that keeps it from satisfying DDC purists.
