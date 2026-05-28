---
title: "Ark: An Alternative Privacy-preserving Second Layer Solution (Burak Keceli, bitcoin-dev, May 2023)"
author: Burak Keceli (brqgoo)
publication: bitcoin-dev mailing list (post #021694)
url: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021694.html
date: 2023-05-31
type: article
ingested: 2026-05-26
quality: 4
credibility: high
confidence: high
tags: [ark, burak, historical, mailing-list, primary, original-proposal]
---

# Ark Original Proposal — Burak Keceli (May 2023)

The genealogical root for the entire Ark line. Posted to bitcoin-dev May 31, 2023 by Burak Keceli (`brqgoo`). Optech newsletter #253 covered it the same day.

## Original framing

- Coined: **VTXOs**, **ATLCs** (Asymmetric Timelocked Contracts replacing HTLCs), **5-second rounds**, "delayed finality" model.
- **Privacy-first**, not scalability-first — original framing was a coinjoin-style privacy L2. The scalability reframing came later from Second / Ark Labs.
- "Joinpool-style" with a counterparty co-signer + timelock-bounded VTXOs supporting mixing, internal transfers, and Lightning-style payments.
- Notable design constraint flagged: ~6.3M anchor txns/year per counterparty.
- Covenants would help but are not strictly required (versions exist using 2-of-2 signatures from operator+user committees as a covenant substitute — what later became "clArk").

## Repo provenance

- April 4, 2023: Burak (`brqgoo`) creates `ark-network/specs` and `ark-network/tapscripts` GitHub repos — predates the public mailing-list post by ~2 months.
- October 28, 2023: `ark-network/ark` (the original arkd) — first reference server.
- 2024: `ark-network` org renamed to `arkade-os`; project rebrands to "Arkade OS."

## Mining payouts

**Not mentioned in the original proposal.** Original use cases enumerated were: mixing, intra-counterparty transfers, Lightning-style payments. The mining-payout fit is downstream / applied — appears to come from outside the Ark dev community (likely 2025–2026 from the Stratum V2 / DATUM / pool-payout side, specifically vnprc and ErikDeSmedt).

## Why ingestion-worthy

Required citation when distinguishing **Ark v1 (Burak 2023)** from **Second's bark / Ark Labs' arkd** (the two competing implementations). Establishes that mining payouts were not part of the original problem statement.

## See also

- [[../papers/2026-05-26-keer-maffei-ark-formal-arxiv]] — formal model (2026)
- [[2026-05-26-second-tech-ark-intro]] — Second's spec
- [[2026-05-26-ark-labs-tether-funding]] — Arkade-camp funding
