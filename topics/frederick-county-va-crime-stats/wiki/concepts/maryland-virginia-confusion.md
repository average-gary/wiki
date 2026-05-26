---
title: Maryland-Virginia "Frederick County" Confusion
type: concept
created: 2026-05-26
confidence: high
tags: [data-trap, Frederick-County-MD, disambiguation]
---

# Maryland-Virginia "Frederick County" Confusion

A persistent data trap. Search engines, news aggregators, and even some statistical sources conflate **Frederick County, Virginia** (~96k pop, county seat Winchester) with **Frederick County, Maryland** (~290k pop, county seat Frederick). Many high-traffic news stories filed under "Frederick County" without state qualification are MD, not VA.

## What gets confused

- 287(g) immigration enforcement — Frederick County MD has the oldest 287(g) program (since 2008); FrCo VA's status is unclear. **Do not import MD-specific Jessica Fitzwater / 1,800 detainers data into FrCo VA articles.**
- Drug overdose statistics — Frederick County MD has its own overdose dashboard with very different (much higher) absolute numbers
- Crime statistics — Frederick MD is much bigger; raw counts will look very different
- Sheriff's office — MD has Sheriff Chuck Jenkins; VA has Sheriff Lenny Millholland
- I-routes — MD is I-70/I-270/I-95; VA is I-81/I-66

## Disambiguators to require

When ingesting any "Frederick County" source for this wiki, require at least one of:

1. **"Virginia" or "VA"** in the body
2. Co-occurrence with **Winchester** (FrCo VA's county seat)
3. Co-occurrence with: **Stephens City, Middletown, Lord Fairfax Health District, Northwest Health District, Shenandoah Health District, Northwest Virginia Regional Drug & Gang Task Force, NWVRDGTF, 26th Judicial Circuit**
4. **I-81 corridor** (NOT I-70/I-270/I-95 which are MD)
5. **Sheriff Lenny Millholland** (NOT Sheriff Chuck Jenkins)
6. ORI VA0340000 (FCSO) or VA1095000 (Winchester PD)

## Documented confusions encountered during research

- "Frederick County overdose 39 deaths July 2023-June 2024" — MD source (Frederick News-Post). Do NOT import as VA data.
- "Frederick County 287(g) since 2008, 1,800 detainers" — MD (Sheriff Jenkins). Do NOT import as VA data.
- WTOP "Frederick County" tag — primarily Maryland (DC media market).
- Generic search results for "Frederick County crime rate" without state — overwhelmingly MD due to higher news volume.

## Wiki posture

Every ingested source about "Frederick County" must be tagged as either `frederick-va` or `frederick-md`. Anything failing the disambiguator test gets rejected or flagged for manual review.

## See also

- [[jurisdictional-map|Jurisdictional map]]
- [[../../raw/articles/2026-05-26-data-quality-caveats|Data quality caveats]]
