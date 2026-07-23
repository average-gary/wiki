---
title: Quality & End-of-Line Testing
type: concept
created: 2026-07-22
updated: 2026-07-22
tags: [eol-test, back-emf, surge-test, hipot, cogging, machine-vision, mes, traceability]
confidence: high
---

# Quality & End-of-Line Testing

Automated testing is what makes automated *building* worth it: a line that produces 200,000 motors a
year must catch defects **in-process**, not in the field. Testing is distributed across the chain, and
the finished motor gets a **100% end-of-line (EOL)** test.

## The distributed test strategy

Tests are placed to catch faults *before they get sealed in*
([Marposs](../raw/data/2026-07-22-marposs-eol-testing.md)):

- **Pre-impregnation stator**: winding resistance + inductance, parasitic capacitance, insulation
  condition — catch winding faults before varnish makes them permanent.
- **Post-impregnation stator**: insulation-state check validating the varnish.
- **In-process machine vision**: at the winding and magnet stations (below).
- **Full-motor EOL**: the final 100% gate.

## The EOL electrical test menu

A single automated EOL station typically runs, on every motor
([Marposs](../raw/data/2026-07-22-marposs-eol-testing.md)):

- **Insulation resistance (IR)** and **dielectric strength (hi-pot)** — gross insulation-to-ground.
- **Surge test** + **partial discharge (PD)** — turn-to-turn insulation (see below).
- **Back-EMF (BEMF)** — magnet / magnetization health.
- **No-load** (current, speed, vibration) and **load** (torque, efficiency map) tests.
- **Cogging & friction torque** (below).
- **NVH** (noise/vibration), friction + iron loss, temperature.

## Back-EMF: the magnetization checker

BEMF directly reveals rotor/magnet defects: "any damaged, partially demagnetised or missing magnet
reduces the BEMF from the expected value" ([Marposs](../raw/data/2026-07-22-marposs-eol-testing.md)).
Two production methods: **Standard** (an active brake spins the de-energized motor at constant speed,
sampling phase voltages) and **Dynamic** (inverter drives to speed, disconnects, samples during
coast-down). Analysis: RMS, peak-to-peak, **FFT**, THD, three-phase balance. This closes the loop on
the [magnetization station](magnet-handling-magnetization.md).

## Surge test: the only turn-to-turn detector

The most important winding-QC insight: **only a surge test finds weak turn-to-turn insulation** —
low-voltage DC IR and hi-pot cannot stress inter-turn insulation and give false passes
([Electrom / MDS / Schleich](../raw/data/2026-07-22-surge-testing-fundamentals.md)):

- Fast pulse (**~100 ns rise**, voltage per IEEE 522 — e.g. 460 V motor → **1920 V**, min 5 pulses)
  induces a turn-to-turn gradient; the **first turn sees the most voltage** (transmission-line
  effect), so faults concentrate at coil entry.
- A shorted turn drops inductance L, raising resonant frequency `f = 1/(2π√LC)` and shifting the
  waveform. **Pass/fail via Error Area Ratio (%EAR)**: compare the three phases pairwise; >10%
  deviation = fail. **ppEAR** ramps voltage in ~25 V steps to catch intermittent breakdown.
- **VFD relevance**: PWM drives create 2–3× line-voltage spikes → void-initiated PD, so surge + PD
  testing is essential for inverter-fed BLDC/PMSM.
- A **spatial probe** can localize the shorted turn ([Schleich](../raw/data/2026-07-22-surge-testing-fundamentals.md)).

This directly answers the [hairpin weld-defect](stator-winding-automation.md) and
[latent insulation-damage](limitations-and-gotchas.md) risks.

## Cogging & friction torque

Measured by back-driving the DUT at 0.5–20 rpm
([Vali Dynamics](../raw/data/2026-07-22-cogging-friction-torque-testing.md)): **cogging** (peak-to-peak,
magnet-tooth interaction) and **friction** (average, bearings/tolerances). Torque sensor 0.1% F.L.,
angle 0.01°, FFT output, automated pass/fail against preset limits.

## In-process machine vision

Vision runs at the assembly stations, not just EOL
([iFactory](../raw/articles/2026-07-22-ai-winding-vision-inspection-ifactory.md) — vendor claims,
treat performance numbers as illustrative):

- **Winding defects**: varnish cracks, exposed conductor, broken wires, bad solder joints, wrong
  conductor spacing.
- **Magnet placement**: position + polarity to sub-mm before rotor closeout; air-gap/concentricity.
- Philosophy: **catch defects in-process**, flag likely balance-test failures predictively.

## Traceability / MES tie-in

Test + vision data feed the **MES / digital thread**
([Bosch Nexeed](../raw/data/2026-07-22-bosch-nexeed-mes-industry40.md)): part genealogy, defined
quality gates, automatic **reject/hold** on a bad unit, SPC, supplier scorecards, and IATF 16949 /
audit-ready records. This is what turns per-station pass/fail into a traceable, improvable line — see
[Line Economics & Architecture](line-economics-and-architecture.md).

## See also

- [The Process Chain](process-chain.md)
- [Stator Winding Automation](stator-winding-automation.md) — what surge testing protects
- [Magnet Handling & Magnetization](magnet-handling-magnetization.md) — what BEMF verifies
- [Limitations & Gotchas](limitations-and-gotchas.md)
- [Vendor Landscape](../reference/vendor-landscape.md) — Schleich, Marposs
