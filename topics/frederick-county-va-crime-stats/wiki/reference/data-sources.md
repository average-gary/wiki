---
title: Data Sources — primary vs secondary
type: reference
created: 2026-05-26
---

# Data Sources

Tiered by authority. Use primary sources when extractable; secondary aggregators as cross-checks only.

## Tier 1 — Primary

### Federal

- **FBI Crime Data Explorer (CDE)** — https://cde.ucr.cjis.gov/
  - FCSO ORI: VA0340000
  - Winchester PD ORI: VA1095000
  - JSON API: `https://api.usa.gov/crime/fbi/cde/agency/byori/VA0340000`

- **BJS National Crime Victimization Survey** — https://bjs.ojp.gov/data-collection/ncvs

- **U.S. Census** — https://www.census.gov/quickfacts/fact/table/frederickcountyvirginia,winchestercityvirginia/PST045224

### State (Virginia)

- **VSP Crime in Virginia** annual reports — https://vsp.virginia.gov/sections-units-bureaus/bass/criminal-justice-information-services/uniform-crime-reporting/
  - 2024 PDF: https://vsp.virginia.gov/wp-content/uploads/2025/12/Crime-In-Virginia-2024.pdf
  - 2023 PDF: https://vsp.virginia.gov/wp-content/uploads/2024/08/CRIME-IN-VIRGINIA-2023.pdf
  - 2022 PDF: https://vsp.virginia.gov/wp-content/uploads/2023/06/Crime-In-Virginia-2022.pdf
  - Legislative mirror: https://rga.lis.virginia.gov/Published/2025/RD1009

- **VSP Beyond 2020** interactive tool — https://va.beyond2020.com/

- **Virginia Department of Health (VDH) drug overdose data** — https://www.vdh.virginia.gov/drug-overdose-data/

- **Virginia Open Data Portal** — https://data.virginia.gov/ (and the Winchester mirror at https://opendata.winchesterva.gov/)
  - Key datasets: VDH PUD Overdose Deaths by Year and Geography; VDH PUD Overdose ED Visits by Locality and Quarter
  - **CKAN SQL endpoint** (preferred extraction method, bypasses CSV-truncation issues): `https://data.virginia.gov/api/3/action/datastore_search_sql?sql={URL-encoded SQL}`
  - Deaths resource UUID: `a3a62450-44f6-4db2-b400-318c57674b11`
  - ED visits annual UUID: `1513876b-3534-4644-9b5e-3f279dd1b8a6`
  - ED visits quarterly UUID: `7a5e5236-3d9b-42b4-b514-8c45b74cf5cf`
  - Note: For ED visits, FIPS 51069 and 51840 are reported as a single combined locality (residential ZIPs span the city-county line); for deaths, they are reported separately

### Local agencies (BLOCKED IN THIS ROUND — fcva.us / winchesterva.gov 403'd)

- **Frederick County Sheriff's Office** — https://www.fcva.us/departments/sheriff-s-office
- **Winchester PD** — https://winchesterva.gov/police
- **Stephens City PD** (chief: William "Bill" Copp)
- **County and city budget docs** — fcva.us/government/budget-and-finance / winchesterva.gov/finance/budget

### Court

- **26th Judicial Circuit Clerk** — https://winfredclerk.com/
- **VA Supreme Court Office of the Executive Secretary, Specialty Dockets** — https://www.vacourts.gov/courtadmin/aoc/djs/programs/sds/home.html

### Federal-court level

- **U.S. Attorney's Office, Western District of Virginia** — https://www.justice.gov/usao-wdva/pr (BLOCKED — 403)
  - FrCo cases route through the WDVA Harrisonburg division

## Tier 2 — Secondary (aggregators)

All derive from FBI UCR/NIBRS via different normalizations. Use as **cross-checks** only.

- **CrimeGrade** — crimegrade.org/violent-crime-{frederick-county-va,winchester-va}/
- **NeighborhoodScout** — neighborhoodscout.com/va/winchester/crime
- **City-Data** — city-data.com/county/Frederick_County-VA.html / city-data.com/crime/crime-Winchester-Virginia.html
- **AreaVibes** — areavibes.com/winchester-va/crime/
- **Data USA** — datausa.io/profile/geo/{frederick-county-va,winchester-va}

## Tier 3 — Local news

- **Winchester Star** — winchesterstar.com (paywalled; HTTP 429 rate-limit on scraping)
- **Royal Examiner** — royalexaminer.com (most accessible VA-specific source)
- **Northern Virginia Daily** — nvdaily.com
- **Winchester Gazette** — local aggregator

## Tier 4 — Reference / context

- VA Constitution Art. VII §4: https://law.lis.virginia.gov/constitution/article7/section4/
- Code of Virginia Title 15.2: https://law.lis.virginia.gov/vacode/title15.2/chapter17/
- Wikipedia: Frederick County VA / Winchester VA / Independent city (United States)

## See also

- [[../concepts/jurisdictional-map|Jurisdictional map]]
- [[../../raw/articles/2026-05-26-data-quality-caveats|Methodology caveats]]
