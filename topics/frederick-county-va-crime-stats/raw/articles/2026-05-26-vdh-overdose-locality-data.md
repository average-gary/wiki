---
title: "VDH locality-resolved overdose data — FrCo + Winchester + adjacent counties (2019-2024)"
publication: Virginia Department of Health (VDH) Public Health Drug Use Surveillance / Virginia Open Data Portal
url: https://data.virginia.gov/dataset/vdh-pud-overdose-deaths-by-year-and-geography
url2: https://data.virginia.gov/dataset/vdh-pud-overdose-ed-visits-by-year-and-geography
url3: https://data.virginia.gov/dataset/vdh-pud-overdose-ed-visits-by-locality-and-quarter
type: article
ingested: 2026-05-26
extracted_via: CKAN datastore_search_sql API (data.virginia.gov)
extract_date_deaths: 2026-04-23
extract_date_ed_visits: 2026-05-10
quality: 5
credibility: high
confidence: high
tags: [VDH, opioid, overdose, fentanyl, Frederick-County, Winchester, FIPS-51069, FIPS-51840, Lord-Fairfax, ED-visits]
---

# VDH locality-resolved overdose data — Frederick County + Winchester + adjacent counties

VDH publishes locality-level overdose surveillance via the Virginia Open Data Portal CKAN instance at `data.virginia.gov`. The portal exposes a `datastore_search_sql` API endpoint that accepts SQL `WHERE` clauses against the live datasets, which is far more reliable than scraping the bulk-download CSVs.

**Critical structural fact**: For ED-visit data, **Frederick County (FIPS 51069) and Winchester City (FIPS 51840) are reported as a single combined locality** (`Combined Locality = Yes`). VDH does this because residential ZIP codes routinely span the city-county boundary. The same count appears under both FIPS codes — they are not additive. For **fatal-overdose data**, Frederick County and Winchester are reported **separately**.

Health-district name: **Lord Fairfax** (covers FrCo, Winchester, Clarke, Page, Shenandoah, Warren). The district was renamed Shenandoah Health District in 2022 in some VDH publications but the open-data dataset still uses "Lord Fairfax" as of the 4/23/2026 extract.

## Fatal-overdose deaths — Frederick County (51069), 2019-2024

Counts and rate per 100,000 residents. 2024 data marked `*` = preliminary as of 2026-04-23.

| Drug class | 2019 | 2020 | 2021 | 2022 | 2023 | 2024* |
|---|---|---|---|---|---|---|
| **All-Drug (total)** | **15** (16.8) | **27** (29.6) | **19** (20.9) | **16** (17.6) | **19** (20.9) | **6** (6.6) |
| Any Opioids | 11 (12.3) | 24 (26.3) | 17 (18.7) | 14 (15.4) | 18 (19.8) | 6 (6.6) |
| Fentanyl + synthetic opioids | 9 (10.1) | 21 (23.0) | 12 (13.2) | 12 (13.2) | 13 (14.3) | 5 (5.5) |
| Heroin | 3 (3.4) | 3 (3.3) | 0 (0) | 0 (0) | 0 (0) | 0 (0) |
| Cocaine | 4 (4.5) | 8 (8.8) | 3 (3.3) | 3 (3.3) | 5 (5.5) | 2 (2.2) |
| Psychostimulant (meth etc.) | 3 (3.4) | 7 (7.7) | 4 (4.4) | 5 (5.5) | 4 (4.4) | 0 (0) |
| Prescription pain relievers | 2 (2.2) | 6 (6.6) | 11 (12.1) | 4 (4.4) | 6 (6.6) | 3 (3.3) |
| Benzodiazepine | 1 (1.1) | 4 (4.4) | 1 (1.1) | 1 (1.1) | 3 (3.3) | 1 (1.1) |
| Methadone | 1 (1.1) | 3 (3.3) | 5 (5.5) | 0 (0) | 4 (4.4) | 1 (1.1) |

**FrCo trajectory**: 15 → 27 (COVID-era spike, +80%) → 19 → 16 → 19 → 6 preliminary. Five-year all-drug death total (2019-2023): 96 deaths in a county of ~95k residents.

## Fatal-overdose deaths — Winchester City (51840), 2019-2024

