---
title: "Cooler-Backed Mobile Model"
category: topic
sources:
  - raw/data/2026-10-02-r3-cooler-turnkey-mobile-cut-pack-units-and-aging-modules.md
  - raw/papers/2026-10-02-r3-cooler-iowa-state-small-red-meat-plant-design-guide.md
  - raw/data/2026-10-02-r3-cooler-coolbot-diy-walk-in-prices-and-limits.md
  - raw/articles/2026-10-02-r3-cutshop-nmpan-costing-throughput-cutter-productivity.md
  - raw/data/2026-10-02-r3-cutshop-bls-oews-butcher-wages-va.md
  - raw/data/2026-10-02-r3-farmkill-operator-price-table.md
  - raw/articles/2026-10-02-r3-cutshop-nmpan-central-coast-mhu.md
  - raw/articles/2026-10-02-r3-coolreg-frederick-county-zoning-ra.md
  - raw/articles/2026-10-02-r3-water-nmpan-wastewater-pretreatment.md
  - raw/data/2026-10-02-r3-ins-cisa-2013-meat-cut-shop-insurance-line.md
  - raw/data/2026-10-02-r2-rig-sentinel-slaughter-trailer-prices.md
  - raw/data/2026-10-02-r2-capacity-valley-processor-prices.md
  - raw/articles/2026-10-02-reg-vdacs-red-meat-custom-exemptions.md
created: 2026-10-02
updated: 2026-10-02
tags: [operating-model, mobile-cut-and-pack, hanging-cooler, dry-aging, throughput, cutter-labor, cooler-sizing, revenue-model, custom-exempt]
aliases: ["the operating model", "cooler + mobile", "kill-and-cut mobile"]
confidence: medium
volatility: warm
summary: "The user's chosen model: a mobile unit kills on the owner's farm AND later cuts and packages; a fixed cooler only hangs and ages carcasses for 7-21 days. It removes the dependency on a partner cut shop that sank other MSUs. The cost is that cutting labor becomes the binding constraint (about 8 man-hours per custom beef, 4.5 standardized), so two cutters cap the business near 6-10 head a week. A cooler for 20-30 hanging beef needs about 300-500 sq ft. Kill-and-cut mobile units list from $300k (Sentinel 53 ft). The legal catch: once the unit docks at the cooler to cut, Frederick County treats the site as a slaughterhouse/processing use (conditional use permit in RA), and it needs a wastewater route."
---

# Cooler-Backed Mobile Model

> **The model, as the user specified it.** The mobile unit **slaughters and also cuts and packages**.
> The fixed site is **a hanging and aging cooler only**. Rounds 1–2 assumed a partner cut shop.
> This article replaces that assumption and works out what the user's model implies.
> All numbers are sourced and dated, and every derived figure is marked [inferred].

## The flow

```
Day 0    Mobile unit at the owner's farm: kill, skin, eviscerate; offal composted on that farm
         (9VAC20-81-95 D.4) or tubbed for the renderer; carcass chills in the unit's onboard cooler
Day 0-1  Unit delivers hanging sides/quarters to the fixed cooler
Day 1-21 Carcasses hang and age (7 days minimum, 14-21 common)
Day 7-21 Mobile unit docks at the cooler: cut, grind, vac-pack, label "Not for Sale"
         Owners pick up at the cooler (or the unit delivers)
```

VDACS expressly allows a custom-exempt "mobile slaughter **and processing** unit"
([VDACS](../../raw/articles/2026-10-02-reg-vdacs-red-meat-custom-exemptions.md)).
Nothing found in Virginia rules requires cutting to happen in a fixed building.

**Why this answers the failure pattern.** The documented failure is a mobile unit with no partner
to hang and cut its carcasses. California's Central Coast unit sat **idle about 2 years** for
exactly that reason ([Central Coast](../../raw/articles/2026-10-02-r3-cutshop-nmpan-central-coast-mhu.md)),
and the regional cut shops are already at 125–150% of capacity. Bringing the cooler and the
cutting in-house removes that dependency. See [[fixed-facility-dependency|The Fixed-Facility Dependency]] ([The Fixed-Facility Dependency](../concepts/fixed-facility-dependency.md)).

## What it costs you: cutting labor becomes the ceiling

