---
title: "Motor Core Lamination Stacking Methods (Lamnow + Sinolami)"
source: https://lamnow.com/several-methods-of-motor-core-lamination-stacking/
source_2: https://sinolami.com/motor-lamination-stacking-automation-guide/
type: data
tags: [lamination-stacking, interlock, welding, bonding-backlack, riveting, process-control]
credibility: medium
confidence: high
retrieved: 2026-07-22
summary: Side-by-side of the five stacking/joining methods with automation implications and loss trade-offs, plus the sensing/QC layer that automates it.
---

# Lamination Stacking Methods (Lamnow + Sinolami)

**Five joining methods:**
- **Bonding / backlack (self-bonding)**: steel pre-coated with adhesive varnish (~2 µm), stacked, heat-cured (withstands ~180°C). Lowest eddy-current loss / best NVH, higher cost. Automated via continuous in-mold dot gluing for mass production (Tesla Model 3 rotor cited).
- **Welding (laser/TIG/MIG/spot)**: laser most common (high power density, minimal deformation); but high-silicon steel welds poorly + post-weld crack risk, and welds create shorting paths that raise losses. Cost-effective, widely adopted.
- **Interlocking (interlock/cleat)**: dimples punched during blanking; laminations self-engage under press force inside the stamping die — **fully automated, no secondary step**. Dimple geometry: square/circular = precision; V-shape tolerates misalignment. Adds local losses.
- **Riveting/bolting**: holes punched, fastened in a fixture; for laser-cut/wire-cut/compound-stamped cores; more labor-intensive secondary step.
- **Cleating/clamping**: steel strips (≤2 mm) pressed into perimeter grooves (2–16 grooves); semi-automated.

**Automation / QC layer (Sinolami):**
- **Stacking pins** control angular position, sheet-to-sheet repeatability, straightness, slot alignment, bore/OD reference, skew accuracy.
- Automated count + multi-point stack-height + compression verification catches tilt, local lift, waviness, uneven compression before joining.
- **Force-distance curves** during compression detect burr interference, pin scraping, wrong variant, debris, poor seating, stack lean, slot mismatch.
- Philosophy: **reject bad stacks early** (before the irreversible weld/bond step) rather than maximize line speed.
