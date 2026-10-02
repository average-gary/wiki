---
title: "FSIS MPI Directory: Virginia establishments with federal grants for cattle slaughter (snapshot to 2026-05-29)"
source: "https://www.fsis.usda.gov/sites/default/files/media_file/documents/MPI_Directory_by_Establishment_Name.csv"
type: data
ingested: 2026-10-02
tags: [fsis, mpi-directory, usda-inspected, processing-capacity, virginia, shenandoah-valley, frederick-county, slaughter-volume]
summary: "The FSIS MPI Directory, plus its Establishment Demographic dataset (Wayback copies, latest grant date 2026-05-29), lists 130 Virginia establishments. Only 21 hold a federal grant to slaughter cattle. All but one are Very Small, and 16 of the 21 fall in the lowest slaughter-volume band (under 1,000 head of all species in the last 360 days). In the Valley and northern Shenandoah corridor, five plants slaughter cattle: Gentle Harvest (Winchester, Frederick Co.), Blue Ridge Meats (Middletown, Warren Co. per FSIS), Crabill's (Toms Brook) and Gore's Processing (Edinburg) in Shenandoah Co., and Honest Meats LLC (Harrisonburg; same phone as T&E Meats). Only Honest Meats/T&E is in volume band 2 (1,000 to 9,999 head). Only Fauquier's Finest (Bealeton) reaches band 4 (100,000+ head). Twenty of the 21 plants also carry a custom-exempt slaughter flag."
authors: ["USDA Food Safety and Inspection Service"]
published: 2026
regulatory_model: usda-inspected
geography: virginia
credibility_score: 5
research_round: 2
research_agent: "processor-capacity"
fetched: 2026-10-02
---

# FSIS MPI Directory: Virginia federal cattle-slaughter establishments

## Provenance

- Live fsis.usda.gov returned "Access Denied". The two CSVs came from the Wayback Machine (`web.archive.org/web/2026id_/...`), gzip-encoded:
  - `MPI_Directory_by_Establishment_Name.csv`: 7,185 establishments nationwide. The latest `grant_date` in the file is 2026-05-29.
  - `Dataset_Establishment_Demographic_Data.csv`: 7,237 rows. It holds the species flags, exemption flags, and volume categories. The two files were joined on `establishment_number`.
- Volume-category definitions come from FSIS "Data Documentation, MPI Directory Establishment Demographic" (PDF):
  - **slaughter_volume_category**, "aggregated head slaughtered for the last 360 days": 1 = <1,000; 2 = 1,000 to <10,000; 3 = 10,000 to <100,000; 4 = 100,000 to <10,000,000; 5 = 10,000,000+. NULL means the plant did not slaughter in the last 360 days.
  - **processing_volume_category**, pounds per month: 1 = <10,000; 2 = 10,000 to <100,000; 3 = 100,000 to <1M; 4 = 1M to <10M; 5 = 10M+.
- Scope limit: this directory lists **federal (FSIS) grants only**. Virginia state-inspected plants under VDACS (Va. Code Ch. 54) and custom-exempt-only shops do not appear. [inferred] The full count of custom-exempt locker plants in the Valley needs the VDACS list instead.

## Virginia totals

- 130 VA establishments: 55 Very Small, 30 Small, 15 Large, 29 N/A (mostly freezer/warehouse/identification-only grants).
- 25 VA establishments list "Meat Slaughter". 21 have at least one cattle class flagged (beef cow, steer, heifer, bull/stag, or dairy cow).
- For comparison, establishments with steer, heifer, or beef-cow slaughter flags: WV 6, MD 19, PA 85.

## Virginia cattle-slaughter establishments

Columns: est. no. | name | city | county (FSIS) | size | slaughter vol. cat. | custom-exempt slaughter flag | grant date

