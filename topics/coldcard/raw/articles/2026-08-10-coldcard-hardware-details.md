---
title: "Coldcard Hardware Details (schematics and BOM index)"
source: "https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/hardware/README.md"
type: articles
ingested: 2026-08-10
tags: [coldcard, hardware, schematics, bill-of-materials, reverse-engineering, security-research, proprietary-license, pcb]
summary: "Index to the hardware directory, which Coinkite states contains enough information to build your own Coldcard from off-the-shelf parts, shared for the benefit of security researchers wanting to analyse the device more completely. Lists the schematic images by revision - Q rev D, Mark4 rev F, Mark4 rev D and Mark3 rev B - and the bill-of-materials spreadsheets for Q rev D, Mk5 rev F, Mk4 rev D and Mk3 rev B, noting most parts are available from Digikey while some come direct from suppliers, and that the custom plastic case, the barcoded secure bag and the pin-recovery card are excluded. Important licensing caveat: unlike the firmware, this material is explicitly not open source - copyright of these files and all Coldcard design elements remains with Coinkite Inc., the information is for research and testing purposes only with no warranties, and Coinkite states it does NOT grant license for commercial use. Also disclaims that the files may not be fully current."
collection: "coldcard"
adapter: git
upstream_id: "hardware/README.md"
upstream_type: git-file
revision: "43b2139227149c281141d08c612afd13c434d456"
sha: "c2755f03433ac81784f5958c7b4c9f8c697fa69a"
canonical_url: "https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/hardware/README.md"
content_format: markdown
license: "Proprietary - research/testing only, no commercial use (Coinkite Inc.)"
authors: [Coinkite Inc.]
fetched: 2026-08-10
---
# Coldcard Hardware Details

This directory contains enough information for you to be able to
build your own Coldcard from off-the-shelf parts.
We are sharing this information for the benefit of security
researchers who wish to analyse the Coldcard more completely.

# Schematic

![](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/hardware/schematic-q1d.png)

`schematic-q1d.png`

This is the Q rev D schematic.

![](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/hardware/schematic-mark5f.png)

`schematic-mark5f.png`

This is the Mark4 rev F schematic.

![](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/hardware/schematic-mark4d.png)

`schematic-mark4d.png`

This is the Mark4 rev D schematic.

![](https://github.com/coldcard/firmware/blob/43b2139227149c281141d08c612afd13c434d456/hardware/schematic-mark3b.png)

`schematic-mark3b.png`

This is the Mark3 rev B schematic.


# BOM - Bill of Materials

The parts used in the Coldcard are detailed in these spreadsheets.
Most of them could be bought on Digikey, but some are direct from suppliers.

- BOM for Q rev D: `bom-q1d.xlsx`
- BOM for Mk5 rev F: `bom-mark5f.xlsx`
- BOM for Mk4 rev D: `bom-mark4d.xlsx`
- BOM for Mk3 rev B: `bom-mark3b.xlsx`

Not included are these minor bits:

- the plastic case (custom)
- the secure bag (with barcode serial number)
- pin-recovery card

# Important

- No promises that these files are 100% current because we constantly make quality improvements.
- Copyright of these files, and all design elements of the Coldcard remain with Coinkite Inc.
- This information is for research and testing purposes only&mdash;no warranties. 
- **Coinkite does NOT grant license of this information for comercial use.**

---

## Ingest note

Repository-relative links in the body above were repointed to absolute GitHub URLs pinned to `43b2139`. Link text and all prose are unchanged; only the destinations were rewritten, since repo-relative paths do not resolve inside the wiki.

Licensing differs from the rest of this collection: the repository LICENSE is MIT-style, but this directory's own README states that copyright in the hardware design files remains with Coinkite Inc., that the material is for research and testing only, and that Coinkite does NOT grant license for commercial use. The `license` field reflects that narrower grant.