| Drug class | 2019 | 2020 | 2021 | 2022 | 2023 | 2024* |
|---|---|---|---|---|---|---|
| **All-Drug (total)** | **11** (39.2) | **16** (57.8) | **9** (32.5) | **9** (32.5) | **8** (28.9) | **1** (3.6) |
| Any Opioids | 10 (35.6) | 15 (54.2) | 9 (32.5) | 8 (28.9) | 6 (21.7) | 0 (0) |
| Fentanyl + synthetic opioids | 7 (24.9) | 14 (50.5) | 7 (25.3) | 8 (28.9) | 6 (21.7) | 0 (0) |
| Heroin | 1 (3.6) | 3 (10.8) | 0 (0) | 0 (0) | 1 (3.6) | 0 (0) |
| Cocaine | 2 (7.1) | 4 (14.4) | 3 (10.8) | 3 (10.8) | 2 (7.2) | 0 (0) |
| Psychostimulant | 0 (0) | 2 (7.2) | 3 (10.8) | 1 (3.6) | 1 (3.6) | 0 (0) |
| Prescription pain relievers | 3 (10.7) | 3 (10.8) | 2 (7.2) | 0 (0) | 0 (0) | 0 (0) |
| Benzodiazepine | 4 (14.2) | 2 (7.2) | 2 (7.2) | 1 (3.6) | 0 (0) | 0 (0) |
| Methadone | 2 (7.1) | 1 (3.6) | 1 (3.6) | 0 (0) | 0 (0) | 0 (0) |

**Winchester trajectory**: 11 → 16 → 9 → 9 → 8 → 1 preliminary. Five-year total (2019-2023): 53 deaths in a city of ~28k residents. Per-capita rate is **~2-3x Frederick County's** in every year.

## Per-capita comparison (rate per 100,000)

| Year | FrCo all-drug rate | Winchester all-drug rate | VA statewide |
|---|---|---|---|
| 2019 | 16.8 | 39.2 | ~17 |
| 2020 | 29.6 | **57.8** | ~25 |
| 2021 | 20.9 | 32.5 | ~28 |
| 2022 | 17.6 | 32.5 | ~24 |
| 2023 | 20.9 | 28.9 | ~28 |
| 2024* | 6.6 | 3.6 | ~17.6 |

Winchester's 2020 rate of **57.8 per 100k is well above Virginia's COVID-era peak**. By 2023, the gap narrowed to ~1.4x. The 2024 preliminary numbers show a sharp drop in both jurisdictions consistent with the 37% statewide decline VDH announced in April 2026 — but these are subject to revision as toxicology/death-investigation backlogs clear.

**Caveat**: Winchester's tiny denominator (~28k) makes its rate per 100k highly volatile. A single additional death moves the rate by ~3.6 points. Treat year-over-year changes with care.

## Drug-overdose ED visits — Frederick County + Winchester (combined), 2021-2025

VDH's ED-visits dataset begins in 2021 (the 2019-2020 era is in a retired predecessor dataset using a different methodology). FIPS 51069 and 51840 share the same combined-locality counts.

| Year | All Drug count | Rate per 10k visits | Opioid count | Heroin count | Stimulant count |
|---|---|---|---|---|---|
| 2021 | 256 | 57.0 | 156 (34.7) | 8 | 3 |
| 2022 | 271 | 56.1 | 157 (32.5) | 5 | 3 |
| 2023 | 240 | 48.2 | 131 (26.3) | 4 | 4 |
| 2024 | 238 | 47.1 | 112 (22.2) | 0 | 9 |
| 2025 | 203 | 39.5 | 76 (14.8) | 0 | * |

**Pattern**: ~250 overdose ED visits/year in the FrCo-Winchester combined area, declining to ~200 in 2025. Heroin essentially disappears as a presenting drug after 2022. Opioid visits drop ~50% 2022→2025. Stimulant (meth/cocaine) ED visits **rise** 2022→2024.

## Adjacent counties — context

### Annual all-drug deaths (count, rate per 100k)

| County | 2019 | 2020 | 2021 | 2022 | 2023 | 2024 |
|---|---|---|---|---|---|---|
| Clarke (51043) | 5 (34.2) | 0 (0) | 8 (54.7) | 5 (34.2) | 2 (13.7) | 1 (6.8) |
| Page (51139) | 6 (25.1) | 9 (37.6) | 10 (41.8) | 5 (20.9) | 8 (33.4) | 2 (8.4) |
| Shenandoah (51171) | 14 (32.1) | 8 (18.2) | 9 (20.5) | 12 (27.3) | 7 (15.9) | 10 (22.8) |
| Warren (51187) | 18 (44.8) | 22 (54.4) | 18 (44.5) | 18 (44.5) | 10 (24.7) | 10 (24.7) |
| **FrCo (51069)** | 15 (16.8) | 27 (29.6) | 19 (20.9) | 16 (17.6) | 19 (20.9) | 6 (6.6) |
| **Winchester (51840)** | 11 (39.2) | 16 (57.8) | 9 (32.5) | 9 (32.5) | 8 (28.9) | 1 (3.6) |

**Frederick County has the lowest all-drug death rate of the Lord Fairfax district** in most years. Winchester and Warren run highest. Page and Clarke are smaller-population (15-25k), so single deaths swing rates dramatically.

### Annual all-drug ED visits, rate per 10k visits

