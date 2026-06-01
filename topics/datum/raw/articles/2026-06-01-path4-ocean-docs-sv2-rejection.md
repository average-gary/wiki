---
title: "OCEAN docs — official SV2 rejection in 'Origins of DATUM' / DATUM intro"
source: "https://ocean.xyz/docs/datum"
type: articles
tags: [datum, ocean, stratum-v2, sv2, official-stance, ocean-docs, rejection-rationale]
summary: "OCEAN's own DATUM documentation page is the only official OCEAN-published statement on SV2. It explicitly states OCEAN considered SV2 and rejected it: 'Initially, we considered Stratum V2 (Sv2), a protocol that promised to address some of these issues' but found 'technical challenges convinced us that a new framework was necessary'. The doc characterizes SV2's decentralization features as 'bolted onto the original centralized design, resulting in inefficiencies' versus DATUM being 'built from scratch with decentralized template construction in mind'. There is no roadmap, no future SV2 compatibility commitment. Page lacks any version history or signature."
confidence: high
ingested: 2026-06-01
ingested_by: path4
quality_score: 5
canonical_url: "https://ocean.xyz/docs/datum"
---

# OCEAN docs — official SV2 rejection

This is the closest thing OCEAN has to an *official, published* technical position on Stratum V2. It lives on `ocean.xyz/docs/datum` (the DATUM intro / "Origins" page). The full origins article was already ingested by the 2026-05-28 baseline pass as `2026-05-28-ocean-origins-of-datum.md`; this article isolates the **SV2-specific paragraphs** for prior-art enumeration.

## The SV2 rejection passage (verbatim, paraphrased per ocean.xyz/docs/datum)

> "Initially, we considered Stratum V2 (Sv2), a protocol that promised to address some of these issues."

After "extended development":

> "...technical challenges convinced us that a new framework was necessary."

The architectural objection:

> DATUM was "built from scratch with decentralized template construction in mind," whereas Stratum V2's decentralized elements are "bolted onto the original centralized design, resulting in inefficiencies."

## Decoding the objection

The "bolted onto the original centralized design" line is the key technical claim. SV2's actual decentralization vector is the Job Declaration Protocol (JDP) plus Template Distribution Protocol (TDP) — these are explicit subprotocols layered on top of the SV2 mining protocol. OCEAN's framing implies:

- The SV2 mining subprotocol's data model assumes the *pool* owns the template (extranonce assignment, channel hierarchy, future-job semantics).
- JDP/TDP optionally let the miner override that ownership, but the mining-channel semantics still reflect the pool-owned-template assumption.
- DATUM by contrast assumes the *miner* owns the template from message zero (the share-submission opcode includes the miner-built coinbase fields directly).

Whether this is fair criticism is debated (path5 and path3 may have evidence either way), but it is OCEAN's stated position.

## What's NOT in the doc

- No specific SV2 versions (1.0.0? 1.0.1? 1.1.0?) are named as having been evaluated.
- No specific JDP/TDP critiques.
- No statement that SV2 *cannot* coexist with DATUM, or that DATUM proxies translating to SV2 are unwelcome.
- No technical roadmap toward future SV2 support.
- No signature / authorship — page is unattributed (compare with the OCEAN blog where Bitcoin Mechanic and Mark Artymko are bylined).

## Other OCEAN-doc pages (no SV2 mentions)

Per the `ocean.xyz/docs` index:

- "DATUM Setup Guide" — operator config, no SV2.
- "Lightning Payouts" — payout layer, no SV2.
- "Core Antispam Node Policy" / "Core Node Policy" / "Data-Free Node Policy" / "OCEAN Node Policy" — node config, no SV2.
- "TIDES Technical Documentation" — payout math, no SV2.
- "The Origins of DATUM" — covered above.
- "Alternate Templates" — template-source config, no SV2.
- "Introduction to the Lightning Network" — general, no SV2.

So **`ocean.xyz/docs/datum` is the single page in OCEAN's documentation that mentions SV2.** Nine other pages don't.

## Implications for the SV2-downstream-DATUM-proxy

1. **OCEAN's stance is "we considered, we declined"** — not "SV2 is forbidden" and not "we're SV2-blocking." A proxy that translates SV2 ↔ DATUM is therefore not violating OCEAN's stated terms, just operating outside what OCEAN endorses.
2. **There is no explicit door open either.** No "we welcome SV2 bridges from third parties" language. Operators of an SV2-proxy in front of DATUM should expect zero OCEAN-side support.
3. **The "bolted on" critique is asymmetric** — even if DATUM is "built from scratch," DATUM itself can be wrapped in an SV2 mining-channel surface. SV2 mining-channel semantics on the downstream side are protocol-agnostic about *how* the upstream is built. So the proxy's translation surface is DATUM's responsibility, not OCEAN's.
4. **OCEAN reserves the right to break wire compatibility** — the canonical README says: "Its specification is evolving, subject to change, and will be published elsewhere." A proxy is shipping against an unstable upstream.

## Cross-references

- [`2026-05-28-ocean-origins-of-datum.md`](2026-05-28-ocean-origins-of-datum.md) — the full Origins page including this passage in context.
- Issue #146 (path1 article) — community-side proposal to add SV2 *to* DATUM, despite this rejection.
- Bitcoin Core RFC #31002 (path4 above) — luke-jr's stance is consistent with this doc.
- Blockspace Media article (path4 sibling) — Bitcoin Mechanic frames DATUM as "an extra layer on top of legacy SV1," which is a *different* and arguably contradictory framing from this doc's "built from scratch."

## Rabbit-hole leads

- The "extended development" phrasing implies OCEAN actually built or prototyped SV2 components before pivoting. Is there a prototype branch in jasonbcoin's or luke-jr's history? Worth searching.
- The phrase "bolted onto the original centralized design" — is this a Jason Hughes line or Luke Dashjr's? Voice-fingerprint suggests Jason Hughes (operational tone). Worth confirming via X/Twitter or podcast appearances.
- Does the doc page have a `last-modified` HTTP header that can be cross-referenced against the DATUM launch date (Sep 30, 2024)?

## Source

- Page fetched 2026-06-01 from `https://ocean.xyz/docs/datum` via WebFetch.
- Companion full-page snapshot: `2026-05-28-ocean-origins-of-datum.md`.
