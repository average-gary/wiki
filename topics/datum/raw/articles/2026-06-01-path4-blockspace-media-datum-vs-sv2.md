---
title: "Blockspace Media — 'OCEAN Pool's DATUM is live, here's how it's different than Stratum V2'"
source: "https://blockspace.media/insight/ocean-pools-datum-is-live-heres-how-its-different-than-stratum-v2/"
type: articles
tags: [datum, ocean, stratum-v2, sv2, bitcoin-mechanic, kristian-csepcsar, braiins, prior-art, framing, on-record]
summary: "December 22, 2024 Blockspace Media piece explicitly comparing DATUM and SV2, with on-the-record quotes from BOTH camps' representatives. The most important on-record OCEAN-side framing of DATUM's relationship to SV2: BitcoinMechanic (OCEAN) calls DATUM 'just an extra layer on top of legacy SV1 to build blocks by miners' — directly contradicting OCEAN's own docs page which calls DATUM 'built from scratch'. Kristian Csepcsar (Braiins) frames SV2 as 'a complete replacement of SV1 with new features'. The article emphasizes both protocols share the goal of decentralizing block construction and reducing OOB-payment opacity but disagree on scope. Critical for thesis-framing because it reveals OCEAN's internal narrative inconsistency."
confidence: high
ingested: 2026-06-01
ingested_by: path4
quality_score: 4
canonical_url: "https://blockspace.media/insight/ocean-pools-datum-is-live-heres-how-its-different-than-stratum-v2/"
---

# Blockspace Media — DATUM vs SV2 (Dec 2024)

The most balanced, on-record technical-trade press comparison of DATUM and Stratum V2 to date. Important for two reasons: (a) it has *direct quotes from both* OCEAN's Bitcoin Mechanic and Braiins' Kristian Csepcsar, and (b) Bitcoin Mechanic's framing here is **structurally inconsistent** with OCEAN's docs-page framing.

## Bibliographic

- Publisher: Blockspace Media (Bitcoin mining trade publication)
- Date: 2024-12-22
- URL: blockspace.media/insight/ocean-pools-datum-is-live-heres-how-its-different-than-stratum-v2/
- Two on-record sources:
  - **BitcoinMechanic** — OCEAN team member, also has 3-star fork of `datum_gateway` (path-4 fork enumeration). Active on X.
  - **Kristian Csepcsar** — Braiins (the SRI's commercial mothership) public spokesperson.

## The two foundational quotes

**OCEAN side (Bitcoin Mechanic):**

> "DATUM is just an extra layer on top of legacy SV1 to build blocks by miners."

**Braiins side (Kristian Csepcsar):**

> "Stratum V2 is a complete replacement of SV1 with new features."

These two statements together are the cleanest one-line summary of the architectural divergence: SV2 replaces SV1 wholesale; DATUM keeps SV1 between miner and gateway and adds the template-construction layer between gateway and pool.

## OCEAN narrative inconsistency

OCEAN's docs page (covered in `2026-06-01-path4-ocean-docs-sv2-rejection.md`) says DATUM was **"built from scratch with decentralized template construction in mind."**

OCEAN's spokesperson here says DATUM is **"just an extra layer on top of legacy SV1."**

These are not the same claim. Reconciling them:

- The *DATUM Protocol* (the encrypted custom wire protocol gateway↔pool) was indeed built from scratch.
- The *DATUM Gateway* (the client miners run) keeps SV1 on the miner-facing side, then runs the new DATUM Protocol upstream.
- So "built from scratch" applies to the upstream half; "extra layer on SV1" applies to the system as a whole including the downstream half.

Both claims are true, but they're rhetorically deployed for different audiences:
- Docs framing emphasizes *novelty* to justify rejecting SV2.
- Trade-press framing emphasizes *low-disruption* to make DATUM seem operator-friendly.

This is important context for any wiki article comparing OCEAN's stated rationale against its actual design.

## Other on-record claims from the article

> "When the TP is Miner-side, it enables the extraction of transactions from the local Bitcoin node."

This applies to both protocols (SV2's TDP and DATUM's GBT-driven gateway both let the miner build the template) and is presented as the shared goal.

> "With DATUM, coinbase payouts go directly to miners, instantaneously and without custodial oversight."

OCEAN's positioning of TIDES + non-custodial coinbase as DATUM's distinguishing feature *over* SV2 (note: SV2 doesn't preclude this, but no SV2 pool currently does it).

## The articulated common ground

Both protocols are framed as solving:
- Block-template centralization (miners not building their own blocks).
- Out-of-band payment opacity (pools getting paid via channels miners can't see).

The disagreement is on *scope* (replace SV1 entirely vs. add a layer above it) and on *trust model* (SV2's encrypted channels with optional decentralized roles vs. DATUM's custodian-elimination via the coinbase output structure itself).

## What the article does NOT do

- Does **not** quote anyone from the SRI core team (only Braiins commercial side).
- Does **not** mention Luke Dashjr.
- Does **not** discuss interoperability — no one is asked "could a DATUM-SV2 proxy exist?"
- Does **not** mention the new Bitcoin Core Mining IPC.
- Does **not** name `getblocktemplate` or BIP 22/23.
- Does **not** mention TIDES (mentions "directly to miners" without naming the payout layer).

So the article is positioning-level, not architectural. Useful for understanding the public framing of the two camps in late 2024; not useful for technical mapping.

## Implications for the SV2-downstream-DATUM-proxy

1. **Bitcoin Mechanic's "extra layer on SV1" framing is the actual architecture** — and it implies that SV2 could *also* be put under DATUM as an alternative downstream layer, since the DATUM Protocol layer is downstream-agnostic. The proxy this wiki targets is therefore the natural completion of OCEAN's own stated architecture, not a violation of it.
2. **The two camps are not in active dialogue** — even in a side-by-side comparison piece, neither party offers operational integration paths. A proxy is not blocked but also not endorsed.
3. **Decentralization framing is shared.** Marketing for an SV2-DATUM proxy can credibly cite both camps' decentralization rhetoric as motivating context.
4. **OCEAN's external framing softens DATUM's claims** — the docs page sounds like DATUM is a wholesale alternative; Bitcoin Mechanic to the press sounds like DATUM is an extension. The latter framing is friendlier to a proxy that swaps the SV1 layer for SV2.

## Cross-references

- [`2026-06-01-path4-ocean-docs-sv2-rejection.md`](2026-06-01-path4-ocean-docs-sv2-rejection.md) — the docs framing this contradicts.
- `2026-05-28-ocean-origins-of-datum.md` — OCEAN's full origin narrative.
- BitcoinMechanic's own fork of datum_gateway (path-4 fork enumeration article) — 3 stars, no apparent SV2 work; consistent with someone whose stated position is "SV1 is fine."

## Rabbit-hole leads

- Find Kristian Csepcsar's full quote in any longer-form podcast or talk in 2024-2025 — does Braiins position SV2 as compatible-with-DATUM, replaced-by-DATUM, or orthogonal?
- Is there a Bitcoin Mechanic blog post or X thread that elaborates the "extra layer on SV1" framing? It would be evidence for the proxy being design-aligned with OCEAN's stated architecture.
- Search Blockspace Media for any 2025 follow-up on DATUM. What's their take 12 months after launch?

## Source

- Article fetched 2026-06-01 via WebFetch.
