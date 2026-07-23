---
title: Limitations & Bottlenecks — What Still Isn't Automated
type: concept
created: 2026-07-22
updated: 2026-07-22
tags: [limitations, bottlenecks, gotchas, am-post-processing, validation, ai-vision, failure-modes]
confidence: high
---

# Limitations & Bottlenecks

"Maximal automation" is not "full automation." These are the steps that resist automation, the
gotchas that scrap parts, and the honest ceiling on how lights-out an implant line can get.

## The remaining bottlenecks

1. **AM post-processing tail (~20 hr/part for L-PBF).** Depowdering internal lattices, support
   removal, HIP, heat treat, and finish-machining of mating faces remain labor- and cycle-heavy
   and hard to fully verify ([L-PBF vs EBM](../raw/data/2026-07-22-lpbf-vs-ebm-process-physics.md)).
   **Trapped powder in porous cups** is a specific depowdering hazard
   ([AM cups](../raw/papers/2026-07-22-am-acetabular-cups-morphometry.md)). The printing is
   automated; cleaning the print is the gap.
2. **Validation, not robotics, is the hard ceiling.** Every non-fully-inspectable automated
   process needs IQ/OQ/PQ, and every change can trigger revalidation
   ([regulatory envelope](the-regulatory-envelope.md)). This is why automation in ortho is
   slower than raw robotics would allow.
3. **Black-box AI inspection can't be fully validated.** AI vision must escalate ambiguous
   accept/reject calls to a human — a validated human stays in the loop
   ([AI vision](../raw/articles/2026-07-22-ai-cosmetic-visual-inspection-limits.md)).
4. **Ceramic finishing is unforgiving.** BIOLOX-type heads are sinter-then-diamond-grind;
   a finishing defect becomes a **crack initiator** — low tolerance for automation error
   ([ceramic](../raw/papers/2026-07-22-biolox-delta-ceramic-rationale.md)).
5. **HMLV changeover cost.** High variant count erodes automation ROI; the long tail of low-
   volume SKUs may stay semi-manual ([economics](economics-and-line-architecture.md)).

## Material-specific gotchas

- **Titanium**: 80% of cutting heat goes into the edge → rapid tool wear; work-hardening if you
  dwell; needs high-pressure/cryogenic coolant and **sister-tooling** for unattended runs
  ([Ti](../raw/data/2026-07-22-titanium-machinability-tool-wear.md)). A dull tool mid-lights-
  out run scraps parts silently unless monitored.
- **CoCrMo**: >50 HRC — the historic hand-polish bottleneck; automated finishing helps but the
  process is slow and abrasive-intensive ([CoCrMo](../raw/data/2026-07-22-cocrmo-femoral-head-machining.md)).
- **CFR-PEEK**: abrasive carbon fiber destroys carbide → **PCD tooling required**
  ([PEEK/SS](../raw/data/2026-07-22-peek-stainless-machinability.md)).
- **UHMWPE**: oxidation is the enemy — needs gamma-crosslink + **vitamin-E stabilization** +
  inert-atmosphere sterilization, a multi-step chain that can't be shortcut
  ([UHMWPE](../raw/papers/2026-07-22-uhmwpe-crosslink-vitamin-e.md)).
- **Tantalum**: 2980 °C melting point forces CVD-on-carbon; not a simple machining/printing part
  ([Ta](../raw/papers/2026-07-22-porous-tantalum-routes.md)).

## Design-for-automation constraints

- **UDI laser marking must not compromise the fatigue surface** — mark placement is a design
  decision, not a free back-end step
  ([coatings/marking](../raw/data/2026-07-22-coatings-passivation-anodize-marking.md)).
- **Fatigue-critical surfaces** limit where you can fixture, mark, or leave finishing artifacts.
- **Cleanliness (ISO 19227)** must be designed in — geometry that traps particulate or
  machining fluid fails cleaning validation ([sampling](../raw/data/2026-07-22-inspection-sampling-cleanliness-standards.md)).

## The honest ceiling

The metal machining + metrology + cleaning core **can** run lights-out today
([Flexxbotics/Mach](../raw/repos/2026-07-22-flexxbotics-mach-medical-lights-out-cell.md)). The
AM post-processing tail, ceramic finishing, and final human sign-off on the DHR **cannot** yet.
"Maximal automation" in 2026 means: automate the machining core fully, automate finishing and
metrology, semi-automate AM post-processing, and keep a validated human at the release gate.

## See also

- [The Process Chain & Station Map](process-chain-and-station-map.md)
- [Forming Routes](forming-routes-machining-am-forging-casting.md)
- [Materials & Route Selection](materials-and-route-selection.md)
- [The Regulatory Envelope](the-regulatory-envelope.md)
- [Economics & Line Architecture](economics-and-line-architecture.md)
- [Build Playbook](../reference/build-playbook.md)
