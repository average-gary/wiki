---
title: Core & Assembly Automation
type: concept
created: 2026-07-22
updated: 2026-07-22
tags: [lamination-stacking, interlock, press-fit, shrink-fit, impregnation, robotics, servo-press]
confidence: high
---

# Core & Assembly Automation

Everything around winding and magnets — building the laminated cores, joining them, pressing the
rotor onto its shaft, dropping the stator into a housing, impregnating, adding bearings and
end-caps — is the **most mature and most automated** part of the line. This is where dedicated
special-purpose machines and force-controlled servo presses earn their keep.

## Lamination stacking: five ways to join steel

Cores are hundreds of thin (0.35 / 0.5 mm) silicon-steel laminations, stamped on high-speed
progressive dies and joined by one of five methods
([Lamnow](../raw/data/2026-07-22-lamination-stacking-methods.md)):

| Method | Automation | Loss impact | Note |
|--------|-----------|-------------|------|
| **Interlock (cleat/dimple)** | **Fully automated, in-die** — no secondary step | Adds local losses at dimples | Dimple geometry: square/circular = precision, V = misalignment-tolerant |
| **Bonding (backlack / self-bonding)** | In-mold dot gluing, heat cure | **Lowest loss, best NVH** | ~2 µm adhesive varnish, ~180°C; higher cost (Tesla Model 3 rotor) |
| **Welding (laser/TIG)** | Automated | Weld creates shorting paths → higher loss | High-silicon steel welds poorly, crack risk |
| **Riveting/bolting** | Semi-auto, secondary step | | For laser/wire-cut cores |
| **Cleating/clamping** | Semi-auto | | Steel strips into perimeter grooves |

**The automation layer that matters** ([Sinolami](../raw/data/2026-07-22-lamination-stacking-methods.md)):
**stacking pins** hold angular position, straightness, slot alignment, and skew; automated lines
verify sheet count + multi-point stack height + compression; **force-distance curves** detect burrs,
debris, wrong variants, and stack lean. Governing philosophy: **reject a bad stack before the
irreversible weld/bond step**, not after.

## Rotor build: press-fit and balancing

([Laserax](../raw/data/2026-07-22-laserax-rotor-manufacturing.md),
[Honest rotor line](../raw/data/2026-07-22-shrink-fit-and-rotor-line-stations.md)):

- **Shaft press-fit**: shaft laser-cleaned + laser-marked, rotor core pre-heated, shaft pneumatically
  pressed for an **interference fit**.
- **Balancing** (fully automated, hard-tolerance): rotors spin 10,000+ RPM; accelerometers +
  tachymeters + scales iterate mass-correction until vibration spec (better than **G2.5**, residual
  unbalance <200 mg standard / <50 mg precision) is met.
- A representative automated rotor line: core load → shaft press-fit → magnet assembly → sleeve +
  end-cap → laser weld → magnetize + flux check → air-tightness test, at **15 s/pc, ≥98% yield**,
  with independent stations (a failed station is skipped to keep the line moving).

## Stator into housing: induction shrink-fit

The classic thermal-interference join ([Induction-Heat](../raw/data/2026-07-22-shrink-fit-and-rotor-line-stations.md)):
**induction-heat the housing** so it expands, drop the stator in, let it shrink onto the stack.
Closed-loop PID with IR thermometers (±1%, 0.1 s resolution) is required because the **thermal window
before the housing re-shrinks is short**. Output 10–50 kHz, 4–60 kVA; an automatic press removes
insertion-force variability. Parameters logged for traceability; line integration via Profibus/CAN.

## Impregnation / varnish

Fills air gaps (thermal conductivity), bonds turns against vibration, seals against moisture, adds
dielectric strength ([Lamnow](../raw/data/2026-07-22-impregnation-varnish-methods.md)):

- **Trickle / drip** — preheat 100–115°C, rotate, drip resin; **fast, cheap, low-resin → the BLDC
  default**.
- **Dip / immersion** — small/medium BLDC, EV, PMSM.
- **VPI (vacuum pressure impregnation)** — vacuum then 200–700 kPa; **most thorough**, eliminates air
  pockets; high-voltage/critical and EV traction stators.
- Trade-off ladder: trickle (fast/cheap) → dip → VPI (best quality, slowest, most capital-intensive).

## Robots vs. dedicated machines

The synthesis across sources: **high-volume lines lean on dedicated special-purpose machines** —
servo-press stations, induction shrink-fit rigs, indexed stacking dies — for the force/thermal/
precision steps, while **6-axis robots / SCARA / cobots** handle flexible pick-and-place, inter-station
transfer, and lower-volume or mixed-variant builds. Schaeffler explicitly spans "manual workstations
to fully automated high-speed machines" and uses **cobot HRC with force feedback** for gear joining
([Schaeffler](../raw/data/2026-07-22-line-capacity-modularity-schaeffler-mny.md)). Machine vision and
force-controlled presses are the quality backbone across both. Bearing insertion, end-cap assembly,
and Hall-sensor/encoder placement appear as discrete stations but are lightly documented publicly —
see [Limitations](limitations-and-gotchas.md) and the open [gaps](#see-also).

## See also

- [The Process Chain](process-chain.md)
- [Stator Winding Automation](stator-winding-automation.md)
- [Magnet Handling & Magnetization](magnet-handling-magnetization.md)
- [Line Economics & Architecture](line-economics-and-architecture.md)
- [Vendor Landscape](../reference/vendor-landscape.md) — lamination presses, integrators
