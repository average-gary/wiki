---
title: "Inside a Modern BLDC Motor Factory (12-Station Map)"
source: https://greensky-power.com/inside-a-modern-bldc-motor-factory/
type: article
tags: [process-chain, station-map, automation-levels, cycle-time, small-bldc]
credibility: medium
confidence: high
retrieved: 2026-07-22
summary: Complete ordered 12-station chain with per-step automation ratings and an explicit "hardest to automate" ranking. Manufacturer-marketing-leaning but unusually detailed; small-motor focus (10W–3kW+).
---

# Inside a Modern BLDC Motor Factory (Greensky Power)

**Full 12-station chain, in order (with automation level):**
1. **Lamination** (full auto): 0.35 mm / 0.5 mm silicon steel, precision stamped + stacked, minimal air gaps.
2. **Slot insulation** (full auto): paper inserted via vision-guided robots at micron accuracy.
3. **Stator winding** (full auto — flagged hardest): multi-axis servo heads, closed-loop tension ±2%; complex patterns remain technically demanding.
4. **Terminal insertion + welding** (full auto): robotic placement then laser/resistance welding with immediate continuity test.
5. **Magnet prep + insertion** (full auto w/ vision): robots place NdFeB magnets into rotor laminations; vision checks polarity + position.
6. **Magnet bonding** (semi-auto): high-strength adhesive vs centrifugal load; cure controlled for temp/humidity/duration.
7. **Rotor balancing** (full auto): better than **G2.5**; residual unbalance <200 mg (std) / <50 mg (precision).
8. **Magnetization** (full auto): calibrated field magnetizes rotor — **magnetize-after-assembly**.
9. **Housing + bearing assembly** (full auto): robotic press, controlled force, torque monitoring.
10. **Stator–rotor integration** (full auto): precision air-gap alignment.
11. **PCB/controller integration** (full auto, integrated-electronics motors): place + solder boards.
12. **100% end-of-line test** (full auto): no-load, load (torque/efficiency map), hi-pot, thermal, NVH.

- **Explicit automation-difficulty ranking**: hardest = stator winding → then magnet insertion/bonding → then dynamic balancing. Easiest/most-automated = lamination stamping, testing, housing assembly.
- Modern lines: **30–35 s cycle time** per motor; claimed ~300% throughput vs traditional.
