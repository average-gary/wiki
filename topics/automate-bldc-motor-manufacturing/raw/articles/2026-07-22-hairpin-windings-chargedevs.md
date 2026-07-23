---
title: "A Closer Look at Hairpin Motor Windings"
source: https://chargedevs.com/features/a-closer-look-at-hairpin-motor-windings/
type: article
tags: [hairpin-winding, ev-traction, slot-fill, skin-effect, welding]
credibility: high
confidence: high
retrieved: 2026-07-22
summary: Independent engineering explainer connecting fill factor, skin-effect limits, and welding tradeoffs — the "why" behind hairpin adoption in EV traction motors.
---

# A Closer Look at Hairpin Motor Windings (Charged EVs)

- **Fill factor**: round-wire windings ~**55%** (insulation overhead); hairpins reach ~**70%** because a single rectangular conductor eliminates multiple insulation layers.
- **Why distributed only**: stout hairpins can't be bent into the tight-radius turns a concentrated winding needs, so hairpin motors *must* use distributed windings → sinusoidal back-EMF, smoother torque (at higher copper volume).
- **Skin-effect physics**: at 400 Hz fundamental (12,000 RPM, 4-pole) copper skin depth ≈ 3.3 mm → limits round wire to ~6.6 mm dia (137 A, ~95 kW 3-phase). Rectangular hairpins up to ~10 mm wide (66 mm² cross-section) nearly double ampacity while respecting skin effect.
- **Insulation stripping**: heat-dip, laser, chemical, or abrasive — each trades speed/cost/insulation-damage risk.
- **Joining (the hardest step)**: resistance welding (needs kiloamperes due to copper conductivity), TIG (proven, reliable, slower), laser (fast/flexible, high capex/opex).
- **Trend**: continuously formed (wave) hairpin windings preform whole coils on tapered mandrels — big assembly-time/cost advantage, "likely the way of the future."
