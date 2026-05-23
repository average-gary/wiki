---
title: "Iroh Issue #2951 — Blob Downloads Freeze Regression"
source_url: https://github.com/n0-computer/iroh/issues/2951
type: issue
date: 2024-2025 (across iroh 0.27 → 0.31)
org: n0-computer
credibility: medium
quality: 3
relevance: indirect
tags: [iroh, regression, stability, contrarian, churn]
ingested: 2026-05-20
---

# Iroh Issue #2951 — silent transfer regression across multiple releases

Real-world example of API/transport stability risk pre-1.0.

## What happened

> "this PR caused about **1/16 of our blob downloads to freeze & fail, reliably**"

- ~6.25% silent transfer failure introduced by an internal change.
- Spanned at least three releases: 0.27 → 0.28 → 0.29.
- First attempted fix (#2876) did not resolve it.
- Final fix landed in 0.31.
- Diagnosis required multi-gigabyte trace logs.

## Implications for SV2

- For a transport carrying **mining shares**, 6% silent loss = 6% lost revenue.
  Catastrophic.
- Mitigation: pin to a known-good iroh version and gate iroh transport behind
  an opt-in feature flag for at least the first few releases. Don't make it
  default until 1.0.x has shipped a few patch versions.
- Observability: tcpdump on TCP gives byte-level visibility. iroh's QUIC stack
  is encrypted end-to-end and fragmented across streams — debugging a stuck
  connection requires SSLKEYLOGFILE-equivalent (qlog), which is a heavier
  ops setup.
- Regression risk decreases substantially after 1.0 (May 2026). Plan adoption
  for after at least 1.0.x has accumulated 3-6 months of patch releases.
