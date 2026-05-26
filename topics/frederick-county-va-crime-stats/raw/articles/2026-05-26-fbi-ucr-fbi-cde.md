---
title: "FBI UCR / Crime Data Explorer — agency profiles for FrCo + Winchester"
publication: FBI CJIS / Crime Data Explorer
url: https://cde.ucr.cjis.gov/LATEST/webapp/#/pages/le/agency/VA0340000/explore
url2: https://cde.ucr.cjis.gov/LATEST/webapp/#/pages/le/agency/VA1095000/explore
type: article
ingested: 2026-05-26
quality: 4
credibility: high
confidence: medium
tags: [FBI, UCR, NIBRS, CDE, ORI, FCSO, Winchester-PD]
---

# FBI Crime Data Explorer — FrCo + Winchester agency profiles

The federal canonical source. CDE is FBI CJIS's public-facing UCR/NIBRS query tool.

## ORI codes (originating agency identifiers)

| Agency | ORI |
|---|---|
| **Frederick County Sheriff's Office (FCSO)** | **VA0340000** |
| **Winchester Police Department** | **VA1095000** |
| Stephens City PD | (TBD; smaller agencies may use VA0340x suffix) |
| Virginia State Police | VA0290000 |

## Direct CDE agency URLs

- FCSO: https://cde.ucr.cjis.gov/LATEST/webapp/#/pages/le/agency/VA0340000/explore
- Winchester PD: https://cde.ucr.cjis.gov/LATEST/webapp/#/pages/le/agency/VA1095000/explore

## Programmatic access

Static URLs render only "Loading..." (CDE is a JS SPA). Use the JSON API instead:

- `https://api.usa.gov/crime/fbi/cde/agency/byori/VA0340000` — FCSO
- `https://api.usa.gov/crime/fbi/cde/agency/byori/VA1095000` — Winchester PD
- API docs: https://crime-data-explorer.fr.cloud.gov/pages/docApi

## What FBI publishes per agency

- Annual offense counts (Group A NIBRS offenses)
- Trends 5 / 10 years
- Clearance rates
- Hate crime
- Arrests by age/sex/race
- LE staffing (sworn / civilian) where reported

## Caveats specific to FBI data

- **NIBRS transition (2021)** — the SRS Hierarchy Rule was abolished. Pre-2021 vs post-2021 totals are NOT apples-to-apples even for fully-compliant agencies. NIBRS counts every offense per incident; SRS counted only the most serious.
- **Coverage gap**: Only ~83% of US agencies submitted data in 2022. Some agencies had multi-year gaps during NIBRS transition.
- **Reporting status**: confirm FCSO and Winchester PD reported every year 2018-2024 (not yet verified in this wiki).

## Why ingest

Every secondary crime-stat aggregator (CrimeGrade, NeighborhoodScout, City-Data, AreaVibes) derives from this dataset. CDE is the federal source-of-truth; VSP's *Crime in Virginia* is the state source-of-truth — they should match within reporting-frame nuances.

## See also

- [[2026-05-26-vsp-crime-in-virginia-annual-reports|VSP Crime in Virginia]]
- [[2026-05-26-data-quality-caveats|Data quality caveats]]
