---
title: The Orthopedic Implant Process Chain & Station Map
type: concept
created: 2026-07-22
updated: 2026-07-22
tags: [process-chain, station-map, automation-levels, machining, additive, finishing, sterilization]
confidence: high
---

# The Process Chain & Station Map

You can't automate what you can't sequence. Every orthopedic implant — hip cup, femoral
stem, femoral head, knee femoral/tibial component, spinal cage, bone screw, trauma plate —
is built as an **ordered chain of stations**, and the automation decision is made *per
station* because they differ wildly in how automatable they are. This is the map; the other
concept articles drill into each hard step.

## The canonical station sequence

Synthesized from the process-chain overview
([overview](../raw/articles/2026-07-22-implant-process-chain-overview.md)) and the
lights-out cell case ([Flexxbotics/Mach](../raw/repos/2026-07-22-flexxbotics-mach-medical-lights-out-cell.md)):

| # | Station | Automation level | Notes |
|---|---------|-----------------|-------|
| 1 | **Design / CAD-CAM + fixture prep** | Full auto (SW) | Must be validated per 820.70(i). Born-digital DHR. |
| 2 | **Raw material in** (bar, powder, cast/forged preform) | Full auto | Lot traceability begins here. |
| 3 | **Forming** — 5-axis CNC / Swiss lathe / metal AM / forging / casting | Full auto (front end) | Route depends on material + geometry. See [Forming Routes](forming-routes-machining-am-forging-casting.md). |
| 4 | **AM post-processing** (depowder, support removal, HIP, heat treat) | **Semi-auto — bottleneck** | ~20 hr/part tail for L-PBF. See [Forming Routes](forming-routes-machining-am-forging-casting.md). |
| 5 | **Surface finishing / polishing** | Full auto (newly) | DLyte, drag/stream, force-control robots. See [Finishing & Coating](finishing-and-coating-automation.md). |
| 6 | **Coating** (porous/HA plasma spray, TiN) | Full auto | 6-axis robot plasma spray. See [Finishing & Coating](finishing-and-coating-automation.md). |
| 7 | **Cleaning** (ultrasonic multi-stage) | Full auto | ISO 19227 cleanliness. |
| 8 | **Passivation / anodize** | Full auto | ASTM F86/A967; Type II color anodize (AMS 2488). |
| 9 | **Inspection / metrology** (CMM, CT, optical, AI vision) | Full auto (mostly) | Trends to 100%/c=0. See [Metrology & Inspection](metrology-and-inspection-automation.md). |
| 10 | **Laser marking / UDI direct part mark** | Full auto | 21 CFR 801.45; can't compromise fatigue surface. |
| 11 | **Packaging** (HFFS, tray-seal) | Full auto | ISO 11607 sterile barrier. |
| 12 | **Sterilization** (gamma/EtO/e-beam/steam) | Full auto (outsourced) | See [back-end sources](../raw/data/2026-07-22-sterilization-packaging-cleaning.md). |
| 13 | **Release / batch record review** | Semi-auto | Human sign-off on DHR. |

## The automation-difficulty ranking

The steps do **not** automate equally. In rough order of remaining difficulty
([finishing](../raw/data/2026-07-22-automated-polishing-electropolish-massfinish.md),
[L-PBF vs EBM](../raw/data/2026-07-22-lpbf-vs-ebm-process-physics.md)):

1. **Manual polishing of CoCr bearing surfaces** — historically the single biggest
   hand-labor bottleneck; only now being displaced by automated electropolish/mass finishing.
2. **AM post-processing tail** — depowdering internal lattices, support removal, HIP —
   labor-heavy and hard to fully automate/verify.
3. **Final cosmetic + dimensional inspection** — automatable but bounded by validation
   burden (see [Regulatory Envelope](the-regulatory-envelope.md)).

The **easiest / most mature**: front-end machining (5-axis, Swiss), CMM metrology, laser
marking, packaging. This ranking is the strategic insight — spend automation budget where the
bottleneck is (finishing + AM post-processing), and note that the *machining core already runs
lights-out today* ([Flexxbotics/Mach](../raw/repos/2026-07-22-flexxbotics-mach-medical-lights-out-cell.md)).

## The unifying logic: material dictates route dictates automatability

The single decision that ripples furthest is **material selection**, because thermal
conductivity + hardness/reactivity fix the forming route and the finishing burden
([materials](materials-and-route-selection.md)). Titanium's low conductivity makes it a
machining headache but an AM darling; CoCr's hardness makes it a polishing headache; 316L is
the most machinable; PEEK/UHMWPE/ceramic each need their own chain. See
[Materials & Route Selection](materials-and-route-selection.md).

## Where inspection sits (not just at the end)

Like any regulated line, testing is distributed: in-process probing on the CNC, in-line CMM
feeding **closed-loop correction back to the machine**
([Flexxbotics/Mach](../raw/repos/2026-07-22-flexxbotics-mach-medical-lights-out-cell.md)),
CT for AM internal porosity, and a final 100% dimensional + cosmetic gate. The closed-loop
CMM→CNC feedback is *the* mechanism that makes lights-out feasible for a regulated implant.
See [Metrology & Inspection](metrology-and-inspection-automation.md).

## See also

- [Forming Routes: Machining, AM, Forging, Casting](forming-routes-machining-am-forging-casting.md)
- [Materials & Route Selection](materials-and-route-selection.md)
- [Finishing & Coating Automation](finishing-and-coating-automation.md)
- [Metrology & Inspection Automation](metrology-and-inspection-automation.md)
- [The Regulatory Envelope](the-regulatory-envelope.md)
- [Economics & Line Architecture](economics-and-line-architecture.md)
- [Limitations & Bottlenecks](limitations-and-bottlenecks.md)
- [Build Playbook](../reference/build-playbook.md)
