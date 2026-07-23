---
title: Stator Winding Automation
type: concept
created: 2026-07-22
updated: 2026-07-22
tags: [stator-winding, needle-winding, flyer-winding, linear-winding, hairpin, slot-fill, segmented-stator]
confidence: high
---

# Stator Winding Automation

Winding is the **hardest and most value-dense** step to automate
([process chain](process-chain.md)). It is where copper meets geometry: the method you pick sets
your **slot fill factor** (how much copper you cram into the slot → torque density and efficiency),
your cycle time, and how automatable everything downstream is. Get this decision right and the rest
of the line follows.

## The four methods

| Method | How it works | Slot fill | Speed | Best for |
|--------|-------------|-----------|-------|----------|
| **Flyer** | Rotating arm orbits a stationary workpiece, "throws" wire into slots | **45–55%** | Fast (2,000–5,000 rpm) | Outer-rotor stators, armatures, power-tool/appliance mass market |
| **Needle** | Hollow nozzle moves XYZ + C-axis, wraps wire around each pole | **65–75%** (orthocyclic) | Slow (500–1,500 rpm) | Inner-rotor concentrated windings, high-performance BLDC |
| **Linear** | Winds individual segments / air coils; handles flat wire | High (segmented) | ≤1,000 rpm (~24 s/part) | Segmented stators, high turn counts, e-mobility |
| **Hairpin (bar)** | Insert preformed rectangular bars, twist, weld | **60–80%** | Sub-component takt (~2.3 s/pin) | EV traction / e-axle stators |

Sources: [needle vs flyer](../raw/articles/2026-07-22-needle-vs-flyer-winding-huaguan.md),
[Honest process](../raw/articles/2026-07-22-bldc-stator-winding-process-honest.md),
[Elmotec linear](../raw/data/2026-07-22-elmotec-statomat-linear-winders.md),
[Odawara hairpin](../raw/data/2026-07-22-odawara-hairpin-winding.md),
[Charged EVs](../raw/articles/2026-07-22-hairpin-windings-chargedevs.md).

**The fill-factor ladder is the through-line of the whole topic:** flyer (45–55%) < random round-wire
baseline (~55%) < needle/orthocyclic (65–75%) ≈ hairpin (60–80%). Mass-production motors realistically
land at **60–70%**; **80%+ needs advanced techniques** (compression winding, segmented stators)
([Windings.com](../raw/articles/2026-07-22-winding-automation-limits-manual-case.md)).

## Method follows topology follows machine

The electromagnetic designer's choice of **concentrated vs distributed** winding forces the machine
([concentrated vs distributed](../raw/articles/2026-07-22-concentrated-vs-distributed-winding.md)):

- **Concentrated** (one coil per tooth): trapezoidal back-EMF, less copper, **easy to automate** →
  needle winding or segmented-linear. Drones, robot joints, appliances.
- **Distributed** (coils span multiple slots): sinusoidal back-EMF, smoother torque, more copper,
  harder layout → flyer/insertion (older) or **hairpin** (modern EV). Stout hairpins physically
  *cannot* bend into concentrated tight-radius turns, so hairpin motors **must** be distributed.

## The segmented-stator unlock

Winding a single-piece inner-rotor stator is fill-limited because the needle can only reach so far
into a closed slot. **Winding individual teeth externally** (needle or linear), stripping and joining
them, then assembling into a ring, gets higher fill *and* easier automated termination
([Elmotec](../raw/data/2026-07-22-elmotec-statomat-linear-winders.md),
[Windings.com](../raw/articles/2026-07-22-winding-automation-limits-manual-case.md)). The cost:
inter-segment joining and more complex interpole handling
([Odawara needle-vs-segment](../raw/data/2026-07-22-odawara-hairpin-winding.md)).

## Hairpin: the EV-traction route in detail

Ordered sequence ([Odawara](../raw/data/2026-07-22-odawara-hairpin-winding.md)): core supply →
insulation paper (U/S/B shape) → **coil forming** of rectangular bars (up to 6.5×4.5 mm) → **enamel
strip** → simultaneous **insert** → **twist** (minimizes end-turn height) → **coil-end weld** →
bus-bar weld → test. Modern lines insert **6–8 layers in one operation**
([MNY](../raw/data/2026-07-22-line-capacity-modularity-schaeffler-mny.md)).

**Why hairpin wins:** a single rectangular conductor eliminates the multiple insulation layers of
round wire (→ ~70% fill), and it respects **skin-effect** limits — at 400 Hz the copper skin depth
(~3.3 mm) caps useful round-wire diameter, whereas a wide-thin bar carries nearly double the current
([Charged EVs](../raw/articles/2026-07-22-hairpin-windings-chargedevs.md)).

**Why hairpin is hard:** enamel stripping and welding. Mechanical stripping removes copper and leaves
fit-up gaps; residue causes **weld porosity** (hydrogen/carbon into the melt pool). A 60-slot, 4-layer
stator has **120+ weld joints** and any one cold/porous weld fails the whole motor
([Coherent](../raw/articles/2026-07-22-hairpin-weld-stripping-coherent.md),
[Patsnap](../raw/articles/2026-07-22-hairpin-defects-fill-factor.md)). See [Limitations](limitations-and-gotchas.md).

## Precision the automation must hold

Real machine tolerances ([Honest](../raw/articles/2026-07-22-bldc-stator-winding-process-honest.md)):
wire placement ±0.03 mm, tension fluctuation ±0.05 N, clamp positioning ±0.02 mm. QC gates: turn
count ±1, three-phase resistance imbalance ≤±2%, hi-pot at 2Uₙ+1000 V. Tension stability is the
Achilles' heel — it drifts with spool friction, feed angle, and speed, and fine wire crushes or loops
([Park Magazine](../raw/articles/2026-07-22-winding-automation-limits-manual-case.md)).

## See also

- [The Process Chain](process-chain.md)
- [Core & Assembly Automation](core-and-assembly-automation.md) — segmented-stator assembly, termination
- [Quality & EOL Testing](quality-and-eol-testing.md) — surge test catches winding faults
- [Limitations & Gotchas](limitations-and-gotchas.md)
- [Vendor Landscape](../reference/vendor-landscape.md) — who makes winding machines
