---
title: "FBI UCR time-series — FCSO + Winchester PD (2014, 2019 confirmed; partial 2017-2018)"
publication: FBI UCR — Crime in the United States annual reports (Tables 8, 10)
url: https://ucr.fbi.gov/crime-in-the-u.s/2014/crime-in-the-u.s.-2014/tables/table-8/table-8-state-cuts/virginia.xls/output.xls
url2: https://ucr.fbi.gov/crime-in-the-u.s/2019/crime-in-the-u.s.-2019/tables/table-8/table-8-state-cuts/virginia.xls/output.xls
url3: https://ucr.fbi.gov/crime-in-the-u.s/2019/crime-in-the-u.s.-2019/tables/table-10/table-10-state-cuts/virginia.xls/output.xls
type: data
ingested: 2026-05-26
quality: 4
credibility: high
confidence: medium
tags: [FBI, UCR, SRS, time-series, FCSO, Winchester-PD, Group-A]
---

# FBI UCR Time-Series — FCSO + Winchester PD

Bookend data points (2014 + 2019) extracted from the FBI's *Crime in the United States* annual reports, Tables 8 (cities) and 10 (metropolitan/nonmetropolitan counties), Virginia state cuts.

These are SRS-era counts (pre-NIBRS-only) and represent the FBI's published agency-level numbers. **2020 was the last "Crime in the U.S." annual report; 2021+ data lives only in the CDE / NIBRS Estimation Tool**, which requires an API key.

## Extracted: bookend years

### Winchester Police Department (Table 8 — cities)

| Year | Pop | Violent | Murder | Rape (rev) | Robbery | Agg assault | Property | Burglary | Larceny | MV theft | Arson |
|------|-----|---------|--------|------------|---------|-------------|----------|----------|---------|----------|-------|
| 2014 | 27,481 | 85 | 0 | 33 | 36 | 16* | 1,083 | 113 | 937 | 33 | 2 |
| 2019 | 28,201 | 80 | 1 | 39 | 6 | 34 | 657 | 76 | 559 | 22 | 5 |

*2014 aggravated assault implied (85 - 0 - 33 - 36 = 16); 2014 also has legacy rape definition = 16.

### Frederick County Sheriff's Office (Table 10 — counties)

| Year | Pop | Violent | Murder | Rape (rev) | Robbery | Agg assault | Property | Burglary | Larceny | MV theft | Arson |
|------|-----|---------|--------|------------|---------|-------------|----------|----------|---------|----------|-------|
| 2014 | (not extracted; URL 404 — file naming variant) | | | | | | | | | | |
| 2019 | (pop omitted in cell) | 80 | 0 | 17 | 13 | 50 | 910 | 97 | 748 | 65 | 1 |

The 2019 Table 10 file gave offense counts but the population cell wasn't returned by the parser. The Census ACS 2019 5-year estimate for Frederick County was ~86k — but FBI's Table 10 covers only the **sheriff's reporting area** (excludes Winchester, which is independent). FBI's footnote: *"data shown in this table do not reflect county totals but are the number of offenses reported by the sheriff's office or county police department."*

## What this trend shows (2014 → 2019, Winchester only)

- **Population**: 27,481 → 28,201 (+2.6%)
- **Violent crime**: 85 → 80 (-6%)
- **Robbery dropped sharply**: 36 → 6 (-83%)
- **Aggravated assault doubled**: 16 → 34 (+113%)
- **Rape (revised def.)**: 33 → 39 (+18%); the revised definition was new in 2013 so 2014 may be early-adoption
- **Property crime down 39%**: 1,083 → 657
- **Burglary down 33%**, larceny down 40%, MV theft down 33%
- **Arson up**: 2 → 5 (small numbers, noisy)

