---
title: "Build Playbook — How to Manufacture Orthopedic Implants with Maximal Automation"
type: reference
created: 2026-07-22
updated: 2026-07-22
tags: [playbook, how-to, automation, orthopedic-implants, decision-framework]
confidence: high
---

# Build Playbook: Manufacturing Orthopedic Implants with Maximal Automation

The actionable answer to the original question. Opinionated, step-by-step: what to decide
first, what to buy vs. build, and the order to automate the chain. Synthesizes all
[concept articles](../_index.md) and the [vendor landscape](vendor-landscape.md). (A
standalone, shareable version lives in [output/](../output/).)

## The one-paragraph answer

Manufacturing orthopedic implants with maximal automation means **sequencing the build into
stations and automating each to a different degree**, where the route is dictated by the
**material's thermal conductivity + hardness/reactivity**, and the ceiling is set not by
robotics but by the **obligation to validate**. The machining core (5-axis/Swiss + in-line CMM
+ wash) **already runs 24/7 lights-out** with closed-loop CMM→CNC correction; the recent
breakthroughs are **automated finishing** (DLyte / drag / stream / force-control robots) that
kills the hand-polish bottleneck, and **serial metal AM** for porous parts. The remaining gaps
are the **AM post-processing tail**, **black-box AI inspection**, and the **human sign-off on
the DHR**. Whether to automate is an HMLV economics call: flexible robotic cells + cobot
tending + single-piece flow, *not* hard automation. Treat **validation (CSA-scoped) as a
first-class line-design input**, and **buy the hard stations** (finishing cells, AM machines,
metrology) rather than build them.

## Decision 0: Should you automate — and how much?

Ortho is **high-mix / low-volume** ([economics](../concepts/economics-and-line-architecture.md)):

- **Volume/mix?** High-runner SKUs (bone screws, common cup sizes) → dedicated Swiss lines / AM
  fleets. The long tail of variants → flexible cells or semi-manual. Don't hard-automate a
  high-mix product.
- **What justifies capital?** **Repeatability + capacity + labor**, not peak speed. Unattended
  lights-out hours are free capacity against fixed capital.
- **Architecture default:** flexible robotic work-cells + cobot machine-tending + single-piece
  flow (lot size as low as one).

## Decision 1: Material → route (do this FIRST)

Material fixes everything downstream ([materials](../concepts/materials-and-route-selection.md),
[forming routes](../concepts/forming-routes-machining-am-forging-casting.md)):

| Implant / material | Route | Automation notes |
|---|---|---|
| Bone screws, trauma (316L / Ti) | **Swiss lathe** | ~95% of screws; bar-fed lights-out; thread whirling, gundrill cannulation |
| Hip stems, femoral components (Ti/CoCr, load-bearing) | **Forge → 5-axis** (or 5-axis from bar) | forging aligns grain for fatigue |
| Femoral heads (CoCr / ceramic) | Cast/wrought → 5-axis + **heavy finishing** / sinter+diamond-grind | polishing/ceramic-grind is the pain |
| Porous cups, spinal cages, patient-specific (Ti) | **Metal AM** (EBM bulk, L-PBF fine) | accept the post-processing tail |
| Bearing liners (UHMWPE) | Machine → **gamma-crosslink → vitamin-E → inert sterilize** | oxidation control, multi-step |

**Rule of thumb:** titanium → prefer AM (miserable to machine, ideal to print); CoCr/SS →
machine; PEEK → mold or machine (PCD for CFR-PEEK); ceramic → sinter+grind.

## Decision 2: Design validation in from day one

The regulatory envelope is the real ceiling ([regulatory](../concepts/the-regulatory-envelope.md)):

1. **Assume 820.75 applies** — most implant processes (weld, coat, sterilize, mold, AM, finish)
   aren't fully inspectable → **IQ/OQ/PQ** each automated cell; plan for revalidation on change.
2. **Validate the automation software** too (820.70(i)) — a robotic cell needs *both* process
   PQ and software validation.
3. **Scope software validation with CSA** (risk-based) — this is the lever that makes automation
   affordable; don't over-document low-risk software.
4. **Born-digital DHR + Part 11 audit trails** — per-implant Device History File traceability
   (as in the [lights-out cell](../raw/repos/2026-07-22-flexxbotics-mach-medical-lights-out-cell.md)).
5. **UDI direct part mark (801.45)** — plan mark placement so it can't compromise the fatigue
   surface.
