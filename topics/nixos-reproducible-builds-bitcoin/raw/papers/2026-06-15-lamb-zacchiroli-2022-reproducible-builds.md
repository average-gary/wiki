---
title: "Reproducible Builds: Increasing the Integrity of Software Supply Chains"
source: https://arxiv.org/abs/2104.06020
doi: 10.1109/MS.2021.3073045
type: paper
authors: Chris Lamb, Stefano Zacchiroli
venue: IEEE Software 39(2), 62–70
year: 2022
ingested: 2026-06-15
tags: [reproducible-builds, supply-chain, definitions, debian]
confidence: high
quality: 5
---

# Reproducible Builds: Increasing the Integrity of Software Supply Chains

The single most-cited modern peer-reviewed reference defining "reproducible
build". Authored by Chris Lamb (Reproducible Builds project lead) and Stefano
Zacchiroli (Debian, Software Heritage).

## Key claims

- **Formal definition**: bit-identical artifacts from same source + build
  environment + instructions, verified by cryptographic hash comparison.
- "Trusting source code is not the same as trusting its executable
  counterparts" — Trusting-Trust framed as ongoing supply-chain risk, not
  historical curiosity.
- Empirical Debian reproducibility >95% — practicality demonstrated.
- Reproducibility is also a QA win: non-determinism is a build-correctness bug.
- Catalog of canonical non-determinism sources: timestamps, build paths,
  locale, parallelism order, ASLR-influenced output.

## Why this matters for Bitcoin

Every claim about "reproducible builds" in the Bitcoin context should anchor
to this paper's definition. Whenever Bitcoin Core release notes or Optech
articles say a build is "reproducible," the formal property they refer to is
the one defined here.
