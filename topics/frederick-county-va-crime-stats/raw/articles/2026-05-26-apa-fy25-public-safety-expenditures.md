---
title: "APA FY25 Comparative Report — Public Safety expenditures, FrCo + Winchester"
publication: VA Auditor of Public Accounts (APA)
url: https://dlasprodpublic.blob.core.windows.net/apa/093D6F15-1079-4D72-87B5-CBBFEF1FDA47.xlsx
type: article
ingested: 2026-05-26
quality: 5
credibility: high
confidence: high
tags: [APA, FY25, public-safety, expenditures, FCSO, Winchester-PD, NRADC, primary]
---

# APA FY25 Comparative Report — Public Safety Expenditures

Primary source: Virginia Auditor of Public Accounts, *Comparative Report of Local Government Revenues and Expenditures, Year Ended June 30, 2025*. Published 2026.

The APA report is the canonical source for **all** locality public-safety expenditures in Virginia. **Exhibit C3** is the Public Safety breakdown.

Local copy: `raw/data/apa/apa-fy25-comparative-report.xlsx` (1.1 MB, 21 sheets).

## FY25 Public Safety expenditures (Exhibit C3)

| Category | **Frederick County** | **Winchester (city)** |
|---|---|---|
| **Law Enforcement & Traffic Control** | **$21,983,873** | $11,112,890 |
| └ Sheriff (LE memo) | $21,983,873 (= 100% via FCSO) | $0 (city PD does LE) |
| **Fire & Rescue Services** | $28,452,432 | $9,629,731 |
| **Correction & Detention** | $14,049,015 | $11,174,302 |
| └ Sheriff (Corrections memo) | $0 | $0 |
| (Both use NRADC, not own staff) | | |
| **Other Protection** | $2,022,023 | $5,003,519 |
| **TOTAL Public Safety** | **$68,316,047** | **$37,710,226** |

Per-capita (using APA Exhibit H 2024 population estimates: FrCo 98,977; Winchester 29,294):

| | FrCo | Winchester |
|---|---|---|
| Total per capita | **$690** | **$1,287** |
| LE per capita | $222 | $379 |
| Fire/Rescue per capita | $287 | $329 |
| Corrections per capita | $142 | $381 |

**Winchester spends ~1.9x per capita** on Public Safety vs FrCo. Most of the gap is **corrections** ($381 vs $142 per capita) and **LE** ($379 vs $222 per capita) — consistent with Winchester being a denser independent city with its own municipal police department on top of court-services Sheriff staffing.

## FY25 Public Safety — funding sources (FrCo)

| Source | Amount | % of Public Safety expenditures |
|---|---|---|
| **Commonwealth Categorical Aid** | $9,825,844 | **14.4%** |
| Federal Pass-Through | $503,149 | 0.7% |
| Direct Federal Aid | $6,846 | 0.0% |
| Local Charges for Service | $4,939,180 | 7.2% |
| **Local supplement (general fund)** | **~$53M (computed: total − all above)** | **~78%** |

## FY25 Public Safety — funding sources (Winchester)

| Source | Amount | % of Public Safety expenditures |
|---|---|---|
| **Commonwealth Categorical Aid** | $4,104,147 | **10.9%** |
| Federal Pass-Through | $791,852 | 2.1% |
| Direct Federal Aid | $18,804 | 0.0% |
| Local Charges for Service | $3,001,762 | 8.0% |
| **Local supplement (general fund)** | **~$30M (computed: total − all above)** | **~79%** |

## Critical structural confirmations

1. **FrCo Sheriff (LE memo) = $21,983,873** — this is the **full** law-enforcement line for the county. FCSO is the sole LE agency in unincorporated FrCo. (Winchester city LE is $11.1M but $0 of that is Sheriff — Winchester PD handles all city LE.)

2. **Both jurisdictions show $0 in the Sheriff (Corrections memo) line** — confirming the Compensation Board finding that **neither operates an own jail**. All corrections expenditure ($14M FrCo, $11M Winchester) flows to **NRADC (Northwestern Regional Adult Detention Center)** as the regional jail authority.

3. **Public-safety funding mix**:
   - **~78-79% local general fund** — the bulk of FCSO and Winchester PD operations comes from county/city tax revenue.
   - ~10-14% Commonwealth aid (this is roughly the Compensation Board state-funded slice for sheriff salaries, plus other state grants)
   - Federal pass-through is minimal (<1% FrCo, ~2% Winchester)

## Statewide context (FY25)

From the APA "Total Counties" + "Total Cities" rows:

| | Cities total | Counties total | Grand Total |
|---|---|---|---|
| LE + Traffic | $936,646,955 | $1,540,811,957 | $2,606,163,348 |
| Fire & Rescue | $808,915,487 | $1,763,277,683 | $2,594,369,516 |
| Correction & Detention | $430,851,440 | $832,669,881 | $1,264,082,697 |
| Other Protection | $101,499,276 | $411,923,449 | $519,593,287 |
| **TOTAL Public Safety** | **$2,334,915,034** | **$4,679,424,114** | **$7,175,317,134** |

## Cross-reference

This article confirms and extends the Compensation Board findings ([[2026-05-26-fcso-wpd-budgets-staffing|FCSO/WPD staffing & state-funded budget]]):

- **CB FY24 state share for FCSO Sheriff**: $3,452,820 (salary base)
- **APA FY25 total LE/Sheriff for FCSO**: $21,983,873
- Implied **local supplement ratio**: ~6.4x state share for the LE function
- This is the breakdown that "FCSO is 8th worst in state-funded staffing" papers over — FrCo locality supplements substantially.

The APA total ($21.98M for LE+Sheriff) versus the CB-state-funded base ($3.45M) tells the real story: **state funds ~16% of FCSO LE; local taxpayers fund ~84%.**

## Sources

- VA APA, *Comparative Report of Local Government Revenues and Expenditures, FY25*: https://dlasprodpublic.blob.core.windows.net/apa/093D6F15-1079-4D72-87B5-CBBFEF1FDA47.xlsx
- Local copy: `raw/data/apa/apa-fy25-comparative-report.xlsx`
- Exhibit C3 (Public Safety), Exhibit H (population / land area)

## See also

- [[2026-05-26-fcso-wpd-budgets-staffing|FCSO + Winchester Sheriff + NRADC — Comp Board staffing & budget]]
- [[2026-05-26-virginia-sheriff-structural-role|VA sheriff structural role]]
- [[../../wiki/concepts/jurisdictional-map|Jurisdictional map]]
