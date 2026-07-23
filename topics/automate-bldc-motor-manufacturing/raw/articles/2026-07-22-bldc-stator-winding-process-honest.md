---
title: "BLDC Motor Stator Coil Winding Process (Honest Automation)"
source: https://www.honest-hls.com/bldc-stator-winding-process
type: article
tags: [stator-winding, needle-winding, flyer-winding, inner-rotor, outer-rotor, concentrated, distributed]
credibility: medium
confidence: high
retrieved: 2026-07-22
summary: Maps winding-machine type to rotor topology to end application, with concrete rpm/gauge/tension/QC tolerance numbers. Found independently by two research agents.
---

# BLDC Stator Winding Process (Honest Automation)

- **External flyer winding = OUTER-rotor stators** (outward teeth): flyer rotates **2,000–5,000 rpm** guiding wire around teeth; RC motors, self-balancing scooters, household fan/appliance motors.
- **Internal needle winding = INNER-rotor stators** (inward slots): servo needle reciprocates vertically while tooling indexes horizontally; wire **0.1–1.5 mm** standard (up to **2.0 mm** heavy); winding speed **500–1,500 rpm** (confirms the speed/precision tradeoff vs flyer).
- **Topology → application**: concentrated (coil per tooth) → drones, robot-joint motors; distributed (span multiple slots) → high-speed blowers, servo spindles, EV traction.
- **Precision**: wire placement ±0.03 mm, tension fluctuation ±0.05 N, setup positioning ±0.02 mm.
- **Winding step sequence**: clamp stator (±0.02 mm) → parameter setup + first-article check → auto winding with interlayer insulation → lead securing + 3-phase connection → **VPI impregnation** → electrical test (DC resistance, inductance, insulation resistance).
- **QC gates**: turn count ±1 turn, three-phase resistance imbalance ≤±2%, hi-pot at **2Uₙ + 1000 V** (min 1000 V).