6. **Prefer high-Cpk automated processes** — they make PQ easier to pass and stay in control.
7. Mind the calendar: **QMSR (ISO 13485 harmonization) effective Feb 2, 2026**.

## The station-by-station build order

Automate mature/cheap stations first to get the line running; attack the bottlenecks last
([process chain](../concepts/process-chain-and-station-map.md)):

1. **Design / CAD-CAM** — validated software; born-digital DHR.
2. **Forming** — Swiss (screws) / 5-axis (stems, heads, knees) / AM (porous) / forge / cast.
   The **machining core runs lights-out**: 5-axis + in-line CMM + wash, one robot, closed-loop.
3. **AM post-processing** (if additive) — depowder (watch trapped powder in lattices), support
   removal, **HIP** (mandatory for L-PBF), heat treat, finish-machine mating faces. Semi-auto;
   the bottleneck.
4. **Finishing** — **automate the polish**: DLyte dry electropolish (24 CoCr knees to
   Ra<0.05 µm/60 min), Rösler drag, OTEC stream, PushCorp/Acme force-control robots. This is the
   highest-payoff recent automation.
5. **Coating** — 6-axis robot HA plasma spray (>62% crystallinity); or print integral AM
   porosity instead.
6. **Clean** — multi-stage automated ultrasonic; verify to ISO 19227.
7. **Passivate / anodize** — F86/A967 passivation; Type II color anodize (AMS 2488).
8. **Inspect** — cobot-loaded CMM (unmanned), **industrial CT for AM internals**, optical GD&T,
   AI cosmetic vision with **two-tier human escalation**. Trend to **100% / c=0**.
9. **Mark** — UDI laser (fatigue-safe placement).
10. **Package** — HFFS / tray-seal to ISO 11607 sterile barrier.
11. **Sterilize** — gamma (implants), EtO (heat-sensitive), e-beam, or steam (usually
    outsourced).
12. **Release** — validated **human sign-off** on the DHR.

## Buy vs. build

**Buy the hard stations, integrate the cell** ([vendor landscape](vendor-landscape.md)):

- Machining: DMG MORI / Willemin / Tornos / Star / Citizen / Matsuura (+ their automation).
- Cell orchestration: **Flexxbotics** (closed-loop CMM→CNC) + Universal Robots / FANUC cobots.
- Finishing: **Acme** (>150 ortho installs) / AV&R / PushCorp; DLyte / Rösler / OTEC media.
- Metal AM: EOS / GE-Arcam (EBM) / AddUp / Renishaw / 3D Systems + AP&C powder handling.
- Metrology: Zeiss (CMM + CT) / VisionGauge.
- Or outsource the whole thing to a scaled CMO (**Tecomet/Orchid**, Paragon, Viant).

## Common failure modes to design against

From [Limitations & Bottlenecks](../concepts/limitations-and-bottlenecks.md):

- **Silent tool wear on titanium** mid-lights-out run → sister-tooling + tool monitoring + HPC
  coolant.
- **Trapped powder in AM lattices** → design for depowdering; verify with CT.
- **Ceramic finishing defect = crack initiator** → tight control on diamond-grind.
- **UHMWPE oxidation** → don't skip vitamin-E + inert sterilization.
- **Black-box AI reject decisions** → keep validated human escalation.
- **HMLV changeover** → don't automate a low-volume variant into unprofitability.
- **Validation drift** → every cell change can trigger revalidation; budget for it.

## Scale reality check

- **R&D / patient-specific:** single AM machine + manual post-processing; compete on lead time
  (7–10 days), not unit cost.
- **Mid-volume CMO (the sweet spot):** flexible robotic cells, cobot tending, automated
  finishing + metrology, single-piece flow, closed-loop lights-out.
- **High-runner:** dedicated Swiss lines (screws) + serial AM fleets (cups/cages — 20k+
  units/yr/machine).

## See also

- [The Process Chain & Station Map](../concepts/process-chain-and-station-map.md)
- [Forming Routes](../concepts/forming-routes-machining-am-forging-casting.md)
- [Materials & Route Selection](../concepts/materials-and-route-selection.md)
- [Finishing & Coating Automation](../concepts/finishing-and-coating-automation.md)
- [Metrology & Inspection Automation](../concepts/metrology-and-inspection-automation.md)
- [The Regulatory Envelope](../concepts/the-regulatory-envelope.md)
- [Economics & Line Architecture](../concepts/economics-and-line-architecture.md)
- [Limitations & Bottlenecks](../concepts/limitations-and-bottlenecks.md)
- [Vendor Landscape](vendor-landscape.md)
