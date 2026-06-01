---
title: "Atlas21 — OCEAN announces DATUM (with Luke Dashjr quote on positioning)"
source: "https://atlas21.com/ocean-announces-datum-the-goal-is-to-decentralize-block-construction/"
type: articles
tags: [datum, ocean, luke-dashjr, atlas21, sv2, launch-announcement, prior-art, on-record]
summary: "Atlas21's October 2, 2024 launch coverage of DATUM is the only on-record source where Luke Dashjr (Ocean co-founder) is directly quoted positioning DATUM 'as an alternative to Stratum V2'. The framing is explicit and competitive: 'The launch of DATUM is a pivotal moment for the Bitcoin mining community. We're moving block creation back to the individual miners, just as it was intended.' Mark Artymko (OCEAN president) is quoted announcing the first DATUM-mined block (Sep 30, 2024) by miner 'Just For Krypto'. Jack Dorsey is mentioned as endorser-investor. Article confirms public-beta date of October 18 (matching jonatack's #31002 quote)."
confidence: high
ingested: 2026-06-01
ingested_by: path4
quality_score: 4
canonical_url: "https://atlas21.com/ocean-announces-datum-the-goal-is-to-decentralize-block-construction/"
---

# Atlas21 — DATUM launch announcement with Dashjr framing

The clearest on-record statement of OCEAN-leadership-side positioning of DATUM **as an alternative** to SV2, contemporaneous with the launch.

## Bibliographic

- Date: 2024-10-02
- Outlet: Atlas21 (Italian Bitcoin news outlet, mostly translation/aggregation)
- URL: atlas21.com/ocean-announces-datum-the-goal-is-to-decentralize-block-construction/
- Coverage: announcement of DATUM closed beta + October 18 public beta date

## Direct quotes captured

**Luke Dashjr (Ocean co-founder):**

> "The launch of DATUM is a pivotal moment for the Bitcoin mining community. We're moving block creation back to the individual miners, just as it was intended."

This is the *founder-level* on-record framing. Not a developer technical critique (which is what luke-jr's later #31002 comment is), but a press-friendly quote.

**Mark Artymko (Ocean president, 2024-09-30 announcement):**

> The first block mined with DATUM was successfully created by a miner nicknamed "Just For Krypto."

(paraphrased from announcement; the article wraps this around the closed-beta announcement)

**Article-voice framing:**

> "DATUM, a new open-source mining protocol that promises to return control of block creation to individual miners."

> DATUM is presented as "an **alternative to Stratum V2**."

The phrase "alternative to Stratum V2" appears to be article-voice, but the framing is consistent with what OCEAN has communicated to the trade press (see the Blockspace Media article).

## Other facts captured

- DATUM launched in **closed beta** on/before 2024-09-30.
- **Public beta** scheduled for 2024-10-18 (matches jonatack's quote in bitcoin/bitcoin#31002 — "ETA of Oct 18 or before").
- Jack Dorsey identified as an OCEAN investor and endorser ("though he is not identified as an Ocean team member").
- The first DATUM-mined block was found by miner pseudonym "Just For Krypto".

## What's missing

- No technical comparison with SV2 beyond the framing label.
- No mention of the DATUM Gateway repository, the DATUM Protocol spec, or the gateway's SV1 downstream.
- No mention of `bitcoind` / `getblocktemplate` requirements.
- No mention of TIDES (the payout layer is referenced only as "non-custodial").

## Why this matters for the SV2-downstream-DATUM-proxy

1. **"Alternative to Stratum V2" is the founder-level framing** — DATUM is *positioned against* SV2 from launch. A proxy bridging the two will operate against this positioning. Marketing must either (a) sidestep the comparison, (b) frame the proxy as "operator choice" middleware, or (c) frame the proxy as "complementary, not contradictory" (as Solo Satoshi article did, see path4 sibling).
2. **Luke Dashjr's launch quote is *not* SV2-hostile per se** — it's about block creation moving to miners. SV2's JDP/TDP are arguably the same goal. The competitive framing is article-voice; the founder quote is goal-aligned with SV2.
3. **The Oct 18 public-beta date pins the source-release window** — anyone reasoning about who could have built DATUM tooling before Oct 18 needs to know the source wasn't yet public. This rules out any pre-Oct-18 third-party SV2-DATUM bridge work.

## Cross-references

- `2026-06-01-path4-bitcoin-core-rfc-31002-datum-mining-interface.md` — luke-jr's December 2024 technical comment is consistent with this October positioning.
- `2026-06-01-path4-blockspace-media-datum-vs-sv2.md` — Bitcoin Mechanic's December 2024 "extra layer on SV1" framing is *softer* than this Dashjr-quoted "alternative to SV2."
- `2026-06-01-path4-ocean-docs-sv2-rejection.md` — the docs page formalizes the position.

## Rabbit-hole leads

- Mark Artymko's posts about DATUM — does he ever mention SV2 directly?
- Jack Dorsey's investment thesis — is there a Block Inc. statement about why DATUM (vs. SV2 from Block's own Proto)? Note: Proto Fleet (a Block project, see issue #92) has open SV2 work. So Block invests in *both* OCEAN/DATUM and Proto Fleet/SV2 — interesting hedge.
- Italian / European Bitcoin press — is there more Atlas21 coverage of DATUM?

## Source

- Article fetched 2026-06-01 via WebFetch.
