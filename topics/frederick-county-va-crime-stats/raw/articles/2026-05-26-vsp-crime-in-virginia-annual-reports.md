---
title: "Virginia State Police — Crime in Virginia annual reports (2022, 2023, 2024)"
publication: Virginia State Police
url: https://vsp.virginia.gov/sections-units-bureaus/bass/criminal-justice-information-services/uniform-crime-reporting/
url2: https://vsp.virginia.gov/wp-content/uploads/2025/12/Crime-In-Virginia-2024.pdf
url3: https://vsp.virginia.gov/wp-content/uploads/2024/08/CRIME-IN-VIRGINIA-2023.pdf
url4: https://vsp.virginia.gov/wp-content/uploads/2023/06/Crime-In-Virginia-2022.pdf
type: article
ingested: 2026-05-26
quality: 5
credibility: high
confidence: high
tags: [VSP, NIBRS, Crime-in-Virginia, primary-source, annual-report]
---

# VSP — Crime in Virginia (annual reports)

The canonical Virginia statewide crime-stats publication. Authored by VSP's BASS/CJIS unit (Bureau of Administrative and Support Services / Criminal Justice Information Services). Published annually under Code of Virginia §52-26 mandate.

## Editions surfaced

| Year | URL | Published | Notes |
|---|---|---|---|
| 2024 | https://vsp.virginia.gov/wp-content/uploads/2025/12/Crime-In-Virginia-2024.pdf | Dec 18, 2025 | Latest. Data freeze: March 31, 2025. |
| 2023 | https://vsp.virginia.gov/wp-content/uploads/2024/08/CRIME-IN-VIRGINIA-2023.pdf | Aug 19, 2024 | |
| 2022 | https://vsp.virginia.gov/wp-content/uploads/2023/06/Crime-In-Virginia-2022.pdf | Jun 8, 2023 | |

Legislative mirror (RD1009 — 2024 ed.): https://rga.lis.virginia.gov/Published/2025/RD1009

## Statewide highlights — Crime in Virginia 2024

From executive summary (full agency-level FrCo + Winchester rows are inside the >10MB PDF; need chunked retrieval to extract):

- **Group A crimes total**: 400,729
- **Incidents**: 343,896
- **Violent offenses**: 16,853 (**−7.0% YoY**)
- **Violent crime victims**: 19,480 (−6.5% YoY)
- **Total property loss**: $631.5M
- **Drug arrests**: down −7.2% overall, but **+41.7% among age 65+**
- **Hate crime incidents**: 340 total. **Anti-Jewish bias incidents jumped from 33 → 84**.
- **Assaults on officers**: 3,257

## Reporting framework

- Virginia is **fully NIBRS** (incident-based, no longer Summary Reporting System).
- All offenses categorized as **Group A** (more serious, 71 specific offenses) or **Group B** (less serious, 11 offenses with arrest data only).
- Data freeze: March 31 of the following year. Expect minor revisions.
- VSP is the publishing authority; **DCJS** (Department of Criminal Justice Services) does forecasting/research but does NOT publish this report.

## Local agency rows — NOT in the PDF (post-2019 format change)

**CORRECTION (2026-05-26 gap-close round)**: The 2022, 2023, and 2024 *Crime in Virginia* PDFs **do not contain agency-level offense, arrest, or clearance rows for any agency** — including FCSO and Winchester PD. All published statistics are statewide aggregates (or sometimes broken down by offense × age range / race / sex, but never by ORI).

The PDFs are 84-85 pages of:
- Statewide Group A offense breakdowns (location, day-of-week, weapon, demographics)
- Statewide arrest data
- Statewide LEOKA officer-assault aggregates
- Officer-Involved Shooting incident list (names agencies but only for OIS events)
- Full-Time LE Employees totals by **agency type** (county/city/other/college/VSP) — NOT by individual ORI

Page 84 explicitly redirects users to https://va.beyond2020.com/ for agency-level data.

**The "Winchester PD 2023 = 1,907 arrests" figure cited in earlier wiki rounds is NOT from this PDF.** It must come from VSP Beyond 2020 portal or FBI CDE.

## Statewide totals confirmed (2022-2024)

| Metric | 2022 | 2023 | 2024 |
|---|---|---|---|
| Group A crimes | 412,961 | 423,636 | 400,729 |
| Incidents | 355,077 | 363,437 | 343,896 |
| Offenses | 395,864 | 405,672 | — |
| Violent crimes | 20,549 | 20,824 | 16,853 (−7.0% YoY) |
| Property loss | $604.3M | $634.9M | $631.5M |
| Forcible sex offenses | 5,556 | 5,349 | — |
| Officer assaults | 2,903 | 3,243 | 3,257 |
| Hate crime incidents | 182 | 325 | 340 |
| Drug-arrest YoY | −8.8% | +18.0% | −7.2% (overall); +41.7% age 65+ |
| Data freeze | Apr 3, 2023 | Mar 31, 2024 | Mar 31, 2025 |

## Where agency-level data ACTUALLY lives

Three channels — none reachable from this sandbox:

1. **VSP Beyond 2020 portal** (https://va.beyond2020.com/) — heavily JS-driven; deep links don't work; needs headless-browser session for NIBRS Agency Crime Overview HTML/Excel exports for VA0340000 and VA1095000. **Canonical replacement** for the agency tables removed from the PDF.
2. **FBI Crime Data Explorer API** (https://api.usa.gov/crime/fbi/cde/...) — mirrors VSP submissions; requires `api.data.gov` API key.
3. **FOIA / direct request to VSP DART** under Code of Va § 52-26.

## Cross-reference data point (secondary)

Per a Virginia Court Records aggregator citing VSP: **Winchester PD 2023 arrests = 1,907 total** (563 Group A + 1,344 Group B). Confirm against the 2023 PDF when extracted.

## Live data tool

VSP's **Beyond 2020** crime data portal: https://va.beyond2020.com/ — interactive, allows custom agency-level queries with nightly updates. Stats Canada platform; heavily JS-driven (deep links don't work). Use for post-publication / current-year data.

## Why ingest

The canonical primary source for every locality-level crime-stat claim about Virginia. Anything in this wiki that says "FrCo violent crime is X" must trace back to one of these PDFs or to FBI CDE — secondary aggregators (CrimeGrade, NeighborhoodScout, City-Data) all derive from this.

## Open follow-up

- Extract FrCo and Winchester rows from each PDF year (2022/2023/2024). PDFs >10MB; required chunked fetch or local download.
- TLS cert chain on vsp.virginia.gov was problematic in this round — may need `curl -k` or alternate route.

## See also

- [[../../wiki/concepts/nibrs-vs-srs|NIBRS vs SRS]]
- [[../articles/2026-05-26-fbi-ucr-fbi-cde|FBI UCR / Crime Data Explorer]]
- [[../articles/2026-05-26-data-quality-caveats|Data quality caveats]]
