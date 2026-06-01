---
title: "Mining Pool Template Similarity - OCEAN as Independent Template Builder"
url: https://b10c.me/observations/12-template-similarity/
source_type: independent-research
ingested_by: path5
ingested_on: 2026-06-01
quality: high
relevance: medium
hypotheses_addressed: [5]
---

# Mining Pool Template Similarity - OCEAN as Independent Template Builder

## Provenance
0xB10C, independent Bitcoin researcher. Template-similarity analysis covering
Jun-Sep 2024. Predates 2026 but still the most-cited reference on which pools
share templates.

## Key Findings

- **Template clusters (2024 data):** AntPool / BTC.com / Poolin / SecPool /
  SigmaPool / Braiins / Ultimus all show 98-99% similarity, indicating shared
  template providers or proxy relationships. AntPool-aligned cluster ~37.6%
  network share.
- **Independent template builders:** Foundry (~31% then) and OCEAN. OCEAN
  exposes multiple template policies including a "datafree" option that
  filters out data-carrying transactions.
- **DATUM not in 2024 data** (DATUM launched late 2024). No direct
  measurement of DATUM templates yet at this report.

## Hypothesis Implications

- **H5 (censorship-resistance comparison):** SUPPORTED. OCEAN sits in the
  "independent" cluster alongside Foundry, but with a *different policy
  posture* (datafree, miner-selectable via DATUM). Foundry independence ≠
  censorship-resistant; OCEAN's independence + DATUM's miner-template
  capability is the differentiator. An SV2-front proxy that wraps DATUM
  Gateway *preserves* OCEAN's posture only if it doesn't override Gateway's
  template input.

## Threat-Model Implications
The relevant censorship-resistance comparison is:
- **Foundry / Antpool / MARA:** pool-driven templates, opaque policy.
- **OCEAN (without DATUM):** pool-driven but with selectable policies.
- **OCEAN + DATUM Gateway:** miner-node-driven templates with Knots policy,
  reward attribution via DATUM protocol.
- **OCEAN + DATUM Gateway + SV2 proxy (Path 3 model a):** *proxy*-node-driven
  templates, downstream SV2 miners are SV1-equivalent w.r.t. template choice.
- **OCEAN + DATUM Gateway + SV2 proxy (Path 3 model b):** *downstream-miner*-
  driven templates, but the proxy must marshal those into DATUM Gateway's
  GBT-shaped input, which Gateway does not currently expose.

The proxy preserves DATUM censorship-resistance only in model (a) and only at
the proxy-operator's discretion.

## Ingest Justification
Anchors the censorship-resistance hypothesis with concrete prior measurement
showing OCEAN is the differentiated player. Important for honest assessment
that the SV2 layer doesn't add CR; DATUM does.