For FCSO, the 2014 row was unrecoverable from this WebFetch session (filename variant URL 404'd; the 2019 file decoded). A meaningful 5-year delta cannot be computed without the 2014 baseline.

## Years attempted but extraction failed

| Year | Table 8 (Winchester) | Table 10 (Frederick) | Failure mode |
|------|---------------------|---------------------|--------------|
| 2015 | URL 404 (variant naming) | URL 404 | Wrong filename pattern |
| 2016 | XLS partial — Winchester not located | URL 404 | XLS parsing |
| 2017 | XLS partial — column list only | XLS — corrupted decode | XLS parsing |
| 2018 | XLS — corrupted decode | XLS — corrupted decode | XLS parsing |

Pattern: WebFetch's XLS-to-text conversion is non-deterministic. 2014 and 2019 succeeded; 2016-2018 returned column headers without row values. Files ARE cached locally at `~/.claude/projects/-Users-garykrause-wiki/.../tool-results/webfetch-*.xls` — they could be parsed offline with `xlrd` or LibreOffice if Bash were available.

## URL patterns that work

- 2014 cities: `https://ucr.fbi.gov/crime-in-the-u.s/2014/crime-in-the-u.s.-2014/tables/table-8/table-8-by-state/Table_8_Offenses_Known_to_Law_Enforcement_by_Virginia_by_City_2014.xls` (returned data)
- 2014 counties: same path, `table-10/Table_10_Offenses_Known_to_Law_Enforcement_by_Virginia_by_Metropolitan_and_Nonmetropolitan_Counties_2014.xls` — **404 (verified URL is wrong; check via Wayback or FBI archive listing)**
- 2015 onward (16-19): `https://ucr.fbi.gov/crime-in-the-u.s/{YEAR}/crime-in-the-u.s.-{YEAR}/tables/table-{8,10}/table-{8,10}-state-cuts/virginia.xls/output.xls` — cached as XLS but extraction inconsistent
- 2020: format changed (Crime in U.S. discontinued); data moved to CDE
- 2021+: CDE / NIBRS only — API key required

## API-blocking summary

The FBI Crime Data Explorer JSON API at `api.usa.gov/crime/fbi/cde` and `api.usa.gov/crime/fbi/sapi` requires an `api.data.gov` API key.

Behavior tested:
- No key → 403 Forbidden
- `api_key=DEMO_KEY` → first request returned 400 (good — endpoint exists, params malformed) or 404 (likely DEMO_KEY not whitelisted for FBI sub-API). Subsequent requests → 429 Too Many Requests with `Retry-After: ~27,660` (≈7.7 hours) — DEMO_KEY is heavily throttled.
- Confirmed paths from `crime-data-frontend` GitHub repo (`src/util/api.js`):
  - `${API}/agencies/{ori}` — agency metadata
  - `${API}/summarized/agency/{place}/{pageType}` — offenses, arrests, etc.
  - `${API}/api/nibrs/{pageType}/{type}/{location}/{dimension}` — NIBRS slices
- Base URL: `https://api.usa.gov/crime/fbi/sapi`

To get a real key: register at https://api.data.gov/signup/ — free, ~1,000 requests/hour. The signup page is a JS SPA so WebFetch cannot complete registration; user would need to do it via browser.

## Workable substitute (no API key needed)

VSP's *Crime in Virginia* PDFs already ingested in this wiki (raw/articles/2026-05-26-vsp-crime-in-virginia-annual-reports.md) cover 2022-2024 with agency-level Group A breakdowns. The FBI numbers and VSP numbers should match within reporting-frame nuances.

For 2014-2021 sheriff/PD-level series, the cleanest path is:
1. Get an api.data.gov key (browser, ~5 min)
2. Hit `https://api.usa.gov/crime/fbi/sapi/summarized/agency/VA0340000/offenses?api_key=...`
3. Hit same for `VA1095000`
4. Parse JSON → 10-year time series

OR: Bash access + LibreOffice/`xlrd` to re-extract the cached XLS files in the WebFetch tool-results directory.

## Cached XLS files (locally available)

```
~/.claude/projects/-Users-garykrause-wiki/92d40f4b-073c-433f-b63f-fab912ba08ac/tool-results/
├── webfetch-1779812420721-hi0veu.xls  (2019 Table 8 VA — Winchester)
├── webfetch-1779812433794-7mb374.xls  (2019 Table 10 VA — Frederick)
├── webfetch-1779812513333-c8f3xq.xls  (2018 Table 8 VA)
├── webfetch-1779812513311-r6a6on.xls  (2018 Table 10 VA)
├── webfetch-1779812528948-w3bikm.xls  (2017 Table 8 VA)
├── webfetch-1779812528856-sv4rry.xls  (2017 Table 10 VA)
└── webfetch-1779812556217-km9dkc.xls  (2016 Table 8 VA)
```

These are real .xls binary files that LibreOffice or `xlrd` would read in seconds.

## Cross-check: 2019 Winchester PD vs FCSO violent crime

Identical headline number: **80 violent crimes each in 2019** — but very different mix:
- Winchester PD: 1 murder, 39 rape, 6 robbery, 34 agg-assault (rape-heavy)
- FCSO: 0 murder, 17 rape, 13 robbery, 50 agg-assault (assault-heavy)

Per-capita (Winchester pop 28,201; FCSO sheriff pop est. ~70k):
- Winchester violent: ~284/100k
- FCSO violent: ~114/100k (roughly 2.5× lower)

Property crime per-capita:
- Winchester: ~2,330/100k
- FCSO: ~1,300/100k

Winchester-as-urban-core, FCSO-as-suburban pattern is consistent with the demographics article in this wiki.

## Confidence notes

- **2019 numbers — high confidence**: extracted directly from FBI Excel, two separate prompts, consistent.
- **2014 Winchester — high confidence**: extracted directly.
- **2014 FCSO — not extracted** (URL variant 404).
- **2015-2018 — low confidence** (column headers extracted but row values not legibly returned by WebFetch's XLS parser; raw files cached for re-extraction).

## See also

- [[../articles/2026-05-26-fbi-ucr-fbi-cde|FBI UCR / CDE source article]]
- [[../articles/2026-05-26-vsp-crime-in-virginia-annual-reports|VSP Crime in Virginia (state-level fallback)]]
- [[../articles/2026-05-26-data-quality-caveats|Data quality caveats]]