| Est. no. | Name | City | County | Size | Vol | Custom | Grant |
|---|---|---|---|---|---|---|---|
| M34103+P34103+V34103 | Gentle Harvest | Winchester | **Frederick** | Very Small | 1 | Y | 2021-07-22 |
| M6526 | Blue Ridge Meats of Front Royal | Middletown | Warren (as listed) | Very Small | 1 | Y | 2021-07-20 |
| M34381+P34381 | Crabill's Retail & Wholesale Meats, LLC | Toms Brook | **Shenandoah** | Very Small | 1 | Y | 2021-07-20 |
| M27237+P27237+V27237 | Gore's Processing, Inc. | Edinburg | **Shenandoah** | Very Small | 1 | Y | 2021-12-14 |
| M7420+V7420 | Honest Meats, LLC (phone 540-434-4415 = T&E Meats) | Harrisonburg | Harrisonburg city | Very Small | 2 | Y | 2021-07-29 |
| M39968+P39968 | Donald's Meat Processing, LLC | Lexington | Rockbridge | Very Small | 1 | Y | 2016-05-31 |
| M33940 | Fauquier's Finest Custom Meat Processing | Bealeton | Fauquier | Very Small | **4** | Y | 2021-03-24 |
| M2581 | Imperial Farms | Sumerduck | Fauquier | Very Small | 1 | Y | 2025-02-18 |
| M31959 | Lebanese Butcher Slaughter House Inc | Warrenton | Fauquier | Very Small | 1 | Y | 2021-03-24 |
| M34799 | Braggs Corner Meat Corp. | Culpeper | Culpeper | Very Small | 2 | N | 2022-10-18 |
| M46877+P46877 | Seven Hills Abattoir | Lynchburg | Lynchburg city | **Small** | 2 | Y | 2022-03-03 |
| M21938+P21938 | EcoFriendly Foods | Moneta | Bedford | Very Small | 3 | Y | 1996-07-26 |
| M44217 | Schrock's Slaughter House | Gladys | Campbell | Very Small | 1 | Y | 2015-08-21 |
| M2793+P2793 | 5 Pillars Meat LLC | Farmville | (blank) | Very Small | 1 | Y | 2025-10-15 |
| M1908+V1908 | Easternview Farms LLC | Drakes Branch | Charlotte | Very Small | 1 | Y | 2024-05-14 |
| M1502 | KC Farms Meats, LLC | Ferrum | Franklin | Very Small | 1 | Y | 2024-02-13 |
| M763 | The Butcher's Block | Dry Fork | Pittsylvania | Very Small | 1 | Y | 2024-02-13 |
| M9979+P9979+V9979 | Smith Valley Meats | Rich Creek | Giles | Very Small | 1 | Y | 2021-07-21 |
| M47541+V47541 | Double L Meat Processing | Jonesville | Lee | Very Small | 1 | Y | 2024-02-13 |
| M2019+P2019+V2019 | Anderson & Son Meat Processing LLC | Abingdon | Washington | Very Small | 1 | Y | 2023-10-19 |
| M32062+P32062+V32062 | Washington County Meat Packing | Bristol | Washington | Very Small | 1 | Y | 2021-07-22 |

Notes:
- Grant dates show the last grant edit, not the plant's founding. Many dates cluster in July 2021, which likely reflects a directory-wide re-grant or edit [inferred].
- Other VA "Meat Slaughter" grants with no cattle flags: Central Meat Packing (Chesapeake, swine), East Coast 1st Venture (Culpeper), ISF/High Liner (Newport News), VSU's Small Ruminant Mobile Meat Processing Unit (Petersburg, Chesterfield Co.; custom flag only), and Wholesome Foods (Edinburg).
- **VSU's Small Ruminant Mobile Meat Processing Unit (M46728)** is an existing Virginia MSU with a federal grant. It is a precedent for this plan.
- Valley processing-only federal plants (no slaughter) include Baker, Inc. (Mt. Jackson), Fimus Limited (Luray), and Cargill (Timberville, large).

## Implications [inferred]

- Federal cattle-kill capacity from Winchester to Harrisonburg is five Very Small plants. Four of them each slaughtered under 1,000 head of all species in the trailing 360 days. Inspected capacity in the northern Valley is thin.
- Gentle Harvest in Winchester is the only federal cattle-slaughter grant in Frederick County. It is a direct competitor or partner for any mobile unit based there.
- Blue Ridge Meats (round 1) holds both FSIS and custom-exempt flags. FSIS lists it at a Middletown address.
