---
title: "BLS OEWS May 2025: wages for butchers and meat cutters (SOC 51-3021), Virginia and the region"
source: "https://api.bls.gov/publicAPI/v1/timeseries/data/ (OEWS series OEU*513021*, OEU*513022*, OEU*513023*)"
type: data
ingested: 2026-10-02
tags: [labor, wages, butchers, meat-cutters, bls-oews, virginia, winchester, staffing-cost]
summary: "May 2025 BLS OEWS estimates pulled from the BLS public API. Butchers and Meat Cutters (51-3021) average $20.03/hr ($41,650/yr) in Virginia, with a median of $19.12, a 10th percentile of $15.04 and a 90th percentile of $26.83, across 2,630 jobs. The national mean is $20.37/hr. BLS does not publish 51-3021 for the Winchester VA-WV MSA (the area itself exists, with 67,740 total jobs). Nearby published areas: Hagerstown-Martinsburg $18.16 mean, Harrisonburg $18.52, Washington DC metro $21.70, Maryland $21.22, West Virginia $15.99. Slaughterers and meat packers (51-3023) in Virginia average $17.58/hr, and meat/poultry/fish cutters and trimmers (51-3022) average $17.05/hr."
authors: [U.S. Bureau of Labor Statistics]
published: 2026
regulatory_model: n/a
geography: virginia
credibility_score: 5
research_round: 3
research_agent: "cutshop-economics"
fetched: 2026-10-02
---

# BLS OEWS May 2025: butcher and meat cutter wages, Virginia region

## Method
The bls.gov HTML pages returned "Access Denied" to curl, and WebFetch only reached index pages. The values below come from the **BLS Public Data API v1** (no key), using OEWS series IDs `OEU` + area type and code + industry `000000` + SOC + datatype. Datatypes: 01 employment, 03 mean hourly, 04 mean annual, 06 10th percentile hourly, 08 median hourly, 10 90th percentile hourly. Every value returned is year **2025**, i.e. the May 2025 OEWS estimates. All figures cover all industries (cross-industry).

## SOC 51-3021 Butchers and Meat Cutters

| Area (code) | Employment | Mean $/hr | Mean $/yr | 10th pct $/hr | Median $/hr | 90th pct $/hr |
|---|---|---|---|---|---|---|
| U.S. | 136,430 | 20.37 | 42,380 | 14.17 | 19.30 | 27.94 |
| Virginia | 2,630 | 20.03 | 41,650 | 15.04 | 19.12 | 26.83 |
| Maryland | 1,500 | 21.22 | 44,150 | 15.00 | 21.22 | 28.38 |
| West Virginia | 600 | 15.99 | 33,250 | 11.17 | 16.14 | 21.42 |
| Washington-Arlington-Alexandria MSA (47900) | 1,610 | 21.70 | 45,130 | 15.00 | 21.23 | 31.14 |
| Hagerstown-Martinsburg MD-WV MSA (25180) | 60 | 18.16 | 37,760 | 13.75 | 18.32 | 22.93 |
| Harrisonburg VA MSA (25500) | "-" (suppressed) | 18.52 | 38,530 | 17.52 | 18.01 | 19.75 |
| **Winchester VA-WV MSA (49020)** | **not published** | – | – | – | – | – |
| Staunton VA MSA (44420) | not published | – | – | – | – | – |
| VA nonmetro area 5100001 | 100 | 17.91 | – | – | 17.56 | – |
| VA nonmetro area 5100002 | 50 | 18.61 | – | – | 18.62 | – |
| VA nonmetro area 5100003 | 120 | 17.20 | – | – | 16.78 | – |
| WV nonmetro area 5400001 | 100 | 14.72 | – | – | 14.26 | – |
| WV nonmetro area 5400002 | 180 | 15.15 | – | – | 14.33 | – |

The Winchester MSA series exists. Its all-occupations employment is 67,740. BLS returned no data for 51-3021, 51-3022 or 51-3023 there, meaning the estimates are suppressed or were not released. The names of the nonmetro area codes were not verified because the BLS area file was blocked. [inferred] The Virginia codes likely correspond to the state's Southwestern, Southside and other nonmetro groupings. Do not cite a specific name without checking it.

## Related occupations (May 2025)

| SOC | Area | Employment | Mean $/hr | Median $/hr |
|---|---|---|---|---|
| 51-3022 Meat, Poultry & Fish Cutters & Trimmers | U.S. | 145,700 | 18.89 | 18.41 |
| 51-3022 | Virginia | 2,740 | 17.05 | 17.39 |
| 51-3023 Slaughterers & Meat Packers | U.S. | 69,950 | 20.08 | 19.29 |
| 51-3023 | Virginia | 1,480 | 17.58 | 18.00 |

## Planning implications [inferred]
- For a Winchester-area mobile kill-and-cut crew, a reasonable wage band is **$18-22/hr base**. That brackets Hagerstown-Martinsburg ($18.16), the Virginia mean ($20.03) and the DC metro ($21.70), which competes for the same labor across the Loudoun and Clarke county line. A skilled lead butcher sits near the 90th percentile ($27-31/hr).
- These are wages only. Loaded labor cost (payroll tax, workers' comp under butchering class codes, which round 2 covered for NMPAN) adds on top.
- 51-3021 is mostly retail (grocery meat counters). Experienced carcass breakers who can work on a mobile floor are scarcer than the occupation count suggests.
