---
title: "Crime statistics — methodology + data-quality caveats"
publication: Pew Research / BJS / Brennan Center / Wikipedia
url: https://www.pewresearch.org/short-reads/2024/04/24/what-the-data-says-about-crime-in-the-us/
url2: https://bjs.ojp.gov/data-collection/ncvs
url3: https://www.brennancenter.org/our-work/research-reports/myths-and-realities-understanding-recent-trends-violent-crime
type: article
ingested: 2026-05-26
quality: 5
credibility: high
confidence: high
tags: [methodology, NCVS, NIBRS, hierarchy-rule, dark-figure, caveats]
---

# Crime Statistics Methodology Caveats

Standing footnote for any per-100k figure cited in this wiki.

## 1. The dark figure of crime (~58% of violence, ~68% of property crime is never reported to police)

Per BJS National Crime Victimization Survey (NCVS) 2022:
- Only **41.5% of violent crimes** are reported to police
- Only **31.8% of property crimes** are reported to police

So police-derived data (UCR/NIBRS) is **a floor, not a count**. The "true" crime rate is roughly **2x the reported rate**.

NCVS methodology: ~240,000 persons in ~150,000 households interviewed annually. Excludes military bases, institutionalized persons, homeless populations, and victimizations outside the U.S. **Cannot measure homicide** (no victim to interview).

## 2. NIBRS transition (2021) broke the trend line

In 2021, FBI mandated all agencies report via NIBRS instead of SRS. Two structural changes broke pre/post comparability:

- **Hierarchy Rule abolished**: SRS reported only the most serious offense per incident. NIBRS reports **all offenses per incident**. Mechanically inflates apparent crime counts even for fully-compliant agencies.
- **Rape definition expanded** (FBI revised UCR rape definition, ~2013): forcible carnal knowledge of a female → gender-neutral expanded definition. Counts step up at the change point.
- **New "Crimes Against Society"** category (drug, gambling, prostitution) added under NIBRS.

**Coverage drop**: pre-2021 UCR covered ~95% of US population. NIBRS-only first year (2021) covered roughly **half**. Recovered to ~82% by Q4 2023 once NYPD/LAPD onboarded.

Brennan Center quote: *"Reliable government data on crime trends in 2021 may never be available."*

## 3. Small-jurisdiction Poisson noise

Frederick County has ~96k population. **A single homicide** = a rate of ~1.04 per 100,000. A swing from 0 to 2 homicides (entirely plausible random year-to-year) produces a 0 to ~2.08 per-100k swing — **headline-grade percentage changes that carry essentially no signal**.

For Winchester (~28k pop), the effect is more severe: 1 homicide ≈ 3.6 per 100k.

**Use 3-5 year rolling averages, not single-year points**, for any sub-100k jurisdiction trend claim.

## 4. Clearance rates: "by arrest" vs "by exception"

- **Cleared by arrest**: someone was arrested and charged.
- **Cleared by exception**: case closed without arrest — suspect died, victim refused to cooperate, prosecutor declined, etc.

Both count as "cleared" in headline clearance rates. Don't equate clearance with prosecution.

## 5. Reporting status

Some Virginia agencies didn't transition cleanly to NIBRS in 2021. **Need to confirm** whether FCSO (VA0340000) and Winchester PD (VA1095000) reported every year 2018-2024. The VSP UCR landing page publishes reporting status — TLS cert issue blocked direct fetch in this round; flagged for follow-up.

## 6. Maryland-vs-Virginia confusion (the worst data trap for this wiki)

**Frederick County, Maryland** (pop ~290k, suburban DC) is much bigger and gets vastly more press coverage than Frederick County, Virginia (pop ~96k). Search engines routinely conflate them.

Distinguishers to require in any source:
- "Virginia" or "VA" in the body
- Co-occurrence with "Winchester" (FrCo VA's county seat) or any of: Stephens City, Middletown, Lord Fairfax Health District, Northwest Virginia Regional Drug Task Force, 26th Judicial Circuit
- I-81 corridor (NOT I-70/I-270/I-95 which are MD)
- Sheriff Lenny Millholland (NOT Sheriff Chuck Jenkins, who's in Frederick County MD)

## Wiki posture

Any per-100k figure ingested for FrCo or Winchester carries a footnote covering these five points. State whether the rate is FBI UCR-derived or NIBRS-derived. State the year. State the population denominator. Use rolling averages, not single years.

## Sources

- Pew Research, *"What the data says about crime in the U.S."* (Apr 2024)
- BJS NCVS program page + Criminal Victimization 2022 report
- Brennan Center, *"Myths and Realities: Understanding Recent Trends in Violent Crime"*
- Wikipedia, *National Incident-Based Reporting System*

## See also

- [[2026-05-26-vsp-crime-in-virginia-annual-reports|VSP Crime in Virginia]]
- [[2026-05-26-fbi-ucr-fbi-cde|FBI UCR / CDE]]
