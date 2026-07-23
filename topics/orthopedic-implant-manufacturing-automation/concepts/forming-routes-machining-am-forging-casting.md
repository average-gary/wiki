---
title: Forming Routes — Machining, Additive, Forging, Casting
type: concept
created: 2026-07-22
updated: 2026-07-22
tags: [cnc, swiss, 5-axis, additive-manufacturing, l-pbf, ebm, forging, investment-casting, post-processing]
confidence: high
---

# Forming Routes

Four routes turn raw material into an implant blank: **subtractive (CNC/Swiss)**, **additive
(L-PBF/EBM)**, **forging**, and **investment casting**. The choice is set by geometry,
material, and volume — and each route has a *different* automation profile.

## Route 1: Subtractive (the workhorse)

- **5-axis CNC machining** dominates hips (stems, heads), knees (femoral/tibial), and complex
  geometries. DMG MORI cut a CoCr knee at 40k rpm to Ra 0.8→0.3 µm
  ([vendor landscape](../raw/repos/2026-07-22-cmo-vendor-landscape-market.md)).
- **Swiss-type lathes make ~95% of bone screws**
  ([Swiss machining](../raw/articles/2026-07-22-swiss-machining-bone-screws.md)) — bar-fed,
  lights-out, with thread whirling and gundrilling for cannulation. This is the most mature,
  most automated corner of the whole industry.
- The machining core genuinely runs **24/7 lights-out today**: 5-axis mill + in-line CMM +
  wash orchestrated by one robot, closed-loop
  ([Flexxbotics/Mach](../raw/repos/2026-07-22-flexxbotics-mach-medical-lights-out-cell.md)).
- Machinability is material-bound: Ti burns tools (see [Materials](materials-and-route-selection.md)),
  CoCr is >50 HRC and hardest, 316L is easiest.

## Route 2: Metal additive (L-PBF vs EBM)

Additive owns **porous, bone-mimicking geometry** that machining can't make — acetabular
cups, spinal cages, patient-specific parts ([L-PBF vs EBM](../raw/data/2026-07-22-lpbf-vs-ebm-process-physics.md),
[EBM parameters](../raw/papers/2026-07-22-ebm-next-gen-implants-parameters.md),
[AM cups](../raw/papers/2026-07-22-am-acetabular-cups-morphometry.md)):

| | **L-PBF** (laser) | **EBM** (electron beam) |
|---|---|---|
| Thermal environment | Cold bed → **high residual stress** | Hot vacuum (~700 °C) → **low stress** |
| Post-processing | **HIP mandatory** | HIP often skippable for stress; still for porosity |
| As-built surface | Smoother | Rougher |
| Ortho users | AddUp, restor3d, EOS fleet | Lima/Enovis (15 machines), Orchid (Spectra L), Stryker |

- **Porous lattices match bone modulus** to fight stress shielding: E = E₀(ρ/ρ₀)ⁿ, tuned to
  ~19 GPa near cancellous bone ([EBM](../raw/papers/2026-07-22-ebm-next-gen-implants-parameters.md)).
  Stryker Tritanium: 55–65% porosity, 100–700 µm pores, **300k+ devices in 10 years**
  ([serial AM cases](../raw/repos/2026-07-22-serial-am-oem-cases-stryker-lima-orchid.md)).
- **The post-processing tail is the automation gap** (~20 hr/part for L-PBF): depowdering
  (especially trapped powder in lattices — [AM cups](../raw/papers/2026-07-22-am-acetabular-cups-morphometry.md)),
  support removal, HIP, heat treat, then machining of mating faces. The *printing* is
  automated; the *finishing of prints* is not.
- Serial-AM economics are real: AddUp FormUp 350 = **21,735 hip cups/yr/machine at 78% OEE**;
  Orchid's stackable "EB-LPB" + automated powder recovery (PRS 30)
  ([serial AM cases](../raw/repos/2026-07-22-serial-am-oem-cases-stryker-lima-orchid.md)).
- **Validation-by-monitoring** is emerging (EOSTATE Exposure OT, Smart Fusion) as an
  alternative to 100% CT — melt-pool tomography as the quality record.

## Route 3: Forging

Closed-die forging aligns grain flow → **superior fatigue strength** for load-bearing hip
stems and femoral components. Highly automatable (press + robotic handling) but tooling is
part-specific; economical only at volume. Forging/casting is the largest CMO category →
$4.9B by 2032 ([vendor landscape](../raw/repos/2026-07-22-cmo-vendor-landscape-market.md)).

## Route 4: Investment casting

The traditional route for **CoCr** knee femoral components (F75 as-cast). Robotic shell
dipping and automated wax injection exist, but casting feeds a heavy downstream **machining +
polishing** burden because cast CoCr is >50 HRC
([CoCrMo](../raw/data/2026-07-22-cocrmo-femoral-head-machining.md)). AM is progressively
displacing casting for porous parts.

## Choosing the route

- **Bone screws / simple trauma** → Swiss lathe (315L/Ti), lights-out.
- **Hip stems, femoral components (load-bearing)** → forging then 5-axis, or 5-axis from bar.
- **Femoral heads (CoCr/ceramic)** → cast/machined + heavy finishing.
- **Porous cups, cages, patient-specific** → metal AM (EBM for low-stress bulk, L-PBF for
  fine features), accept the post-processing tail.

## See also

- [The Process Chain & Station Map](process-chain-and-station-map.md)
- [Materials & Route Selection](materials-and-route-selection.md)
- [Finishing & Coating Automation](finishing-and-coating-automation.md)
- [Limitations & Bottlenecks](limitations-and-bottlenecks.md)
- [Build Playbook](../reference/build-playbook.md)