| Task | Labor | Source |
|---|---|---|
| Kill and dress | One person ≈ 7 beef per 8-hour day | NMPAN/Lorentz 2010 |
| Cut a **custom** beef (owner's cut sheet) | ≈ **8 man-hours** per beef | NMPAN/Lorentz 2010 |
| Cut to **standardized** specs | ≈ 4.5 man-hours per beef | NMPAN/Lorentz 2010 |
| Virginia butcher wage | Mean **$20.03/hr**; median $19.12 (May 2025). Winchester not published; neighbouring areas $18.16–21.70 | [BLS](../../raw/data/2026-10-02-r3-cutshop-bls-oews-butcher-wages-va.md) |

Source for productivity: [NMPAN costing](../../raw/articles/2026-10-02-r3-cutshop-nmpan-costing-throughput-cutter-productivity.md).

**A worked week, two people** [inferred]:
- **Kill:** 2 kill days at about 5 head each (with travel) = **about 10 head killed**, using about 2 person-days.
- **Cutting capacity:** the remaining time is about 8 person-days, or 64 hours.
- **Cutting demand:** 10 custom beef at 8 hours each = 80 hours. That is **more than 64**, so cutting is the bottleneck.
- **Ceiling:** about **6–8 head a week on custom cut sheets**, or about 10 with a simplified, standardized cut menu.
- **Annual volume:** about 300–400 head a year over a 50-week season.
- **Levers:** offer a limited cut menu, hire a third cutter for the fall peak, or offer "kill + hang only" to owners who cut their own.

This is the same constraint every regional plant reports (PEC 2021: cutter shortage at all 7 plants).
The model **moves the constraint in-house; it doesn't remove it.**

## The cooler

**Sizing rules (round 3):**

| Rule | Value | Source |
|---|---|---|
| Floor per hanging beef | ≈ 12–17 sq ft at a 14 ft ceiling | Iowa State PM 2077 (13 beef in 14×14.5 ft); Friesla 12×50 ft aging cooler ≈ 50 head [inferred] |
| Rail per side | ≈ 1.5 linear ft | Friesla [inferred] |
| Holding temperature | 34°F (Iowa State); CoolBot vendor suggests about 38°F and 75% RH for dry aging | [Iowa State](../../raw/papers/2026-10-02-r3-cooler-iowa-state-small-red-meat-plant-design-guide.md), [CoolBot](../../raw/data/2026-10-02-r3-cooler-coolbot-diy-walk-in-prices-and-limits.md) |
| Pre-chill load | 5,000 lb from 100°F to 36°F in 24 h (Iowa State), but the mobile unit's onboard cooler does the first chill in this model | Iowa State |
| Cooler vs kill rate | A 20-head cooler with 7-day aging supports a kill of 4/day, 5 days/week | NMPAN/Lorentz |

**Sizing for this model** [inferred]: 8–10 head/week × 2–3 weeks of hanging = **about 20–30 beef on the rail**,
which needs **about 300–500 sq ft**, roughly two 12×20 ft walk-ins.

| Build option | Cost | Note |
|---|---|---|
| CoolBot turnkey walk-in | **From $5,100** (2026) | Holds 34–36°F *with* an insulated floor. Weak at pulling down warm carcasses, which suits this model because carcasses arrive pre-chilled. Rail only on some sizes. Not rated for trailers |
| Plant-standard construction | ≈ **$300/sq ft** (NMPAN rule of thumb, undated); $100/sq ft in 2009 | 300–500 sq ft ≈ **$90k–$150k** [inferred] |
| Friesla aging module | Not published | 12×50 ft, holds 40,000 lb (about 50 head) |
| Used reefer trailer or container | **Not found** | Gap |
| Rails, trolleys, hoist | **Not found** | Gap (Walton's, Hantover, Jarvis) |

## The mobile unit: kill-and-cut options

| Unit | Price | What's on it | Source |
|---|---|---|---|
| Sentinel 53 ft semi | **From $300,000** (2026 list) | 18 ft kill room, 10 ft cooler, 18 ft butcher room (tables, 3-tub sink, 10 hp grinder, 5 hp band saw, vac sealer; one page lists these as extra), 35 kW diesel generator + shore-power switch, 200 gal water, 60 gal drain tank | [Turnkey units](../../raw/data/2026-10-02-r3-cooler-turnkey-mobile-cut-pack-units-and-aging-modules.md) |
| Mobile Processing Trailers & Supply turnkey | **Quote only** | Goosenecks 38–44 ft (cooler 4–8 beef), 45 ft semi (9), modular; options: band saw, grinder, mixer, stuffer, vac packer, label printer, scales | Same |
| Friesla cut-and-package module | Quote only | Modular | Same |
| *Comparison:* Sentinel custom-exempt kill-only | $72k–$115k | No cutting room | [Sentinel](../../raw/data/2026-10-02-r2-rig-sentinel-slaughter-trailer-prices.md) |

**Practical points** [inferred]:
- **Size.** A 53 ft semi is a lot to take down farm lanes and needs a Class A CDL. A 38–44 ft gooseneck is more
  farm-friendly, so get an MPTS quote.
- **Cut at the dock only.** Because cutting only happens at the cooler, the cut room never needs to be in a field. That could
  justify two units: a cheap kill-only trailer for farms, and a cut-room trailer parked at the cooler. The cut-room trailer
  would effectively be a modular building.
- **Docking hookups.** No vendor publishes a docking spec. The cooler site needs at least shore power (amperage
  unknown), potable water, and a gray-water connection or holding tank.

## The site: the cooler is a processing site once you cut there

- **Zoning (Frederick County).** In RA, "Slaughterhouses" are a **conditional use (CUP)**, and the county's
  definition covers establishments "primarily engaged in the slaughtering or processing of meats". § 165-204.17
  reaches any place where animals "dead or alive, are processed".
  - By-right agricultural storage needs the farm to produce **more than half** of what it stores, which a service
    cooler fails.
  - RA has **no cold-storage or warehouse use**.
  - Expect a CUP with **100 ft setbacks**, a **20,000 sq ft cap**, **all operations under roof** (a canopy or bay
    over the docked trailer), and screening.
  
  See [[cooler-site-permits|Cooler Site Permits]] ([Cooler Site Permits](../concepts/cooler-site-permits.md)).
- **Wastewater.** Cutting and wash-down at the dock produce industrial wastewater:
  - NMPAN says septic "probably will not work for most meat processing plants".
  - Public sewer is usually best (Frederick Water). A VDH-permitted engineered system is the alternative.
  - Frederick County bans pump-and-haul for RA restaurants, which is a warning sign for a holding tank.
  
  See [[slaughter-waste-disposal-virginia|Slaughter Waste Disposal in Virginia]] ([Slaughter Waste Disposal in Virginia](../concepts/slaughter-waste-disposal-virginia.md)).
- **Siting implication** [inferred]: the cheapest legal site may be **commercially or industrially zoned land with
  public sewer**, not a farm. Alternatively, accept the CUP and sewer-extension cost on an RA parcel. Get a
  written use determination from the Zoning Administrator before buying land or equipment.

## Revenue per head: a sketch [inferred from dated benchmarks]

| Line | Benchmark | 750 lb hanging steer |
|---|---|---|
| Kill (farm call) | $100–150/head + about $2.65/mile + about $500/day minimum (Backyard Butchery, OK, 2025); Beaverhead MT $75–125 (2026) | $125 + travel |
| Cut, vac-pack, label | $0.90/lb (Backyard Butchery 2025) to $1.05/lb (T&E 2025) | $675–$790 |
| Aging beyond 2 weeks | T&E: $25/head/week (2025) | $0–$25 |
| Over-30-month SRM handling | T&E: $50/head | $0–$50 |
| Offal haul-off (if not composted) | $100 optional (Backyard Butchery) | $0–$100 |
| **Total** | | **≈ $800–$1,100/head** |

Sources: [farm-kill table](../../raw/data/2026-10-02-r3-farmkill-operator-price-table.md),
[Valley prices](../../raw/data/2026-10-02-r2-capacity-valley-processor-prices.md).
Compare a fixed USDA plant: about $860–$975 all-in for the same carcass, with no farm call.
So the mobile service has to sell **convenience, no queue and no hauling**, not a lower price.

**A rough annual frame** [inferred, not a budget]: 300 head × about $900 = **about $270k** revenue.
Costs include:
- **Labor:** 2–3 people at about $20/hr plus 15% burden, about $90k–$140k.
- **Insurance:** about 4% of revenue in the CISA 2013 template, or about $11k.
- **Capital:** debt service on $300k+ of unit and cooler.
- **Running costs:** packaging, fuel, renderer, utilities.

Whether this clears depends heavily on the capex choice. The difference between a $300k semi and a
$92k kill trailer plus a CUP-permitted cut room is the biggest swing in the plan. **A full pro forma is
the next step**, and it needs real quotes.

## Open items specific to this model

1. Quotes: MPTS turnkey gooseneck, Sentinel 53 ft with cutting equipment, Friesla modules.
2. Does VDACS OMPS review the cooler site and the docked cut room as part of the Custom Permit? Is any
   equipment checklist applied?
3. A Frederick County use determination for a cooler where a mobile cut unit docks.
4. Sewer availability and cost at candidate sites; the FWSA/Winchester discharge limits.
5. Rail and trolley pricing; used reefer conversion; humidity and airflow specs for aging.
6. How customer pickup works at the cooler (hours, freezer holding). More than 25 people a day would trigger VDH waterworks rules.

## See Also

- [[mobile-beef-business-plan|Mobile Beef Processing Business Plan]] ([Mobile Beef Processing Business Plan](mobile-beef-business-plan.md))
- [[cooler-site-permits|Cooler Site Permits]] ([Cooler Site Permits](../concepts/cooler-site-permits.md))
- [[custom-exempt-mobile-rig|Custom-Exempt Mobile Rig]] ([Custom-Exempt Mobile Rig](../concepts/custom-exempt-mobile-rig.md))
- [[slaughter-waste-disposal-virginia|Slaughter Waste Disposal in Virginia]] ([Slaughter Waste Disposal in Virginia](../concepts/slaughter-waste-disposal-virginia.md))
- [[insurance-benchmarks|Insurance Benchmarks]] ([Insurance Benchmarks](../references/insurance-benchmarks.md))
- [[grant-and-financing-opportunities|Grant and Financing Opportunities]] ([Grant and Financing Opportunities](grant-and-financing-opportunities.md))
