---
title: "OCEAN Documentation Index"
source: "https://ocean.xyz/docs"
type: articles
ingested: 2026-05-28
tags: [ocean, datum, mining-pool, documentation-index, collection]
summary: "Landing/directory page for OCEAN's official documentation site. Lists 10 entries across How-To Guides, Technical Documentation, and Articles sections — DATUM setup, TIDES math, Lightning payouts, OCEAN node policies, and the Origins of DATUM. Functions as the entry point for OCEAN's published doc set; per-page contents are ingested as separate child sources."
collection: "ocean-docs"
adapter: "wayback-cdx"
canonical_url: "https://ocean.xyz/docs"
fetched: 2026-05-28
---

# OCEAN Documentation Index

> Landing page at https://ocean.xyz/docs. Acts as a directory of OCEAN's
> publicly documented guides, policies, and articles. The page itself contains
> only navigation (titles, dates, and links into per-doc pages) plus a footer
> with global pool stats. Each linked entry is ingested as its own raw source
> under this same collection (`ocean-docs`).

## Entries

| # | Section | Title | Date | URL |
|---|---------|-------|------|-----|
| 1 | How-To Guides | Alternate Templates | Dec 20, 2023 | https://ocean.xyz/docs/templateselection |
| 2 | How-To Guides | DATUM Setup Guide | Oct 18, 2024 | https://ocean.xyz/docs/datum-setup |
| 3 | How-To Guides | Lightning Payouts | Apr 14, 2026 | https://ocean.xyz/docs/lightning |
| 4 | Technical Documentation | Core Antispam Node Policy | Dec 08, 2023 | https://ocean.xyz/docs/ordispolicy |
| 5 | Technical Documentation | Core Node Policy | Jun 09, 2025 | https://ocean.xyz/docs/corepolicy |
| 6 | Technical Documentation | Data-Free Node Policy | Jun 09, 2025 | https://ocean.xyz/docs/datafreepolicy |
| 7 | Technical Documentation | OCEAN Node Policy | Jun 09, 2025 | https://ocean.xyz/docs/nodepolicy |
| 8 | Technical Documentation | TIDES Technical Documentation | Feb 29, 2024 | https://ocean.xyz/docs/tides |
| 9 | Technical Documentation | The Origins of DATUM | Sep 29, 2024 | https://ocean.xyz/docs/datum |
| 10 | Articles | Introduction to the Lightning Network | Jan 13, 2026 | https://ocean.xyz/docs/intro-to-lightning |

## Site Footer / Operator

- Operator: Bitcoin Ocean, LLC.
- Copyright: 2023–2026.
- Site-wide hashrate readout at fetch time: ~27.79 Eh/s (informational; not part
  of the docs themselves).

## Notes

- The "How-To Guides" group covers operator-facing setup material:
  [Alternate Templates] (Bitcoin Knots / Core / DATUM template-source choice),
  the [DATUM Setup Guide] for running `datum_gateway` against DATUM Prime, and
  [Lightning Payouts] for opting into LN payout rails.
- The "Technical Documentation" group is OCEAN's policy / mechanism layer:
  three node policies (Core, Data-Free, OCEAN), the older Antispam policy
  (anti-ordinals/inscription mempool policy), the TIDES payout-math doc, and
  the DATUM origins / motivation post.
- The "Articles" group currently has a single educational piece on the
  Lightning Network — context for the Lightning Payouts how-to.
- All dates above are publication dates as displayed on the index page; later
  per-page revisions are not visible from this index.

## Coverage Map (this wiki)

- DATUM-related entries (DATUM Setup, Origins of DATUM, Alternate Templates,
  the three node policies, Antispam policy) → in scope for `datum-gateway`.
- TIDES → primarily in scope for `bitcoin-mining-payout-schemas`; cross-linked
  here because OCEAN's payout math is tied to the same operator stack DATUM
  feeds into.
- Lightning entries → operator-side payout rail; only loosely related to
  DATUM. Capturing for completeness of the OCEAN docs corpus, not because
  DATUM Gateway depends on Lightning.
