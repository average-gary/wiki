---
title: The BLDC/PMSM Manufacturing Process Chain
type: concept
created: 2026-07-22
updated: 2026-07-22
tags: [process-chain, station-map, automation-levels, rotor, stator, bottleneck]
confidence: high
---

# The Process Chain

You can't automate what you can't sequence. A brushless (BLDC / PMSM) motor is built as an
ordered chain of stations, and the automation strategy is decided **per station** — because the
stations differ wildly in how hard they are to automate. This article is the map; the
station-specific articles drill into each hard step.

## The canonical station sequence

Synthesized from a small-motor 12-station line ([Greensky](../raw/articles/2026-07-22-greensky-bldc-factory-station-map.md))
and a rotor-focused sub-chain ([Laserax](../raw/data/2026-07-22-laserax-rotor-manufacturing.md)). Two
parallel sub-chains (stator and rotor) converge at final assembly:

| # | Station | Automation level | Notes |
|---|---------|-----------------|-------|
| 1 | **Lamination stamping + stacking** (stator & rotor cores) | **Full auto** | Progressive dies; interlock/weld/bond in-die. See [Core & Assembly](core-and-assembly-automation.md). |
| 2 | **Slot insulation** (paper insertion) | Full auto | Vision-guided robots, micron accuracy. |
| 3 | **Stator winding** | Full auto **but hardest** | Needle/flyer/linear/hairpin. See [Stator Winding](stator-winding-automation.md). |
| 4 | **Termination / weld** (leads, hairpin welds, bus-bar) | Full auto | Laser/TIG/resistance + continuity test. |
| 5 | **Impregnation / varnish** (VPI, trickle, dip) | Full auto | Bonds turns, seals, adds dielectric. |
| 6 | **Rotor: magnet insertion** (SPM bond / IPM slot) | **Semi-auto — bottleneck** | See [Magnet Handling](magnet-handling-magnetization.md). |
| 7 | **Rotor: shaft press-fit + balancing** | Full auto | Interference fit; balance to G2.5. |
| 8 | **Magnetization** (post-assembly, in-line) | Full auto | Capacitor-discharge pulse + flux check. |
| 9 | **Housing / bearing / end-cap assembly** | Full auto | Servo press, induction shrink-fit. |
| 10 | **Stator–rotor integration** | Full auto | Precision air-gap alignment. |
| 11 | **Controller/PCB integration** (if integrated) | Full auto | Place + solder. |
| 12 | **End-of-line (EOL) test** | Full auto | See [Quality & EOL Testing](quality-and-eol-testing.md). |

## The automation-difficulty ranking

Every source that ranks the steps agrees on the order
([Greensky](../raw/articles/2026-07-22-greensky-bldc-factory-station-map.md)):

1. **Stator winding** — pattern complexity + closed-loop tension control; fine-gauge wire is fragile and fill-factor-limited.
2. **Magnet insertion / bonding** — positioning, adhesive dosing/curing, and the handling hazard of magnetized parts.
3. **Dynamic balancing** — tight residual-unbalance tolerances at 10,000+ RPM.

The **easiest / most mature** to automate: lamination stamping, EOL testing, and housing/bearing
press assembly. This ranking is *the* strategic insight — spend your automation budget where the
difficulty is, and consider buying (not building) the winding and magnetizing stations from
specialists (see [Vendor Landscape](../reference/vendor-landscape.md)).

## Two chains diverge: small BLDC vs. large traction

The process chain *branches on scale and topology*:

- **Small BLDC** (drones, RC, appliances, fans, pumps, power tools): **inner-rotor needle winding**
  or **outer-rotor flyer winding**, **concentrated** windings (coil-per-tooth), trickle/dip
  impregnation. Chinese turnkey lines dominate this segment.
  ([Honest](../raw/articles/2026-07-22-bldc-stator-winding-process-honest.md))
- **Large EV traction / e-axle**: **hairpin (bar) winding** with **distributed** windings, VPI,
  IPM rotors, induction shrink-fit into aluminum housings. German/Italian integrators (GROB,
  Aumann, Comau, Schaeffler) dominate. ([Odawara](../raw/data/2026-07-22-odawara-hairpin-winding.md),
  [GROB](../raw/repos/2026-07-22-grob-emotor-line-case.md))

The **winding topology chosen by the electromagnetic designer dictates the machine** and therefore
the whole line's automatability — this is the single decision that ripples furthest downstream.
See [Stator Winding](stator-winding-automation.md) and
[concentrated vs distributed](../raw/articles/2026-07-22-concentrated-vs-distributed-winding.md).

## Where testing sits (not just at the end)

Testing is distributed, not a single EOL gate
([Marposs](../raw/data/2026-07-22-marposs-eol-testing.md)): **pre-impregnation** stator tests catch
winding faults *before* varnish seals them in; **post-impregnation** validates the varnish; the
**full-motor EOL** is the final 100% gate. In-process **machine vision** runs at the winding and
magnet stations. See [Quality & EOL Testing](quality-and-eol-testing.md).

## See also

- [Stator Winding Automation](stator-winding-automation.md)
- [Magnet Handling & Magnetization](magnet-handling-magnetization.md)
- [Core & Assembly Automation](core-and-assembly-automation.md)
- [Quality & End-of-Line Testing](quality-and-eol-testing.md)
- [Line Economics & Architecture](line-economics-and-architecture.md)
- [Limitations & Gotchas](limitations-and-gotchas.md)
- [Build Playbook](../reference/build-playbook.md)