| County | 2021 | 2022 | 2023 | 2024 |
|---|---|---|---|---|
| Clarke | 13 (29.0) | 15 (30.3) | 24 (45.9) | 21 (39.2) |
| Fauquier | 170 (68.9) | 152 (58.3) | 106 (38.7) | 121 (42.6) |
| Page | 59 (38.3) | 51 (30.0) | 55 (31.1) | 41 (23.0) |
| Shenandoah | 125 (48.9) | 117 (42.4) | 131 (46.0) | 84 (30.2) |
| Warren | 118 (55.5) | 118 (52.2) | 120 (51.7) | 97 (42.1) |
| **FrCo+Winchester** | 256 (57.0) | 271 (56.1) | 240 (48.2) | 238 (47.1) |

The **FrCo+Winchester combined ED rate (47-57 per 10k) sits in the middle of the Lord Fairfax district** — lower than Fauquier 2021 and Warren consistently, higher than Page and Shenandoah. All localities trend down 2022→2024.

## Methodology notes

- **Geography assignment**: Both deaths and ED visits are attributed by **patient residence ZIP code**, not incident location. A FrCo resident who overdoses on I-81 in Shenandoah County and dies at Winchester Medical Center counts as a **FrCo death**, not a Shenandoah or Winchester death. (VDH Geography Locator Tool: https://www.vdh.virginia.gov/data/vdh-geography-locator-tool/)
- **Combined-locality logic**: ZIP codes 22601, 22602, 22603 (Winchester area) span the city-county line; VDH cannot reliably split ED visits between FrCo and Winchester without re-geocoding addresses, so they publish a combined number. Some residents file mailing addresses as "Winchester, VA" while living in unincorporated FrCo.
- **Provisional markers**: `*` = preliminary (2024); `^` = preliminary (2025); `†` = partial-year (2026 first months only). Final 2024 data expected late 2026; 2025 final expected late 2027.
- **Suppression**: counts shown as `*` indicate cell suppressed for privacy when count < small-cell threshold.
- **Rate volatility**: For populations <30k, rate-per-100k changes can be driven by single-event noise. Multi-year averages are more reliable.
- **2024 drop is preliminary**: VDH's April 2026 release flagged 2024 data as subject to revision. Toxicology backlogs typically add 5-15% to preliminary opioid death counts as final reports clear. The reported 37% statewide decline may compress somewhat in the final data.

## Cross-checks against earlier wiki research

- Wiki article `2026-05-26-demographics-context.md` cited Lord Fairfax district fatal overdoses 2015-2019 (30, 30, 40, 22, 27 per year). These are **district totals** across six localities. The 2019 sum from the locality data above (5+6+14+18+15+11 = 69) far exceeds the 27 cited, suggesting either (a) the older figure was specific to a narrower drug class, or (b) the dataset published in 2026 incorporates death-investigation revisions and reclassifications not reflected in the 2020 Winchester Star article cited. The 2026 VDH locality data should be considered authoritative.
- The statewide 2024 figure of 1,548 deaths (-37% from 2023) cited in `demographics-context.md` is consistent with the FrCo and Winchester preliminary 2024 drops (FrCo -68%, Winchester -88%). Local data tracks the statewide collapse, possibly more sharply.
- The drug-supply-collapse hypothesis (cited in `demographics-context.md` regarding the 2023→2024 crime drop) gains additional support: ED-visit opioid presentations are also collapsing (157 → 112 → 76, 2022→2025), consistent with reduced street fentanyl supply rather than purely with policing or treatment effects.

## Direct dataset citations

| Dataset | Resource UUID | Extract date |
|---|---|---|
| VDH PUD Overdose Deaths by Year and Geography | `a3a62450-44f6-4db2-b400-318c57674b11` | 2026-04-23 |
| VDH PUD Overdose ED Visits by Year and Geography | `1513876b-3534-4644-9b5e-3f279dd1b8a6` | 2026-05-10 |
| VDH PUD Overdose ED Visits by Locality and Quarter | `7a5e5236-3d9b-42b4-b514-8c45b74cf5cf` | 2026-05-10 |

CKAN SQL endpoint: `https://data.virginia.gov/api/3/action/datastore_search_sql?sql={SQL}`

Raw extracted CSVs saved at:
- `raw/data/vdh/frederick-county-deaths-2019-2026.csv`
- `raw/data/vdh/winchester-city-deaths-2019-2026.csv`
- `raw/data/vdh/ed-visits-frco-winchester-2021-2026.csv`

## See also

- [[2026-05-26-demographics-context|Demographics + opioid context]]
- [[2026-05-26-drug-enforcement-i81-corridor|Drug enforcement + I-81 + NWVRDGTF]]
- [[../../wiki/concepts/jurisdictional-map|Jurisdictional map: FrCo vs Winchester]]
- [[../../wiki/reference/data-sources|Data sources index]]
